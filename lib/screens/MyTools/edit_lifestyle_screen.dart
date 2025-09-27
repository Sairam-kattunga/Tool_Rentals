// lib/screens/MyTools/edit_lifestyle_screen.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tool_rental_app/screens/Profile/AddAddressScreen.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EditLifestyleScreen extends StatefulWidget {
  final String docId;
  final Map<String, dynamic> initialData;

  const EditLifestyleScreen({super.key, required this.docId, required this.initialData});

  @override
  State<EditLifestyleScreen> createState() => _EditLifestyleScreenState();
}

class _EditLifestyleScreenState extends State<EditLifestyleScreen> {
  final _formKey = GlobalKey<FormState>();
  final _auth = FirebaseAuth.instance;

  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _priceController;
  late TextEditingController _brandController;
  late String _selectedCondition;
  late bool _isAvailable;

  String? _selectedAddressId;
  Map<String, dynamic>? _selectedAddress;

  final List<String> _itemConditions = ["Brand new", "Gently used", "Fair", "Used - Poor"];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.initialData['title'] ?? '');
    _descriptionController = TextEditingController(text: widget.initialData['description'] ?? '');
    _priceController = TextEditingController(text: (widget.initialData['price'] ?? 0.0).toString());
    _brandController = TextEditingController(text: widget.initialData['brand'] ?? '');
    _selectedCondition = widget.initialData['condition'] ?? 'Brand new';
    _isAvailable = widget.initialData['isAvailable'] ?? true;

    // Initialize the selected address
    _selectedAddress = widget.initialData['address'] as Map<String, dynamic>?;
    // You might need to find the docId of the address to set the dropdown's initial value.
    // This is a simplified approach, assuming the docId is in the address map itself.
    // A more robust solution might require fetching all addresses and matching the data.
    if (_selectedAddress != null) {
      _selectedAddressId = _selectedAddress!['id'] ?? '';
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _brandController.dispose();
    super.dispose();
  }

  Future<void> _updateListing() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      if (_selectedAddress == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a pickup address.')),
        );
        return;
      }

      final updatedData = {
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim(),
        'price': double.tryParse(_priceController.text.trim()) ?? 0.0,
        'brand': _brandController.text.trim(),
        'condition': _selectedCondition,
        'isAvailable': _isAvailable,
        'address': _selectedAddress,
      };

      try {
        await FirebaseFirestore.instance.collection('lifestyleItems').doc(widget.docId).update(updatedData);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Listing updated successfully!')),
          );
          Navigator.of(context).pop();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error updating listing: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;
    if (user == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("Edit Lifestyle Item", style: TextStyle(color: Colors.white)),
          backgroundColor: const Color(0xFF203a43),
          foregroundColor: Colors.white,
        ),
        body: const Center(child: Text("Please log in to edit a listing.", style: TextStyle(color: Colors.white))),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Lifestyle Item", style: TextStyle(color: Colors.white)),
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTextField(
                  controller: _titleController,
                  labelText: "Item Title",
                  icon: Icons.style,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _descriptionController,
                  labelText: "Description",
                  icon: Icons.description,
                  maxLines: 5,
                ),
                const SizedBox(height: 16),
                _buildDropdownField(
                  labelText: "Condition",
                  items: _itemConditions,
                  selectedValue: _selectedCondition,
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedCondition = newValue!;
                    });
                  },
                  icon: Icons.health_and_safety,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _brandController,
                  labelText: "Brand (Optional)",
                  icon: Icons.diamond,
                  isRequired: false,
                ),
                const SizedBox(height: 24),

                Text("Pricing & Availability", style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
                const Divider(color: Colors.white24, height: 24),
                _buildTextField(
                  controller: _priceController,
                  labelText: "Rental Rate (in ₹)",
                  icon: Icons.currency_rupee,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Rental rate is required';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Please enter a valid number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Available for Rent",
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                    Switch(
                      value: _isAvailable,
                      onChanged: (bool newValue) {
                        setState(() {
                          _isAvailable = newValue;
                        });
                      },
                      activeColor: Colors.greenAccent,
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // NEW: Address selection section
                Text("Pickup Address", style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
                const Divider(color: Colors.white24, height: 24),
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('userAddresses')
                      .where('ownerId', isEqualTo: user.uid)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator(color: Colors.greenAccent));
                    }
                    if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.white)));
                    }
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: TextButton.icon(
                          onPressed: () {
                            Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => const AddAddressScreen(),
                            ));
                          },
                          icon: const Icon(Icons.add_circle, color: Colors.greenAccent),
                          label: const Text(
                            "No addresses found. Add a new address.",
                            style: TextStyle(color: Colors.white70),
                          ),
                        ),
                      );
                    }

                    final addresses = snapshot.data!.docs;
                    return DropdownButtonFormField<String>(
                      value: _selectedAddressId,
                      decoration: InputDecoration(
                        labelText: "Select Address",
                        labelStyle: const TextStyle(color: Colors.white70),
                        prefixIcon: const Icon(Icons.location_on, color: Colors.white70),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.1),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.white10),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.greenAccent, width: 2.0),
                        ),
                      ),
                      dropdownColor: const Color(0xFF203a43),
                      style: const TextStyle(color: Colors.white),
                      icon: const Icon(Icons.arrow_drop_down, color: Colors.white70),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedAddressId = newValue;
                          if (newValue != null) {
                            _selectedAddress = addresses.firstWhere((doc) => doc.id == newValue).data() as Map<String, dynamic>;
                          }
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select an address';
                        }
                        return null;
                      },
                      items: addresses.map<DropdownMenuItem<String>>((DocumentSnapshot doc) {
                        final data = doc.data() as Map<String, dynamic>;
                        return DropdownMenuItem<String>(
                          value: doc.id,
                          child: Text(data['addressName'] ?? 'Unnamed Address', style: const TextStyle(color: Colors.white)),
                        );
                      }).toList(),
                    );
                  },
                ),
                const SizedBox(height: 40),


                Center(
                  child: ElevatedButton(
                    onPressed: _updateListing,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.greenAccent,
                      padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    ),
                    child: const Text("Save Changes", style: TextStyle(fontSize: 18, color: Colors.black, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    required IconData icon,
    bool isRequired = true,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: const TextStyle(color: Colors.white70),
        prefixIcon: Icon(icon, color: Colors.white70),
        filled: true,
        fillColor: Colors.white.withOpacity(0.1),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.white10),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.greenAccent, width: 2.0),
        ),
      ),
      validator: validator ??
              (value) {
            if (isRequired && (value == null || value.isEmpty)) {
              return 'This field is required';
            }
            return null;
          },
    );
  }

  Widget _buildDropdownField({
    required String labelText,
    required List<String> items,
    required String? selectedValue,
    required Function(String?) onChanged,
    required IconData icon,
  }) {
    return DropdownButtonFormField<String>(
      value: selectedValue,
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: const TextStyle(color: Colors.white70),
        prefixIcon: Icon(icon, color: Colors.white70),
        filled: true,
        fillColor: Colors.white.withOpacity(0.1),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.white10),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.greenAccent, width: 2.0),
        ),
      ),
      dropdownColor: const Color(0xFF203a43),
      style: const TextStyle(color: Colors.white),
      icon: const Icon(Icons.arrow_drop_down, color: Colors.white70),
      onChanged: onChanged,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please select an option';
        }
        return null;
      },
      items: items.map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value, style: const TextStyle(color: Colors.white)),
        );
      }).toList(),
    );
  }
}