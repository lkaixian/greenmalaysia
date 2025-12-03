import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart'; // Add intl to pubspec.yaml if missing

class NotificationPage extends StatelessWidget {
  const NotificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(body: Center(child: Text("Please login first")));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Notifications"),
        actions: [
          // Clear All Button
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            onPressed: () => _clearAllNotifications(user.uid),
            tooltip: "Clear All",
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        // Listen to the specific user's notifications
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('notifications')
            .orderBy('timestamp', descending: true) // Newest first
            .limit(10) // Limit to latest 10 notifications
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          var docs = snapshot.data!.docs;

          if (docs.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications_off, size: 60, color: Colors.grey),
                  SizedBox(height: 10),
                  Text(
                    "No notifications yet",
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              var data = docs[index].data() as Map<String, dynamic>;
              String type = data['type'] ?? 'info';

              // Handle Timestamp formatting
              String timeString = "Just now";
              if (data['timestamp'] != null) {
                DateTime date = (data['timestamp'] as Timestamp).toDate();
                timeString = DateFormat('dd MMM, hh:mm a').format(date);
              }

              return Dismissible(
                key: Key(docs[index].id),
                background: Container(
                  color: Colors.red,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                onDismissed: (direction) {
                  _deleteNotification(user.uid, docs[index].id);
                },
                child: Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  child: ListTile(
                    leading: _getIconForType(type),
                    title: Text(
                      data['title'] ?? "Notification",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(data['body'] ?? ""),
                        const SizedBox(height: 4),
                        Text(
                          timeString,
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    isThreeLine: true,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  // --- UI HELPERS ---
  Widget _getIconForType(String type) {
    if (type == 'pickup') {
      return const CircleAvatar(
        backgroundColor: Colors.blueAccent,
        child: Icon(Icons.local_shipping, color: Colors.white),
      );
    } else if (type == 'reward') {
      return const CircleAvatar(
        backgroundColor: Colors.orangeAccent,
        child: Icon(Icons.card_giftcard, color: Colors.white),
      );
    } else {
      return const CircleAvatar(
        backgroundColor: Colors.grey,
        child: Icon(Icons.info, color: Colors.white),
      );
    }
  }

  // --- DATABASE LOGIC ---
  Future<void> _deleteNotification(String uid, String docId) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('notifications')
        .doc(docId)
        .delete();
  }

  Future<void> _clearAllNotifications(String uid) async {
    var collection = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('notifications');
    var snapshots = await collection.get();
    for (var doc in snapshots.docs) {
      await doc.reference.delete();
    }
  }
}
