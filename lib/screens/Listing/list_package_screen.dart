import 'package:flutter/material.dart';
import 'package:tool_rental_app/widgets/animated_button.dart';
import 'package:tool_rental_app/screens/Listing/select_tools_for_package_screen.dart';

class ListPackageScreen extends StatefulWidget {
  final String selectedCategory;

  const ListPackageScreen({
    super.key,
    required this.selectedCategory,
  });

  @override
  State<ListPackageScreen> createState() => _ListPackageScreenState();
}

class _ListPackageScreenState extends State<ListPackageScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _advanceController = TextEditingController();

  bool _isAvailable = true;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _advanceController.dispose();
    super.dispose();
  }

  void _navigateToSelectTools() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Correct navigation to the tool selection screen
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => SelectToolsForPackageScreen(
          packageName: _nameController.text.trim(),
          packageDescription: _descriptionController.text.trim(),
          packagePrice: double.tryParse(_priceController.text.trim()) ?? 0.0,
          packageAdvance: double.tryParse(_advanceController.text.trim()) ?? 0.0,
          isAvailable: _isAvailable,
          selectedCategory: widget.selectedCategory,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("List a Tool Package", style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF203a43),
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
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
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      "Enter Package Details",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Category: ${widget.selectedCategory}",
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildTextField(
                      controller: _nameController,
                      hint: "Package Name",
                      icon: Icons.inventory_2_outlined,
                    ),
                    const SizedBox(height: 20),
                    _buildTextField(
                      controller: _descriptionController,
                      hint: "Description",
                      icon: Icons.description,
                      maxLines: 3,
                    ),
                    const SizedBox(height: 20),
                    _buildTextField(
                      controller: _priceController,
                      hint: "Price per Day (₹)",
                      icon: Icons.currency_rupee,
                      keyboard: TextInputType.number,
                    ),
                    const SizedBox(height: 20),
                    _buildTextField(
                      controller: _advanceController,
                      hint: "Advance Amount (₹)",
                      icon: Icons.paid_outlined,
                      keyboard: TextInputType.number,
                    ),
                    const SizedBox(height: 30),
                    _buildAvailabilityToggle(),
                    const SizedBox(height: 30),
                    AnimatedButton(
                      text: "Next: Select Tools",
                      onTap: _navigateToSelectTools,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    TextInputType keyboard = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboard,
      style: const TextStyle(color: Colors.white),
      validator: (val) {
        if (val == null || val.isEmpty) {
          return "$hint cannot be empty";
        }
        if (keyboard == TextInputType.number && double.tryParse(val) == null) {
          return "Please enter a valid number";
        }
        return null;
      },
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white70),
        prefixIcon: Icon(icon, color: Colors.white70),
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

  Widget _buildAvailabilityToggle() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          "Available for Rent",
          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Switch.adaptive(
          value: _isAvailable,
          onChanged: (bool value) {
            setState(() {
              _isAvailable = value;
            });
          },
          activeColor: Colors.greenAccent,
          inactiveThumbColor: Colors.grey,
          inactiveTrackColor: Colors.white12,
        ),
      ],
    );
  }
}