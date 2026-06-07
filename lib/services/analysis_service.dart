import 'dart:io';
import 'dart:ui';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:camera/camera.dart';
import 'package:image/image.dart' as img;
import 'package:ultralytics_yolo/ultralytics_yolo.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:greenmalaysia/services/settings_service.dart';

class AnalysisService {
  // --- Available Models (v2) ---
  static const Map<String, String> availableModels = {
    'mta-v2-yolov11n-low.tflite': 'YOLOv11n Low (3.1MB)',
    'mta-v2-yolov11n-high.tflite': 'YOLOv11n High (11.1MB)',
    'mta-v2-yolov11s-low.tflite': 'YOLOv11s Low (10.1MB)',
    'mta-v2-yolov11s-high.tflite': 'YOLOv11s High (38.7MB)',
  };

  final ImagePicker _picker = ImagePicker();
  YOLO? _yoloModel;
  bool _isModelLoaded = false;
  String _currentModelFile = '';
  String _localModelPath = '';
  bool _isGpuFallback = false;

  // Device info
  String _cpuModel = 'Unknown';
  int _cpuCores = 0;
  String _deviceModel = 'Unknown';
  bool _deviceInfoLoaded = false;

  // Performance metrics
  int _lastInferenceMs = 0;
  int _lastPrepMs = 0;
  String _activeBackend = 'CPU (XNNPACK)';
  int _threadCount = 0;

  // --- Public Getters ---
  bool get isLoaded => _isModelLoaded;
  String get modelName => _currentModelFile;
  String get localModelPath => _localModelPath;
  String get cpuModel => _cpuModel;
  int get cpuCores => _cpuCores;
  String get deviceModel => _deviceModel;
  String get activeBackend => _activeBackend;
  int get lastInferenceMs => _lastInferenceMs;
  int get lastPrepMs => _lastPrepMs;
  int get threadCount => _threadCount;

  // --- 1. Copy Asset Helper ---
  Future<String> _copyAssetToLocal(String assetPath) async {
    final String filename = assetPath.split('/').last;
    final directory = await getApplicationDocumentsDirectory();
    final String filePath = '${directory.path}/$filename';
    final File file = File(filePath);

    if (!await file.exists()) {
      final ByteData data = await rootBundle.load(assetPath);
      final List<int> bytes = data.buffer.asUint8List();
      await file.writeAsBytes(bytes);
    }
    return filePath;
  }

  // --- 2. Load Device Info ---
  Future<void> _loadDeviceInfo() async {
    if (_deviceInfoLoaded) return;
    try {
      if (Platform.isAndroid) {
        final androidInfo = await DeviceInfoPlugin().androidInfo;
        _deviceModel = '${androidInfo.manufacturer} ${androidInfo.model}';
        _cpuModel = androidInfo.hardware;

        // Use supported ABIs to infer architecture, cores from Platform
        _cpuCores = Platform.numberOfProcessors;
        debugPrint("📱 Device: $_deviceModel | CPU: $_cpuModel | Cores: $_cpuCores");
      } else {
        _cpuCores = Platform.numberOfProcessors;
        _cpuModel = 'Unknown';
        _deviceModel = 'Unknown';
      }
      _deviceInfoLoaded = true;
    } catch (e) {
      debugPrint("⚠️ Failed to load device info: $e");
      _cpuCores = Platform.numberOfProcessors;
    }
  }

  // --- 3. Smart Model Selection ---
  /// Picks the best model based on CPU core count.
  /// High-end (8+ cores) → yolov11s (better accuracy)
  /// Mid-range (4-7 cores) → yolov11n (balanced)
  /// Low-end (<4 cores) → yolov11n-low (fastest)
  String _selectBestModel({required bool useHighAccuracy}) {
    final settings = SettingsService();

    // If user forced a specific model, use it
    if (settings.forcedModel != 'auto') {
      return settings.forcedModel;
    }

    // Auto-select based on CPU cores
    if (_cpuCores >= 8) {
      // Flagship: use small model
      return useHighAccuracy
          ? 'mta-v2-yolov11s-high.tflite'
          : 'mta-v2-yolov11s-low.tflite';
    } else if (_cpuCores >= 4) {
      // Mid-range: use nano model
      return useHighAccuracy
          ? 'mta-v2-yolov11n-high.tflite'
          : 'mta-v2-yolov11n-low.tflite';
    } else {
      // Low-end: always use lightest
      return 'mta-v2-yolov11n-low.tflite';
    }
  }

