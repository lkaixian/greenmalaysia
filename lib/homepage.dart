import 'package:flutter/material.dart';
import 'package:greenmalaysia/l10n/app_localizations.dart'; // Import this
import 'profile_page.dart';
import 'pickup_page.dart';
import 'navigation_page.dart';
import 'analysis_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Helper variable for cleaner code
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(l10n.dashboardTitle), // Refactored
        centerTitle: true,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (c) => const ProfilePage()),
              );
            },
            child: const CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.person, color: Colors.grey),
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              // Logic...
            },
          ),
        ],
      ),
      body: Center(
        child: Text(l10n.welcomeMessage), // Refactored
      ),
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
              Text(
                l10n.analysis,
                style: const TextStyle(fontSize: 9),
              ), // Refactored
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        child: SizedBox(
          height: 60.0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (c) => const PickupPage()),
                  );
                },
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.recycling, size: 28),
                    Text(
                      l10n.pickup,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ), // Refactored
                  ],
                ),
              ),
              const SizedBox(width: 48),
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (c) => const NavigationPage()),
                  );
                },
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.navigation, size: 28),
                    Text(
                      l10n.navigate,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ), // Refactored
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
