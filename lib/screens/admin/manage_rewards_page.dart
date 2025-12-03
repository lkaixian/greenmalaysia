import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'manage_codes_page.dart'; // We will create this in Step 2

class ManageRewardsPage extends StatelessWidget {
  const ManageRewardsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Manage Rewards")),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => _showRewardDialog(context, null), // Pass null for new
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('rewards').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          var docs = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              var data = docs[index].data() as Map<String, dynamic>;
              String id = docs[index].id;

              return Card(
                margin: const EdgeInsets.only(bottom: 10),
                child: ListTile(
                  title: Text(data['title'], style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text("${data['cost']} pts • ${data['description']}"),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // BUTTON: Manage Codes
                      IconButton(
                        icon: const Icon(Icons.qr_code, color: Colors.green),
                        tooltip: "Manage Codes",
                        onPressed: () {
                          Navigator.push(
                            context, 
                            MaterialPageRoute(builder: (c) => ManageCodesPage(rewardId: id, rewardTitle: data['title']))
                          );
                        },
                      ),
                      // BUTTON: Edit Reward
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => _showRewardDialog(context, docs[index]),
                      ),
                      // BUTTON: Delete Reward
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteReward(context, id),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  // --- DIALOG: Add or Edit Reward ---
  void _showRewardDialog(BuildContext context, DocumentSnapshot? doc) {
    final titleCtrl = TextEditingController(text: doc?['title']);
    final costCtrl = TextEditingController(text: doc?['cost']?.toString());
    final descCtrl = TextEditingController(text: doc?['description']);
    bool isEditing = doc != null;

    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        title: Text(isEditing ? "Edit Reward" : "New Reward"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: "Title")),
            TextField(controller: costCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "Cost (Points)")),
            TextField(controller: descCtrl, decoration: const InputDecoration(labelText: "Description")),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              Map<String, dynamic> data = {
                'title': titleCtrl.text,
                'cost': int.tryParse(costCtrl.text) ?? 0,
                'description': descCtrl.text,
              };

              if (isEditing) {
                await FirebaseFirestore.instance.collection('rewards').doc(doc.id).update(data);
              } else {
                await FirebaseFirestore.instance.collection('rewards').add(data);
              }
              if (c.mounted) Navigator.pop(c);
            },
            child: const Text("Save"),
          )
        ],
      ),
    );
  }

  void _deleteReward(BuildContext context, String id) {
    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text("Delete Reward?"),
        content: const Text("This will NOT delete the codes associated with it. You should delete codes first."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c), child: const Text("Cancel")),
          TextButton(
            onPressed: () {
              FirebaseFirestore.instance.collection('rewards').doc(id).delete();
              Navigator.pop(c);
            },
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}