  // --- 4. Determine Thread Count ---
  int _determineThreadCount() {
    final settings = SettingsService();
    if (settings.aiThreadCount > 0) {
      return settings.aiThreadCount;
    }
    // Auto: use half of available cores, clamped 2-4
    return (_cpuCores ~/ 2).clamp(2, 4);
  }

  // --- 5. Load Model ---
  Future<void> loadModel({bool useHighAccuracy = false, String? modelPathOverride}) async {
    // Load device info first
    await _loadDeviceInfo();

    final String selectedModel = modelPathOverride ?? _selectBestModel(useHighAccuracy: useHighAccuracy);
    final String assetPath = 'assets/models/$selectedModel';

    // Skip reload if same model
    if (_isModelLoaded && _currentModelFile == selectedModel) return;
    if (_isModelLoaded) await dispose();

    try {
      final String localPath = await _copyAssetToLocal(assetPath);
      debugPrint("🔄 Loading model: $selectedModel from: $localPath");

      final settings = SettingsService();
      final bool useGpu = settings.forceGpu;
      _activeBackend = useGpu ? 'GPU (OpenCL)' : 'CPU (XNNPACK)';
      if (!useGpu) _isGpuFallback = false; // Reset fallback state if explicitly off
      _threadCount = _determineThreadCount();

      debugPrint("⚙️ Backend: $_activeBackend | Threads: $_threadCount");

      _yoloModel = YOLO(
        modelPath: localPath,
        task: YOLOTask.segment,
        useGpu: useGpu,
      );

      bool success = await _yoloModel!.loadModel();

      if (success) {
        _isModelLoaded = true;
        _currentModelFile = selectedModel;
        _localModelPath = localPath;
        debugPrint("✅ Model Loaded: $selectedModel ($_activeBackend, ${_threadCount}T)");
      } else {
        debugPrint("❌ Failed to load model: $selectedModel");
        _isModelLoaded = false;
      }
    } catch (e) {
      debugPrint("❌ CRITICAL: Failed to initialize model: $e");
      _isModelLoaded = false;
    }
  }

  // --- 6. Prediction on Image File ---
  Future<List<Map<String, dynamic>>> detectOnImage(File imageFile) async {
    if (!_isModelLoaded || _yoloModel == null) return [];
    try {
      final Uint8List imageBytes = await imageFile.readAsBytes();
      final stopwatch = Stopwatch()..start();
      final result = await _predictBytes(imageBytes);
      stopwatch.stop();
      _lastInferenceMs = stopwatch.elapsedMilliseconds;
      _lastPrepMs = 0;
      return result;
    } catch (e) {
      debugPrint("⚠️ Prediction error: $e");
      
      // Automatic GPU Fallback
      if (_activeBackend.contains('GPU') && !_isGpuFallback) {
        debugPrint("🔄 GPU Inference failed. Falling back to CPU (XNNPACK)...");
        _isGpuFallback = true;
        
        // Turn off GPU setting
        SettingsService().updateForceGpu(false);
        
        // Reload model on CPU
        await loadModel();
        
        // Retry prediction
        try {
          final Uint8List imageBytes = await imageFile.readAsBytes();
          final stopwatch = Stopwatch()..start();
          final result = await _predictBytes(imageBytes);
          stopwatch.stop();
          _lastInferenceMs = stopwatch.elapsedMilliseconds;
          _lastPrepMs = 0;
          return result;
        } catch (retryError) {
          debugPrint("⚠️ Prediction error after fallback: $retryError");
          return [];
        }
      }
      
      return [];
    }
  }

  // --- 7. Prediction on Camera Frame ---
  Future<List<Map<String, dynamic>>> detectOnFrame(
    CameraImage image, {
    double? confThreshold,
    double? iouThreshold,
  }) async {
    if (!_isModelLoaded || _yoloModel == null) return [];

    final stopwatch = Stopwatch()..start();

    Uint8List jpegBytes;
    if (image.format.group == ImageFormatGroup.jpeg) {
      jpegBytes = image.planes[0].bytes;
    } else {
      // 1. Convert YUV420 CameraImage to JPEG in an isolate to prevent UI freezing
      final Uint8List? converted = await compute(convertYUV420ToJpeg, image);
      if (converted == null) return [];
      jpegBytes = converted;
    }
    _lastPrepMs = stopwatch.elapsedMilliseconds;

    // 2. Perform Inference
    stopwatch.reset();
    final results = await _predictBytes(
      jpegBytes,
      confThreshold: confThreshold,
      iouThreshold: iouThreshold,
    );
    _lastInferenceMs = stopwatch.elapsedMilliseconds;
    stopwatch.stop();

    return results;
  }

