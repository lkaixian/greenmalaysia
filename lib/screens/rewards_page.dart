import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:greenmalaysia/l10n/app_localizations.dart';
import 'package:greenmalaysia/services/notification_service.dart';

class RewardsPage extends StatelessWidget {
  const RewardsPage({super.key});

  // Helper to determine membership level (Now Localized)
  String _getMembershipLevel(int points, AppLocalizations l10n) {
    if (points > 5000) return l10n.memberGreenMaster;
    if (points > 2000) return l10n.memberEcoWarrior;
    return l10n.memberGreenStarter;
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final l10n = AppLocalizations.of(context)!; // Initialize L10n

    if (user == null) {
      return Scaffold(body: Center(child: Text(l10n.loginFirst)));
    }

    return Scaffold(
      appBar: AppBar(title: Text(l10n.rewardsTitle)),
      body: StreamBuilder<DocumentSnapshot>(
        // 1. Listen to USER POINTS
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .snapshots(),
        builder: (context, userSnapshot) {
          if (!userSnapshot.hasData)
            return const Center(child: CircularProgressIndicator());

          var userData = userSnapshot.data!.data() as Map<String, dynamic>?;
          int currentPoints = userData?['points'] ?? 0;

          return Column(
            children: [
              // --- TOP SECTION: POINTS ---
              Container(
                padding: const EdgeInsets.all(30),
                width: double.infinity,
                color: Colors.green.withOpacity(0.1),
                child: Column(
                  children: [
                    const Icon(Icons.verified, size: 60, color: Colors.orange),
                    const SizedBox(height: 10),
                    Text(
                      l10n.pointsLabel(currentPoints), // Localized "100 Points"
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    Text(
                      l10n.membershipLabel(
                        _getMembershipLevel(currentPoints, l10n),
                      ), // Localized Level
                      style: const TextStyle(
                        color: Colors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              // --- BOTTOM SECTION: REWARDS LIST ---
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  // 2. Listen to REWARDS collection
                  stream: FirebaseFirestore.instance
                      .collection('rewards')
                      .snapshots(),
                  builder: (context, rewardSnapshot) {
                    if (!rewardSnapshot.hasData)
                      return const Center(child: CircularProgressIndicator());

                    var rewards = rewardSnapshot.data!.docs;

                    if (rewards.isEmpty) {
                      return Center(child: Text(l10n.noRewardsMsg));
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: rewards.length,
                      itemBuilder: (context, index) {
                        var reward =
                            rewards[index].data() as Map<String, dynamic>;
                        String rewardId = rewards[index].id;
                        String title = reward['title'] ?? "Unknown";
                        int cost = reward['cost'] ?? 99999;
                        bool canRedeem = currentPoints >= cost;

                        // FIX: Wrapped Card in Opacity Widget
                        return Opacity(
                          opacity: canRedeem ? 1.0 : 0.5,
                          child: Card(
                            margin: const EdgeInsets.only(bottom: 16),
                            child: ListTile(
                              contentPadding: const EdgeInsets.all(16),
                              title: Text(
                                title,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Text(
                                "${reward['description'] ?? ''}\n${l10n.costPts(cost)}",
                              ),
                              trailing: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: canRedeem
                                      ? Colors.green
                                      : Colors.grey,
                                  foregroundColor: Colors.white,
                                ),
                                onPressed: canRedeem
                                    ? () => _redeemReward(
                                        context,
                                        user,
                                        rewardId,
                                        cost,
                                        title,
                                        l10n,
                                      )
                                    : null,
                                child: Text(l10n.redeemBtn),
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // --- LOGIC: REDEEM REWARD ---
  Future<void> _redeemReward(
    BuildContext context,
    User user,
    String rewardId,
    int cost,
    String rewardTitle,
    AppLocalizations l10n,
  ) async {
    final db = FirebaseFirestore.instance;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (c) => const Center(child: CircularProgressIndicator()),
    );

    try {
      await db.runTransaction((transaction) async {
        // Step 1: Find an available code
        final querySnapshot = await db
            .collection('reward_codes')
            .where('rewardId', isEqualTo: rewardId)
            .where('redeemed', isEqualTo: 0)
            .limit(1)
            .get();

        if (querySnapshot.docs.isEmpty) {
          throw Exception(l10n.errOutOfStock); // Localized Error
        }

        DocumentReference codeRef = querySnapshot.docs.first.reference;
        DocumentReference userRef = db.collection('users').doc(user.uid);
        String actualCode = querySnapshot.docs.first.get('code');

        // Step 2: Safety Check Points
        DocumentSnapshot userSnapshot = await transaction.get(userRef);
        int currentPoints = userSnapshot.get('points') ?? 0;

        if (currentPoints < cost) {
          throw Exception(l10n.errInsufficientPoints); // Localized Error
        }

        // Step 3: Execute Updates
        transaction.update(userRef, {'points': currentPoints - cost});
        transaction.update(codeRef, {'redeemed': 1});

        // Step 4: Trigger Email (Localized Content)
        await NotificationService().notifyRewardRedeemed(rewardTitle);
        DocumentReference mailRef = db.collection('mail').doc();
        transaction.set(mailRef, {
          'to': user.email,
          'message': {
            'subject': l10n
                .emailSubjectReward(rewardTitle)
                .replaceAll(
                  "{rewardTitle}",
                  rewardTitle,
                ), // Ensure string replacement
            // Note: .replaceAll needed because l10n function returns the full string, but Firestore might need raw string manipulation if not using the getter directly.
            // Actually, l10n.emailSubjectReward(rewardTitle) returns the *final* string, so we just pass that.
            // Simplified below:
            'subject': l10n.emailSubjectReward(rewardTitle),
            'html': l10n.emailBodyCongrats(actualCode),
          },
        });
      });

      if (context.mounted) Navigator.pop(context); // Close loading

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.redeemSuccess),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) Navigator.pop(context); // Close loading

      // Extract the message from the Exception object if possible
      String errorMessage = e.toString();
      if (errorMessage.startsWith("Exception: ")) {
        errorMessage = errorMessage.substring(
          11,
        ); // Remove "Exception: " prefix
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.errGeneric(errorMessage)),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
