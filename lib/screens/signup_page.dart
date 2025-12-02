import 'package:flutter/material.dart';
import 'package:greenmalaysia/l10n/app_localizations.dart';
import 'otp_page.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _emailController = TextEditingController();
  bool _agreedToEula = false;

  void _showEulaDialog() {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.eulaDialogTitle), // Localized
        content: SingleChildScrollView(
          child: Text(l10n.eulaDialogContent), // Localized
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.close), // Localized
          ),
        ],
      ),
    );
  }

  void _goToOtp() {
    final l10n = AppLocalizations.of(context)!;

    if (!_agreedToEula) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.eulaError)));
      return;
    }
    if (_emailController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.emailRequired)));
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (c) => OtpPage(email: _emailController.text)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.createAccount)), // Localized
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              TextField(
                decoration: InputDecoration(
                  labelText: l10n.fullName,
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
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
                        l10n.agreeEula, // Localized
                        style: const TextStyle(
                          color: Colors.blue,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(l10n.back), // Localized
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
                      child: Text(l10n.continueBtn), // Localized
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
