import 'package:cloud_firestore/cloud_firestore.dart'; // Needed to fetch role
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:greenmalaysia/l10n/app_localizations.dart';
import 'package:greenmalaysia/app_config.dart'; // Import Config for redirection
import '../homepage.dart';
import 'signup_page.dart';
import '../services/auth_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passController = TextEditingController();
  final AuthService _authService = AuthService();
  bool _isLoading = false;

  // --- HELPER: HANDLE REDIRECT BASED ON ROLE ---
  Future<void> _handleLoginSuccess() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    // 1. Fetch User Role from Firestore
    String role = 'user';
    try {
      var doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      if (doc.exists) {
        role = doc.data()?['role'] ?? 'user';
      }
    } catch (e) {
      print("Error fetching role: $e");
    }

    // 2. Save Login State
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', true);

    if (!mounted) return;

    // 3. Route based on Role & AppConfig
    if (role == 'collector') {
      // Check if this APK has the Collector Dashboard installed
      if (AppConfig().collectorScreenBuilder != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (c) => AppConfig().collectorScreenBuilder!(c),
          ),
        );
      } else {
        // Prevent Drivers from logging into the User App
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Drivers must use the 'GreenMalaysia Driver' app."),
            backgroundColor: Colors.red,
          ),
        );
        await _authService.signOut();
        await prefs.setBool('isLoggedIn', false);
      }
    } else {
      // Admin & Regular Users go to Home
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (c) => const HomePage()),
      );
    }
  }

  void _doLogin() async {
    final l10n = AppLocalizations.of(context)!;

    if (_emailController.text.isEmpty || _passController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.fillAllFieldsError)));
      return;
    }

    setState(() => _isLoading = true);

    String? error = await _authService.signIn(
      _emailController.text.trim(),
      _passController.text.trim(),
    );

    if (mounted) setState(() => _isLoading = false);

    if (error == null) {
      await _handleLoginSuccess(); // Call helper
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _handleGoogleSignIn() async {
    final l10n = AppLocalizations.of(context)!;
    setState(() => _isLoading = true);

    final userCredential = await _authService.signInWithGoogle();

    if (mounted) setState(() => _isLoading = false);

    if (userCredential != null) {
      await _handleLoginSuccess(); // Call helper
    } else {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.googleSignInFailed)));
      }
    }
  }

  void _showForgotPasswordDialog() {
    final l10n = AppLocalizations.of(context)!;
    final TextEditingController resetEmailController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(l10n.resetPasswordTitle),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(l10n.resetPasswordDesc),
              const SizedBox(height: 16),
              TextField(
                controller: resetEmailController,
                decoration: InputDecoration(
                  labelText: l10n.email,
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.email),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(
                l10n.cancel,
                style: const TextStyle(color: Colors.grey),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
              onPressed: () async {
                String email = resetEmailController.text.trim();
                if (email.isEmpty) return;

                Navigator.pop(dialogContext);

                if (!mounted) return;
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(l10n.loading)));

                String? error = await _authService.sendPasswordResetEmail(
                  email,
                );

                if (!mounted) return;

                if (error == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(l10n.resetEmailSent),
                      backgroundColor: Colors.green,
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(error), backgroundColor: Colors.red),
                  );
                }
              },
              child: Text(l10n.sendResetLink),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.eco, size: 80, color: Colors.green),
                      const SizedBox(height: 20),
                      Text(
                        l10n.appName,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 40),

                      TextField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          labelText: l10n.email,
                          border: const OutlineInputBorder(),
                          prefixIcon: const Icon(Icons.email),
                        ),
                      ),
                      const SizedBox(height: 16),

                      TextField(
                        controller: _passController,
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: l10n.password,
                          border: const OutlineInputBorder(),
                          prefixIcon: const Icon(Icons.lock),
                        ),
                      ),

                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: _showForgotPasswordDialog,
                          child: Text(
                            l10n.forgotPassword,
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ),
                      ),

                      const SizedBox(height: 10),

                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                          ),
                          onPressed: _doLogin,
                          child: Text(l10n.loginTitle),
                        ),
                      ),

                      const SizedBox(height: 16),
                      Text(l10n.orText),
                      const SizedBox(height: 16),

                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: OutlinedButton.icon(
                          icon: const FaIcon(
                            FontAwesomeIcons.google,
                            color: Colors.red,
                          ),
                          label: Text(l10n.signInGoogle),
                          onPressed: _handleGoogleSignIn,
                        ),
                      ),

                      const SizedBox(height: 24),

                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (c) => const SignUpPage(),
                            ),
                          );
                        },
                        child: Text(l10n.signUpLink),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
