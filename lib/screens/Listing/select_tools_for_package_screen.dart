import 'package:flutter/material.dart';
import 'package:tool_rental_app/screens/Listing/list_package_summary_screen.dart';
import 'package:tool_rental_app/widgets/animated_button.dart';

class SelectToolsForPackageScreen extends StatefulWidget {
  final String packageName;
  final String packageDescription;
  final double packagePrice;
  final double packageAdvance;
  final bool isAvailable;
  final String selectedCategory;

  const SelectToolsForPackageScreen({
    super.key,
    required this.packageName,
    required this.packageDescription,
    required this.packagePrice,
    required this.packageAdvance,
    required this.isAvailable,
    required this.selectedCategory,
  });

  @override
  State<SelectToolsForPackageScreen> createState() => _SelectToolsForPackageScreenState();
}

class _SelectToolsForPackageScreenState extends State<SelectToolsForPackageScreen> {
  final _formKey = GlobalKey<FormState>();
  final _toolNameController = TextEditingController();
  final _toolConditionController = TextEditingController();

  List<Map<String, dynamic>> _toolsInPackage = [];

  @override
  void dispose() {
    _toolNameController.dispose();
    _toolConditionController.dispose();
    super.dispose();
  }

  void _addToolToPackage() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _toolsInPackage.add({
          'name': _toolNameController.text.trim(),
          'condition': _toolConditionController.text.trim(),
        });
        _toolNameController.clear();
        _toolConditionController.clear();
      });
      Navigator.of(context).pop();
    }
  }

  void _showAddToolDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF203a43),
          title: const Text("Add a Tool", style: TextStyle(color: Colors.white)),
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _toolNameController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    hintText: "Tool Name",
                    hintStyle: TextStyle(color: Colors.white70),
                  ),
                  validator: (value) => value == null || value.isEmpty ? 'Please enter a tool name' : null,
                ),
                TextFormField(
                  controller: _toolConditionController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    hintText: "Condition (e.g., 'Good', 'New')",
                    hintStyle: TextStyle(color: Colors.white70),
                  ),
                  validator: (value) => value == null || value.isEmpty ? 'Please enter a condition' : null,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Cancel", style: TextStyle(color: Colors.white70)),
            ),
            ElevatedButton(
              onPressed: _addToolToPackage,
              child: const Text("Add"),
            ),
          ],
        );
      },
    );
  }

  void _navigateToSummaryScreen() {
    if (_toolsInPackage.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please add at least one tool to the package.")),
      );
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ListPackageSummaryScreen(
          packageName: widget.packageName,
          packageDescription: widget.packageDescription,
          packagePrice: widget.packagePrice,
          packageAdvance: widget.packageAdvance,
          isAvailable: widget.isAvailable,
          selectedCategory: widget.selectedCategory,
          selectedTools: _toolsInPackage,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Tools to Package", style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF203a43),
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
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
            child: Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: _toolsInPackage.isEmpty
                      ? const Center(
                    child: Text(
                      "No tools added yet.\nTap the '+' button to add tools.",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white70, fontSize: 18),
                    ),
                  )
                      : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _toolsInPackage.length,
                    itemBuilder: (context, index) {
                      final tool = _toolsInPackage[index];
                      return _buildToolCard(tool['name'], tool['condition'], index);
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddToolDialog,
        backgroundColor: Colors.greenAccent,
        child: const Icon(Icons.add, color: Colors.black),
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Package: ${widget.packageName}",
            style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            "Category: ${widget.selectedCategory}",
            style: const TextStyle(color: Colors.white70, fontSize: 16),
          ),
          const Divider(color: Colors.white24, height: 24),
        ],
      ),
    );
  }

  Widget _buildToolCard(String name, String condition, int index) {
    return Card(
      color: Colors.white.withOpacity(0.08),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        title: Text(
          name,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Text(
          'Condition: $condition',
          style: const TextStyle(color: Colors.white70, fontSize: 14),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete, color: Colors.redAccent),
          onPressed: () {
            setState(() {
              _toolsInPackage.removeAt(index);
            });
          },
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      color: Colors.white.withOpacity(0.1),
      child: AnimatedButton(
        text: "Review Package (${_toolsInPackage.length})",
        onTap: _navigateToSummaryScreen,
      ),
    );
  }
}