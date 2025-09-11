import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../widgets/animated_button.dart';

class ListToolScreen extends StatefulWidget {
  const ListToolScreen({super.key});

  @override
  State<ListToolScreen> createState() => _ListToolScreenState();
}

class _ListToolScreenState extends State<ListToolScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();

  String? _selectedCategory;
  bool _isAvailable = true;
  bool _isLoading = false;

  final List<String> categories = [
    "Accommodation & Spaces",
    "Audio & Video Equipment",
    "Automobiles & Vehicles",
    "Books",
    "Catering & Wedding Supplies",
    "Computers & Accessories",
    "Construction Equipment",
    "Electronics & Gadgets",
    "Engineering Machinery / Heavy Equipment",
    "Events & Party Supplies",
    "Farm & Agricultural Equipment",
    "Fitness & Sports Equipment",
    "Fishing Gear & Nets",
    "Fly & Floats (Boats, Water Sports Gear)",
    "Furniture & Decor",
    "Garden Tools & Outdoor Equipment",
    "Generators & Power Equipment",
    "Heavy Vehicles & Earthmovers",
    "Home Appliances & Utilities",
    "Lifestyle Products",
    "Medical Equipment & Services",
    "Mobile Phones & Tablets",
    "Musical Instruments",
    "Office Equipment & Supplies",
    "Outdoor Camping Gear",
    "Pets & Plants",
    "Security & Safety Equipment",
    "Other Products"
  ];

  Future<void> _saveTool() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception("User not logged in");

      final docRef = FirebaseFirestore.instance.collection("tools").doc();

      await docRef.set({
        "ownerId": user.uid,
        "name": _nameController.text.trim(),
        "description": _descController.text.trim(),
        "pricePerDay": double.parse(_priceController.text.trim()),
        "category": _selectedCategory ?? "Other Products",
        "available": _isAvailable,
        "city": _cityController.text.trim(),
        "location": _locationController.text.trim(),
        "createdAt": FieldValue.serverTimestamp(),
      });

      setState(() => _isLoading = false);
      _showSuccessDialog();
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${e.toString()}")),
      );
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF203a43),
        title: const Text(
          "Success",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: const Text(
          "Your tool has been listed successfully!",
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.pushReplacementNamed(context, '/home');
            },
            child: const Text("OK", style: TextStyle(color: Colors.greenAccent)),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _priceController.dispose();
    _cityController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushReplacementNamed(context, '/home');
        return false;
      },
      child: Scaffold(
        // Remove extendBodyBehindAppBar
        appBar: AppBar(
          title: const Text("List a Tool", style: TextStyle(color: Colors.white)),
          backgroundColor: const Color(0xFF203a43), // Add a solid background color
          elevation: 0,
          centerTitle: true,
          iconTheme: const IconThemeData(color: Colors.white),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pushReplacementNamed(context, '/home'),
          ),
        ),
        body: Stack(
          children: [
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF0f2027), Color(0xFF203a43), Color(0xFF2c5364)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
            SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0), // Reduced top padding
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Your next rental starts here",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Fill out the form to list your tool for rent.",
                      style: TextStyle(
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
                      controller: _cityController,
                      label: "City",
                      validator: (val) => val == null || val.isEmpty ? "Please enter a city" : null,
                    ),
                    const SizedBox(height: 24),

                    _buildTextField(
                      controller: _locationController,
                      label: "Location (Google Maps Link)",
                      validator: (val) => val == null || val.isEmpty ? "Please enter a location link" : null,
                    ),
                    const SizedBox(height: 24),

                    _buildDropdownField(),
                    const SizedBox(height: 24),

                    _buildAvailabilitySwitch(),
                    const SizedBox(height: 40),

                    _isLoading
                        ? const Center(child: CircularProgressIndicator(color: Colors.white))
                        : AnimatedButton(
                      text: "List Tool",
                      onTap: _saveTool,
                    ),
                    const SizedBox(height: 20),
                  ],
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

  Widget _buildDropdownField() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          value: _selectedCategory,
          hint: const Text("Select Category", style: TextStyle(color: Colors.white70)),
          style: const TextStyle(color: Colors.white, fontSize: 16),
          icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
          dropdownColor: const Color(0xFF203a43),
          items: categories.map((c) {
            return DropdownMenuItem(
              value: c,
              child: Text(c, style: const TextStyle(color: Colors.white)),
            );
          }).toList(),
          onChanged: (val) {
            setState(() {
              _selectedCategory = val;
            });
          },
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
}