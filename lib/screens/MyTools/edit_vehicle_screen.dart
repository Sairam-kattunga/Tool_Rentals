// file: lib/screens/MyListings/edit_vehicle_screen.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tool_rental_app/constants/vehicle.dart';
import 'package:tool_rental_app/screens/Profile/AddressesScreen.dart';

class EditVehicleScreen extends StatefulWidget {
  final String docId;
  final Map<String, dynamic> initialData;

  const EditVehicleScreen({
    super.key,
    required this.docId,
    required this.initialData,
  });

  @override
  State<EditVehicleScreen> createState() => _EditVehicleScreenState();
}

class _EditVehicleScreenState extends State<EditVehicleScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _makeController;
  late final TextEditingController _modelController;
  late final TextEditingController _yearController;
  late final TextEditingController _licensePlateController;
  late final TextEditingController _mileageController;
  late final TextEditingController _rentController;
  late final TextEditingController _advanceController;
  late final TextEditingController _descriptionController;

  late bool _isAvailable;
  late bool _requiresLicense;
  String? _selectedAddressId;
  String? _selectedAddressText;

  @override
  void initState() {
    super.initState();
    _makeController = TextEditingController(text: widget.initialData['make'] ?? '');
    _modelController = TextEditingController(text: widget.initialData['model'] ?? '');
    _yearController = TextEditingController(text: widget.initialData['year']?.toString() ?? '');
    _licensePlateController = TextEditingController(text: widget.initialData['licensePlate'] ?? '');
    _mileageController = TextEditingController(text: widget.initialData['mileage']?.toString() ?? '');
    _rentController = TextEditingController(text: widget.initialData['rentPerDay']?.toString() ?? '');
    _advanceController = TextEditingController(text: widget.initialData['advanceAmount']?.toString() ?? '');
    _descriptionController = TextEditingController(text: widget.initialData['description'] ?? '');

    _isAvailable = widget.initialData['isAvailable'] ?? true;
    _requiresLicense = widget.initialData['requiresLicense'] ?? true;
    _selectedAddressId = widget.initialData['addressId'];
    _selectedAddressText = widget.initialData['address'];
  }

  @override
  void dispose() {
    _makeController.dispose();
    _modelController.dispose();
    _yearController.dispose();
    _licensePlateController.dispose();
    _mileageController.dispose();
    _rentController.dispose();
    _advanceController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _updateVehicleInFirebase() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedAddressId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a saved address.')),
        );
        return;
      }

      try {
        await FirebaseFirestore.instance.collection('vehicles').doc(widget.docId).update({
          'make': _makeController.text,
          'model': _modelController.text,
          'year': int.tryParse(_yearController.text),
          'licensePlate': _licensePlateController.text,
          'mileage': int.tryParse(_mileageController.text),
          'rentPerDay': double.tryParse(_rentController.text),
          'advanceAmount': double.tryParse(_advanceController.text),
          'description': _descriptionController.text,
          'isAvailable': _isAvailable,
          'requiresLicense': _requiresLicense,
          'address': _selectedAddressText!,
          'addressId': _selectedAddressId!,
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Vehicle updated successfully!')),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to update vehicle: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text("Error")),
        body: const Center(child: Text('You must be logged in to edit a vehicle.')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Edit Vehicle",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF203a43),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0f2027), Color(0xFF203a43), Color(0xFF2c5364)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: ListView(
                    children: <Widget>[
                      _buildSectionTitle('Vehicle Details'),
                      _buildTextField(
                        controller: _makeController,
                        labelText: 'Make',
                        validator: (value) => value!.isEmpty ? 'Please enter the make' : null,
                      ),
                      _buildTextField(
                        controller: _modelController,
                        labelText: 'Model',
                        validator: (value) => value!.isEmpty ? 'Please enter the model' : null,
                      ),
                      _buildTextField(
                        controller: _yearController,
                        labelText: 'Year',
                        keyboardType: TextInputType.number,
                        validator: (value) => value!.isEmpty || int.tryParse(value) == null ? 'Enter a valid year' : null,
                      ),
                      _buildTextField(
                        controller: _licensePlateController,
                        labelText: 'License Plate Number',
                        validator: (value) => value!.isEmpty ? 'Please enter the license plate' : null,
                      ),
                      _buildTextField(
                        controller: _mileageController,
                        labelText: 'Mileage (km)',
                        keyboardType: TextInputType.number,
                        validator: (value) => value!.isEmpty || int.tryParse(value) == null ? 'Enter a valid mileage' : null,
                      ),
                      _buildTextField(
                        controller: _descriptionController,
                        labelText: 'Description',
                        maxLines: 3,
                        validator: (value) => value!.isEmpty ? 'Please enter a description' : null,
                      ),
                      const SizedBox(height: 20),
                      _buildSectionTitle('Rental Information'),
                      _buildTextField(
                        controller: _rentController,
                        labelText: 'Rent per Day (₹)',
                        keyboardType: TextInputType.number,
                        validator: (value) => value!.isEmpty || double.tryParse(value) == null ? 'Enter a valid price' : null,
                      ),
                      _buildTextField(
                        controller: _advanceController,
                        labelText: 'Advance Amount (₹)',
                        keyboardType: TextInputType.number,
                        validator: (value) => value!.isEmpty || double.tryParse(value) == null ? 'Enter a valid amount' : null,
                      ),
                      _buildSwitchListTile('Available for Rent', _isAvailable, (value) => setState(() => _isAvailable = value)),
                      _buildSwitchListTile('Requires Driving License', _requiresLicense, (value) => setState(() => _requiresLicense = value)),
                      const SizedBox(height: 20),
                      _buildSectionTitle('Vehicle Address'),
                      _buildAddressSelection(user.uid),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: _updateVehicleInFirebase,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: const Color(0xFF38ef7d),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text(
                  'Save Changes',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: labelText,
          labelStyle: const TextStyle(color: Colors.white70),
          enabledBorder: OutlineInputBorder(borderSide: const BorderSide(color: Colors.white38), borderRadius: BorderRadius.circular(12)),
          focusedBorder: OutlineInputBorder(borderSide: const BorderSide(color: Colors.white), borderRadius: BorderRadius.circular(12)),
          errorBorder: OutlineInputBorder(borderSide: const BorderSide(color: Colors.redAccent), borderRadius: BorderRadius.circular(12)),
          focusedErrorBorder: OutlineInputBorder(borderSide: const BorderSide(color: Colors.red), borderRadius: BorderRadius.circular(12)),
        ),
        validator: validator,
      ),
    );
  }

  Widget _buildSwitchListTile(String title, bool value, ValueChanged<bool> onChanged) {
    return SwitchListTile(
      title: Text(title, style: const TextStyle(color: Colors.white, fontSize: 16)),
      value: value,
      onChanged: onChanged,
      activeColor: const Color(0xFF38ef7d),
      inactiveTrackColor: Colors.white24,
      contentPadding: EdgeInsets.zero,
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildAddressSelection(String userId) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_selectedAddressText != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Text(
              "Selected: $_selectedAddressText",
              style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('userAddresses')
              .where('ownerId', isEqualTo: userId)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: Colors.greenAccent));
            }
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.white70)));
            }
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return Column(
                children: [
                  const Text('No addresses found. Please add one.', style: TextStyle(color: Colors.white70)),
                  TextButton.icon(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const AddressesScreen()));
                    },
                    icon: const Icon(Icons.add, color: Colors.greenAccent),
                    label: const Text('Add Address', style: TextStyle(color: Colors.greenAccent)),
                  ),
                ],
              );
            }

            final addresses = snapshot.data!.docs;

            return DropdownButtonFormField<String>(
              dropdownColor: const Color(0xFF2c5364),
              decoration: InputDecoration(
                labelText: 'Select from Saved Addresses',
                labelStyle: const TextStyle(color: Colors.white70),
                enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.white38),
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.white),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              value: _selectedAddressId,
              style: const TextStyle(color: Colors.white),
              onChanged: (String? newAddressId) {
                if (newAddressId != null) {
                  final selectedDoc = addresses.firstWhere((doc) => doc.id == newAddressId);
                  final data = selectedDoc.data() as Map<String, dynamic>;
                  setState(() {
                    _selectedAddressId = newAddressId;
                    _selectedAddressText = '${data['street']}, ${data['city']}, ${data['state']} - ${data['postalCode']}';
                  });
                }
              },
              items: addresses.map((DocumentSnapshot doc) {
                final addressData = doc.data() as Map<String, dynamic>;
                final addressText = '${addressData['street']}, ${addressData['city']}, ${addressData['state']} - ${addressData['postalCode']}';
                return DropdownMenuItem<String>(
                  value: doc.id,
                  child: Text(addressText, overflow: TextOverflow.ellipsis),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }
}