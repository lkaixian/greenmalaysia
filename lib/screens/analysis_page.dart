import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:greenmalaysia/services/analysis_service.dart'; // Adjust path if needed

class AnalysisPage extends StatefulWidget {
  const AnalysisPage({super.key});

  @override
  State<AnalysisPage> createState() => _AnalysisPageState();
}

class _AnalysisPageState extends State<AnalysisPage> {
  // --- DEPENDENCIES ---
  final AnalysisService _aiService = AnalysisService();
  late CameraController _cameraController;

  // --- STATE ---
  bool _isLoaded = false;
  bool _isDetecting = false;
  bool _isLiveMode = false;
  bool _useHighAccuracy = false; // New State Variable

  File? _staticImage;
  List<Map<String, dynamic>> _detections = [];

  double _imageWidth = 1;
  double _imageHeight = 1;

  @override
  void initState() {
    super.initState();
    _initializeSetup();
  }

  @override
  void dispose() {
    if (_isLoaded) {
      _cameraController.dispose();
    }
    _aiService.dispose(); // Changed close() to dispose() to match service
    super.dispose();
  }

  Future<void> _initializeSetup() async {
    // 1. Load Model (Default to Low Accuracy)
    await _aiService.loadModel(useHighAccuracy: _useHighAccuracy);

    // 2. Setup Camera
    final cameras = await availableCameras();
    _cameraController = CameraController(
      cameras[0],
      ResolutionPreset.medium,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.yuv420,
    );

    await _cameraController.initialize();

    if (mounted) {
      setState(() {
        _isLoaded = true;
        _imageWidth = _cameraController.value.previewSize!.height;
        _imageHeight = _cameraController.value.previewSize!.width;
      });
    }
  }

  // --- NEW: TOGGLE ACCURACY ---
  Future<void> _toggleAccuracy() async {
    // Pause live stream if active to prevent crash during model switch
    if (_isLiveMode) {
      await _cameraController.stopImageStream();
    }

    setState(() {
      _isLoaded = false; // Show loading spinner
      _useHighAccuracy = !_useHighAccuracy;
    });

    // Reload Model
    await _aiService.loadModel(useHighAccuracy: _useHighAccuracy);

    setState(() {
      _isLoaded = true;
    });

    // Restart live stream if it was on
    if (_isLiveMode) {
      _startLiveStream();
    }
  }

  Color _getColorForLabel(String label) {
    final int hash = label.codeUnits.fold(0, (prev, element) => prev + element);
    const List<Color> colors = [
      Colors.greenAccent,
      Colors.redAccent,
      Colors.yellowAccent,
      Colors.cyanAccent,
      Colors.purpleAccent,
      Colors.orangeAccent,
      Colors.pinkAccent,
    ];
    return colors[hash % colors.length];
  }

  void _toggleLiveMode() {
    if (_isLiveMode) {
      _cameraController.stopImageStream();
      setState(() {
        _isLiveMode = false;
        _detections = [];
      });
    } else {
      setState(() {
        _isLiveMode = true;
        _staticImage = null;
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
        final results = await _aiService.detectOnFrame(
          image,
          confThreshold: _useHighAccuracy
              ? 0.5
              : 0.35, // Adjust thresholds based on model
        );

        if (mounted) {
          setState(() {
            _detections = results;
            _imageWidth = image.height.toDouble();
            _imageHeight = image.width.toDouble();
          });
        }
      } catch (e) {
        debugPrint("Live detection error: $e");
      } finally {
        _isDetecting = false;
      }
    });
  }

  Future<void> _pickFromGallery() async {
    if (_isLiveMode) _toggleLiveMode();
    File? file = await _aiService.pickImageFromGallery();
    if (file != null) {
      await _analyzeStaticImage(file);
    }
  }

  Future<void> _takePhoto() async {
    if (_isLiveMode) {
      _toggleLiveMode();
      return;
    }
    try {
      final XFile photo = await _cameraController.takePicture();
      await _analyzeStaticImage(File(photo.path));
    } catch (e) {
      debugPrint("Error taking photo: $e");
    }
  }

  Future<void> _analyzeStaticImage(File file) async {
    var decoded = await decodeImageFromList(await file.readAsBytes());

    final results = await _aiService.detectOnImage(file);

    setState(() {
      _staticImage = file;
      _detections = results;
      _imageWidth = decoded.width.toDouble();
      _imageHeight = decoded.height.toDouble();
    });
  }

  // --- UI ---

