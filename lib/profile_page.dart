import 'dart:io'; // Needed for File
import 'package:flutter/material.dart';
import 'package:greenmalaysia/profile_features.dart';
import 'package:greenmalaysia/screens/login_page.dart';
import 'personal_information_page.dart';
import 'rewards_page.dart';
import 'app_settings.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final ProfileFeatures _features = ProfileFeatures();

  // State variables
  String? _localImagePath;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  // Determine what to show on startup
  void _loadProfileData() async {
    if (!_features.isGoogleUser()) {
      // If Email User, check for a saved local path
      String? path = await _features.getLocalProfilePicPath();
      setState(() {
        _localImagePath = path;
        _isLoading = false;
      });
    } else {
      // If Google User, we just use currentUser.photoURL directly in build
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _changeProfilePic() async {
    if (_features.isGoogleUser()) return; // Google users can't change it here

    // 1. Trigger the local save logic
    String? newPath = await _features.setLocalProfilePicture();

    // 2. Update UI
    if (newPath != null) {
      setState(() {
        _localImagePath = newPath;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Profile picture updated locally!")),
        );
      }
    }
  }

  void _handleLogout() async {
    await _features.signOut();
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (c) => const LoginPage()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // LOGIC: Which Image Provider to use?
    ImageProvider? imageProvider;

    if (_features.isGoogleUser() && _features.currentUser?.photoURL != null) {
      // Case A: Google User (Network URL)
      imageProvider = NetworkImage(_features.currentUser!.photoURL!);
    } else if (_localImagePath != null) {
      // Case B: Email User with custom pic (Local File)
      imageProvider = FileImage(File(_localImagePath!));
    } else {
      // Case C: No picture (Default)
      imageProvider = null; // Will show child icon instead
    }

    bool canEdit = !_features.isGoogleUser();

    return Scaffold(
      appBar: AppBar(title: const Text("Profile")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // --- 1. PROFILE PICTURE SECTION ---
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.grey[200],
                    backgroundImage: imageProvider,
                    // If no imageProvider (Case C), show the Icon
                    child: imageProvider == null
                        ? const Icon(Icons.person, size: 60, color: Colors.grey)
                        : null,
                  ),
                  if (canEdit)
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: _changeProfilePic,
                        child: Container(
                          height: 40,
                          width: 40,
                          decoration: const BoxDecoration(
                            color: Colors.green,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.camera_alt,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // --- 2. USER NAME ---
            Text(
              _features.currentUser?.displayName ?? "User",
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text(
              _features.currentUser?.email ?? "",
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 40),

            // --- 3. MENU ITEMS ---
            _buildProfileItem(Icons.person, "Personal Information", () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (c) => const PersonalInformationPage(),
                ),
              );
            }),
            _buildProfileItem(Icons.verified, "Rewards", () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (c) => const RewardsPage()),
              );
            }),
            _buildProfileItem(Icons.settings, "App Settings", () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (c) => const AppSettingsPage()),
              );
            }),

            const SizedBox(height: 40),

            // --- 4. LOGOUT ---
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                onPressed: _handleLogout,
                child: const Text("Log Out"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileItem(IconData icon, String text, VoidCallback onTap) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: Icon(icon, color: Colors.green),
        title: Text(text),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}
