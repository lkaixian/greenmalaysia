import 'dart:io';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:camera/camera.dart';
import 'package:greenmalaysia/services/analysis_service.dart';
import 'package:greenmalaysia/services/settings_service.dart';
import 'package:greenmalaysia/data/recycling_data.dart';

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
  bool _useHighAccuracy = false;

  File? _staticImage;
  List<Map<String, dynamic>> _detections = [];

  double _imageWidth = 1;
  double _imageHeight = 1;

  // --- PERFORMANCE HUD STATE ---
  double _fps = 0.0;
  int _prepTimeMs = 0;
  int _aiTimeMs = 0;
  int _frameCount = 0;
  DateTime _lastFpsUpdate = DateTime.now();

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
    _aiService.dispose();
    super.dispose();
  }

  Future<void> _initializeSetup() async {
    // 1. Load Model with Settings Override
    final forced = SettingsService().forcedModel;
    String? overridePath;
    if (forced != 'auto') {
      overridePath = forced;
    }
    await _aiService.loadModel(
      useHighAccuracy: _useHighAccuracy,
      modelPathOverride: overridePath,
    );

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

  // --- TOGGLE ACCURACY ---
  Future<void> _toggleAccuracy() async {
    if (_isLiveMode) {
      await _cameraController.stopImageStream();
    }

    setState(() {
      _isLoaded = false;
      _useHighAccuracy = !_useHighAccuracy;
    });

    final forced = SettingsService().forcedModel;
    String? overridePath;
    if (forced != 'auto') {
      overridePath = forced;
    }
    await _aiService.loadModel(
      useHighAccuracy: _useHighAccuracy,
      modelPathOverride: overridePath,
    );

    setState(() {
      _isLoaded = true;
    });

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
        _fps = 0.0;
      });
    } else {
      setState(() {
        _isLiveMode = true;
        _staticImage = null;
        _frameCount = 0;
        _lastFpsUpdate = DateTime.now();
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
          confThreshold: _useHighAccuracy ? 0.5 : 0.35,
        );

        if (mounted) {
          setState(() {
            _aiTimeMs = _aiService.lastInferenceMs;
            _prepTimeMs = _aiService.lastPrepMs;

            // Calculate FPS
            _frameCount++;
            final now = DateTime.now();
            if (now.difference(_lastFpsUpdate).inMilliseconds >= 1000) {
              _fps = _frameCount /
                  (now.difference(_lastFpsUpdate).inMilliseconds / 1000.0);
              _frameCount = 0;
              _lastFpsUpdate = now;
            }

            _detections = results;
            if (results.isNotEmpty) {
              _imageWidth = image.height.toDouble();
              _imageHeight = image.width.toDouble();
            }
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
    final stopwatch = Stopwatch()..start();
    var decoded = await decodeImageFromList(await file.readAsBytes());

    final results = await _aiService.detectOnImage(file);
    stopwatch.stop();

    setState(() {
      _staticImage = file;
      _detections = results;
      _imageWidth = decoded.width.toDouble();
      _imageHeight = decoded.height.toDouble();
      _prepTimeMs = 0;
      _aiTimeMs = _aiService.lastInferenceMs;
    });
  }

  // --- TAP HANDLER: Find detection at tap position ---
  void _onOverlayTap(TapUpDetails details, Size overlaySize) {
    final normalizedX = details.localPosition.dx / overlaySize.width;
    final normalizedY = details.localPosition.dy / overlaySize.height;

    Map<String, dynamic>? bestMatch;
    double smallestArea = double.infinity;

    for (var det in _detections) {
      final box = det["box"];
      double x1 = box[0], y1 = box[1], x2 = box[2], y2 = box[3];

      // Normalize if pixel values
      if (x1 > 1.0 || x2 > 1.0) {
        x1 /= _imageWidth;
        y1 /= _imageHeight;
        x2 /= _imageWidth;
        y2 /= _imageHeight;
      }

      if (normalizedX >= x1 &&
          normalizedX <= x2 &&
          normalizedY >= y1 &&
          normalizedY <= y2) {
        double area = (x2 - x1) * (y2 - y1);
        if (area < smallestArea) {
          smallestArea = area;
          bestMatch = det;
        }
      }
    }

    if (bestMatch != null) {
      _showRecyclingInfo(bestMatch);
    }
  }

  // --- RECYCLING INFO BOTTOM SHEET ---
  void _showRecyclingInfo(Map<String, dynamic> det) {
    final String label = det["tag"];
    final double conf = (det["confidence"] ?? 0.0).toDouble();
    final info = recyclingData[label] ?? recyclingData["s-other"]!;

    // Gather alternative predictions if available
    final List<Map<String, dynamic>> alternatives =
        (det["alternatives"] as List<Map<String, dynamic>>?) ?? [];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.65,
          decoration: const BoxDecoration(
            color: Color(0xFF16213E),
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Text(
                  "${info.icon} ${label.toUpperCase()}",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: _getColorForLabel(label),
                  ),
                ),
                Text(
                  "Type: ${info.label} • Confidence: ${(conf * 100).toStringAsFixed(1)}%",
                  style: const TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 12),

                // Recyclable Badge
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: info.recyclable ? Colors.green : Colors.red,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    info.recyclable ? "♻️ RECYCLABLE" : "🚫 NOT RECYCLABLE",
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 16),

                // Alternative predictions
                if (alternatives.isNotEmpty) ...[
                  const Text("📊 Other Possibilities",
                      style: TextStyle(
                          color: Colors.lightBlueAccent,
                          fontWeight: FontWeight.bold,
                          fontSize: 14)),
                  const SizedBox(height: 4),
                  ...alternatives.map((alt) {
                    final altConf =
                        ((alt['confidence'] ?? 0.0) as double) * 100;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 2),
                      child: Text(
                        "  • ${alt['tag']} — ${altConf.toStringAsFixed(1)}%",
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 13),
                      ),
                    );
                  }),
                  const Divider(color: Colors.white24, height: 20),
                ],

                // Bin info
                const Text("🗑️ Disposal Bin",
                    style: TextStyle(
                        color: Colors.lightBlueAccent,
                        fontWeight: FontWeight.bold,
                        fontSize: 16)),
                Text(info.bin,
                    style: const TextStyle(color: Colors.white)),
                const Divider(color: Colors.white24, height: 30),

                // Steps
                const Text("📋 How to Dispose / Recycle",
                    style: TextStyle(
                        color: Colors.lightBlueAccent,
                        fontWeight: FontWeight.bold,
                        fontSize: 16)),
                const SizedBox(height: 5),
                ...info.steps.map((step) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(step,
                          style: const TextStyle(color: Colors.white)),
                    )),
                const Divider(color: Colors.white24, height: 30),

                // Tips
                const Text("💡 Tips",
                    style: TextStyle(
                        color: Colors.yellowAccent,
                        fontWeight: FontWeight.bold,
                        fontSize: 16)),
                const SizedBox(height: 5),
                Text(info.tips,
                    style: const TextStyle(color: Colors.white)),
                const SizedBox(height: 20),

                // Source & Link
                Text("Source: ${info.source}",
                    style:
                        const TextStyle(color: Colors.grey, fontSize: 12)),
                const SizedBox(height: 10),
                ElevatedButton.icon(
                  icon: const Icon(Icons.link),
                  label: const Text("Learn more on Trashpedia"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0F9B8E),
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(45),
                  ),
                  onPressed: () => launchUrl(Uri.parse(info.link)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ═══════════════════════════════════════════
  // UI BUILD
  // ═══════════════════════════════════════════

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
                CircleAvatar(
                  backgroundColor: Colors.black54,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color:
                          _useHighAccuracy ? Colors.greenAccent : Colors.grey,
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

          // 3. PERFORMANCE HUD (top-left, below top bar)
          if (SettingsService().showHud && (_isLiveMode || _staticImage != null))
            Positioned(
              top: 100,
              left: 16,
              child: _buildPerformanceHud(),
            ),

          // 4. BOTTOM CONTROL BAR
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

  // --- PERFORMANCE HUD WIDGET ---
  Widget _buildPerformanceHud() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.7),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.greenAccent.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "Model: ${_aiService.modelName}",
            style: const TextStyle(
                color: Colors.greenAccent, fontSize: 10, fontFamily: 'monospace'),
          ),
          Text(
            "Device: ${_aiService.deviceModel}",
            style: const TextStyle(
                color: Colors.grey, fontSize: 10, fontFamily: 'monospace'),
          ),
          Text(
            "CPU: ${_aiService.cpuModel} (${_aiService.cpuCores} cores)",
            style: const TextStyle(
                color: Colors.grey, fontSize: 10, fontFamily: 'monospace'),
          ),
          Text(
            "Backend: ${_aiService.activeBackend} | Threads: ${_aiService.threadCount}",
            style: const TextStyle(
                color: Colors.cyanAccent, fontSize: 10, fontFamily: 'monospace'),
          ),
          Text(
            "Prep: ${_prepTimeMs}ms | AI: ${_aiTimeMs}ms",
            style: const TextStyle(
                color: Colors.yellowAccent,
                fontSize: 10,
                fontFamily: 'monospace'),
          ),
          if (_isLiveMode)
            Text(
              "FPS: ${_fps.toStringAsFixed(1)}",
              style: const TextStyle(
                  color: Colors.orangeAccent,
                  fontSize: 10,
                  fontFamily: 'monospace'),
            ),
          Text(
            "Detections: ${_detections.length}",
            style: const TextStyle(
                color: Colors.white70, fontSize: 10, fontFamily: 'monospace'),
          ),
        ],
      ),
    );
  }

  // --- SEGMENTATION OVERLAY (with tap interaction) ---
  Widget _buildSegmentationOverlay() {
    if (_detections.isEmpty) return const SizedBox.shrink();

    return LayoutBuilder(
      builder: (context, constraints) {
        return GestureDetector(
          onTapUp: (details) => _onOverlayTap(
            details,
            Size(constraints.maxWidth, constraints.maxHeight),
          ),
          child: CustomPaint(
            painter: SegmentationPainter(
              detections: _detections,
              imageWidth: _imageWidth,
              imageHeight: _imageHeight,
              colorGenerator: _getColorForLabel,
            ),
            child: Container(color: Colors.transparent),
          ),
        );
      },
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

// ═══════════════════════════════════════════
// SEGMENTATION PAINTER
// ═══════════════════════════════════════════

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
        ..color = baseColor.withOpacity(0.4)
        ..style = PaintingStyle.fill;

      // --- DRAW POLYGONS (SEGMENTATION) ---
      bool drawnPolygon = false;

      if (det["polygons"] != null) {
        final List<dynamic> points = det["polygons"] as List<dynamic>;

        if (points.isNotEmpty) {
          final Path path = Path();

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
            if (x > 1.0) x /= imageWidth;
            if (y > 1.0) y /= imageHeight;
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

      // --- DRAW BOX ---
      final box = det["box"];
      double x1 = box[0], y1 = box[1], x2 = box[2], y2 = box[3];

      if (x1 > 1.0 || x2 > 1.0) {
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

      if (!drawnPolygon) {
        canvas.drawRect(rect, strokePaint);
      } else {
        final Paint faintPaint = Paint()
          ..color = baseColor.withOpacity(0.2)
          ..style = PaintingStyle.stroke;
        canvas.drawRect(rect, faintPaint);
      }

      // --- DRAW LABEL with confidence ---
      final double conf = (det["confidence"] ?? 0.0).toDouble();
      final String displayText =
          "${label.toUpperCase()} ${(conf * 100).toStringAsFixed(0)}%";

      final TextPainter tp = TextPainter(
        text: TextSpan(
          text: displayText,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      tp.layout();

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
