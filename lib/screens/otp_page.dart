import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:greenmalaysia/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../homepage.dart';
import '../services/auth_service.dart';

class OtpPage extends StatefulWidget {
  final String email;
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

  String? _generatedOtp;
  int _secondsRemaining = 60;
  bool _canResend = false;
  Timer? _timer;
  bool _isVerifying = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _sendMailgunOTP();
    });
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _sendMailgunOTP() async {
    final l10n = AppLocalizations.of(context)!;
    final rng = Random();
    final code = (rng.nextInt(900000) + 100000).toString();

    setState(() {
      _generatedOtp = code;
    });

    final String username = dotenv.env['MAILGUN_SMTP_USERNAME'] ?? '';
    final String password = dotenv.env['MAILGUN_SMTP_PASSWORD'] ?? '';

    final smtpServer = SmtpServer(
      'smtp.mailgun.org',
      username: username,
      password: password,
      port: 587,
    );

    String htmlContent;
    try {
      htmlContent = await rootBundle.loadString(
        'assets/templates/otp_email.html',
      );
      htmlContent = htmlContent.replaceAll('{{code}}', code);
    } catch (e) {
      print("Error loading HTML template: $e");
      htmlContent = "<h1>Your Code: $code</h1>";
    }

    final message = Message()
      ..from = Address(username, 'GreenMalaysia Security')
      ..recipients.add(widget.email)
      ..subject = 'Your Verification Code'
      ..html = htmlContent;

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

  void _verifyOtp() async {
    final l10n = AppLocalizations.of(context)!;

    if (_generatedOtp != null && _otpController.text == _generatedOtp) {
      setState(() => _isVerifying = true);

      // Create Account via AuthService
      String? error = await AuthService().signUp(
        email: widget.email,
        password: widget.password,
        fullName: widget.fullName,
        dob: widget.dob,
      );

      if (!mounted) return;
      setState(() => _isVerifying = false);

      if (error == null) {
        _showSuccessDialog(l10n);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Registration Failed: $error"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } else {
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
          title: Text(
            l10n.verifiedTitle,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Text(l10n.verifiedMessage, textAlign: TextAlign.center),
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
          title: Text(
            l10n.failedTitle,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Text(l10n.failedMessage, textAlign: TextAlign.center),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Try Again"),
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
      appBar: AppBar(title: Text(l10n.verifyOtp)),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon for visual appeal
              const Icon(Icons.mark_email_read, size: 80, color: Colors.green),
              const SizedBox(height: 20),

              Text(
                l10n.otpSentPrompt(widget.email),
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 30),

              // OTP Input Field
              TextField(
                controller: _otpController,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                maxLength: 6,
                style: const TextStyle(
                  fontSize: 28,
                  letterSpacing: 8,
                  fontWeight: FontWeight.bold,
                ),
                decoration: const InputDecoration(
                  hintText: "000000",
                  counterText: "",
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(vertical: 16),
                ),
              ),
              const SizedBox(height: 20),

              // Timer / Resend Link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (!_canResend)
                    const Icon(Icons.timer, size: 16, color: Colors.grey),
                  const SizedBox(width: 5),
                  Text(
                    _canResend
                        ? l10n.codeExpired
                        : l10n.resendTimer(_secondsRemaining),
                    style: TextStyle(
                      color: _canResend ? Colors.red : Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),

              if (_canResend)
                TextButton(
                  onPressed: () {
                    _sendMailgunOTP();
                    _startTimer();
                  },
                  child: Text(
                    l10n.resendNow,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),

              const SizedBox(height: 40),

              // Action Buttons
              _isVerifying
                  ? const CircularProgressIndicator()
                  : Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 15),
                            ),
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
                              padding: const EdgeInsets.symmetric(vertical: 15),
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
