import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class ListPackageScreen extends StatefulWidget {
  final String selectedCategory;

  const ListPackageScreen({super.key, required this.selectedCategory});

  @override
  State<ListPackageScreen> createState() => _ListPackageScreenState();
}

class _ListPackageScreenState extends State<ListPackageScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _dailyRateController = TextEditingController();
  final _weeklyRateController = TextEditingController();
  final _depositController = TextEditingController();
  final _brandController = TextEditingController();
  final _modelController = TextEditingController();

  final List<TextEditingController> _toolControllers = [];
  final List<String> _toolConditions = ["New", "Like New", "Used - Good", "Used - Fair", "Used - Poor"];
  String? _selectedCondition;
  bool _isResponsible = false;
  bool _isAvailable = true;

  @override
  void initState() {
    super.initState();
    _toolControllers.add(TextEditingController());
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

  void _handleReview() {
    if (_formKey.currentState!.validate()) {
      final packageDetails = {
        'category': widget.selectedCategory,
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
        'isAvailable': _isAvailable,
      };

      Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => ReviewScreen(packageDetails: packageDetails),
      ));
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
    return Scaffold(
      appBar: AppBar(
        title: Text("List a ${widget.selectedCategory} Package", style: const TextStyle(color: Colors.white)),
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
                const Center(
                  child: Text(
                    "Step 1 of 2: Package Details & Pricing",
                    style: TextStyle(color: Colors.white54, fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 24),
                // Package Details
                Text("Package Details", style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
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
                Text("Pricing & Terms", style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
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

                // Review Button
                Center(
                  child: ElevatedButton(
                    onPressed: _handleReview,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.greenAccent,
                      padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    ),
                    child: const Text("Review & Publish", style: TextStyle(fontSize: 18, color: Colors.black, fontWeight: FontWeight.bold)),
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

// =========================================================================
// NEW: Review Screen
// =========================================================================

class ReviewScreen extends StatelessWidget {
  final Map<String, dynamic> packageDetails;
  const ReviewScreen({super.key, required this.packageDetails});

  Future<void> _submitToFirestore(BuildContext context) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('User not logged in.')));
        return;
      }

      await FirebaseFirestore.instance.collection('packages').add({
        ...packageDetails,
        'userId': user.uid,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Navigate to a success screen or pop to the root
      Navigator.of(context).popUntil((route) => route.isFirst);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Package listed successfully!')));

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to publish package: $e')));
    }
  }

  Widget _buildReviewItem(String label, dynamic value) {
    String displayValue = value.toString();
    if (value is double) {
      displayValue = "₹${value.toStringAsFixed(2)}";
    } else if (value is List) {
      displayValue = value.join(', ');
    } else if (value is DateTime) {
      displayValue = DateFormat('dd/MM/yyyy').format(value);
    } else if (value is bool) {
      displayValue = value ? "Yes" : "No";
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.white70, fontSize: 14)),
          const SizedBox(height: 4),
          Text(displayValue, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          const Divider(color: Colors.white24, height: 16),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Review Package Details", style: TextStyle(color: Colors.white)),
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                "Please review the details before publishing.",
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              _buildReviewItem("Category", packageDetails['category']),
              _buildReviewItem("Package Title", packageDetails['title']),
              _buildReviewItem("Description", packageDetails['description']),
              _buildReviewItem("Condition", packageDetails['condition']),
              if (packageDetails['brand']?.isNotEmpty ?? false)
                _buildReviewItem("Brand", packageDetails['brand']),
              if (packageDetails['model']?.isNotEmpty ?? false)
                _buildReviewItem("Model", packageDetails['model']),

              if (packageDetails['tools'] is List && packageDetails['tools'].isNotEmpty)
                _buildReviewItem("Tools", packageDetails['tools']),

              _buildReviewItem("Daily Rate", packageDetails['dailyRate']),
              if (packageDetails['weeklyRate'] != 0.0)
                _buildReviewItem("Weekly Rate", packageDetails['weeklyRate']),
              _buildReviewItem("Security Deposit", packageDetails['deposit']),
              _buildReviewItem("Availability", packageDetails['isAvailable']),
              _buildReviewItem("Responsibility", packageDetails['isResponsible']),

              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () => _submitToFirestore(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.greenAccent,
                  padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
                child: const Text("Confirm & Publish", style: TextStyle(fontSize: 18, color: Colors.black, fontWeight: FontWeight.bold)),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text("Go Back to Edit", style: TextStyle(color: Colors.white70)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}