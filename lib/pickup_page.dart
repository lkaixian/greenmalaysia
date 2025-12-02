import 'package:flutter/material.dart';
import 'package:greenmalaysia/l10n/app_localizations.dart';
import 'pickup_feature.dart';

class PickupPage extends StatelessWidget {
  const PickupPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final pickupLogic = PickupFeature();
    final pickups = pickupLogic.getScheduledPickups();

    return Scaffold(
      appBar: AppBar(title: Text(l10n.schedulePickup)), // Refactored
      body: ListView.builder(
        itemCount: pickups.length,
        itemBuilder: (context, index) {
          return ListTile(
            leading: const Icon(Icons.check_circle_outline),
            title: Text(
              pickups[index],
            ), // Note: Data from backend is usually not translated here
          );
        },
      ),
    );
  }
}
