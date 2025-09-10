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

  String? _selectedCategory;
  bool _isAvailable = true;
  bool _isLoading = false;

  final List<String> categories = [
    "Electrical",
    "Gardening",
    "Construction",
    "Plumbing",
    "Painting",
    "Others"
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
        "category": _selectedCategory ?? "Others",
        "available": _isAvailable,
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
        title: const Text("Success"),
        content: const Text("Your tool has been listed successfully!"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.pushReplacementNamed(context, '/home'); // ✅ Go home after success
            },
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushReplacementNamed(context, '/home'); // ✅ Instead of closing app, go back home
        return false; // Prevents default app close
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text("List a Tool", style: TextStyle(color: Colors.white)),
          backgroundColor: const Color(0xFF203a43),
          elevation: 0,
          centerTitle: true,
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
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 80),
                    const Text(
                      "List your tool for rent",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 30),

                    _buildTextField(
                      controller: _nameController,
                      hint: "Tool Name",
                      validator: (val) => val == null || val.isEmpty ? "Enter tool name" : null,
                    ),
                    const SizedBox(height: 20),

                    _buildTextField(
                      controller: _descController,
                      hint: "Description",
                      maxLines: 3,
                      validator: (val) => val == null || val.isEmpty ? "Enter description" : null,
                    ),
                    const SizedBox(height: 20),

                    _buildTextField(
                      controller: _priceController,
                      hint: "Price per Day",
                      keyboard: TextInputType.number,
                      validator: (val) => val == null || val.isEmpty ? "Enter price" : null,
                    ),
                    const SizedBox(height: 20),

                    _buildDropdownField(),
                    const SizedBox(height: 20),

                    SwitchListTile(
                      title: const Text("Available for Rent", style: TextStyle(color: Colors.white)),
                      value: _isAvailable,
                      onChanged: (val) => setState(() => _isAvailable = val),
                      activeColor: Colors.lightGreenAccent,
                      tileColor: Colors.white.withOpacity(0.1),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    ),
                    const SizedBox(height: 40),

                    _isLoading
                        ? const Center(child: CircularProgressIndicator(color: Colors.white))
                        : AnimatedButton(
                      text: "List Tool",
                      onTap: _saveTool,
                    ),
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
    required String hint,
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
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white70),
        filled: true,
        fillColor: Colors.white.withOpacity(0.1),
        contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildDropdownField() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(30),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          value: _selectedCategory,
          hint: const Text("Select Category", style: TextStyle(color: Colors.white70)),
          style: const TextStyle(color: Colors.white),
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
}
