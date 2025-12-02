import 'package:flutter/material.dart';
import 'profile_features.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final features = ProfileFeatures();
    final data = features.getUserData();

    return Scaffold(
      appBar: AppBar(title: const Text("My Profile")),
      body: Center(
        child: Column(
          children: [
            const SizedBox(height: 30),
            const CircleAvatar(radius: 50, child: Icon(Icons.person, size: 50)),
            const SizedBox(height: 20),
            Text(
              data["name"]!,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text(data["email"]!, style: const TextStyle(color: Colors.grey)),
            const Divider(height: 40),
            ListTile(
              leading: const Icon(Icons.star),
              title: const Text("Membership Level"),
              trailing: Text(data["level"]!),
            ),
          ],
        ),
      ),
    );
  }
}
