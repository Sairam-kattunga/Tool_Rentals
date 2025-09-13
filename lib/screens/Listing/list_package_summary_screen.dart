import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tool_rental_app/widgets/animated_button.dart';

class ListPackageSummaryScreen extends StatefulWidget {
  final String packageName;
  final String packageDescription;
  final double packagePrice;
  final double packageAdvance;
  final bool isAvailable;
  final String selectedCategory;
  final List<Map<String, dynamic>> selectedTools;

  const ListPackageSummaryScreen({
    super.key,
    required this.packageName,
    required this.packageDescription,
    required this.packagePrice,
    required this.packageAdvance,
    required this.isAvailable,
    required this.selectedCategory,
    required this.selectedTools,
  });

  @override
  State<ListPackageSummaryScreen> createState() => _ListPackageSummaryScreenState();
}

class _ListPackageSummaryScreenState extends State<ListPackageSummaryScreen> {
  bool _isProcessing = false;
  String _buttonText = "List Package";

  Future<void> _listPackage() async {
    // Check if processing is already in progress to prevent duplicate submissions
    if (_isProcessing) return;

    setState(() {
      _isProcessing = true;
      _buttonText = "Listing...";
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception("User not authenticated.");
      }

      final toolIds = widget.selectedTools.map((tool) => tool['docId']).toList();

      // Step 1: Create the new tool package document
      final newPackageRef = FirebaseFirestore.instance.collection("toolPackages").doc();
      final newPackage = {
        "name": widget.packageName,
        "description": widget.packageDescription,
        "pricePerDay": widget.packagePrice,
        "advanceAmount": widget.packageAdvance,
        "toolsInPackage": toolIds,
        "ownerId": user.uid,
        "available": widget.isAvailable,
        "category": widget.selectedCategory,
        "createdAt": FieldValue.serverTimestamp(),
      };
      await newPackageRef.set(newPackage);

      // Step 2: Update each individual tool to link it to the new package
      final batch = FirebaseFirestore.instance.batch();
      for (var toolId in toolIds) {
        final toolRef = FirebaseFirestore.instance.collection("tools").doc(toolId);
        batch.update(toolRef, {
          'isPartofPackage': true,
          'packageId': newPackageRef.id,
        });
      }
      await batch.commit();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Tool package listed successfully!")),
        );
        Navigator.of(context).popUntil(ModalRoute.withName('/home'));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to list package: $e")),
        );
        setState(() {
          _isProcessing = false;
          _buttonText = "List Package";
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_isProcessing,
      onPopInvoked: (bool didPop) {
        if (didPop) return;
        Navigator.pop(context);
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Review Package", style: TextStyle(color: Colors.white)),
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSummaryCard(),
                    const SizedBox(height: 24),
                    _buildToolsList(),
                  ],
                ),
              ),
            ),
          ],
        ),
        bottomNavigationBar: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          color: Colors.white.withOpacity(0.1),
          child: AnimatedButton(
            text: _buttonText,
            onTap: () {
              if (!_isProcessing) {
                _listPackage();
              }
            },
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Package Details",
            style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildDetailRow("Package Name", widget.packageName),
          _buildDetailRow("Category", widget.selectedCategory),
          _buildDetailRow("Description", widget.packageDescription),
          _buildDetailRow("Price per Day", "₹${widget.packagePrice.toStringAsFixed(2)}"),
          _buildDetailRow("Advance Amount", "₹${widget.packageAdvance.toStringAsFixed(2)}"),
          _buildDetailRow("Availability", widget.isAvailable ? "Available" : "Not Available", isAvailable: widget.isAvailable),
        ],
      ),
    );
  }

  Widget _buildToolsList() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Tools in Package (${widget.selectedTools.length})",
            style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          ...widget.selectedTools.map((tool) => _buildToolListItem(tool)).toList(),
        ],
      ),
    );
  }

  Widget _buildToolListItem(Map<String, dynamic> tool) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          const Icon(Icons.build_circle, color: Colors.greenAccent, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              tool['name'] ?? 'Unknown Tool',
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isAvailable = true}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "$label:",
            style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: isAvailable ? Colors.greenAccent : Colors.redAccent,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}