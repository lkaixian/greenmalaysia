import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:greenmalaysia/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../homepage.dart';
import '../services/auth_service.dart'; // REQUIRED: To create account

class OtpPage extends StatefulWidget {
  final String email;
  // --- NEW: Data needed to create the account after verification ---
  final String password;
  final String fullName;
  final String dob;

  const OtpPage({
    super.key,
    required this.email,
    required this.password,
    required this.fullName,
    required this.dob,
  });

  @override
  State<OtpPage> createState() => _OtpPageState();
}

class _OtpPageState extends State<OtpPage> {
  final TextEditingController _otpController = TextEditingController();

  // Local state for OTP logic
  String? _generatedOtp;
  int _secondsRemaining = 60;
  bool _canResend = false;
  Timer? _timer;
  bool _isVerifying = false; // To show loading spinner during Firebase creation

  @override
  void initState() {
    super.initState();
    // Send OTP immediately when page loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _sendMailgunOTP();
    });
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  // --- LOGIC: Send OTP via Mailgun ---
  Future<void> _sendMailgunOTP() async {
    final l10n = AppLocalizations.of(context)!;

    // 1. Generate 6-digit code
    final rng = Random();
    final code = (rng.nextInt(900000) + 100000).toString();

    setState(() {
      _generatedOtp = code;
    });

    // 2. Configure Mailgun
    final String username = dotenv.env['MAILGUN_SMTP_USERNAME'] ?? '';
    final String password = dotenv.env['MAILGUN_SMTP_PASSWORD'] ?? '';

    final smtpServer = SmtpServer(
      'smtp.mailgun.org',
      username: username,
      password: password,
      port: 587,
    );

    // 3. Create Email
    final message = Message()
      ..from = Address(username, 'GreenMalaysia Security')
      ..recipients.add(widget.email)
      ..subject = 'Your Verification Code'
      ..html =
          "<h1>$code</h1>\n<p>Please enter this code to verify your account.</p>";

    try {
      await send(message, smtpServer);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.otpSentSnackbar(widget.email, "*****")),
            backgroundColor: Colors.green,
          ),
        );
      }
    } on MailerException catch (e) {
      print("Mailgun Error: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Failed to send OTP. Check internet."),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _startTimer() {
    setState(() {
      _secondsRemaining = 60;
      _canResend = false;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining == 0) {
        setState(() => _canResend = true);
        timer.cancel();
      } else {
        setState(() => _secondsRemaining--);
      }
    });
  }

  // --- LOGIC: Verify & Create Account ---
  void _verifyOtp() async {
    final l10n = AppLocalizations.of(context)!;

    // 1. Check if Code Matches
    if (_generatedOtp != null && _otpController.text == _generatedOtp) {
      // 2. Start Loading (Creating account in background)
      setState(() => _isVerifying = true);

      // 3. Call Firebase to create User + Database Entry
      String? error = await AuthService().signUp(
        email: widget.email,
        password: widget.password,
        fullName: widget.fullName,
        dob: widget.dob,
      );

      if (!mounted) return;
      setState(() => _isVerifying = false); // Stop loading

      if (error == null) {
        // Success! Account created.
        _showSuccessDialog(l10n);
      } else {
        // Failed (e.g. Weak Password)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Registration Failed: $error"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } else {
      // Wrong Code
      _showFailDialog(l10n);
    }
  }

  void _showSuccessDialog(AppLocalizations l10n) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', true);

    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          icon: const Icon(Icons.check_circle, color: Colors.green, size: 60),
          title: Text(l10n.verifiedTitle),
          content: Text(l10n.verifiedMessage),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (c) => const HomePage()),
                  (route) => false,
                );
              },
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }

  void _showFailDialog(AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          icon: const Icon(Icons.cancel, color: Colors.red, size: 60),
          title: Text(l10n.failedTitle),
          content: Text(l10n.failedMessage),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.verifyOtp)),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                l10n.otpSentPrompt(widget.email),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),

              TextField(
                controller: _otpController,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                maxLength: 6,
                style: const TextStyle(fontSize: 24, letterSpacing: 8),
                decoration: const InputDecoration(
                  hintText: "000000",
                  counterText: "",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),

              Text(
                _canResend
                    ? l10n.codeExpired
                    : l10n.resendTimer(_secondsRemaining),
                style: TextStyle(color: _canResend ? Colors.red : Colors.grey),
              ),

              if (_canResend)
                TextButton(
                  onPressed: () {
                    _sendMailgunOTP();
                    _startTimer();
                  },
                  child: Text(l10n.resendNow),
                ),

              const SizedBox(height: 40),

              // Show Spinner if creating account, else show Buttons
              _isVerifying
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
                            onPressed: _verifyOtp,
                            child: Text(l10n.verifyBtn),
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
