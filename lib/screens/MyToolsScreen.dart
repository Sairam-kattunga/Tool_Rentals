import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MyToolsScreen extends StatelessWidget {
  const MyToolsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Center(child: Text("Please log in to view your tools."));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Tools", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      extendBodyBehindAppBar: true,
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
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection("tools")
                  .where("ownerId", isEqualTo: user.uid)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: Colors.white));
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Text("Error: ${snapshot.error}", style: const TextStyle(color: Colors.white)),
                  );
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text(
                      "You have no tools listed.",
                      style: TextStyle(color: Colors.white70, fontSize: 18),
                    ),
                  );
                }

                final tools = snapshot.data!.docs;

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: ListView.builder(
                    itemCount: tools.length,
                    itemBuilder: (context, index) {
                      final toolDoc = tools[index];
                      final toolData = toolDoc.data() as Map<String, dynamic>;
                      return _buildMyToolCard(toolData, toolDoc.id);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMyToolCard(Map<String, dynamic> toolData, String docId) {
    final bool isAvailable = toolData["available"] ?? false;

    return Card(
      color: Colors.white.withOpacity(0.1),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Colors.white24),
      ),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              toolData["name"] ?? "Tool",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Category: ${toolData["category"] ?? "N/A"}",
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 8),
            Text(
              toolData["description"] ?? "",
              style: const TextStyle(color: Colors.white, fontStyle: FontStyle.italic),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "\$${toolData["pricePerDay"]?.toStringAsFixed(2) ?? '0.00'} / day",
                  style: const TextStyle(
                    color: Colors.greenAccent,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Switch(
                  value: isAvailable,
                  onChanged: (bool newValue) {
                    FirebaseFirestore.instance
                        .collection("tools")
                        .doc(docId)
                        .update({"available": newValue});
                  },
                  activeColor: Colors.lightGreenAccent,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}