import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:greenmalaysia/services/analysis_service.dart'; // Import Service

class AnalysisPage extends StatefulWidget {
  const AnalysisPage({super.key});

  @override
  State<AnalysisPage> createState() => _AnalysisPageState();
}

class _AnalysisPageState extends State<AnalysisPage> {
  // Logic
  final AnalysisService _aiService = AnalysisService();
  late CameraController _cameraController;

  // State
  bool _isLoaded = false;
  bool _isDetecting = false;
  bool _isLiveMode = false; // Toggle between Live and Manual
  File? _staticImage; // For gallery or captured photo

  // Results
  List<Map<String, dynamic>> _detections = [];

  // Dimensions for Scaling
  double _sourceWidth = 1;
  double _sourceHeight = 1;

  @override
  void initState() {
    super.initState();
    _initializeSetup();
  }

  Future<void> _initializeSetup() async {
    // 1. Load AI
    await _aiService.loadModel();

    // 2. Load Camera
    final cameras = await availableCameras();
    _cameraController = CameraController(
      cameras[0],
      ResolutionPreset.low, // Keep low for speed on old phones
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.yuv420,
    );

    await _cameraController.initialize();

    // Set initial source dims to camera preview size
    _sourceWidth =
        _cameraController.value.previewSize!.height; // Android swaps W/H
    _sourceHeight = _cameraController.value.previewSize!.width;

    setState(() => _isLoaded = true);
  }

  // --- ACTIONS ---

  void _toggleLiveMode() {
    if (_isLiveMode) {
      // Stop Live Mode
      _cameraController.stopImageStream();
      setState(() {
        _isLiveMode = false;
        _detections = [];
      });
    } else {
      // Start Live Mode
      setState(() {
        _isLiveMode = true;
        _staticImage = null; // Clear static image
      });
      _startLiveStream();
    }
  }

  Future<void> _startLiveStream() async {
    if (!_cameraController.value.isInitialized) return;

    _cameraController.startImageStream((image) async {
      if (_isDetecting) return;
      _isDetecting = true;

      try {
        final results = await _aiService.detectOnFrame(image);
        if (mounted) {
          setState(() {
            _detections = results;
            // Update source dims just in case
            _sourceWidth = image.height.toDouble();
            _sourceHeight = image.width.toDouble();
          });
        }
      } finally {
        _isDetecting = false;
      }
    });
  }

  Future<void> _pickFromGallery() async {
    // Stop live mode if running
    if (_isLiveMode) _toggleLiveMode();

    File? file = await _aiService.pickImageFromGallery();
    if (file != null) {
      _analyzeStaticImage(file);
    }
  }

  Future<void> _takePhoto() async {
    if (_isLiveMode) {
      // If live, just freeze the current frame logic (or stop stream)
      _toggleLiveMode();
      return;
    }

    // Take actual photo
    try {
      final XFile photo = await _cameraController.takePicture();
      _analyzeStaticImage(File(photo.path));
    } catch (e) {
      print("Error taking photo: $e");
    }
  }

  Future<void> _analyzeStaticImage(File file) async {
    setState(() {
      _staticImage = file;
      _detections = []; // Clear old boxes while loading
    });

    // We need to know image dimensions to scale boxes correctly
    var decodedImage = await decodeImageFromList(await file.readAsBytes());

    final results = await _aiService.detectOnImage(file);

    setState(() {
      _detections = results;
      _sourceWidth = decodedImage.width.toDouble();
      _sourceHeight = decodedImage.height.toDouble();
    });
  }

  @override
  void dispose() {
    if (_isLoaded && _cameraController.value.isStreamingImages) {
      _cameraController.stopImageStream();
    }
    _cameraController.dispose();
    _aiService.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isLoaded)
      return const Scaffold(body: Center(child: CircularProgressIndicator()));

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 1. THE VIEW (Camera or Image)
          Positioned.fill(
            child: _staticImage != null
                ? Image.file(_staticImage!, fit: BoxFit.contain)
                : CameraPreview(_cameraController),
          ),

          // 2. BOUNDING BOXES (Scaled)
          Positioned.fill(
            child: LayoutBuilder(
              builder: (context, constraints) {
                // Calculate Scale
                double scaleX = constraints.maxWidth / _sourceWidth;
                double scaleY = constraints.maxHeight / _sourceHeight;

                // Adjust for BoxFit.contain if using static image
                if (_staticImage != null) {
                  // More complex math needed here for perfect Image.file fitting,
                  // but for MVP usually fitWidth or fitHeight dominates.
                  // For now, we assume full screen preview for simplicity.
                }

                return Stack(
                  children: _detections.map((det) {
                    final box = det["box"];
                    return Positioned(
                      left: box[0] * scaleX,
                      top: box[1] * scaleY,
                      width: (box[2] - box[0]) * scaleX,
                      height: (box[3] - box[1]) * scaleY,
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.green, width: 3),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          "${det['tag']} ${(det['box'][4] * 100).toStringAsFixed(0)}%",
                          style: const TextStyle(
                            backgroundColor: Colors.green,
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ),

          // 3. TOP BAR (Back Button)
          Positioned(
            top: 40,
            left: 20,
            child: CircleAvatar(
              backgroundColor: Colors.black54,
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),

          // 4. BOTTOM CONTROL BAR
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              color: Colors.black.withOpacity(0.6),
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 30),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // LEFT: Gallery
                  IconButton(
                    icon: const Icon(
                      Icons.photo_library,
                      color: Colors.white,
                      size: 30,
                    ),
                    onPressed: _pickFromGallery,
                    tooltip: "Gallery",
                  ),

                  // CENTER: Take Photo / Trigger
                  GestureDetector(
                    onTap: _takePhoto,
                    child: Container(
                      height: 70,
                      width: 70,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 4),
                        color: _isLiveMode
                            ? Colors.red
                            : Colors
                                  .white, // Red if Live (Stop), White if Photo
                      ),
                      child: _isLiveMode
                          ? const Icon(
                              Icons.stop,
                              color: Colors.white,
                              size: 30,
                            )
                          : null,
                    ),
                  ),

                  // RIGHT: Live Mode Toggle
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Switch(
                        value: _isLiveMode,
                        activeColor: Colors.green,
                        onChanged: (val) => _toggleLiveMode(),
                      ),
                      const Text(
                        "Live AI",
                        style: TextStyle(color: Colors.white, fontSize: 10),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
