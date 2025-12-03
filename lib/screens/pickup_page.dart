import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:greenmalaysia/services/pickup_service.dart';
import 'package:greenmalaysia/services/notification_service.dart'; // Ensure this is imported
import 'package:greenmalaysia/l10n/app_localizations.dart';

class PickupPage extends StatefulWidget {
  const PickupPage({super.key});

  @override
  State<PickupPage> createState() => _PickupPageState();
}

class _PickupPageState extends State<PickupPage> {
  final PickupService _service = PickupService();

  // --- WIZARD STATE ---
  int _currentStep = 1;
  bool _isLoading = false;

  // --- DATA VARIABLES ---
  String? _selectedCategory;
  bool _useProfileAddress = true;
  final TextEditingController _addressController = TextEditingController();
  DateTime? _selectedDate;
  String? _selectedTimeSlot;

  List<Map<String, dynamic>> _foundFacilities = [];
  Map<String, dynamic>? _selectedFacility;

  final List<String> _timeSlots = [
    '8:00 AM - 11:00 AM',
    '11:00 AM - 2:00 PM',
    '2:00 PM - 5:00 PM',
    '5:00 PM - 8:00 PM',
  ];

  @override
  void initState() {
    super.initState();
    _loadUserProfileAddress();
  }

  void _loadUserProfileAddress() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      var doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      if (doc.exists && mounted) {
        setState(() {
          _addressController.text = doc.data()?['pickupAddress'] ?? "";
        });
      }
    }
  }

  // --- LOGIC: GPS & SEARCH ---
  Future<void> _handleStep2Next() async {
    final l10n = AppLocalizations.of(context)!;

    if (_addressController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.errAddressRequired)));
      return;
    }
    if (_selectedDate == null || _selectedTimeSlot == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.errDateTimeRequired)));
      return;
    }

    setState(() {
      _isLoading = true;
      _currentStep = 3;
    });

    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception(l10n.errGpsPermission);
        }
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      var results = await _service.findNearbyFacilities(
        category: _selectedCategory!,
        userLocation: position,
      );

      if (mounted) {
        setState(() {
          _foundFacilities = results;
          _isLoading = false;
        });
        if (results.isEmpty) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(l10n.noFacilitiesFound)));
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _currentStep = 2;
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    }
  }

  // --- LOGIC: SUBMIT ---
  void _submitOrder() async {
    final l10n = AppLocalizations.of(context)!;
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    // 1. SHOW LOADING DIALOG (Blocking)
    // barrierDismissible: false prevents user from clicking outside to close it
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      // 2. Perform Database Operation
      await _service.createOrder(
        userId: user.uid,
        userEmail: user.email!,
        facilityId: _selectedFacility!['id'],
        facilityName: _selectedFacility!['name'],
        category: _selectedCategory!,
        address: _addressController.text,
        date: _selectedDate!,
        timeSlot: _selectedTimeSlot!,
      );

      // 3. Trigger Notification
      await NotificationService().notifyPickupSubmitted(_selectedCategory!);

      // 4. DISMISS LOADING DIALOG
      if (mounted) Navigator.pop(context);

      // 5. Show Success Dialog
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (c) => AlertDialog(
            icon: const Icon(Icons.check_circle, color: Colors.green, size: 60),
            title: Text(l10n.dialogSubmittedTitle),
            content: Text(l10n.dialogSubmittedContent),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(c); // Close Dialog
                  Navigator.pop(context); // Close Page (Return to Home)
                },
                child: Text(l10n.doneBtn),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      // Handle Errors
      if (mounted) Navigator.pop(context); // Close Loading Dialog
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Submission Failed: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.stepProgress(_currentStep, 4)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (_currentStep > 1) {
              setState(() => _currentStep--);
            } else {
              Navigator.pop(context);
            }
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: _buildCurrentStep(l10n),
      ),
    );
  }

  Widget _buildCurrentStep(AppLocalizations l10n) {
    switch (_currentStep) {
      case 1:
        return _step1Category(l10n);
      case 2:
        return _step2Details(l10n);
      case 3:
        return _step3Search(l10n);
      case 4:
        return _step4Confirm(l10n);
      default:
        return const SizedBox();
    }
  }

  // --- STEP 1 ---
  Widget _step1Category(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.titleCategory,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        Text(l10n.subtitleCategory, style: const TextStyle(color: Colors.grey)),
        const SizedBox(height: 20),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: _service.getCategories(),
            builder: (context, snapshot) {
              if (!snapshot.hasData)
                return const Center(child: CircularProgressIndicator());

              var docs = snapshot.data!.docs;
              return ListView.builder(
                itemCount: docs.length,
                itemBuilder: (context, index) {
                  String name = docs[index]['name'];
                  bool isSelected = _selectedCategory == name;
                  return Card(
                    color: isSelected ? Colors.green.shade50 : null,
                    shape: isSelected
                        ? RoundedRectangleBorder(
                            side: const BorderSide(
                              color: Colors.green,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          )
                        : null,
                    child: ListTile(
                      title: Text(
                        name,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      trailing: isSelected
                          ? const Icon(Icons.check_circle, color: Colors.green)
                          : const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () => setState(() => _selectedCategory = name),
                    ),
                  );
                },
              );
            },
          ),
        ),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _selectedCategory == null
                ? null
                : () => setState(() => _currentStep = 2),
            child: Text(l10n.nextBtn),
          ),
        ),
      ],
    );
  }

  // --- STEP 2 ---
  Widget _step2Details(AppLocalizations l10n) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.titleDetails,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),

          Text(
            l10n.labelAddress,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(l10n.useProfileAddress),
            value: _useProfileAddress,
            onChanged: (val) {
              setState(() {
                _useProfileAddress = val;
                if (val)
                  _loadUserProfileAddress();
                else
                  _addressController.clear();
              });
            },
          ),
          TextField(
            controller: _addressController,
            enabled: !_useProfileAddress,
            maxLines: 2,
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              hintText: l10n.hintAddress,
            ),
          ),
          const SizedBox(height: 20),

          Text(
            l10n.labelDate,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 5),
          InkWell(
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: DateTime.now().add(const Duration(days: 1)),
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 30)),
              );
              if (picked != null) setState(() => _selectedDate = picked);
            },
            child: InputDecorator(
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                suffixIcon: Icon(Icons.calendar_today),
              ),
              child: Text(
                _selectedDate == null
                    ? l10n.selectDate
                    : DateFormat('dd/MM/yyyy').format(_selectedDate!),
              ),
            ),
          ),
          const SizedBox(height: 20),

          Text(
            l10n.labelTimeSlot,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 5),
          DropdownButtonFormField<String>(
            value: _selectedTimeSlot,
            items: _timeSlots
                .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                .toList(),
            onChanged: (val) => setState(() => _selectedTimeSlot = val),
            decoration: const InputDecoration(border: OutlineInputBorder()),
          ),

          const SizedBox(height: 40),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _handleStep2Next,
              child: Text(l10n.searchFacilitiesBtn),
            ),
          ),
        ],
      ),
    );
  }

  // --- STEP 3 ---
  Widget _step3Search(AppLocalizations l10n) {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 20),
            Text(l10n.loadingCollectors),
          ],
        ),
      );
    }

    if (_foundFacilities.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.search_off, size: 50, color: Colors.grey),
            Text(l10n.noFacilitiesFound),
            TextButton(
              onPressed: () => setState(() => _currentStep = 2),
              child: Text(l10n.changeAddressBtn),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.titleSelectFacility,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        Text(
          l10n.subtitleSelectFacility,
          style: const TextStyle(color: Colors.grey),
        ),
        const SizedBox(height: 20),
        Expanded(
          child: ListView.separated(
            itemCount: _foundFacilities.length,
            separatorBuilder: (c, i) => const Divider(),
            itemBuilder: (context, index) {
              var fac = _foundFacilities[index];
              bool isSelected = _selectedFacility == fac;
              return ListTile(
                tileColor: isSelected ? Colors.green.withOpacity(0.1) : null,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                leading: const CircleAvatar(child: Icon(Icons.store)),
                title: Text(
                  fac['name'],
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text("${fac['distance']} km • ${fac['address']}"),
                trailing: isSelected
                    ? const Icon(Icons.check_circle, color: Colors.green)
                    : null,
                onTap: () => setState(() => _selectedFacility = fac),
              );
            },
          ),
        ),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _selectedFacility == null
                ? null
                : () => setState(() => _currentStep = 4),
            child: Text(l10n.nextBtn),
          ),
        ),
      ],
    );
  }

  // --- STEP 4 ---
  Widget _step4Confirm(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.titleConfirm,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        Text(l10n.subtitleConfirm, style: const TextStyle(color: Colors.grey)),
        const SizedBox(height: 30),

        _buildSummaryRow(l10n.labelCategory, _selectedCategory!),
        _buildSummaryRow(
          l10n.labelDate,
          DateFormat('dd/MM/yyyy').format(_selectedDate!),
        ),
        _buildSummaryRow(l10n.labelTimeSlot, _selectedTimeSlot!),
        const Divider(),
        _buildSummaryRow(l10n.labelFacility, _selectedFacility!['name']),
        _buildSummaryRow(l10n.labelAddress, _addressController.text),

        const Spacer(),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            onPressed: _submitOrder,
            child: Text(l10n.submitRequestBtn),
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Flexible(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.bold),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}
