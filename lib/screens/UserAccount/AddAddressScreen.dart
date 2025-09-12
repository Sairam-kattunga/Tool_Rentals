import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tool_rental_app/widgets/animated_button.dart';

class AddAddressScreen extends StatefulWidget {
  final DocumentSnapshot? addressDoc;

  const AddAddressScreen({super.key, this.addressDoc});

  @override
  State<AddAddressScreen> createState() => _AddAddressScreenState();
}

class _AddAddressScreenState extends State<AddAddressScreen> {
  final _formKey = GlobalKey<FormState>();
  final _addressNameController = TextEditingController();
  final _streetController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _postalCodeController = TextEditingController();
  final _locationController = TextEditingController(); // For Google Maps Link

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // If an addressDoc is passed, populate the form fields
    if (widget.addressDoc != null) {
      final data = widget.addressDoc!.data() as Map<String, dynamic>;
      _addressNameController.text = data['addressName'] ?? '';
      _streetController.text = data['street'] ?? '';
      _cityController.text = data['city'] ?? '';
      _stateController.text = data['state'] ?? '';
      _postalCodeController.text = data['postalCode'] ?? '';
      _locationController.text = data['location'] ?? '';
    }
  }

  Future<void> _saveAddress() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception("User not logged in");
      }

      final addressData = {
        'ownerId': user.uid,
        'addressName': _addressNameController.text.trim(),
        'street': _streetController.text.trim(),
        'city': _cityController.text.trim(),
        'state': _stateController.text.trim(),
        'postalCode': _postalCodeController.text.trim(),
        'location': _locationController.text.trim(),
        'createdAt': FieldValue.serverTimestamp(),
      };

      if (widget.addressDoc == null) {
        // Adding a new address
        await FirebaseFirestore.instance.collection('userAddresses').add(addressData);
      } else {
        // Updating an existing address
        await FirebaseFirestore.instance.collection('userAddresses').doc(widget.addressDoc!.id).update(addressData);
      }

      if (mounted) {
        Navigator.of(context).pop(); // Go back to the addresses list
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Address saved successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error saving address: ${e.toString()}")),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _addressNameController.dispose();
    _streetController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _postalCodeController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  // A reusable text field with the new design
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70, fontWeight: FontWeight.bold),
        filled: true,
        fillColor: Colors.white.withOpacity(0.08),
        contentPadding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.white10),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.greenAccent, width: 2),
        ),
      ),
      validator: validator,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.addressDoc != null;
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Address' : 'Add a New Address', style: const TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF203a43),
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0f2027), Color(0xFF203a43), Color(0xFF2c5364)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: ListView(
                children: [
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _addressNameController,
                    label: 'Address Name (e.g., Home, Office)',
                    validator: (value) => value!.isEmpty ? 'Please enter a name for this address' : null,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _streetController,
                    label: 'Street Address',
                    validator: (value) => value!.isEmpty ? 'Please enter a street address' : null,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _cityController,
                    label: 'City',
                    validator: (value) => value!.isEmpty ? 'Please enter a city' : null,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _stateController,
                    label: 'State',
                    validator: (value) => value!.isEmpty ? 'Please enter a state' : null,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _postalCodeController,
                    label: 'Postal Code',
                    keyboardType: TextInputType.number,
                    validator: (value) => value!.isEmpty ? 'Please enter a postal code' : null,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _locationController,
                    label: 'Google Maps Link',
                    validator: (value) => value!.isEmpty ? 'Please enter a location link' : null,
                  ),
                  const SizedBox(height: 40),
                  _isLoading
                      ? const Center(child: CircularProgressIndicator(color: Colors.greenAccent))
                      : SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _saveAddress,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.greenAccent,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: Text(
                        isEditing ? 'Update Address' : 'Save Address',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}