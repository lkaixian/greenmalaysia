import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter_vision/flutter_vision.dart'; // The magic package
import 'package:greenmalaysia/services/settings_service.dart';

class AnalysisPage extends StatefulWidget {
  const AnalysisPage({super.key});

  @override
  State<AnalysisPage> createState() => _AnalysisPageState();
}

class _AnalysisPageState extends State<AnalysisPage> {
  // --- VARIABLES ---
  late CameraController _controller;
  late FlutterVision _vision; // The AI Controller
  late List<CameraDescription> _cameras;
  
  bool _isLoaded = false;
  bool _isDetecting = false; // Prevents spamming the AI
  List<Map<String, dynamic>> _detections = []; // Store results here

  @override
  void initState() {
    super.initState();
    _initAI();
  }

  // 1. Initialize Camera & AI Model
  Future<void> _initAI() async {
    _cameras = await availableCameras();
    _vision = FlutterVision();

    // Load the TFLite Model
    await _vision.loadYoloModel(
      labels: 'assets/models/labels.txt', 
      modelPath: 'assets/models/yolov8n.tflite',
      modelVersion: "yolov8",
      quantization: true, // TRUE because we use Int8 model for Snapdragon 660
      numThreads: 2, // 2-4 threads is safe for older phones
      useGpu: false, // Keep false for broad compatibility on old Androids
    );

    // Initialize Camera
    _controller = CameraController(
      _cameras[0], // Back Camera
      ResolutionPreset.low, // 320p or 480p is enough for AI and FAST
      enableAudio: false,
    );

    await _controller.initialize();
    setState(() => _isLoaded = true);

    // If "Live Mode" is enabled in settings, start scanning immediately
    final settings = SettingsService();
    if (settings.isAiLiveMode) {
      _startScanning();
    }
  }

  // 2. The Loop: Send Frames to AI
  Future<void> _startScanning() async {
    if (!_controller.value.isInitialized) return;

    await _controller.startImageStream((CameraImage image) async {
      if (_isDetecting) return; // If busy processing previous frame, skip this one

      _isDetecting = true;

      try {
        // Run Inference
        final stopwatch = Stopwatch()..start();
        
        final results = await _vision.yoloOnFrame(
          bytesList: image.planes.map((plane) => plane.bytes).toList(),
          imageHeight: image.height,
          imageWidth: image.width,
          iouThreshold: 0.4, // Overlap threshold
          confThreshold: 0.4, // Confidence threshold (40% sure)
          classThreshold: 0.5,
        );

        // Update UI with Bounding Boxes
        if (mounted) {
          setState(() {
            _detections = results;
          });
        }
        
        // print("Inference took: ${stopwatch.elapsedMilliseconds}ms");

      } catch (e) {
        print("AI Error: $e");
      } finally {
        _isDetecting = false;
      }
    });
  }

  Future<void> _stopScanning() async {
    await _controller.stopImageStream();
    setState(() => _detections = []);
  }

  @override
  void dispose() {
    _controller.dispose();
    _vision.closeYoloModel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isLoaded) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      body: Stack(
        children: [
          // A. The Camera View
          CameraPreview(_controller),

          // B. The Bounding Boxes Overlay
          ..._detections.map((detection) {
            final box = detection["box"]; // [x1, y1, x2, y2, class_conf]
            // Note: You need logic to map coordinates from Camera Resolution to Screen Size.
            // For MVP, we simply draw them (positioning might need math adjustment).
            
            return Positioned(
              left: box[0] * 1.0,
              top: box[1] * 1.0,
              width: (box[2] - box[0]) * 1.0,
              height: (box[3] - box[1]) * 1.0,
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.green, width: 3),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  "${detection['tag']} ${(detection['box'][4] * 100).toStringAsFixed(0)}%",
                  style: const TextStyle(
                    backgroundColor: Colors.green, 
                    color: Colors.white,
                    fontSize: 12,
                  ),
                ),
              ),
            );
          }).toList(),

          // C. Control Buttons
          Positioned(
            bottom: 30,
            left: 0, 
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FloatingActionButton(
                  onPressed: () {
                    // Manual Trigger logic (Capture Photo -> Analyze)
                    // This is for "Non-Live Mode"
                  },
                  child: const Icon(Icons.camera),
                ),
                const SizedBox(width: 20),
                // Toggle Live Mode
                FloatingActionButton.small(
                  backgroundColor: Colors.grey,
                  onPressed: () {
                     if (_controller.value.isStreamingImages) {
                       _stopScanning();
                     } else {
                       _startScanning();
                     }
                  },
                  child: Icon(_controller.value.isStreamingImages ? Icons.stop : Icons.play_arrow),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}