  // Helper function to map YOLOView results, keeping it around just in case
  List<Map<String, dynamic>> convertYoloResults(List<YOLOResult> results, double imageWidth, double imageHeight) {
    return results.map((res) {
      // YOLOView returns normalizedBox (0.0 to 1.0)
      List<double> boxData = [
        res.normalizedBox.left,
        res.normalizedBox.top,
        res.normalizedBox.right,
        res.normalizedBox.bottom,
      ];

      return {
        "tag": res.className,
        "confidence": res.confidence,
        "box": boxData,
        "polygons": res.mask,
        "alternatives": <Map<String, dynamic>>[],
      };
    }).toList();
  }

// --- Top-Level Conversion Function for Isolate ---
Uint8List? convertYUV420ToJpeg(CameraImage image) {
  try {
    // Optimization 1: Skip pixels (downsample by 2) to reduce workload by 4x
    final int inWidth = image.width;
    final int inHeight = image.height;
    final int outWidth = inWidth >> 1;
    final int outHeight = inHeight >> 1;
    
    final int uvRowStride = image.planes[1].bytesPerRow;
    final int uvPixelStride = image.planes[1].bytesPerPixel ?? 1;

    final img.Image outImg = img.Image(width: outWidth, height: outHeight);

    for (int y = 0; y < outHeight; y++) {
      int origY = y << 1;
      int pY = origY * image.planes[0].bytesPerRow;
      int pUV = (origY >> 1) * uvRowStride;

      for (int x = 0; x < outWidth; x++) {
        int origX = x << 1;
        int uvOffset = pUV + (origX >> 1) * uvPixelStride;

        final yp = image.planes[0].bytes[pY + origX];
        // Optimization 2: Fast integer math for YUV to RGB
        final int up = image.planes[1].bytes[uvOffset] - 128;
        final int vp = image.planes[2].bytes[uvOffset] - 128;

        int r = (yp + ((359 * vp) >> 8)).clamp(0, 255);
        int g = (yp - ((88 * up + 183 * vp) >> 8)).clamp(0, 255);
        int b = (yp + ((454 * up) >> 8)).clamp(0, 255);

        outImg.setPixelRgb(x, y, r, g, b);
      }
    }

    // Optimization 3: Fast encode with low quality
    return Uint8List.fromList(img.encodeJpg(outImg, quality: 50));
  } catch (e) {
    debugPrint("Image conversion error: $e");
    return null;
  }
}
  // --- 8. Internal Prediction ---
  Future<List<Map<String, dynamic>>> _predictBytes(Uint8List bytes, {double? confThreshold, double? iouThreshold}) async {
    if (_yoloModel == null) return [];

    final results = await _yoloModel!.predict(
      bytes,
      confidenceThreshold: confThreshold ?? 0.35,
      iouThreshold: iouThreshold ?? 0.45,
    );

    if (results['boxes'] == null) return [];

    final List<dynamic> boxes = results['boxes'] as List<dynamic>;

    return boxes.map<Map<String, dynamic>>((box) {
      // 1. Tag
      String tag = box['class']?.toString() ?? "Unknown";

      // 2. Confidence
      final double confidence = box['confidence'] ?? 0.0;

      // 3. Bounding Box [x1, y1, x2, y2]
      List<double> boxData = [0.0, 0.0, 0.0, 0.0];

      if (box.containsKey('x1') && box.containsKey('y1')) {
        boxData = [
          (box['x1'] as num).toDouble(),
          (box['y1'] as num).toDouble(),
          (box['x2'] as num).toDouble(),
          (box['y2'] as num).toDouble(),
        ];
      } else if (box['box'] != null) {
        final b = box['box'];
        if (b is List) {
          boxData = b.map((e) => (e as num).toDouble()).toList().cast<double>();
        }
      }

      // 4. Segmentation Mask/Polygons
      List<dynamic>? polygons;

      if (box.containsKey('polygons')) {
        polygons = box['polygons'];
      } else if (box.containsKey('mask')) {
        polygons = box['mask'] as List<dynamic>?;
      }

      return {
        'tag': tag,
        'confidence': confidence,
        'box': boxData,
        'polygons': polygons,
      };
    }).toList();
  }

  // --- 9. Gallery Picker ---
  Future<File?> pickImageFromGallery() async {
    try {
      final XFile? file = await _picker.pickImage(source: ImageSource.gallery);
      if (file != null) return File(file.path);
    } catch (e) {
      debugPrint("⚠️ Gallery error: $e");
    }
    return null;
  }

  // --- 10. Dispose ---
  Future<void> dispose() async {
    if (_yoloModel != null) {
      await _yoloModel!.dispose();
      _yoloModel = null;
    }
    _isModelLoaded = false;
    _currentModelFile = '';
  }
}
