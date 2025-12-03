import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:greenmalaysia/l10n/app_localizations.dart'; // Import L10n

class CollectorDashboard extends StatelessWidget {
  const CollectorDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.collectorPortal), // Localized Title
          backgroundColor: Colors.blue[900],
          foregroundColor: Colors.white,
          bottom: TabBar(
            tabs: [
              Tab(text: l10n.tabNewRequests), // Localized Tab 1
              Tab(text: l10n.tabActiveJobs), // Localized Tab 2
            ],
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
          ),
        ),
        body: const TabBarView(
          children: [
            _PickupList(statusFilter: ['Pending']),
            _PickupList(statusFilter: ['Accepted', 'On The Way']),
          ],
        ),
      ),
    );
  }
}

class _PickupList extends StatelessWidget {
  final List<String> statusFilter;

  const _PickupList({required this.statusFilter});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('pickup_requests')
          .where('status', whereIn: statusFilter)
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        var docs = snapshot.data!.docs;

        if (docs.isEmpty) {
          return Center(child: Text(l10n.noRequestsFound)); // Localized
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            var data = docs[index].data() as Map<String, dynamic>;
            String docId = docs[index].id;

            DateTime date = (data['scheduledDate'] as Timestamp).toDate();
            String dateStr = DateFormat('dd MMM yyyy').format(date);

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          data['category'],
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Chip(
                          label: Text(
                            data['status'],
                          ), // Keeping raw status from DB is usually safer for logic, but UI could map it if needed
                          backgroundColor: _getStatusColor(data['status']),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text("📍 ${data['pickupAddress']}"),
                    Text("📅 $dateStr  •  ⏰ ${data['timeSlot']}"),
                    const Divider(),

                    // --- ACTION BUTTONS ---
                    _buildActionButtons(
                      context,
                      l10n, // Pass L10n down
                      docId,
                      data['status'],
                      data['userId'],
                      data['category'],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Pending':
        return Colors.orange[100]!;
      case 'Accepted':
        return Colors.blue[100]!;
      case 'On The Way':
        return Colors.purple[100]!;
      default:
        return Colors.grey[200]!;
    }
  }

  Widget _buildActionButtons(
    BuildContext context,
    AppLocalizations l10n,
    String docId,
    String status,
    String userId,
    String category,
  ) {
    // 1. PENDING
    if (status == 'Pending') {
      return Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          OutlinedButton(
            onPressed: () => _updateStatus(docId, 'Rejected'),
            child: Text(
              l10n.btnReject,
              style: const TextStyle(color: Colors.red),
            ), // Localized
          ),
          const SizedBox(width: 10),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            onPressed: () => _updateStatus(docId, 'Accepted'),
            child: Text(l10n.btnAccept), // Localized
          ),
        ],
      );
    }

    // 2. ACCEPTED
    if (status == 'Accepted') {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          icon: const Icon(Icons.local_shipping),
          label: Text(l10n.btnStartPickup), // Localized
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
          ),
          onPressed: () => _updateStatus(docId, 'On The Way'),
        ),
      );
    }

    // 3. ON THE WAY
    if (status == 'On The Way') {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          icon: const Icon(Icons.check_circle),
          label: Text(l10n.btnCompleteReward), // Localized
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
          ),
          onPressed: () => _completeJob(context, l10n, docId, userId, category),
        ),
      );
    }

    return const SizedBox();
  }

  // --- LOGIC: UPDATE STATUS ---
  Future<void> _updateStatus(String docId, String newStatus) async {
    await FirebaseFirestore.instance
        .collection('pickup_requests')
        .doc(docId)
        .update({'status': newStatus});
  }

  // --- LOGIC: COMPLETE & REWARD ---
  Future<void> _completeJob(
    BuildContext context,
    AppLocalizations l10n,
    String docId,
    String userId,
    String category,
  ) async {
    int pointsAwarded = 500;
    final db = FirebaseFirestore.instance;

    try {
      await db.runTransaction((transaction) async {
        DocumentReference requestRef = db
            .collection('pickup_requests')
            .doc(docId);
        DocumentReference userRef = db.collection('users').doc(userId);

        transaction.update(requestRef, {'status': 'Completed'});

        DocumentSnapshot userSnapshot = await transaction.get(userRef);
        int currentPoints =
            (userSnapshot.data() as Map<String, dynamic>)['points'] ?? 0;
        transaction.update(userRef, {'points': currentPoints + pointsAwarded});

        DocumentReference mailRef = db.collection('mail').doc();
        transaction.set(mailRef, {
          'to': (userSnapshot.data() as Map<String, dynamic>)['email'],
          'message': {
            'subject': l10n.emailSubjectComplete, // Localized Subject
            'html': l10n.emailBodyComplete(
              pointsAwarded,
            ), // Localized HTML Body with Argument
          },
        });
      });

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.msgJobCompleted)), // Localized
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.errStatusUpdate(e.toString())),
          ), // Localized Error
        );
      }
    }
  }
}
