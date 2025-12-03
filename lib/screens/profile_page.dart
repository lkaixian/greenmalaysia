import 'dart:io';
import 'package:flutter/material.dart';
import 'package:greenmalaysia/l10n/app_localizations.dart'; // Import L10n
import 'package:greenmalaysia/profile_features.dart';
import 'package:greenmalaysia/screens/login_page.dart';
import 'package:greenmalaysia/app_config.dart'; // For Admin Tree Shaking

// Sub-pages
import '../personal_information_page.dart';
import 'rewards_page.dart';
import 'app_settings.dart';
import 'package:greenmalaysia/screens/collector/collector_dashboard.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final ProfileFeatures _features = ProfileFeatures();

  // State variables
  String? _localImagePath;
  String _userRole = 'user'; // 'user', 'admin', or 'collector'
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  void _loadProfileData() async {
    // 1. Load Local Image (if applicable)
    if (!_features.isGoogleUser()) {
      String? path = await _features.getLocalProfilePicPath();
      setState(() {
        _localImagePath = path;
      });
    }

    // 2. Load User Role from Firestore
    String role = await _features.getUserRole();

    if (mounted) {
      setState(() {
        _userRole = role;
        _isLoading = false;
      });
    }
  }

  void _changeProfilePic() async {
    final l10n = AppLocalizations.of(context)!;
    if (_features.isGoogleUser()) return; 

    String? newPath = await _features.setLocalProfilePicture();

    if (newPath != null) {
      setState(() {
        _localImagePath = newPath;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.profilePicUpdated)),
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
    final l10n = AppLocalizations.of(context)!;
    
    // Determine Image Source
    ImageProvider? imageProvider;
    if (_features.isGoogleUser() && _features.currentUser?.photoURL != null) {
      imageProvider = NetworkImage(_features.currentUser!.photoURL!);
    } else if (_localImagePath != null) {
      imageProvider = FileImage(File(_localImagePath!));
    } else {
      imageProvider = null;
    }

    bool canEdit = !_features.isGoogleUser();

    return Scaffold(
      appBar: AppBar(title: Text(l10n.profileTitle)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // --- 1. PROFILE HEADER ---
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.grey[200],
                    backgroundImage: imageProvider,
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
                          height: 40, width: 40,
                          decoration: const BoxDecoration(
                            color: Colors.green,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              _features.currentUser?.displayName ?? "User",
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text(
              _features.currentUser?.email ?? "",
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 40),

            // --- 2. MENU ITEMS ---
            _buildProfileItem(Icons.person, l10n.personalInfo, () {
              Navigator.push(context, MaterialPageRoute(builder: (c) => const PersonalInformationPage()));
            }),
            _buildProfileItem(Icons.verified, l10n.rewards, () {
              Navigator.push(context, MaterialPageRoute(builder: (c) => const RewardsPage()));
            }),
            _buildProfileItem(Icons.settings, l10n.appSettings, () {
              Navigator.push(context, MaterialPageRoute(builder: (c) => const AppSettingsPage()));
            }),

            const SizedBox(height: 20),

            // --- 3. SPECIAL DASHBOARDS (Role Based) ---
            
            // A. ADMIN DASHBOARD (Developer)
            // Checks: Global Config + Role
            if (enableAdminFeatures && _userRole == 'admin' && AppConfig().adminScreenBuilder != null)
              _buildDashboardButton(
                l10n.adminDashboard,
                Icons.admin_panel_settings,
                Colors.black,
                () {
                  Navigator.push(context, MaterialPageRoute(builder: (c) => AppConfig().adminScreenBuilder!(c)));
                },
              ),

            // B. COLLECTOR DASHBOARD (Pickup Company)
            // Checks: Role Only
            if (_userRole == 'collector')
              _buildDashboardButton(
                l10n.collectorDashboard,
                Icons.local_shipping,
                Colors.blue[900]!, // Distinct color
                () {
                  Navigator.push(context, MaterialPageRoute(builder: (c) => const CollectorDashboard()));
                },
              ),

            // --- 4. LOGOUT ---
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                onPressed: _handleLogout,
                child: Text(l10n.logOut),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- UI HELPERS ---

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

  Widget _buildDashboardButton(String text, IconData icon, Color color, VoidCallback onTap) {
    return Container(
      width: double.infinity,
      height: 50,
      margin: const EdgeInsets.only(bottom: 20),
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
        ),
        icon: Icon(icon),
        label: Text(text),
        onPressed: onTap,
      ),
    );
  }
}