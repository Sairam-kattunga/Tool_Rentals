import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RentToolScreen extends StatefulWidget {
  const RentToolScreen({super.key});

  @override
  State<RentToolScreen> createState() => _RentToolScreenState();
}

class _RentToolScreenState extends State<RentToolScreen> {
  String _searchQuery = "";

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushReplacementNamed(context, '/home'); // ✅ Go back to Home
        return false; // Prevent default exit
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Rent a Tool", style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        extendBodyBehindAppBar: true,
        body: Stack(
          children: [
            // Background gradient
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
                  // 🔍 Search bar
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: TextField(
                      onChanged: (value) {
                        setState(() => _searchQuery = value.toLowerCase());
                      },
                      decoration: InputDecoration(
                        hintText: "Search tools...",
                        hintStyle: const TextStyle(color: Colors.white70),
                        prefixIcon: const Icon(Icons.search, color: Colors.white),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.1),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  Expanded(
                    child: StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection("tools")
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(color: Colors.white),
                          );
                        }
                        if (snapshot.hasError) {
                          return Center(
                            child: Text("Error: ${snapshot.error}",
                                style: const TextStyle(color: Colors.white)),
                          );
                        }
                        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                          return const Center(
                            child: Text(
                              "No tools currently available for rent.",
                              style: TextStyle(color: Colors.white70, fontSize: 18),
                            ),
                          );
                        }

                        // ✅ Filter tools with search query
                        final tools = snapshot.data!.docs.where((doc) {
                          final data = doc.data() as Map<String, dynamic>;
                          final name = (data["name"] ?? "").toString().toLowerCase();
                          final category = (data["category"] ?? "").toString().toLowerCase();
                          return name.contains(_searchQuery) || category.contains(_searchQuery);
                        }).toList();

                        if (tools.isEmpty) {
                          return const Center(
                            child: Text(
                              "No tools match your search.",
                              style: TextStyle(color: Colors.white70, fontSize: 18),
                            ),
                          );
                        }

                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: ListView.builder(
                            itemCount: tools.length,
                            itemBuilder: (context, index) {
                              final toolData = tools[index].data() as Map<String, dynamic>;
                              return _buildToolCard(toolData);
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Tool Card widget
  Widget _buildToolCard(Map<String, dynamic> toolData) {
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
                Text(
                  isAvailable ? "Available" : "Not Available",
                  style: TextStyle(
                    color: isAvailable ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                ElevatedButton(
                  onPressed: isAvailable ? () {
                    // TODO: Implement rental logic
                  } : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2c5364),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text("Rent"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
