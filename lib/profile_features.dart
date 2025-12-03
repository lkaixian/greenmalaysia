import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path/path.dart' as path;

class ProfileFeatures {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final ImagePicker _picker = ImagePicker();

  User? get currentUser => _auth.currentUser;

  bool isGoogleUser() {
    if (currentUser == null) return false;
    for (var provider in currentUser!.providerData) {
      if (provider.providerId == 'google.com') {
        return true;
      }
    }
    return false;
  }

  /// 1. Get the local profile pic path (if exists)
  Future<String?> getLocalProfilePicPath() async {
    if (currentUser == null) return null;
    final prefs = await SharedPreferences.getInstance();
    // Key format: profile_pic_{uid}
    return prefs.getString('profile_pic_${currentUser!.uid}');
  }

  /// 2. Pick Image -> Save Locally -> Save Path to Prefs
  Future<String?> setLocalProfilePicture() async {
    try {
      // A. Pick Image
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image == null) return null;

      // B. Find a permanent place to store it
      final directory = await getApplicationDocumentsDirectory();
      // Create a unique filename based on User ID
      final String newPath = path.join(
        directory.path,
        'profile_${currentUser!.uid}.jpg',
      );

      // C. Copy the file there (overwrite if exists)
      final File newImage = await File(image.path).copy(newPath);

      // D. Save this path to SharedPrefs so we remember it next time
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('profile_pic_${currentUser!.uid}', newImage.path);

      return newImage.path;
    } catch (e) {
      print("Error saving local image: $e");
      return null;
    }
  }

  Future<String> getUserRole() async {
    if (currentUser == null) return 'user';

    try {
      DocumentSnapshot doc = await _db
          .collection('users')
          .doc(currentUser!.uid)
          .get();

      if (doc.exists && doc.data() != null) {
        // Return the role field, or 'user' if it's missing
        return (doc.data() as Map<String, dynamic>)['role'] ?? 'user';
      }
    } catch (e) {
      print("Error fetching role: $e");
    }
    return 'user'; // Default fallback
  }

  Future<void> signOut() async {
    // Note: We don't delete the local file on logout, so it's there if they log back in.
    await _auth.signOut();
  }
}
