import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_sign_in/google_sign_in.dart';


class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // CHANGE 1: Use the default constructor.
  // We explicitly ask for 'email' to ensure we get it.
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  Future<void> _ensureInitialized() async {
    await _googleSignIn.initialize(serverClientId: dotenv.env['WEB_ID'] ?? '');
  }

  // 1. Sign Up with Email & Password
  Future<String?> signUp({
    required String email,
    required String password,
    required String fullName,
    required String dob,
  }) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = result.user;

      if (user != null) {
        // Save extra data to Firestore
        await _db.collection('users').doc(user.uid).set({
          'uid': user.uid,
          'fullName': fullName,
          'email': email,
          'dob': dob,
          'createdAt': FieldValue.serverTimestamp(), // Server time is safer
          'role': 'user',
          'points': 0,
        });
        return null; // Success
      }
      return "User creation failed";
    } on FirebaseAuthException catch (e) {
      return e.message;
    } catch (_) {
      return "An unknown error occurred";
    }
  }

  // 2. Login with Email & Password
  Future<String?> signIn(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }

  // 3. Google Sign In (Updated for v7)
  Future<UserCredential?> signInWithGoogle() async {
    try {
      // CHANGE 2: Authenticate instead of signIn
      // This gives us better control and handles cancellations.
      await _ensureInitialized();
      // This now throws an exception if the user cancels, so we are inside a try/catch.
      final GoogleSignInAccount googleUser = await _googleSignIn.authenticate(
        scopeHint: ['email', 'profile'],
      );

      // CHANGE 3: Get Auth Details
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // CHANGE 4: Handle missing accessToken
      // v7 removed accessToken from googleAuth.
      // Fortunately, Firebase only needs the idToken to log you in.
      // We pass null for accessToken.
      final credential = GoogleAuthProvider.credential(
        accessToken: null,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase
      UserCredential userCred = await _auth.signInWithCredential(credential);

      // Save user to Firestore (Same logic as before)
      final userDoc = await _db
          .collection('users')
          .doc(userCred.user!.uid)
          .get();
      if (!userDoc.exists) {
        await _db.collection('users').doc(userCred.user!.uid).set({
          'uid': userCred.user!.uid,
          'fullName': userCred.user!.displayName ?? "New User",
          'email': userCred.user!.email,
          'dob': "Not Set",
          'createdAt': FieldValue.serverTimestamp(),
          'role': 'user',
          'points': 0,
        });
      }

      return userCred;
    } catch (e) {
      print("Google Sign In Error: $e");
      // If user cancelled, 'e' will be a specific error, but returning null handles it gracefully for the UI.
      return null;
    }
  }

  // 4. Sign Out
  Future<void> signOut() async {
    try {
      // We wait for both. If google sign out fails, we still want to sign out of Firebase.
      await _googleSignIn.signOut();
      await _auth.signOut();
    } catch (e) {
      print("Error signing out: $e");
    }
  }
}
