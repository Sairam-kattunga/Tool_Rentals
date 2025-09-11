import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditToolScreen extends StatefulWidget {
  final String docId;
  final Map<String, dynamic> initialData;

  const EditToolScreen({super.key, required this.docId, required this.initialData});

  @override
  State<EditToolScreen> createState() => _EditToolScreenState();
}

class _EditToolScreenState extends State<EditToolScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _priceController;
  late TextEditingController _cityController; // New controller
  late TextEditingController _locationController; // New controller
  late String _selectedCategory;
  late bool _isAvailable; // New state variable

  final List<String> categories = [
    "Accommodation & Spaces", "Audio & Video Equipment", "Automobiles & Vehicles",
    "Books", "Catering & Wedding Supplies", "Computers & Accessories",
    "Construction Equipment", "Electronics & Gadgets",
    "Engineering Machinery / Heavy Equipment", "Events & Party Supplies",
    "Farm & Agricultural Equipment", "Fitness & Sports Equipment",
    "Fishing Gear & Nets", "Fly & Floats (Boats, Water Sports Gear)",
    "Furniture & Decor", "Garden Tools & Outdoor Equipment",
    "Generators & Power Equipment", "Heavy Vehicles & Earthmovers",
    "Home Appliances & Utilities", "Lifestyle Products",
    "Medical Equipment & Services", "Mobile Phones & Tablets",
    "Musical Instruments", "Office Equipment & Supplies",
    "Outdoor Camping Gear", "Pets & Plants",
    "Security & Safety Equipment", "Other Products"
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialData['name']);
    _descriptionController = TextEditingController(text: widget.initialData['description']);
    _priceController = TextEditingController(text: widget.initialData['pricePerDay']?.toString());
    _cityController = TextEditingController(text: widget.initialData['city']);
    _locationController = TextEditingController(text: widget.initialData['location']);
    _selectedCategory = widget.initialData['category'] ?? categories.first;
    _isAvailable = widget.initialData['available'] ?? false;
  }

  Future<void> _updateTool() async {
    if (_formKey.currentState!.validate()) {
      try {
        await FirebaseFirestore.instance.collection('tools').doc(widget.docId).update({
          'name': _nameController.text,
          'description': _descriptionController.text,
          'pricePerDay': double.tryParse(_priceController.text),
          'city': _cityController.text,
          'location': _locationController.text,
          'category': _selectedCategory,
          'available': _isAvailable,
        });
        if (mounted) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Tool updated successfully!')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error updating tool: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Tool", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // Background Gradient
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
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    // Tool Name
                    _buildTextField(_nameController, 'Tool Name', validator: (value) => value!.isEmpty ? 'Please enter a name' : null),
                    const SizedBox(height: 16),
                    // Description
                    _buildTextField(_descriptionController, 'Description', maxLines: 3),
                    const SizedBox(height: 16),
                    // Price Per Day
                    _buildTextField(_priceController, 'Price Per Day', keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value!.isEmpty) return 'Please enter a price';
                          if (double.tryParse(value) == null) return 'Please enter a valid number';
                          return null;
                        }),
                    const SizedBox(height: 16),
                    // City
                    _buildTextField(_cityController, 'City', validator: (value) => value!.isEmpty ? 'Please enter a city' : null),
                    const SizedBox(height: 16),
                    // Location Link
                    _buildTextField(_locationController, 'Location Link (Google Maps)', validator: (value) => value!.isEmpty ? 'Please enter a location link' : null),
                    const SizedBox(height: 20),
                    // Category Dropdown
                    _buildCategoryDropdown(),
                    const SizedBox(height: 20),
                    // Availability Switch
                    _buildAvailabilitySwitch(),
                    const SizedBox(height: 30),
                    // Save Changes Button
                    _buildSaveButton(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Reusable text field widget
  Widget _buildTextField(TextEditingController controller, String label, {TextInputType keyboardType = TextInputType.text, String? Function(String?)? validator, int maxLines = 1}) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        filled: true,
        fillColor: Colors.white.withOpacity(0.1),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.white24),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.greenAccent),
        ),
      ),
      validator: validator,
    );
  }

  // Widget for the category dropdown
  Widget _buildCategoryDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white24),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedCategory,
          isExpanded: true,
          icon: const Icon(Icons.arrow_drop_down, color: Colors.white70),
          dropdownColor: const Color(0xFF203a43),
          style: const TextStyle(color: Colors.white, fontSize: 16),
          items: categories.map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
          onChanged: (String? newValue) {
            if (newValue != null) {
              setState(() {
                _selectedCategory = newValue;
              });
            }
          },
        ),
      ),
    );
  }

  // Widget for the availability switch
  Widget _buildAvailabilitySwitch() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          "Available",
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
        Switch(
          value: _isAvailable,
          onChanged: (bool newValue) {
            setState(() {
              _isAvailable = newValue;
            });
          },
          activeColor: Colors.lightGreenAccent,
        ),
      ],
    );
  }

  // Widget for the save button
  Widget _buildSaveButton() {
    return ElevatedButton(
      onPressed: _updateTool,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.greenAccent,
        foregroundColor: Colors.black,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: const Text(
        'Save Changes',
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }
}