import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';

class AddFacilityPage extends StatefulWidget {
  const AddFacilityPage({super.key});

  @override
  State<AddFacilityPage> createState() => _AddFacilityPageState();
}

class _AddFacilityPageState extends State<AddFacilityPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _latCtrl = TextEditingController();
  final _lngCtrl = TextEditingController();

  // Multi-Select logic for accepted items
  final List<String> _allCategories = [
    'Plastic',
    'Metal',
    'Glass',
    'Paper',
    'Electronics',
  ];
  final Map<String, bool> _selectedCategories = {};

  @override
  void initState() {
    super.initState();
    for (var cat in _allCategories) {
      _selectedCategories[cat] = false;
    }
  }

  Future<void> _getCurrentLocation() async {
    Position pos = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    setState(() {
      _latCtrl.text = pos.latitude.toString();
      _lngCtrl.text = pos.longitude.toString();
    });
  }

  void _saveFacility() async {
    if (!_formKey.currentState!.validate()) return;

    // Get list of selected strings
    List<String> accepts = _selectedCategories.entries
        .where((entry) => entry.value)
        .map((entry) => entry.key)
        .toList();

    await FirebaseFirestore.instance.collection('facilities').add({
      'name': _nameCtrl.text,
      'address': _addressCtrl.text,
      'latitude': double.parse(_latCtrl.text),
      'longitude': double.parse(_lngCtrl.text),
      'accepts': accepts,
    });

    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Facility Added!")));
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add Facility")),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nameCtrl,
              decoration: const InputDecoration(
                labelText: "Facility Name",
                border: OutlineInputBorder(),
              ),
              validator: (v) => v!.isEmpty ? "Required" : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _addressCtrl,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: "Full Address",
                border: OutlineInputBorder(),
              ),
              validator: (v) => v!.isEmpty ? "Required" : null,
            ),
            const SizedBox(height: 20),

            // --- GPS SECTION ---
            const Text(
              "Location Coordinates",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _latCtrl,
                    decoration: const InputDecoration(
                      labelText: "Latitude",
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextFormField(
                    controller: _lngCtrl,
                    decoration: const InputDecoration(
                      labelText: "Longitude",
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: _getCurrentLocation,
              icon: const Icon(Icons.my_location),
              label: const Text("Use Current Location"),
            ),

            const SizedBox(height: 20),
            // --- CATEGORIES SECTION ---
            const Text(
              "Accepts Categories:",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            ..._allCategories.map((cat) {
              return CheckboxListTile(
                title: Text(cat),
                value: _selectedCategories[cat],
                onChanged: (val) =>
                    setState(() => _selectedCategories[cat] = val!),
              );
            }),

            const SizedBox(height: 30),
            SizedBox(
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
                onPressed: _saveFacility,
                child: const Text("Save to Database"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
