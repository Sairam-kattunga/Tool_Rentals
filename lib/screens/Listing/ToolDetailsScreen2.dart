import 'package:flutter/material.dart';
import 'package:tool_rental_app/screens/Profile/AddAddressScreen.dart';
import 'package:tool_rental_app/widgets/animated_button.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ToolDetailsScreen extends StatefulWidget {
  final String selectedCategory;

  const ToolDetailsScreen({super.key, required this.selectedCategory});

  @override
  State<ToolDetailsScreen> createState() => _ToolDetailsScreenState();
}

class _ToolDetailsScreenState extends State<ToolDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _auth = FirebaseAuth.instance;
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  final _priceController = TextEditingController();
  final _advanceController = TextEditingController();
  bool _isAvailable = true;

  String? _selectedAddressId;
  Map<String, dynamic>? _selectedAddress;

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _priceController.dispose();
    _advanceController.dispose();
    super.dispose();
  }

  Future<void> _publishTool() async {
    final user = _auth.currentUser;
    if (user == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please log in to list a tool.')),
        );
      }
      return;
    }

    if (_formKey.currentState!.validate()) {
      if (_selectedAddress == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please select a pickup address.')),
          );
        }
        return;
      }

      final toolData = {
        "name": _nameController.text.trim(),
        "description": _descController.text.trim(),
        "pricePerDay": double.parse(_priceController.text.trim()),
        "advanceAmount": double.parse(_advanceController.text.trim()),
        "category": widget.selectedCategory,
        "available": _isAvailable,
        "ownerId": user.uid,
        "address": _selectedAddress,
        "createdAt": FieldValue.serverTimestamp(),
        "ratings": [],
        "ratingCount": 0,
        "averageRating": 0.0,
      };

      try {
        await FirebaseFirestore.instance.collection('tools').add(toolData);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Tool listed successfully!')),
          );
          Navigator.of(context).pop();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error listing tool: $e')),
          );
        }
      }
    }
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? Function(String?)? validator,
    int maxLines = 1,
    TextInputType keyboard = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboard,
      validator: validator,
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
    );
  }

  Widget _buildAvailabilitySwitch() {
    return Card(
      color: Colors.white.withOpacity(0.08),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Colors.white10),
      ),
      child: SwitchListTile(
        title: const Text("Available for Rent", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        value: _isAvailable,
        onChanged: (val) => setState(() => _isAvailable = val),
        activeColor: Colors.lightGreenAccent,
        inactiveThumbColor: Colors.grey,
        inactiveTrackColor: Colors.grey.withOpacity(0.4),
      ),
    );
  }

  Widget _buildAddressDropdown(BuildContext context) {
    final user = _auth.currentUser;
    if (user == null) {
      return const SizedBox.shrink(); // Hide dropdown if user is not logged in
    }

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('userAddresses')
          .where('ownerId', isEqualTo: user.uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: Colors.greenAccent));
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.red)));
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Column(
            children: [
              const SizedBox(height: 24),
              const Text("Pickup Address", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              const Divider(color: Colors.white24),
              TextButton.icon(
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => const AddAddressScreen(),
                  ));
                },
                icon: const Icon(Icons.add_circle, color: Colors.greenAccent),
                label: const Text(
                  "Add a new address to continue.",
                  style: TextStyle(color: Colors.white70),
                ),
              ),
            ],
          );
        }

        final addresses = snapshot.data!.docs;
        return Column(
          children: [
            const SizedBox(height: 24),
            const Text("Pickup Address", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            const Divider(color: Colors.white24),
            DropdownButtonFormField<String>(
              value: _selectedAddressId,
              decoration: InputDecoration(
                labelText: "Select Address",
                labelStyle: const TextStyle(color: Colors.white70),
                filled: true,
                fillColor: Colors.white.withOpacity(0.08),
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
            ),
          ],
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("List a Tool", style: TextStyle(color: Colors.white)),
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  "Enter Tool Information",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(
                        blurRadius: 4.0,
                        color: Colors.black,
                        offset: Offset(2.0, 2.0),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Category: ${widget.selectedCategory}",
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 40),
                _buildTextField(
                  controller: _nameController,
                  label: "Tool Name",
                  validator: (val) => val == null || val.isEmpty ? "Please enter a tool name" : null,
                ),
                const SizedBox(height: 24),
                _buildTextField(
                  controller: _descController,
                  label: "Description",
                  maxLines: 3,
                  validator: (val) => val == null || val.isEmpty ? "Please enter a description" : null,
                ),
                const SizedBox(height: 24),
                _buildTextField(
                  controller: _priceController,
                  label: "Price per Day (₹)",
                  keyboard: TextInputType.number,
                  validator: (val) {
                    if (val == null || val.isEmpty) return "Please enter a price";
                    if (double.tryParse(val) == null) return "Please enter a valid number";
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                _buildTextField(
                  controller: _advanceController,
                  label: "Advance Amount (₹)",
                  keyboard: TextInputType.number,
                  validator: (val) {
                    if (val == null || val.isEmpty) return "Please enter an advance amount";
                    if (double.tryParse(val) == null) return "Please enter a valid number";
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                _buildAvailabilitySwitch(),
                const SizedBox(height: 24),
                _buildAddressDropdown(context),
                const SizedBox(height: 40),
                AnimatedButton(
                  text: "Publish Tool",
                  onTap: _publishTool,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}