  @override
  Widget build(BuildContext context) {
    if (!_isLoaded) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: Colors.green),
              SizedBox(height: 10),
              Text(
                "Loading AI Model...",
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 1. THE VIEWPORT
          Positioned.fill(child: Center(child: _buildContentLayer())),

          // 2. TOP BAR
          Positioned(
            top: 40,
            left: 20,
            right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Back Button
                CircleAvatar(
                  backgroundColor: Colors.black54,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),

                // NEW: Accuracy Toggle
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: _useHighAccuracy
                          ? Colors.greenAccent
                          : Colors.grey,
                    ),
                  ),
                  child: Row(
                    children: [
                      Text(
                        _useHighAccuracy ? "High Acc" : "Fast Mode",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                      Switch(
                        value: _useHighAccuracy,
                        activeColor: Colors.greenAccent,
                        onChanged: (val) => _toggleAccuracy(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // 3. BOTTOM CONTROL BAR
          Positioned(bottom: 0, left: 0, right: 0, child: _buildControlBar()),
        ],
      ),
    );
  }

  Widget _buildContentLayer() {
    double aspectRatio;
    if (_staticImage != null) {
      aspectRatio = _imageWidth / _imageHeight;
    } else {
      aspectRatio = 1 / _cameraController.value.aspectRatio;
    }

    return AspectRatio(
      aspectRatio: aspectRatio,
      child: Stack(
        fit: StackFit.expand,
        children: [
          _staticImage != null
              ? Image.file(_staticImage!, fit: BoxFit.fill)
              : CameraPreview(_cameraController),

          _buildSegmentationOverlay(),
        ],
      ),
    );
  }

  Widget _buildSegmentationOverlay() {
    if (_detections.isEmpty) return const SizedBox.shrink();

    return CustomPaint(
      painter: SegmentationPainter(
        detections: _detections,
        imageWidth: _imageWidth,
        imageHeight: _imageHeight,
        colorGenerator: _getColorForLabel,
      ),
      child: Container(),
    );
  }

  Widget _buildControlBar() {
    return Container(
      color: Colors.black.withOpacity(0.6),
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 30),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(
              Icons.photo_library,
              color: Colors.white,
              size: 30,
            ),
            onPressed: _pickFromGallery,
          ),
          GestureDetector(
            onTap: _takePhoto,
            child: Container(
              height: 70,
              width: 70,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 4),
                color: _isLiveMode ? Colors.red : Colors.white,
              ),
              child: _isLiveMode
                  ? const Icon(Icons.stop, color: Colors.white, size: 30)
                  : const Icon(Icons.camera_alt, color: Colors.black, size: 30),
            ),
          ),
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
    );
  }
}

// Ensure SegmentationPainter matches your existing class
class SegmentationPainter extends CustomPainter {
  final List<Map<String, dynamic>> detections;
  final double imageWidth;
  final double imageHeight;
  final Color Function(String) colorGenerator;

  SegmentationPainter({
    required this.detections,
    required this.imageWidth,
    required this.imageHeight,
    required this.colorGenerator,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (detections.isEmpty) return;

    for (var det in detections) {
      final String label = det["tag"];
      final Color baseColor = colorGenerator(label);

      final Paint strokePaint = Paint()
        ..color = baseColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0;

      final Paint fillPaint = Paint()
        ..color = baseColor
            .withOpacity(0.4) // Make it visible!
        ..style = PaintingStyle.fill;

      // --- DRAW POLYGONS (SEGMENTATION) ---
      // This is the "Instance Segmentation" part
      bool drawnPolygon = false;

      if (det["polygons"] != null) {
        final List<dynamic> points = det["polygons"] as List<dynamic>;

        if (points.isNotEmpty) {
          final Path path = Path();

          // Helper to get X/Y from point data (handles both Map and List formats)
          Offset getPoint(dynamic p) {
            double x, y;
            if (p is Map) {
              x = (p['x'] as num).toDouble();
              y = (p['y'] as num).toDouble();
            } else if (p is List) {
              x = (p[0] as num).toDouble();
              y = (p[1] as num).toDouble();
            } else {
              return Offset.zero;
            }
            // Normalize: If raw pixel > 1, divide by image dimensions
            if (x > 1.0) x /= imageWidth;
            if (y > 1.0) y /= imageHeight;

            // Scale to Screen
            return Offset(x * size.width, y * size.height);
          }

          path.moveTo(getPoint(points[0]).dx, getPoint(points[0]).dy);

          for (int i = 1; i < points.length; i++) {
            final Offset o = getPoint(points[i]);
            path.lineTo(o.dx, o.dy);
          }
          path.close();

          canvas.drawPath(path, fillPaint);
          canvas.drawPath(path, strokePaint);
          drawnPolygon = true;
        }
      }

      // --- DRAW BOX (Fallback if no polygon, or just to show location) ---
      // If we didn't draw a polygon, or just want to confirm detection, draw the box
      final box = det["box"];
      double x1 = box[0];
      double y1 = box[1];
      double x2 = box[2];
      double y2 = box[3];

      if (x1 > 1.0 || x2 > 1.0) {
        // Normalize if needed
        x1 /= imageWidth;
        y1 /= imageHeight;
        x2 /= imageWidth;
        y2 /= imageHeight;
      }

      final Rect rect = Rect.fromLTRB(
        x1 * size.width,
        y1 * size.height,
        x2 * size.width,
        y2 * size.height,
      );

      // If polygon failed, draw a solid box. If polygon worked, just a faint border.
      if (!drawnPolygon) {
        canvas.drawRect(rect, strokePaint);
      } else {
        // Optional: Draw a faint box around the polygon
        final Paint faintPaint = Paint()
          ..color = baseColor.withOpacity(0.2)
          ..style = PaintingStyle.stroke;
        canvas.drawRect(rect, faintPaint);
      }

      // --- DRAW LABEL ---
      // Draw label at top-left of the box
      final TextPainter tp = TextPainter(
        text: TextSpan(
          text: label.toUpperCase(),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      tp.layout();

      // Background for text
      canvas.drawRect(
        Rect.fromLTWH(rect.left, rect.top - 20, tp.width + 6, 20),
        Paint()..color = baseColor,
      );
      tp.paint(canvas, Offset(rect.left + 3, rect.top - 18));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
