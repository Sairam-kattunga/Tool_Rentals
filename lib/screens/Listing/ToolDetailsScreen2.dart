import 'package:flutter/material.dart';
import 'SelectAddressScreen3.dart'; // Import the next screen
import 'package:tool_rental_app/widgets/animated_button.dart';
import 'package:flutter/services.dart';

class ToolDetailsScreen extends StatefulWidget {
  final String selectedCategory;

  const ToolDetailsScreen({super.key, required this.selectedCategory});

  @override
  State<ToolDetailsScreen> createState() => _ToolDetailsScreenState();
}

class _ToolDetailsScreenState extends State<ToolDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  final _priceController = TextEditingController();
  final _advanceController = TextEditingController(); // New controller for advance amount
  bool _isAvailable = true;

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _priceController.dispose();
    _advanceController.dispose(); // Dispose the new controller
    super.dispose();
  }

  void _navigateToNextStep() {
    if (_formKey.currentState!.validate()) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => SelectAddressScreen(
            toolData: {
              "name": _nameController.text.trim(),
              "description": _descController.text.trim(),
              "pricePerDay": double.parse(_priceController.text.trim()),
              "advanceAmount": double.parse(_advanceController.text.trim()), // Pass the new data
              "category": widget.selectedCategory,
              "available": _isAvailable,
            },
          ),
        ),
      );
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("List a Tool", style: TextStyle(color: Colors.white)), // Changed title to reflect purpose
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
              crossAxisAlignment: CrossAxisAlignment.stretch, // Stretch children to fill available width
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
                const SizedBox(height: 40),
                AnimatedButton(
                  text: "Next",
                  onTap: _navigateToNextStep,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}