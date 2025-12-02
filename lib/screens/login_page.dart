import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:greenmalaysia/l10n/app_localizations.dart';
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

  void _doLogin() async {
    final l10n = AppLocalizations.of(context)!;

    // Basic Validation
    if (_emailController.text.isEmpty || _passController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.fillAllFieldsError)));
      return;
    }

    setState(() => _isLoading = true);

    // Call Firebase
    String? error = await _authService.signIn(
      _emailController.text.trim(),
      _passController.text.trim(),
    );

    setState(() => _isLoading = false);

    if (error == null) {
      // Success
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', true);

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (c) => const HomePage()),
        );
      }
    } else {
      // Failure
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error, style: const TextStyle(color: Colors.white)),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _handleGoogleSignIn() async {
    final l10n = AppLocalizations.of(context)!;

    setState(() => _isLoading = true);

    final userCredential = await _authService.signInWithGoogle();

    setState(() => _isLoading = false);

    if (userCredential != null) {
      // Success!
      // Save "isLoggedIn" to SharedPrefs so the app remembers next time
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', true);

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
      }
    } else {
      // Failed or Cancelled
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.googleSignInFailed)));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      // FIX 1: Center + SingleChildScrollView prevents pixel overflow
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
                        keyboardType:
                            TextInputType.emailAddress, // Better keyboard
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
                      const SizedBox(height: 24),

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
