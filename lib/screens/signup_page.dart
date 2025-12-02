import 'package:flutter/material.dart';
import 'package:greenmalaysia/l10n/app_localizations.dart';
import '../services/auth_service.dart';
import 'otp_page.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _emailController = TextEditingController();
  final _passController = TextEditingController(); // Added Password Controller
  final _nameController = TextEditingController(); // Added Name Controller
  final _dobController = TextEditingController(); // Added DOB Controller

  bool _agreedToEula = false;
  bool _isLoading = false; // To show spinner while checking email

  void _showEulaDialog() {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.eulaDialogTitle),
        content: SingleChildScrollView(child: Text(l10n.eulaDialogContent)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.close),
          ),
        ],
      ),
    );
  }

  void _goToOtp() async {
    final l10n = AppLocalizations.of(context)!;

    // 1. Basic Validation
    if (!_agreedToEula) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.eulaError)));
      return;
    }
    if (_emailController.text.isEmpty ||
        _passController.text.isEmpty ||
        _nameController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.fillAllFieldsError)));
      return;
    }

    // 2. Check if Email Exists (Backend Check)
    setState(() => _isLoading = true); // Start Loading

    // FIX 2: Now calling the imported service
    bool emailTaken = await AuthService().checkEmailExists(
      _emailController.text.trim(),
    );

    setState(() => _isLoading = false); // Stop Loading

    // 3. Handle Result
    if (emailTaken) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Email is already registered. Please Login."),
            backgroundColor: Colors.red,
          ),
        );
      }
      return; // Stop here, do not go to OTP
    }

    // 4. Navigate to OTP Page
    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (c) => OtpPage(
            email: _emailController.text.trim(),
            // --- PASS THE MISSING DATA HERE ---
            password: _passController.text,
            fullName: _nameController.text,
            dob: _dobController.text,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.createAccount)),
      // Added Center + SingleScrollView to fix pixel overflow
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: l10n.fullName,
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              TextField(
                controller: _dobController,
                decoration: InputDecoration(
                  labelText: l10n.birthDate,
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: l10n.email,
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              TextField(
                controller: _passController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: l10n.password,
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),

              Row(
                children: [
                  Checkbox(
                    value: _agreedToEula,
                    onChanged: (v) => setState(() => _agreedToEula = v!),
                  ),
                  Expanded(
                    child: InkWell(
                      onTap: _showEulaDialog,
                      child: Text(
                        l10n.agreeEula,
                        style: const TextStyle(
                          color: Colors.green,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),

              _isLoading
                  ? const CircularProgressIndicator()
                  : Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text(l10n.back),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                            ),
                            onPressed: _goToOtp,
                            child: Text(l10n.continueBtn),
                          ),
                        ),
                      ],
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
