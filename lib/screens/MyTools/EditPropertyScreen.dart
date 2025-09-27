import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tool_rental_app/screens/Profile/AddAddressScreen.dart';

class EditPropertyScreen extends StatefulWidget {
  final String docId;
  final Map<String, dynamic> initialData;

  const EditPropertyScreen({
    super.key,
    required this.docId,
    required this.initialData,
  });

  @override
  State<EditPropertyScreen> createState() => _EditPropertyScreenState();
}

class _EditPropertyScreenState extends State<EditPropertyScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _rentController;
  late final TextEditingController _depositController;
  late final TextEditingController _amenitiesController;
  late final TextEditingController _bedroomsController;
  late final TextEditingController _bathroomsController;
  late final TextEditingController _areaController;

  late bool _isAvailable;
  String? _selectedAddressId;
  Map<String, dynamic>? _selectedAddress;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.initialData['title']);
    _descriptionController = TextEditingController(text: widget.initialData['description']);
    _rentController = TextEditingController(text: widget.initialData['rent']?.toString() ?? '0.0');
    _depositController = TextEditingController(text: widget.initialData['deposit']?.toString() ?? '0.0');
    _amenitiesController = TextEditingController(text: (widget.initialData['amenities'] as List<dynamic>?)?.join(', ') ?? '');
    _bedroomsController = TextEditingController(text: widget.initialData['bedrooms']?.toString() ?? '0');
    _bathroomsController = TextEditingController(text: widget.initialData['bathrooms']?.toString() ?? '0');
    _areaController = TextEditingController(text: widget.initialData['area']?.toString() ?? '0.0');

    _isAvailable = widget.initialData['isAvailable'] ?? false;
    _selectedAddress = widget.initialData['address'];
    _selectedAddressId = _selectedAddress?['id'];
  }

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

  Future<void> _saveChanges() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedAddress == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a property address.')),
        );
        return;
      }

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final updatedDetails = {
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
      };

      try {
        await FirebaseFirestore.instance.collection('properties').doc(widget.docId).update(updatedDetails);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Property updated successfully!')),
        );
        Navigator.of(context).pop();
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating property: $e')),
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
          title: const Text("Edit Property", style: TextStyle(color: Colors.white)),
          backgroundColor: const Color(0xFF203a43),
          foregroundColor: Colors.white,
        ),
        body: const Center(child: Text("Please log in to edit a property.", style: TextStyle(color: Colors.white))),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Edit ${widget.initialData['title'] ?? 'Property'}", style: const TextStyle(color: Colors.white)),
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
                    if (_selectedAddressId == null && addresses.isNotEmpty) {
                      // Set a default selected address if none is selected yet
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        setState(() {
                          _selectedAddressId = addresses.first.id;
                          _selectedAddress = addresses.first.data() as Map<String, dynamic>;
                        });
                      });
                    }

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

                // Save Changes Button
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