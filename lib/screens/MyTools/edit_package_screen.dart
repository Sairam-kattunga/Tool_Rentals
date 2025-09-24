// file: lib/screens/EditPackage/edit_package_screen.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:tool_rental_app/screens/Profile/AddAddressScreen.dart'; // Import for AddAddressScreen

class EditPackageScreen extends StatefulWidget {
  final String docId;
  final Map<String, dynamic> initialData;

  const EditPackageScreen({
    super.key,
    required this.docId,
    required this.initialData,
  });

  @override
  State<EditPackageScreen> createState() => _EditPackageScreenState();
}

class _EditPackageScreenState extends State<EditPackageScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _dailyRateController;
  late TextEditingController _weeklyRateController;
  late TextEditingController _depositController;
  late TextEditingController _brandController;
  late TextEditingController _modelController;

  final List<TextEditingController> _toolControllers = [];
  final List<String> _toolConditions = ["New", "Like New", "Used - Good", "Used - Fair", "Used - Poor"];
  String? _selectedCondition;
  bool _isResponsible = false;
  bool _isAvailable = true; // New state variable for the toggle

  // Address-related state variables
  String? _selectedAddressId;
  Map<String, dynamic>? _selectedAddress;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.initialData['title']);
    _descriptionController = TextEditingController(text: widget.initialData['description']);
    _dailyRateController = TextEditingController(text: widget.initialData['dailyRate']?.toString() ?? '');
    _weeklyRateController = TextEditingController(text: widget.initialData['weeklyRate']?.toString() ?? '');
    _depositController = TextEditingController(text: widget.initialData['deposit']?.toString() ?? '');
    _brandController = TextEditingController(text: widget.initialData['brand']);
    _modelController = TextEditingController(text: widget.initialData['model']);

    _selectedCondition = widget.initialData['condition'];
    _isResponsible = widget.initialData['isResponsible'] ?? false;
    _isAvailable = widget.initialData['isAvailable'] ?? true; // Initialize toggle state

    final tools = widget.initialData['tools'] as List? ?? [];
    if (tools.isNotEmpty) {
      for (var tool in tools) {
        _toolControllers.add(TextEditingController(text: tool.toString()));
      }
    } else {
      _toolControllers.add(TextEditingController());
    }

    // Initialize selected address from initialData if available
    _selectedAddress = widget.initialData['address'];
    _selectedAddressId = _selectedAddress?['addressId'];
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _dailyRateController.dispose();
    _weeklyRateController.dispose();
    _depositController.dispose();
    _brandController.dispose();
    _modelController.dispose();
    for (var controller in _toolControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _addToolField() {
    setState(() {
      _toolControllers.add(TextEditingController());
    });
  }

  void _removeToolField(int index) {
    setState(() {
      _toolControllers.removeAt(index).dispose();
    });
  }

  Future<void> _handleUpdate() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedAddress == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a pickup address.')),
        );
        return;
      }

      final packageDetails = {
        'title': _titleController.text,
        'description': _descriptionController.text,
        'condition': _selectedCondition,
        'brand': _brandController.text,
        'model': _modelController.text,
        'tools': _toolControllers.map((c) => c.text).where((s) => s.isNotEmpty).toList(),
        'dailyRate': double.tryParse(_dailyRateController.text) ?? 0.0,
        'weeklyRate': double.tryParse(_weeklyRateController.text) ?? 0.0,
        'deposit': double.tryParse(_depositController.text) ?? 0.0,
        'isResponsible': _isResponsible,
        'isAvailable': _isAvailable, // Use the new toggle state
        'address': _selectedAddress,
      };

      try {
        await FirebaseFirestore.instance
            .collection('packages')
            .doc(widget.docId)
            .update(packageDetails);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Package updated successfully!')),
          );
          Navigator.of(context).pop();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to update package: $e')),
          );
        }
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

  Widget _buildDropdownField({
    required String labelText,
    required List<String> items,
    required String? selectedValue,
    required Function(String?) onChanged,
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
      onChanged: onChanged,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please select an option';
        }
        return null;
      },
      items: items.map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("Edit Package", style: TextStyle(color: Colors.white)),
          backgroundColor: const Color(0xFF203a43),
          foregroundColor: Colors.white,
        ),
        body: const Center(child: Text("Please log in to edit a package.", style: TextStyle(color: Colors.white))),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Package", style: TextStyle(color: Colors.white)),
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
                // Package Details
                Text(
                  "Package Details",
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Divider(color: Colors.white24, height: 24),
                _buildTextField(
                  controller: _titleController,
                  labelText: "Package Title",
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
                _buildDropdownField(
                  labelText: "Condition",
                  items: _toolConditions,
                  selectedValue: _selectedCondition,
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedCondition = newValue;
                    });
                  },
                  icon: Icons.handyman,
                ),
                const SizedBox(height: 16),
                // Dynamic Tools List
                Text("Tools in this Package", style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                ..._toolControllers.asMap().entries.map((entry) {
                  int index = entry.key;
                  TextEditingController controller = entry.value;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            controller: controller,
                            labelText: "Tool ${index + 1}",
                            icon: Icons.build,
                          ),
                        ),
                        if (_toolControllers.length > 1)
                          IconButton(
                            icon: const Icon(Icons.remove_circle_outline, color: Colors.redAccent),
                            onPressed: () => _removeToolField(index),
                          ),
                      ],
                    ),
                  );
                }),
                Center(
                  child: TextButton.icon(
                    onPressed: _addToolField,
                    icon: const Icon(Icons.add, color: Colors.greenAccent),
                    label: const Text("Add Another Tool", style: TextStyle(color: Colors.greenAccent)),
                  ),
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _brandController,
                  labelText: "Brand (Optional)",
                  icon: Icons.business,
                  isRequired: false,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _modelController,
                  labelText: "Model (Optional)",
                  icon: Icons.model_training,
                  isRequired: false,
                ),
                const SizedBox(height: 24),

                // Pricing
                Text(
                  "Pricing & Terms",
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Divider(color: Colors.white24, height: 24),
                _buildTextField(
                  controller: _dailyRateController,
                  labelText: "Daily Rental Rate (in INR)",
                  icon: Icons.currency_rupee,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Daily rate is required';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Please enter a valid number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _weeklyRateController,
                  labelText: "Weekly Rental Rate (in INR)",
                  icon: Icons.calendar_today,
                  isRequired: false,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  validator: (value) {
                    if (value != null && value.isNotEmpty && double.tryParse(value) == null) {
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
                const SizedBox(height: 16),

                // Address Selection
                Text("Pickup Address", style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
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
                          _selectedAddress = addresses.firstWhere((doc) => doc.id == newValue).data() as Map<String, dynamic>;
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
                          child: Text(data['addressName'] ?? 'Unnamed Address'),
                        );
                      }).toList(),
                    );
                  },
                ),
                const SizedBox(height: 16),

                // Availability
                Text(
                  "Availability",
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Divider(color: Colors.white24, height: 24),
                // _buildDateField(
                //   labelText: "Select Date Range",
                //   icon: Icons.calendar_month,
                //   startDate: _startDate,
                //   endDate: _endDate,
                //   onTap: _selectDateRange,
                // ),
                const SizedBox(height: 16),

                // Responsibility Checkbox
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
                    const Expanded(
                      child: Text(
                        "I am responsible for any tool-related issues and will address them.",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 40),

                // Update Button
                Center(
                  child: ElevatedButton(
                    onPressed: _handleUpdate,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.greenAccent,
                      padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    ),
                    child: const Text(
                      "Update Package",
                      style: TextStyle(fontSize: 18, color: Colors.black, fontWeight: FontWeight.bold),
                    ),
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