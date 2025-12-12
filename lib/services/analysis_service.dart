import 'dart:io';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:camera/camera.dart';
import 'package:ultralytics_yolo/ultralytics_yolo.dart';

class AnalysisService {
  static const String _modelPathLow = 'assets/models/mta-v1a-low.tflite';
  static const String _modelPathHigh = 'assets/models/mta-v1a-high.tflite';

  final ImagePicker _picker = ImagePicker();
  YOLO? _yoloModel;
  bool _isModelLoaded = false;
  bool _usingHighAccuracy = false;

  bool get isLoaded => _isModelLoaded;

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

  // --- 2. Load Model ---
  Future<void> loadModel({bool useHighAccuracy = false}) async {
    if (_isModelLoaded && _usingHighAccuracy == useHighAccuracy) return;
    if (_isModelLoaded) await dispose();

    try {
      final String assetPath = useHighAccuracy ? _modelPathHigh : _modelPathLow;
      final String localPath = await _copyAssetToLocal(assetPath);

      debugPrint("🔄 Loading model from: $localPath");

      _yoloModel = YOLO(
        modelPath: localPath,
        task: YOLOTask.segment, // Segmentation Task
        useGpu: true,
      );

      bool success = await _yoloModel!.loadModel();

      if (success) {
        _isModelLoaded = true;
        _usingHighAccuracy = useHighAccuracy;
        debugPrint("✅ Model Loaded Successfully");
      } else {
        debugPrint("❌ Failed to load model");
      }
    } catch (e) {
      debugPrint("❌ CRITICAL: Failed to initialize model: $e");
      _isModelLoaded = false;
    }
  }

  // --- 3. Prediction Logic (Updated to match Official Sample) ---
  Future<List<Map<String, dynamic>>> detectOnImage(File imageFile) async {
    if (!_isModelLoaded || _yoloModel == null) return [];
    try {
      final Uint8List imageBytes = await imageFile.readAsBytes();
      return _predictBytes(imageBytes);
    } catch (e) {
      debugPrint("⚠️ Prediction error: $e");
      return [];
    }
  }

  // Placeholder for live frame detection
  Future<List<Map<String, dynamic>>> detectOnFrame(
    CameraImage image, {
    double? confThreshold,
    double? iouThreshold,
  }) async {
    return [];
  }

  Future<List<Map<String, dynamic>>> _predictBytes(Uint8List bytes) async {
    if (_yoloModel == null) return [];

    // Run Prediction
    final results = await _yoloModel!.predict(
      bytes,
      confidenceThreshold: 0.35,
      iouThreshold: 0.45,
    );

    // ✅ FIX: Use 'boxes' as per official sample
    if (results['boxes'] == null) return [];

    final List<dynamic> boxes = results['boxes'] as List<dynamic>;

    return boxes.map<Map<String, dynamic>>((box) {
      // 1. Tag
      String tag = box['class']?.toString() ?? "Unknown";

      // 2. Confidence
      final double confidence = box['confidence'] ?? 0.0;

      // 3. Bounding Box [x1, y1, x2, y2]
      // The sample usually puts coordinates directly in the object or in a 'box' key depending on version.
      // We check both for safety.
      List<double> boxData = [0.0, 0.0, 0.0, 0.0];

      if (box.containsKey('x1') && box.containsKey('y1')) {
        // Flat structure (common in some versions)
        boxData = [
          (box['x1'] as num).toDouble(),
          (box['y1'] as num).toDouble(),
          (box['x2'] as num).toDouble(),
          (box['y2'] as num).toDouble(),
        ];
      } else if (box['box'] != null) {
        // Nested structure
        final b = box['box'];
        if (b is List) {
          boxData = b.map((e) => (e as num).toDouble()).toList().cast<double>();
        }
      }

      // 4. Segmentation Mask/Polygons
      // The sample says: box.containsKey('mask')
      // Note: 'polygons' is often a processed version of 'mask'. We check both.
      List<dynamic>? polygons;

      if (box.containsKey('polygons')) {
        polygons = box['polygons'];
      } else if (box.containsKey('mask')) {
        // If it's a raw bitmap mask, we pass it.
        // If the plugin converts it to points, it might be here.
        // For now, we assume the UI Painter handles what comes out.
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

  Future<File?> pickImageFromGallery() async {
    try {
      final XFile? file = await _picker.pickImage(source: ImageSource.gallery);
      if (file != null) return File(file.path);
    } catch (e) {
      debugPrint("⚠️ Gallery error: $e");
    }
    return null;
  }

  Future<void> dispose() async {
    if (_yoloModel != null) {
      await _yoloModel!.dispose();
      _yoloModel = null;
    }
    _isModelLoaded = false;
  }
}
