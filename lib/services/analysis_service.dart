import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart'; // <--- ADD THIS LINE
import 'package:flutter/services.dart';
import 'package:flutter_vision/flutter_vision.dart';
import 'package:image_picker/image_picker.dart';

class AnalysisService {
  final FlutterVision _vision = FlutterVision();
  final ImagePicker _picker = ImagePicker();

  // 1. Load Model
  Future<void> loadModel() async {
    await _vision.loadYoloModel(
      labels: 'assets/models/labels.txt',
      modelPath: 'assets/models/yolov8n.tflite',
      modelVersion: "yolov8",
      quantization: true,
      numThreads: 2,
      useGpu: false,
    );
  }

  // 2. Detect on Live Camera Frame
  Future<List<Map<String, dynamic>>> detectOnFrame(CameraImage image) async {
    return await _vision.yoloOnFrame(
      bytesList: image.planes.map((plane) => plane.bytes).toList(),
      imageHeight: image.height,
      imageWidth: image.width,
      iouThreshold: 0.4,
      confThreshold: 0.1,
      classThreshold: 0.5,
    );
  }

  // 3. Detect on Static Image File
  Future<List<Map<String, dynamic>>> detectOnImage(File imageFile) async {
    // Read file bytes
    Uint8List bytes = await imageFile.readAsBytes();

    // We need to decode the image to get its width/height for the AI model
    // This function comes from 'package:flutter/material.dart'
    var decodedImage = await decodeImageFromList(bytes);

    return await _vision.yoloOnImage(
      bytesList: bytes,
      imageHeight: decodedImage.height,
      imageWidth: decodedImage.width,
      iouThreshold: 0.4,
      confThreshold: 0.4,
      classThreshold: 0.5,
    );
  }

  // 4. Pick Image from Gallery
  Future<File?> pickImageFromGallery() async {
    final XFile? file = await _picker.pickImage(source: ImageSource.gallery);
    if (file != null) return File(file.path);
    return null;
  }

  void close() {
    _vision.closeYoloModel();
  }
}
