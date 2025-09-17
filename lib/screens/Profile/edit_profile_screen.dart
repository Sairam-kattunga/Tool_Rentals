import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EditProfileScreen extends StatefulWidget {
  final User user;
  const EditProfileScreen({super.key, required this.user});

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _contactController = TextEditingController();
  String? _selectedAgeRange;
  bool _isLoading = false;

  final List<String> _ageRanges = ['0-18', '19-40', '40+'];

  @override
  void initState() {
    super.initState();
    _loadCurrentUserData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _contactController.dispose();
    super.dispose();
  }

  Future<void> _loadCurrentUserData() async {
    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.user.uid)
          .get();
      if (doc.exists) {
        var userData = doc.data() as Map<String, dynamic>;
        _nameController.text = userData['name'] ?? '';
        _contactController.text = userData['contact'] ?? '';
        _selectedAgeRange = userData['age'];
        setState(() {}); // Refresh UI with loaded data
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to load data: $e")),
        );
      }
    }
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    setState(() {
      _isLoading = true;
    });
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.user.uid)
          .update({
        'name': _nameController.text.trim(),
        'contact': _contactController.text.trim(),
        'age': _selectedAgeRange,
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Profile updated successfully!")),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to update profile: $e")),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    String? Function(String?)? validator,
    TextInputType keyboard = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      style: const TextStyle(color: Colors.white),
      keyboardType: keyboard,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white70),
        prefixIcon: Icon(icon, color: Colors.white70),
        filled: true,
        fillColor: Colors.white.withOpacity(0.1),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildAgeDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(30),
      ),
      child: DropdownButtonFormField<String>(
        value: _selectedAgeRange,
        isExpanded: true,
        decoration: const InputDecoration(
          hintText: "Age Range",
          hintStyle: TextStyle(color: Colors.white70),
          prefixIcon: Icon(Icons.cake, color: Colors.white70),
          border: InputBorder.none,
        ),
        dropdownColor: const Color(0xFF2c5364),
        style: const TextStyle(color: Colors.white),
        icon: const Icon(Icons.arrow_drop_down, color: Colors.white70),
        items: _ageRanges.map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
        onChanged: (String? newValue) {
          setState(() {
            _selectedAgeRange = newValue;
          });
        },
        validator: (value) => value == null ? "Please select an age range" : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Profile",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),
                _buildTextField(
                  controller: _nameController,
                  hint: "Full Name",
                  icon: Icons.person,
                  validator: (val) => val!.isEmpty ? "Name cannot be empty" : null,
                ),
                const SizedBox(height: 20),
                _buildTextField(
                  controller: _contactController,
                  hint: "Contact Number",
                  icon: Icons.phone,
                  keyboard: TextInputType.phone,
                  validator: (val) {
                    if (val!.isEmpty) return "Contact number cannot be empty";
                    if (val.trim().length != 10) return "Number must be 10 digits";
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                _buildAgeDropdown(),
                const SizedBox(height: 40),
                _isLoading
                    ? const Center(child: CircularProgressIndicator(color: Colors.greenAccent))
                    : ElevatedButton(
                  onPressed: _updateProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.greenAccent,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                  child: const Text("Save Changes",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}