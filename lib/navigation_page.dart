import 'package:flutter/material.dart';
import 'package:greenmalaysia/l10n/app_localizations.dart';
import 'navigation_helper.dart';

class NavigationPage extends StatelessWidget {
  const NavigationPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final navHelper = NavigationHelper();

    return Scaffold(
      appBar: AppBar(title: Text(l10n.gpsNavigation)), // Refactored
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.map, size: 100, color: Colors.blue),
            const SizedBox(height: 20),
            Text("Current: ${navHelper.getCurrentLocationName()}"),
          ],
        ),
      ),
    );
  }
}
