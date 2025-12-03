import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Required for Date Formatting
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
  final _passController = TextEditingController();
  final _nameController = TextEditingController();
  final _dobController = TextEditingController();

  bool _agreedToEula = false;
  bool _isLoading = false;

  // Password Validation State
  bool _hasMinLength = false;
  bool _hasUppercase = false;
  bool _hasDigits = false;

  @override
  void initState() {
    super.initState();
    // Listen to password changes
    _passController.addListener(_updatePasswordStrength);
  }

  @override
  void dispose() {
    _passController.dispose();
    _emailController.dispose();
    _nameController.dispose();
    _dobController.dispose();
    super.dispose();
  }

  void _updatePasswordStrength() {
    String pass = _passController.text;
    setState(() {
      _hasMinLength = pass.length >= 8;
      _hasUppercase = pass.contains(RegExp(r'[A-Z]'));
      _hasDigits = pass.contains(RegExp(r'[0-9]'));
    });
  }

  // --- DATE PICKER LOGIC ---
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000), // Default to year 2000
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      // Format: dd/MM/yyyy (Standard Malaysian format)
      _dobController.text = DateFormat('dd/MM/yyyy').format(picked);
    }
  }

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
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.eulaError)));
      return;
    }
    if (_emailController.text.isEmpty ||
        _passController.text.isEmpty ||
        _nameController.text.isEmpty ||
        _dobController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.fillAllFieldsError)));
      return;
    }

    // 2. Password Strength Validation
    if (!_hasMinLength || !_hasUppercase || !_hasDigits) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please meet all password requirements."), backgroundColor: Colors.red),
      );
      return;
    }

    // 3. Backend Email Check
    setState(() => _isLoading = true);
    
    bool emailTaken = await AuthService().checkEmailExists(_emailController.text.trim());

    setState(() => _isLoading = false);

    if (emailTaken) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Email is already registered. Please Login."), backgroundColor: Colors.red),
        );
      }
      return;
    }

    // 4. Navigate
    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (c) => OtpPage(
            email: _emailController.text.trim(),
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
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- FULL NAME ---
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: l10n.fullName,
                  prefixIcon: const Icon(Icons.person),
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              // --- DATE OF BIRTH (Calendar Picker) ---
              TextField(
                controller: _dobController,
                readOnly: true, // Prevent typing
                onTap: () => _selectDate(context),
                decoration: InputDecoration(
                  labelText: l10n.birthDate,
                  prefixIcon: const Icon(Icons.calendar_today),
                  border: const OutlineInputBorder(),
                  suffixIcon: const Icon(Icons.arrow_drop_down),
                ),
              ),
              const SizedBox(height: 16),

              // --- EMAIL ---
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: l10n.email,
                  prefixIcon: const Icon(Icons.email),
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              // --- PASSWORD ---
              TextField(
                controller: _passController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: l10n.password,
                  prefixIcon: const Icon(Icons.lock),
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),

              // --- DYNAMIC PASSWORD REQUIREMENTS ---
              _buildPasswordRequirements(l10n),
              
              const SizedBox(height: 24),

              // --- EULA ---
              Row(
                children: [
                  Checkbox(
                    value: _agreedToEula,
                    activeColor: Colors.green,
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
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),

              // --- BUTTONS ---
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
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

  // --- WIDGET: Password Requirement List ---
  Widget _buildPasswordRequirements(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.passwordReqTitle, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
          const SizedBox(height: 8),
          _buildRequirementRow(l10n.reqMinChars, _hasMinLength),
          _buildRequirementRow(l10n.reqUppercase, _hasUppercase),
          _buildRequirementRow(l10n.reqNumber, _hasDigits),
        ],
      ),
    );
  }

  Widget _buildRequirementRow(String text, bool isMet) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        children: [
          Icon(
            isMet ? Icons.check_circle : Icons.circle_outlined,
            color: isMet ? Colors.green : Colors.grey,
            size: 16,
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              color: isMet ? Colors.green[800] : Colors.grey[600],
              fontSize: 12,
              decoration: isMet ? TextDecoration.lineThrough : null,
            ),
          ),
        ],
      ),
    );
  }
}