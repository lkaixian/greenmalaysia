import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ManageUsersPage extends StatefulWidget {
  const ManageUsersPage({super.key});

  @override
  State<ManageUsersPage> createState() => _ManageUsersPageState();
}

class _ManageUsersPageState extends State<ManageUsersPage> {
  // Search logic (Optional, for now basically filters locally or fetches all)
  String _searchQuery = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Manage Users")),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: const InputDecoration(
                labelText: "Search by Name or Email",
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (val) =>
                  setState(() => _searchQuery = val.toLowerCase()),
            ),
          ),

          // List of Users
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                var docs = snapshot.data!.docs;

                // Simple Client-side Filter
                var filteredDocs = docs.where((doc) {
                  var data = doc.data() as Map<String, dynamic>;
                  String name = (data['fullName'] ?? "")
                      .toString()
                      .toLowerCase();
                  String email = (data['email'] ?? "").toString().toLowerCase();
                  return name.contains(_searchQuery) ||
                      email.contains(_searchQuery);
                }).toList();

                if (filteredDocs.isEmpty) {
                  return const Center(child: Text("No users found."));
                }

                return ListView.builder(
                  itemCount: filteredDocs.length,
                  itemBuilder: (context, index) {
                    var data =
                        filteredDocs[index].data() as Map<String, dynamic>;
                    String userId = filteredDocs[index].id;

                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.teal.shade100,
                          child: const Icon(Icons.person, color: Colors.teal),
                        ),
                        title: Text(data['fullName'] ?? "No Name"),
                        subtitle: Text(
                          "${data['email']}\nPoints: ${data['points'] ?? 0}",
                        ),
                        trailing: const Icon(Icons.edit, color: Colors.blue),
                        onTap: () => _showEditUserDialog(context, userId, data),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // --- EDIT DIALOG ---
  void _showEditUserDialog(
    BuildContext context,
    String uid,
    Map<String, dynamic> data,
  ) {
    final nameCtrl = TextEditingController(text: data['fullName']);
    final phoneCtrl = TextEditingController(text: data['phoneNumber']);
    final addressCtrl = TextEditingController(text: data['pickupAddress']);
    final pointsCtrl = TextEditingController(
      text: (data['points'] ?? 0).toString(),
    );

    String role = data['role'] ?? 'user';

    showDialog(
      context: context,
      builder: (c) => StatefulBuilder(
        // StatefulBuilder to handle Dropdown updates inside dialog
        builder: (context, setState) {
          return AlertDialog(
            title: const Text("Edit User Data"),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameCtrl,
                    decoration: const InputDecoration(labelText: "Full Name"),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: phoneCtrl,
                    decoration: const InputDecoration(
                      labelText: "Phone Number",
                    ),
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: addressCtrl,
                    decoration: const InputDecoration(
                      labelText: "Pickup Address",
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: pointsCtrl,
                    decoration: const InputDecoration(
                      labelText: "Points (Manual Adjustment)",
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 20),

                  // Role Dropdown (Admin/User)
                  DropdownButtonFormField<String>(
                    value: role,
                    decoration: const InputDecoration(labelText: "Role"),
                    items: const [
                      DropdownMenuItem(value: 'user', child: Text("User")),
                      DropdownMenuItem(value: 'admin', child: Text("Admin")),
                    ],
                    onChanged: (val) => setState(() => role = val!),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(c),
                child: const Text("Cancel"),
              ),
              ElevatedButton(
                onPressed: () async {
                  await FirebaseFirestore.instance
                      .collection('users')
                      .doc(uid)
                      .update({
                        'fullName': nameCtrl.text,
                        'phoneNumber': phoneCtrl.text,
                        'pickupAddress': addressCtrl.text,
                        'points': int.tryParse(pointsCtrl.text) ?? 0,
                        'role': role,
                      });
                  if (c.mounted) Navigator.pop(c);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("User Updated!")),
                    );
                  }
                },
                child: const Text("Update"),
              ),
            ],
          );
        },
      ),
    );
  }
}
