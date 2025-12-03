import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

// =============================================================================
// TAB 1: REAL-TIME TRACKING
// Listen to 'pickup_requests' for the current user
// =============================================================================
class TrackingTab extends StatelessWidget {
  const TrackingTab({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Center(child: Text("Please login to track orders"));
    }

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('pickup_requests')
          .where('userId', isEqualTo: user.uid)
          .orderBy('createdAt', descending: true) // Newest first
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        var docs = snapshot.data!.docs;

        if (docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.local_shipping_outlined,
                  size: 60,
                  color: Colors.grey[300],
                ),
                const SizedBox(height: 10),
                const Text(
                  "No active pickups",
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            var data = docs[index].data() as Map<String, dynamic>;
            return _buildTrackingCard(context, data);
          },
        );
      },
    );
  }

  Widget _buildTrackingCard(BuildContext context, Map<String, dynamic> data) {
    String status = data['status'] ?? 'Pending';
    String category = data['category'] ?? 'Unknown';
    String timeSlot = data['timeSlot'] ?? '';

    // Determine Color based on Status
    Color statusColor;
    double progress;
    String statusMsg;

    switch (status) {
      case 'Accepted':
        statusColor = Colors.blue;
        progress = 0.3;
        statusMsg = "Facility accepted request";
        break;
      case 'On The Way':
        statusColor = Colors.orange;
        progress = 0.7;
        statusMsg = "Driver is en route";
        break;
      case 'Completed':
        statusColor = Colors.green;
        progress = 1.0;
        statusMsg = "Pickup successful";
        break;
      case 'Rejected':
        statusColor = Colors.red;
        progress = 0.0;
        statusMsg = "Request declined";
        break;
      default: // Pending
        statusColor = Colors.grey;
        progress = 0.1;
        statusMsg = "Waiting for approval...";
    }

    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(Icons.recycling, color: statusColor),
                const SizedBox(width: 10),
                Text(
                  category,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const Spacer(),
                Chip(
                  label: Text(
                    status,
                    style: const TextStyle(color: Colors.white, fontSize: 10),
                  ),
                  backgroundColor: statusColor,
                  padding: EdgeInsets.zero,
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Progress Bar
            LinearProgressIndicator(
              value: progress,
              color: statusColor,
              backgroundColor: Colors.grey[200],
            ),
            const SizedBox(height: 8),

            // Details
            Text(
              statusMsg,
              style: TextStyle(color: statusColor, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              "Scheduled: $timeSlot",
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
            Text(
              "Facility: ${data['facilityName'] ?? 'Unknown'}",
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// TAB 2: ENVIRONMENTAL NEWS
// Static list for now, but structured for easy API replacement
// =============================================================================
class NewsTab extends StatelessWidget {
  const NewsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          "Latest Updates",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        const SizedBox(height: 10),

        _buildNewsItem(
          "Malaysia's Plastic Ban 2025",
          "Government announces stricter policies on single-use plastics starting next year.",
          "assets/news_plastic.jpg", // You can use network images here later
          Colors.orange[100]!,
          Icons.warning_amber_rounded,
        ),
        _buildNewsItem(
          "Recycling Rates Hit New High",
          "Penang records 45% recycling rate, leading the nation in green initiatives.",
          "assets/news_chart.jpg",
          Colors.green[100]!,
          Icons.trending_up,
        ),
        _buildNewsItem(
          "E-Waste Collection Drive",
          "Bring your old phones and laptops to the City Hall this weekend for safe disposal.",
          "assets/news_ewaste.jpg",
          Colors.blue[100]!,
          Icons.phone_android,
        ),
        _buildNewsItem(
          "Composting 101",
          "How to turn your kitchen scraps into gold for your garden. A beginner's guide.",
          "assets/news_compost.jpg",
          Colors.brown[100]!,
          Icons.grass,
        ),
      ],
    );
  }

  Widget _buildNewsItem(
    String title,
    String summary,
    String imgPath,
    Color bgColor,
    IconData icon,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias, // Clips content to rounded corners
      child: InkWell(
        onTap: () {
          // Future: Open webview or detailed page
        },
        child: Row(
          children: [
            // Left Image/Icon Area
            Container(
              width: 100,
              height: 100,
              color: bgColor,
              child: Center(child: Icon(icon, size: 40, color: Colors.black54)),
            ),

            // Right Text Area
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      summary,
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
