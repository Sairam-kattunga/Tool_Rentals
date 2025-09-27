// file: lib/screens/ListProperty/list_property_form_screen.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tool_rental_app/screens/Profile/AddAddressScreen.dart';

class ListPropertyFormScreen extends StatefulWidget {
  final String category;

  const ListPropertyFormScreen({super.key, required this.category});

  @override
  State<ListPropertyFormScreen> createState() => _ListPropertyFormScreenState();
}

class _ListPropertyFormScreenState extends State<ListPropertyFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _rentController = TextEditingController();
  final _depositController = TextEditingController();
  final _amenitiesController = TextEditingController();
  final _bedroomsController = TextEditingController();
  final _bathroomsController = TextEditingController();
  final _areaController = TextEditingController();

  String? _selectedAddressId;
  Map<String, dynamic>? _selectedAddress;
  bool _isAvailable = true;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _rentController.dispose();
    _depositController.dispose();
    _amenitiesController.dispose();
    _bedroomsController.dispose();
    _bathroomsController.dispose();
    _areaController.dispose();
    super.dispose();
  }

  Future<void> _publishProperty() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedAddress == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a property address.')),
        );
        return;
      }

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final propertyDetails = {
        'category': widget.category,
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim(),
        'rent': double.tryParse(_rentController.text.trim()) ?? 0.0,
        'deposit': double.tryParse(_depositController.text.trim()) ?? 0.0,
        'amenities': _amenitiesController.text.trim().split(',').map((e) => e.trim()).toList(),
        'bedrooms': int.tryParse(_bedroomsController.text.trim()) ?? 0,
        'bathrooms': int.tryParse(_bathroomsController.text.trim()) ?? 0,
        'area': double.tryParse(_areaController.text.trim()) ?? 0.0,
        'address': _selectedAddress,
        'isAvailable': _isAvailable,
        'ownerId': user.uid,
        'createdAt': FieldValue.serverTimestamp(),
        'ratings': [],
        'ratingCount': 0,
        'averageRating': 0.0,
      };

      try {
        await FirebaseFirestore.instance.collection('properties').add(propertyDetails);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Property listed successfully!')),
        );
        Navigator.of(context).pop();
        Navigator.of(context).pop(); // Go back to the main ListingChoiceScreen
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error listing property: $e')),
        );
      }
    }
  }

  void _showConfirmAndPublishDialog() {
    if (_formKey.currentState!.validate()) {
      if (_selectedAddress == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a property address.')),
        );
        return;
      }

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: const Color(0xFF203a43),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text("Confirm Listing", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          content: const Text("Are you sure you want to publish this property for rent?", style: TextStyle(color: Colors.white70)),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Cancel", style: TextStyle(color: Colors.white70)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _publishProperty();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.greenAccent,
                foregroundColor: Colors.black,
              ),
              child: const Text("Publish"),
            ),
          ],
        ),
      );
    }
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

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("List a Property", style: TextStyle(color: Colors.white)),
          backgroundColor: const Color(0xFF203a43),
          foregroundColor: Colors.white,
        ),
        body: const Center(child: Text("Please log in to list a property.", style: TextStyle(color: Colors.white))),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("List a ${widget.category}", style: const TextStyle(color: Colors.white)),
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
                const Center(
                  child: Text(
                    "Step 1 of 1: Property Details & Pricing",
                    style: TextStyle(color: Colors.white54, fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 24),
                // Property Details
                Text("Property Details", style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
                const Divider(color: Colors.white24, height: 24),
                _buildTextField(
                  controller: _titleController,
                  labelText: "Property Title",
                  icon: Icons.title,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _descriptionController,
                  labelText: "Description",
                  icon: Icons.description,
                  maxLines: 5,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _amenitiesController,
                  labelText: "Amenities (comma separated)",
                  icon: Icons.kitchen,
                  isRequired: false,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        controller: _bedroomsController,
                        labelText: "Bedrooms",
                        icon: Icons.king_bed,
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildTextField(
                        controller: _bathroomsController,
                        labelText: "Bathrooms",
                        icon: Icons.shower,
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _areaController,
                  labelText: "Area (in sq. ft.)",
                  icon: Icons.square_foot,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 24),

                // Pricing
                Text("Pricing", style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
                const Divider(color: Colors.white24, height: 24),
                _buildTextField(
                  controller: _rentController,
                  labelText: "Monthly Rent (in INR)",
                  icon: Icons.currency_rupee,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Monthly rent is required';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Please enter a valid number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _depositController,
                  labelText: "Security Deposit (in INR)",
                  icon: Icons.security,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Deposit is required';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Please enter a valid number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // Address Selection
                Text("Property Address", style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
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
                const SizedBox(height: 16),

                // Availability
                Text("Availability", style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
                const Divider(color: Colors.white24, height: 24),
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
                const SizedBox(height: 40),

                // Review Button
                Center(
                  child: ElevatedButton(
                    onPressed: _showConfirmAndPublishDialog,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.greenAccent,
                      padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    ),
                    child: const Text("Publish Property", style: TextStyle(fontSize: 18, color: Colors.black, fontWeight: FontWeight.bold)),
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
}