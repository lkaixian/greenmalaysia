import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  Future<void> _ensureInitialized() async {
    String? clientId = dotenv.env['WEB_ID'];
    if (clientId != null && clientId.isNotEmpty) {
      await _googleSignIn.initialize(serverClientId: clientId);
    }
  }

  // --- CHANGED: Helper to Check if Email Exists (Using Firestore) ---
  Future<bool> checkEmailExists(String email) async {
    try {
      // Query Firestore instead of Auth
      final QuerySnapshot result = await _db
          .collection('users')
          .where('email', isEqualTo: email)
          .limit(1) // We only need to know if 1 exists
          .get();

      // If we found a document, the email exists
      return result.docs.isNotEmpty;
    } catch (e) {
      print("Error checking email: $e");
      return false;
    }
  }

  // 1. Sign Up with Email & Password
  Future<String?> signUp({
    required String email,
    required String password,
    required String fullName,
    required String dob,
  }) async {
    try {
      // Step A: Double check email availability
      // Note: We rely on the UI to call checkEmailExists before this,
      // but this is a final safety net.

      // Step B: Create User in Auth
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = result.user;

      // Step C: Save details to Firestore
      if (user != null) {
        await _db.collection('users').doc(user.uid).set({
          'uid': user.uid,
          'fullName': fullName,
          'email': email,
          'dob': dob,
          'phoneNumber': "",
          'sex': null,
          'pickupAddress': "",
          'createdAt': FieldValue.serverTimestamp(),
          'role': 'user',
          'points': 0,
        });
        return null; // Success
      }
      return "User creation failed";
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        return "The account already exists for that email.";
      }
      return e.message;
    } catch (_) {
      return "An unknown error occurred";
    }
  }

  // 2. Login with Email & Password
  Future<String?> signIn(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return null; // Success
    } on FirebaseAuthException catch (e) {
      print("Firebase Login Error: ${e.code}"); // DEBUG: See the exact code

      if (e.code == 'invalid-credential' ||
          e.code == 'wrong-password' ||
          e.code == 'user-not-found') {
        return "Incorrect Email or Password.";
      }
      if (e.code == 'invalid-email') {
        return "The email address is badly formatted.";
      }
      return e.message; // Return the raw error for other cases
    } catch (e) {
      return "An unknown error occurred.";
    }
  }

  // 3. Google Sign In
  Future<UserCredential?> signInWithGoogle() async {
    try {
      await _ensureInitialized();

      final GoogleSignInAccount? googleUser = await _googleSignIn.authenticate(
        scopeHint: ['email', 'profile'],
      );

      if (googleUser == null) return null; // Cancelled

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: null,
        idToken: googleAuth.idToken,
      );

      UserCredential userCred = await _auth.signInWithCredential(credential);

      // Check if user exists in Firestore
      final userDoc = await _db
          .collection('users')
          .doc(userCred.user!.uid)
          .get();

      if (!userDoc.exists) {
        await _db.collection('users').doc(userCred.user!.uid).set({
          'uid': userCred.user!.uid,
          'fullName': userCred.user!.displayName ?? "New User",
          'email': userCred.user!.email,
          'dob': null,
          'phoneNumber': "",
          'sex': null,
          'pickupAddress': "",
          'createdAt': FieldValue.serverTimestamp(),
          'role': 'user',
          'points': 0,
        });
      }

      return userCred;
    } catch (e) {
      print("Google Sign In Error: $e");
      return null;
    }
  }

  // 4. Sign Out
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _auth.signOut();
    } catch (e) {
      print("Error signing out: $e");
    }
  }

  Future<String?> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return null; // Success (null means no error)
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        return "No user found for that email.";
      }
      return e.message;
    } catch (e) {
      return "An unknown error occurred.";
    }
  }
}
