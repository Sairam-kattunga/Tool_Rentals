import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EditExperienceScreen extends StatefulWidget {
  final String docId;
  final Map<String, dynamic> initialData;

  const EditExperienceScreen({
    super.key,
    required this.docId,
    required this.initialData,
  });

  @override
  State<EditExperienceScreen> createState() => _EditExperienceScreenState();
}

class _EditExperienceScreenState extends State<EditExperienceScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _skillsController;
  late final TextEditingController _priceController;
  late final TextEditingController _languagesController;
  late final TextEditingController _addonsController;

  late bool _isAvailable;
  late bool _isResponsible;

  // New fields
  late String _selectedServiceType;
  late String _selectedExperienceLevel;

  final List<String> _serviceTypes = ['In-person', 'Online', 'Hybrid'];
  final List<String> _experienceLevels = ['Beginner', 'Intermediate', 'Expert'];

  @override
  void initState() {
    super.initState();
    // Initialize controllers with initial data
    _titleController = TextEditingController(text: widget.initialData['title']);
    _descriptionController = TextEditingController(text: widget.initialData['description']);
    _skillsController = TextEditingController(text: (widget.initialData['skills'] ?? "").toString());
    _priceController = TextEditingController(text: widget.initialData['price']?.toString() ?? '0.0');
    _languagesController = TextEditingController(text: (widget.initialData['languagesSpoken'] as List<dynamic>?)?.join(', ') ?? '');
    _addonsController = TextEditingController(text: (widget.initialData['addons'] as List<dynamic>?)?.join(', ') ?? '');

    // Initialize state variables
    _isAvailable = widget.initialData['availability']?['available'] ?? false;
    _isResponsible = widget.initialData['isResponsible'] ?? false;
    _selectedServiceType = widget.initialData['serviceType'] ?? _serviceTypes.first;
    _selectedExperienceLevel = widget.initialData['experienceLevel'] ?? _experienceLevels.first;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _skillsController.dispose();
    _priceController.dispose();
    _languagesController.dispose();
    _addonsController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    if (_formKey.currentState!.validate()) {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final updatedDetails = {
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim(),
        'skills': _skillsController.text.trim(),
        'availability': {'available': _isAvailable},
        'price': double.tryParse(_priceController.text.trim()) ?? 0.0,
        'isResponsible': _isResponsible,
        'serviceType': _selectedServiceType,
        'experienceLevel': _selectedExperienceLevel,
        'languagesSpoken': _languagesController.text.trim().split(',').map((e) => e.trim()).toList(),
        'addons': _addonsController.text.trim().split(',').map((e) => e.trim()).toList(),
      };

      try {
        await FirebaseFirestore.instance.collection('experienceServices').doc(widget.docId).update(updatedDetails);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Experience updated successfully!')),
        );
        Navigator.of(context).pop();
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating experience: $e')),
        );
      }
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
      validator: validator ?? (value) {
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
    required String selectedValue,
    required void Function(String?) onChanged,
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
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.white10)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.greenAccent, width: 2.0)),
      ),
      dropdownColor: const Color(0xFF203a43),
      style: const TextStyle(color: Colors.white),
      iconEnabledColor: Colors.white,
      onChanged: onChanged,
      validator: (value) {
        if (value == null || value.isEmpty) return 'Please select an option';
        return null;
      },
      items: items.map((e) => DropdownMenuItem<String>(value: e, child: Text(e))).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Edit ${widget.initialData['title'] ?? 'Experience'}", style: const TextStyle(color: Colors.white)),
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
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),

                // Service Details
                Text("Service Details", style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
                const Divider(color: Colors.white24, height: 24),
                _buildTextField(controller: _titleController, labelText: "Service Title", icon: Icons.title),
                const SizedBox(height: 16),
                _buildTextField(controller: _descriptionController, labelText: "Description", icon: Icons.description, maxLines: 4),
                const SizedBox(height: 16),
                _buildTextField(controller: _skillsController, labelText: "Experience / Skills (Optional)", icon: Icons.school, isRequired: false),
                const SizedBox(height: 16),
                _buildDropdownField(
                  labelText: "Service Type",
                  items: _serviceTypes,
                  selectedValue: _selectedServiceType,
                  onChanged: (val) => setState(() => _selectedServiceType = val!),
                  icon: Icons.design_services,
                ),
                const SizedBox(height: 16),
                _buildDropdownField(
                  labelText: "Experience Level",
                  items: _experienceLevels,
                  selectedValue: _selectedExperienceLevel,
                  onChanged: (val) => setState(() => _selectedExperienceLevel = val!),
                  icon: Icons.star,
                ),
                const SizedBox(height: 16),
                _buildTextField(controller: _languagesController, labelText: "Languages Spoken (comma separated)", icon: Icons.language, isRequired: false),
                const SizedBox(height: 16),
                _buildTextField(controller: _addonsController, labelText: "Add-ons / Extras (comma separated)", icon: Icons.add, isRequired: false),
                const SizedBox(height: 24),

                // Price
                Text("Pricing", style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
                const Divider(color: Colors.white24, height: 24),
                _buildTextField(
                  controller: _priceController,
                  labelText: "Price (per hour/day in INR)",
                  icon: Icons.currency_rupee,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Price is required';
                    if (double.tryParse(value) == null) return 'Enter a valid number';
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // Availability
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Available for Service", style: TextStyle(color: Colors.white, fontSize: 16)),
                    Switch(value: _isAvailable, onChanged: (val) => setState(() => _isAvailable = val), activeColor: Colors.greenAccent),
                  ],
                ),
                const SizedBox(height: 16),

                // Responsibility
                Row(
                  children: [
                    Checkbox(
                      value: _isResponsible,
                      onChanged: (bool? newValue) {
                        setState(() {
                          _isResponsible = newValue ?? false;
                        });
                      },
                      activeColor: Colors.greenAccent,
                      checkColor: Colors.black,
                    ),
                    const Expanded(child: Text("I am responsible for providing this service as described.", style: TextStyle(color: Colors.white))),
                  ],
                ),
                const SizedBox(height: 40),

                // Save Button
                Center(
                  child: ElevatedButton(
                    onPressed: _saveChanges,
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
}