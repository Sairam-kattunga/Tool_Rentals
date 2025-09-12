// edit_tool_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tool_rental_app/widgets/animated_button.dart';

class EditToolScreen extends StatefulWidget {
  final String docId;
  final Map<String, dynamic> initialData;

  const EditToolScreen({super.key, required this.docId, required this.initialData});

  @override
  State<EditToolScreen> createState() => _EditToolScreenState();
}

class _EditToolScreenState extends State<EditToolScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _descController;
  late final TextEditingController _priceController;
  late String _selectedCategory;
  String? _selectedAddressId;
  late bool _isAvailable;
  bool _isLoading = false;

  final List<String> categories = [
    "Home & Garden", "Automotive", "Electronics", "Construction",
    "Events", "Sports & Outdoors", "Medical & Health", "Office",
    "Photography & Video", "Musical Instruments", "Party Supplies",
    "Heavy Machinery", "Miscellaneous"
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialData["name"] ?? "");
    _descController = TextEditingController(text: widget.initialData["description"] ?? "");
    _priceController = TextEditingController(text: widget.initialData["pricePerDay"]?.toString() ?? "");

    final initialCategory = widget.initialData["category"];
    _selectedCategory = categories.firstWhere(
          (cat) => cat == initialCategory,
      orElse: () => categories.first,
    );

    _isAvailable = widget.initialData["available"] ?? true;
    _selectedAddressId = null;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _updateTool() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedAddressId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please select an address.")),
        );
        return;
      }

      setState(() => _isLoading = true);
      try {
        final addressDoc = await FirebaseFirestore.instance
            .collection('userAddresses')
            .doc(_selectedAddressId)
            .get();

        if (!addressDoc.exists) {
          throw Exception("Selected address not found.");
        }

        final addressData = addressDoc.data() as Map<String, dynamic>;

        await FirebaseFirestore.instance.collection("tools").doc(widget.docId).update({
          "name": _nameController.text.trim(),
          "description": _descController.text.trim(),
          "pricePerDay": double.parse(_priceController.text.trim()),
          "category": _selectedCategory,
          "available": _isAvailable,
          "city": addressData['city'],
          "location": addressData['location'],
          "updatedAt": FieldValue.serverTimestamp(),
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Tool updated successfully!", style: TextStyle(color: Colors.white))),
          );
          Navigator.of(context).pop();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Error updating tool: $e", style: const TextStyle(color: Colors.white))),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
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

  Widget _buildCategoryDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: DropdownButtonFormField<String>(
        value: _selectedCategory,
        dropdownColor: const Color(0xFF203a43),
        style: const TextStyle(color: Colors.white),
        decoration: const InputDecoration(
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 20, horizontal: 0),
        ),
        icon: const Icon(Icons.arrow_drop_down, color: Colors.white70),
        onChanged: (String? newValue) {
          if (newValue != null) {
            setState(() {
              _selectedCategory = newValue;
            });
          }
        },
        items: categories.map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
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

  Widget _buildAddressSelection() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Center(child: Text("Please log in."));
    }
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('userAddresses')
          .where('ownerId', isEqualTo: user.uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator(color: Colors.greenAccent);
        }
        if (snapshot.hasError) {
          return Text("Error: ${snapshot.error}", style: const TextStyle(color: Colors.white70));
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Text("No addresses found.", style: TextStyle(color: Colors.white70));
        }

        final addresses = snapshot.data!.docs;

        // Find the initial address based on the current tool's location data
        if (_selectedAddressId == null) {
          final initialCity = widget.initialData['city'];
          final initialLocation = widget.initialData['location'];
          try {
            final initialAddressDoc = addresses.firstWhere(
                  (doc) => doc.get('city') == initialCity && doc.get('location') == initialLocation,
            );
            _selectedAddressId = initialAddressDoc.id;
          } catch (e) {
            _selectedAddressId = addresses.first.id;
          }
        }

        return DropdownButtonFormField<String>(
          value: _selectedAddressId,
          dropdownColor: const Color(0xFF203a43),
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            labelText: "Select Address",
            labelStyle: const TextStyle(color: Colors.white70, fontWeight: FontWeight.bold),
            filled: true,
            fillColor: Colors.white.withOpacity(0.08),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
          ),
          onChanged: (String? newValue) {
            if (newValue != null) {
              setState(() {
                _selectedAddressId = newValue;
              });
            }
          },
          items: addresses.map<DropdownMenuItem<String>>((doc) {
            final address = doc.data() as Map<String, dynamic>;
            final addressId = doc.id;
            return DropdownMenuItem<String>(
              value: addressId,
              child: Text(address['addressName'] ?? 'Unnamed Address'),
            );
          }).toList(),
          validator: (value) => value == null ? "Please select an address" : null,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Tool", style: TextStyle(color: Colors.white)),
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
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  "Edit Tool Details",
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
                _buildCategoryDropdown(),
                const SizedBox(height: 24),
                _buildAvailabilitySwitch(),
                const SizedBox(height: 24),
                _buildAddressSelection(),
                const SizedBox(height: 40),
                AnimatedButton(
                  text: _isLoading ? "Saving..." : "Save Changes",
                  onTap: _isLoading
                      ? () {}
                      : () => _updateTool(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}