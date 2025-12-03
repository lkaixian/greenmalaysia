import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:greenmalaysia/l10n/app_localizations.dart';
import 'package:greenmalaysia/profile_features.dart'; // To check if google user
import 'screens/profile_page.dart';
import 'screens/pickup_page.dart';
import 'screens/navigation_page.dart';
import 'screens/analysis_page.dart';
import 'screens/notification_page.dart';
import 'screens/home_tabs.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Logic to get profile pic
  final ProfileFeatures _profileFeatures = ProfileFeatures();
  String? _profilePicUrl;

  @override
  void initState() {
    super.initState();
    _loadProfilePic();
  }

  void _loadProfilePic() async {
    // 1. Check User
    final user = FirebaseAuth.instance.currentUser;
    if (user?.photoURL != null) {
      setState(() {
        _profilePicUrl = user!.photoURL;
      });
    } else {
      // 2. Check Local Storage (if non-google user)
      String? localPath = await _profileFeatures.getLocalProfilePicPath();
      if (localPath != null) {
        // Note: Displaying local file in NetworkImage won't work directly here without logic change,
        // but for now we focus on the structure.
        // Ideally, ProfileFeatures returns a generic ImageProvider.
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final user = FirebaseAuth.instance.currentUser;

    return DefaultTabController(
      length: 2, // Tracking & News
      child: Scaffold(
        // --- APP BAR ---
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: Text(l10n.dashboardTitle),
          centerTitle: true,

          // Profile Icon (Top Left)
          leading: Padding(
            padding: const EdgeInsets.all(8.0),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (c) => const ProfilePage()),
                );
              },
              child: CircleAvatar(
                backgroundColor: Colors.white,
                backgroundImage: (user?.photoURL != null)
                    ? NetworkImage(user!.photoURL!)
                    : null, // Shows Network Image if available
                child: (user?.photoURL == null)
                    ? const Icon(Icons.person, color: Colors.grey)
                    : null, // Shows Icon if no image
              ),
            ),
          ),

          // Notification Icon (Top Right)
          actions: [
            IconButton(
              icon: const Icon(Icons.notifications),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (c) => const NotificationPage()),
                );
              },
            ),
          ],

          // --- THE TABS ---
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.location_on), text: "Tracking"),
              Tab(icon: Icon(Icons.newspaper), text: "News"),
            ],
          ),
        ),

        // --- BODY (TAB VIEWS) ---
        body: const TabBarView(
          children: [
            TrackingTab(), // Tab 1 Content
            NewsTab(), // Tab 2 Content
          ],
        ),

        // --- FAB (Camera) ---
        floatingActionButton: SizedBox(
          height: 70,
          width: 70,
          child: FloatingActionButton(
            shape: const CircleBorder(),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (c) => const AnalysisPage()),
              );
            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.camera_alt, size: 28),
                Text(l10n.analysis, style: const TextStyle(fontSize: 9)),
              ],
            ),
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

        // --- BOTTOM NAV BAR ---
        bottomNavigationBar: BottomAppBar(
          shape: const CircularNotchedRectangle(),
          notchMargin: 8.0,
          child: SizedBox(
            height: 60.0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                InkWell(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (c) => const PickupPage()),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.recycling, size: 28),
                      Text(
                        l10n.pickup,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 48), // Spacer
                InkWell(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (c) => const NavigationPage()),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.navigation, size: 28),
                      Text(
                        l10n.navigate,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
