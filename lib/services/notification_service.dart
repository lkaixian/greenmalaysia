import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
          requestSoundPermission: true,
          requestBadgePermission: true,
          requestAlertPermission: true,
        );

    await _notificationsPlugin.initialize(
      InitializationSettings(android: androidSettings, iOS: iosSettings),
    );
  }

  Future<bool> requestPermissions() async {
    bool? isGranted = false;

    if (Platform.isIOS) {
      // iOS Permission Request
      isGranted = await _notificationsPlugin
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >()
          ?.requestPermissions(alert: true, badge: true, sound: true);
    } else if (Platform.isAndroid) {
      // Android 13+ Permission Request
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
          _notificationsPlugin
              .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin
              >();

      isGranted = await androidImplementation?.requestNotificationsPermission();
    }

    return isGranted ?? false;
  }

  NotificationDetails _getChannelDetails(String type) {
    if (type == 'pickup') {
      return const NotificationDetails(
        android: AndroidNotificationDetails(
          'pickup_channel',
          'Pickup Updates',
          importance: Importance.max,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
      );
    } else {
      return const NotificationDetails(
        android: AndroidNotificationDetails(
          'rewards_channel',
          'Rewards & Promos',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
          icon: '@mipmap/ic_launcher',
        ),
      );
    }
  }

  // --- CORE: RAW SHOW + SAVE TO DB ---
  Future<void> _showRaw({
    required int id,
    required String title,
    required String body,
    required String type,
  }) async {
    // 1. Show System Notification (The Pop-up)
    await _notificationsPlugin.show(id, title, body, _getChannelDetails(type));

    // 2. Save to Firestore (The In-App History)
    await _saveToDatabase(title, body, type);
  }

  // --- HELPER: SAVE TO FIRESTORE ---
  Future<void> _saveToDatabase(String title, String body, String type) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final collection = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('notifications');

      // 1. Add the new notification
      await collection.add({
        'title': title,
        'body': body,
        'type': type,
        'isRead': false,
        'timestamp': FieldValue.serverTimestamp(),
      });

      // 2. CLEANUP: Check if we have too many (e.g., keep only latest 10)
      // We get the oldest documents skipping the newest 10
      final oldDocsSnapshot = await collection
          .orderBy('timestamp', descending: true) // Newest first
          .startAt([10]) // Skip the first 10
          .get(); // Get the rest

      // 3. Delete the old ones
      for (var doc in oldDocsSnapshot.docs) {
        await doc.reference.delete();
      }
    }
  }

  // ===========================================================================
  // UNIVERSAL PRESETS (No changes needed here, logic handled above)
  // ===========================================================================

  Future<void> notifyRewardRedeemed(String rewardName) async {
    await _showRaw(
      id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      type: 'reward',
      title: 'Reward Redeemed! 🎉',
      body: 'You have claimed: $rewardName.',
    );
  }

  Future<void> notifyPickupSubmitted(String category) async {
    await _showRaw(
      id: 1001,
      type: 'pickup',
      title: 'Request Submitted 📤',
      body: 'Request for $category sent. Waiting for approval.',
    );
  }

  Future<void> notifyPickupAccepted(String facilityName) async {
    await _showRaw(
      id: 1001,
      type: 'pickup',
      title: 'Pickup Accepted! ✅',
      body: '$facilityName has accepted your request.',
    );
  }

  Future<void> notifyPickupRejected() async {
    await _showRaw(
      id: 1001,
      type: 'pickup',
      title: 'Request Declined ❌',
      body: 'Facility could not accept. Please try another.',
    );
  }

  Future<void> notifyPickupOnTheWay(String driverName) async {
    await _showRaw(
      id: 1001,
      type: 'pickup',
      title: 'Driver on the Way 🚚',
      body: '$driverName is en route.',
    );
  }

  Future<void> notifyPickupCompleted(int pointsEarned) async {
    await _showRaw(
      id: 1001,
      type: 'pickup',
      title: 'Pickup Complete! ♻️',
      body: 'Trash collected. You earned $pointsEarned Points!',
    );
  }
}
