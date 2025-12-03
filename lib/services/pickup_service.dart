import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:greenmalaysia/services/settings_service.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/intl.dart';

class PickupService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // 1. Get Categories
  Stream<QuerySnapshot> getCategories() {
    return _db.collection('recycling_categories').snapshots();
  }

  // 2. Find Nearby Facilities (Keeping your working logic)
  Future<List<Map<String, dynamic>>> findNearbyFacilities({
    required String category,
    required Position userLocation,
  }) async {
    final settings = SettingsService();
    double radiusInMeters = settings.navRadius.toDouble();

    QuerySnapshot snapshot = await _db
        .collection('facilities')
        .where('accepts', arrayContains: category)
        .get();

    List<Map<String, dynamic>> validFacilities = [];

    for (var doc in snapshot.docs) {
      var data = doc.data() as Map<String, dynamic>;

      double? lat = (data['latitude'] as num?)?.toDouble();
      double? lng = (data['longitude'] as num?)?.toDouble();

      if (lat == null || lng == null) continue;

      double distanceInMeters = Geolocator.distanceBetween(
        userLocation.latitude,
        userLocation.longitude,
        lat,
        lng,
      );

      if (distanceInMeters <= radiusInMeters) {
        data['id'] = doc.id;
        data['distance'] = (distanceInMeters / 1000).toStringAsFixed(1);
        validFacilities.add(data);
      }
    }

    validFacilities.sort(
      (a, b) =>
          double.parse(a['distance']).compareTo(double.parse(b['distance'])),
    );
    return validFacilities;
  }

  // 3. Submit Order & Send Email (UPDATED)
  Future<void> createOrder({
    required String userId,
    required String userEmail,
    required String facilityId,
    required String facilityName,
    required String category,
    required String address,
    required DateTime date,
    required String timeSlot,
  }) async {
    // A. Save to Firestore
    await _db.collection('pickup_requests').add({
      'userId': userId,
      'facilityId': facilityId,
      'facilityName': facilityName,
      'category': category,
      'pickupAddress': address,
      'scheduledDate': Timestamp.fromDate(date),
      'timeSlot': timeSlot,
      'status': 'Pending',
      'createdAt': FieldValue.serverTimestamp(),
    });

    // B. Send Email via Mailgun (Directly)
    await _sendConfirmationEmail(
      userEmail,
      category,
      facilityName,
      date,
      timeSlot,
    );
  }

  // --- NEW PRIVATE HELPER: Send Email ---
  Future<void> _sendConfirmationEmail(
    String userEmail,
    String category,
    String facilityName,
    DateTime date,
    String timeSlot,
  ) async {
    final String username = dotenv.env['MAILGUN_SMTP_USERNAME'] ?? '';
    final String password = dotenv.env['MAILGUN_SMTP_PASSWORD'] ?? '';

    // --- NEW: Load Template ---
    String htmlContent = await rootBundle.loadString(
      'assets/templates/pickup_email.html',
    );

    // --- NEW: Replace Placeholders ---
    String formattedDate = DateFormat('dd MMM yyyy').format(date);

    htmlContent = htmlContent
        .replaceAll('{{category}}', category)
        .replaceAll('{{facilityName}}', facilityName)
        .replaceAll('{{date}}', formattedDate)
        .replaceAll('{{timeSlot}}', timeSlot);

    final smtpServer = SmtpServer(
      'smtp.mailgun.org',
      username: username,
      password: password,
      port: 587,
    );

    final message = Message()
      ..from = Address(username, 'GreenMalaysia')
      ..recipients.add(userEmail)
      ..subject = 'Pickup Confirmed: $category'
      ..html = htmlContent; // Use the loaded content

    try {
      await send(message, smtpServer);
      print("Confirmation email sent successfully.");
    } catch (e) {
      print("Failed to send email: $e");
    }
  }
}
