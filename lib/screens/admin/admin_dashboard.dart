import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'add_facility_page.dart';
import 'manage_rewards_page.dart';
import 'manage_users_page.dart';
import 'create_collector_page.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin (Dev)"),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // --- SECTION 1: SYSTEM DATA ---
          _sectionHeader("System Data"),
          _buildAdminCard(
            context,
            "Manage Categories",
            Icons.category,
            Colors.orange,
            () => _showAddCategoryDialog(context),
          ),
          _buildAdminCard(
            context,
            "Manage Rewards",
            Icons.card_giftcard,
            Colors.purple,
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (c) => const ManageRewardsPage()),
            ),
          ),

          const SizedBox(height: 20),

          // --- SECTION 2: OPERATIONS ---
          _sectionHeader("Operations"),
          _buildAdminCard(
            context,
            "Add Recycling Facility",
            Icons.location_on,
            Colors.blue,
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (c) => const AddFacilityPage()),
            ),
          ),

          const SizedBox(height: 20),

          // --- SECTION 3: USER MANAGEMENT ---
          _sectionHeader("User Management"),
          _buildAdminCard(
            context,
            "Edit User Data",
            Icons.people,
            Colors.teal,
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (c) => const ManageUsersPage()),
            ),
          ),
          _buildAdminCard(
            context,
            "Create Collector Account",
            Icons.local_shipping,
            Colors.redAccent,
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (c) => const CollectorDashboard()),
            ),
          ),
        ],
      ),
    );
  }

  // --- UI HELPER: SECTION HEADER ---
  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.grey,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    );
  }

  // --- UI HELPER: ADMIN CARD ---
  Widget _buildAdminCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.1),
          child: Icon(icon, color: color),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: Colors.grey,
        ),
        onTap: onTap,
      ),
    );
  }

  // --- DIALOG: ADD CATEGORY ---
  void _showAddCategoryDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text("New Category"),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: "Category Name (e.g., Plastic)",
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              if (controller.text.isNotEmpty) {
                // Use Custom ID (Lowercase) for easier querying
                String id = controller.text.trim().toLowerCase();
                await FirebaseFirestore.instance
                    .collection('recycling_categories')
                    .doc(id)
                    .set({'name': controller.text.trim()});
                if (c.mounted) Navigator.pop(c);
              }
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }
}
