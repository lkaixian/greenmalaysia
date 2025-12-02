import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For number input formatting
import 'package:intl/intl.dart'; // For Date Formatting (add intl to pubspec if missing)
import 'package:greenmalaysia/l10n/app_localizations.dart';

class PersonalInformationPage extends StatefulWidget {
  const PersonalInformationPage({super.key});

  @override
  State<PersonalInformationPage> createState() =>
      _PersonalInformationPageState();
}

class _PersonalInformationPageState extends State<PersonalInformationPage> {
  // Firebase Instances
  final User? currentUser = FirebaseAuth.instance.currentUser;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Form Controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  // State Variables
  String? _selectedSex;
  DateTime? _selectedDob;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  // --- 1. FETCH DATA FROM FIREBASE ---
  Future<void> _fetchUserData() async {
    if (currentUser == null) return;

    try {
      DocumentSnapshot doc = await _db
          .collection('users')
          .doc(currentUser!.uid)
          .get();

      if (doc.exists && doc.data() != null) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

        setState(() {
          // Name and Email are usually read-only from Auth, but we load from DB if available
          _nameController.text =
              data['fullName'] ?? currentUser!.displayName ?? '';
          _emailController.text = data['email'] ?? currentUser!.email ?? '';

          _phoneController.text = data['phoneNumber'] ?? '';
          _addressController.text = data['pickupAddress'] ?? '';

          _selectedSex = data['sex']; // "Male" or "Female"

          // Handle Date (Firestore stores it as Timestamp)
          if (data['dob'] != null && data['dob'] is Timestamp) {
            _selectedDob = (data['dob'] as Timestamp).toDate();
          } else if (data['dob'] is String) {
            // Fallback if stored as string previously
            // _selectedDob = DateTime.tryParse(data['dob']);
          }
        });
      }
    } catch (e) {
      print("Error fetching user data: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // --- 2. SAVE DATA TO FIREBASE ---
  Future<void> _saveData() async {
    if (currentUser == null) return;

    final l10n = AppLocalizations.of(context)!;
    setState(() => _isLoading = true);

    try {
      await _db.collection('users').doc(currentUser!.uid).update({
        'sex': _selectedSex,
        'dob': _selectedDob != null ? Timestamp.fromDate(_selectedDob!) : null,
        'phoneNumber': _phoneController.text.trim(),
        'pickupAddress': _addressController.text.trim(),
        // We usually don't allow changing Email/Name here directly without re-auth,
        // so we exclude them from the update to be safe.
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.updateSuccess),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("${l10n.updateError}: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // --- HELPER: DATE PICKER ---
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDob ?? DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDob) {
      setState(() {
        _selectedDob = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    // Formatting date for display
    String dobText = l10n.selectDate;
    if (_selectedDob != null) {
      dobText = DateFormat('dd/MM/yyyy').format(_selectedDob!);
    }

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.personalInfoTitle)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(l10n.personalInfoTitle)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- READ ONLY FIELDS ---
            _buildReadOnlyField(
              l10n.fullName,
              _nameController.text,
              Icons.person,
            ),
            const SizedBox(height: 16),
            _buildReadOnlyField(l10n.email, _emailController.text, Icons.email),
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 24),

            // --- EDITABLE FIELDS ---

            // 1. SEX (Dropdown)
            DropdownButtonFormField<String>(
              value: _selectedSex,
              decoration: InputDecoration(
                labelText: l10n.sex,
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.wc),
              ),
              items: [
                DropdownMenuItem(value: 'Male', child: Text(l10n.male)),
                DropdownMenuItem(value: 'Female', child: Text(l10n.female)),
              ],
              onChanged: (val) => setState(() => _selectedSex = val),
            ),
            const SizedBox(height: 16),

            // 2. DOB (Calendar Picker)
            InkWell(
              onTap: () => _selectDate(context),
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: l10n.dob,
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.calendar_today),
                ),
                child: Text(dobText, style: const TextStyle(fontSize: 16)),
              ),
            ),
            const SizedBox(height: 16),

            // 3. PHONE NUMBER (Numbers Only)
            TextFormField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
              ], // Only allow numbers
              decoration: InputDecoration(
                labelText: l10n.phoneNumber,
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.phone),
              ),
            ),
            const SizedBox(height: 16),

            // 4. PICKUP ADDRESS (Text Area)
            TextFormField(
              controller: _addressController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: l10n.pickupAddress,
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.location_on),
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 40),

            // --- SAVE BUTTON ---
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
                onPressed: _saveData,
                child: Text(l10n.saveChanges),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper for Read-Only fields (Greyed out)
  Widget _buildReadOnlyField(String label, String value, IconData icon) {
    return TextFormField(
      initialValue: value,
      readOnly: true,
      enabled: false, // Greys it out
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        prefixIcon: Icon(icon),
        filled: true,
        fillColor: Colors.grey[100],
      ),
    );
  }
}
