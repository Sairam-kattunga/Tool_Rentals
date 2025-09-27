import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tool_rental_app/screens/Profile/AddAddressScreen.dart';

class ListExperienceFormScreen extends StatefulWidget {
  final String category;
  const ListExperienceFormScreen({super.key, required this.category});

  @override
  State<ListExperienceFormScreen> createState() => _ListExperienceFormScreenState();
}

class _ListExperienceFormScreenState extends State<ListExperienceFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _skillsController = TextEditingController();
  final _priceController = TextEditingController();
  final _languagesController = TextEditingController();
  final _addonsController = TextEditingController();

  bool _isAvailable = true;
  bool _isResponsible = false;

  String? _selectedAddressId;
  Map<String, dynamic>? _selectedAddress;

  String? _selectedServiceType;
  String? _selectedExperienceLevel;

  final List<String> _serviceTypes = ['In-person', 'Online', 'Hybrid'];
  final List<String> _experienceLevels = ['Beginner', 'Intermediate', 'Expert'];

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

  Future<void> _publishService() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedAddress == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select an address.')),
        );
        return;
      }

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final serviceDetails = {
        'category': widget.category,
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim(),
        'skills': _skillsController.text.trim(),
        'address': _selectedAddress,
        'availability': {'available': _isAvailable},
        'price': double.tryParse(_priceController.text.trim()) ?? 0.0,
        'isResponsible': _isResponsible,
        'serviceType': _selectedServiceType,
        'experienceLevel': _selectedExperienceLevel,
        'languagesSpoken': _languagesController.text.trim().split(',').map((e) => e.trim()).toList(),
        'addons': _addonsController.text.trim().split(',').map((e) => e.trim()).toList(),
        'ratings': [],
        'createdBy': user.uid,
        'createdAt': FieldValue.serverTimestamp(),
      };

      try {
        await FirebaseFirestore.instance.collection('experienceServices').add(serviceDetails);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Service listed successfully!')),
        );
        Navigator.of(context).pop();
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error listing service: $e')),
        );
      }
    }
  }

  void _showConfirmDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF203a43), // Set dialog background color
        title: const Text("Confirm Listing", style: TextStyle(color: Colors.white)),
        content: const Text("Are you sure you want to publish this service?", style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("Cancel", style: TextStyle(color: Colors.redAccent)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _publishService();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.greenAccent,
            ),
            child: const Text("Confirm", style: TextStyle(color: Colors.black)),
          ),
        ],
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
    required String? selectedValue,
    required void Function(String?) onChanged,
    required IconData icon,
  }) {
    return DropdownButtonFormField<String>(
      value: selectedValue,
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: const TextStyle(color: Colors.white70), // Label text color
        prefixIcon: Icon(icon, color: Colors.white70),
        filled: true,
        fillColor: Colors.white.withOpacity(0.1),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.white10)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.greenAccent, width: 2.0)),
      ),
      dropdownColor: const Color(0xFF203a43),
      style: const TextStyle(color: Colors.white),
      iconEnabledColor: Colors.white, // Dropdown arrow color
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
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("List a Service", style: TextStyle(color: Colors.white)),
          backgroundColor: const Color(0xFF203a43),
        ),
        body: const Center(child: Text("Please log in to list a service.", style: TextStyle(color: Colors.white))),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("List a ${widget.category} Service", style: const TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF203a43),
        iconTheme: const IconThemeData(color: Colors.white), // Ensure back button is white
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
                const Center(
                  child: Text(
                    "Step 2 of 2: Service Details & Pricing",
                    style: TextStyle(color: Colors.white54, fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                ),
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
                  onChanged: (val) => setState(() => _selectedServiceType = val),
                  icon: Icons.design_services,
                ),
                const SizedBox(height: 16),
                _buildDropdownField(
                  labelText: "Experience Level",
                  items: _experienceLevels,
                  selectedValue: _selectedExperienceLevel,
                  onChanged: (val) => setState(() => _selectedExperienceLevel = val),
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
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Price is required';
                    if (double.tryParse(value) == null) return 'Enter a valid number';
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // Address
                Text("Address", style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
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
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return TextButton.icon(
                        onPressed: () {
                          Navigator.of(context).push(MaterialPageRoute(builder: (context) => const AddAddressScreen()));
                        },
                        icon: const Icon(Icons.add_circle, color: Colors.greenAccent),
                        label: const Text("No address found. Add one.", style: TextStyle(color: Colors.white70)),
                      );
                    }

                    final addresses = snapshot.data!.docs;
                    return DropdownButtonFormField<String>(
                      value: _selectedAddressId,
                      decoration: InputDecoration(
                        labelText: "Select Address",
                        labelStyle: const TextStyle(color: Colors.white70), // Label text color
                        prefixIcon: const Icon(Icons.location_on, color: Colors.white70),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.1),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.white10)),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.greenAccent, width: 2.0)),
                      ),
                      dropdownColor: const Color(0xFF203a43),
                      style: const TextStyle(color: Colors.white),
                      iconEnabledColor: Colors.white, // Dropdown arrow color
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedAddressId = newValue;
                          if (newValue != null) {
                            _selectedAddress = addresses.firstWhere((doc) => doc.id == newValue).data() as Map<String, dynamic>;
                          }
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Please select an address';
                        return null;
                      },
                      items: addresses.map<DropdownMenuItem<String>>((doc) {
                        final data = doc.data() as Map<String, dynamic>;
                        return DropdownMenuItem<String>(
                          value: doc.id,
                          child: Text(data['addressName'] ?? 'Unnamed Address', style: const TextStyle(color: Colors.white)), // Text color for dropdown items
                        );
                      }).toList(),
                    );
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
                      checkColor: Colors.black, // Checkbox tick color
                    ),
                    const Expanded(child: Text("I am responsible for providing this service as described.", style: TextStyle(color: Colors.white))),
                  ],
                ),
                const SizedBox(height: 40),

                // Confirm & Publish
                Center(
                  child: ElevatedButton(
                    onPressed: _showConfirmDialog,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.greenAccent,
                      padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    ),
                    child: const Text("Publish Service", style: TextStyle(fontSize: 18, color: Colors.black, fontWeight: FontWeight.bold)),
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