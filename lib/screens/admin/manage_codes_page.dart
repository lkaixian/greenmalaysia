import 'dart:math';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ManageCodesPage extends StatelessWidget {
  final String rewardId;
  final String rewardTitle;

  const ManageCodesPage({
    super.key,
    required this.rewardId,
    required this.rewardTitle,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Codes for: $rewardTitle")),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: const Text("Add Codes"),
        onPressed: () => _showAddCodeDialog(context),
      ),
      body: StreamBuilder<QuerySnapshot>(
        // FILTER: Only show codes for THIS reward ID
        stream: FirebaseFirestore.instance
            .collection('reward_codes')
            .where('rewardId', isEqualTo: rewardId)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          var docs = snapshot.data!.docs;

          if (docs.isEmpty) {
            return const Center(child: Text("No codes added yet."));
          }

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              var data = docs[index].data() as Map<String, dynamic>;
              bool isRedeemed = (data['redeemed'] ?? 0) == 1;

              return ListTile(
                title: Text(
                  data['code'],
                  style: TextStyle(
                    decoration: isRedeemed ? TextDecoration.lineThrough : null,
                    color: isRedeemed ? Colors.grey : Colors.black,
                  ),
                ),
                subtitle: Text(
                  isRedeemed ? "Status: USED" : "Status: AVAILABLE",
                ),
                leading: Icon(
                  isRedeemed ? Icons.cancel : Icons.check_circle,
                  color: isRedeemed ? Colors.red : Colors.green,
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Edit/Reset Button
                    IconButton(
                      icon: const Icon(Icons.refresh),
                      onPressed: () => _resetCodeStatus(docs[index].id),
                      tooltip: "Reset to Available",
                    ),
                    // Delete Button
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _deleteCode(docs[index].id),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  // --- DIALOG: Add Codes ---
  void _showAddCodeDialog(BuildContext context) {
    final codeCtrl = TextEditingController();
    final amountCtrl = TextEditingController(text: "1");
    bool autoGenerate = false;

    showDialog(
      context: context,
      builder: (c) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text("Add Codes"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SwitchListTile(
                  title: const Text("Auto Generate?"),
                  value: autoGenerate,
                  onChanged: (val) => setState(() => autoGenerate = val),
                ),
                if (!autoGenerate)
                  TextField(
                    controller: codeCtrl,
                    decoration: const InputDecoration(
                      labelText: "Manual Code (e.g. GRAB-88)",
                    ),
                  ),
                if (autoGenerate)
                  TextField(
                    controller: amountCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: "How many codes?",
                    ),
                  ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(c),
                child: const Text("Cancel"),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (autoGenerate) {
                    int amount = int.tryParse(amountCtrl.text) ?? 1;
                    await _batchGenerateCodes(amount);
                  } else {
                    if (codeCtrl.text.isNotEmpty) {
                      await FirebaseFirestore.instance
                          .collection('reward_codes')
                          .add({
                            'rewardId': rewardId,
                            'code': codeCtrl.text.trim(),
                            'redeemed': 0,
                          });
                    }
                  }
                  if (c.mounted) Navigator.pop(c);
                },
                child: const Text("Add"),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _batchGenerateCodes(int amount) async {
    final batch = FirebaseFirestore.instance.batch();
    for (int i = 0; i < amount; i++) {
      var docRef = FirebaseFirestore.instance.collection('reward_codes').doc();
      String randomCode =
          "RWD-${Random().nextInt(999999)}"; // Simple randomizer
      batch.set(docRef, {
        'rewardId': rewardId,
        'code': randomCode,
        'redeemed': 0,
      });
    }
    await batch.commit();
  }

  void _resetCodeStatus(String docId) {
    FirebaseFirestore.instance.collection('reward_codes').doc(docId).update({
      'redeemed': 0,
    });
  }

  void _deleteCode(String docId) {
    FirebaseFirestore.instance.collection('reward_codes').doc(docId).delete();
  }
}
