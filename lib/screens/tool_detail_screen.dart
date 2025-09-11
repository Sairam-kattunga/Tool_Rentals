// tool_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ToolDetailScreen extends StatelessWidget {
  final Map<String, dynamic> toolData;

  const ToolDetailScreen({super.key, required this.toolData});

  @override
  Widget build(BuildContext context) {
    final bool isAvailable = toolData["available"] ?? false;
    final String city = toolData["city"] ?? "N/A";
    final String locationLink = toolData["location"] ?? "N/A";

    return Scaffold(
      appBar: AppBar(
        title: Text(
          toolData["name"] ?? "Tool Details",
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF203a43),
        elevation: 0,
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
          SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Tool Name and Status
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        toolData["name"] ?? "Tool",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Text(
                      isAvailable ? "Available" : "Not Available",
                      style: TextStyle(
                        color: isAvailable ? Colors.greenAccent : Colors.redAccent,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Price
                Text(
                  "₹${toolData["pricePerDay"]?.toStringAsFixed(2) ?? '0.00'} / day",
                  style: const TextStyle(
                    color: Colors.green,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),

                // Location Section
                _buildInfoRow(
                  icon: Icons.location_on,
                  label: "Location",
                  value: city,
                ),
                if (locationLink != "N/A")
                  TextButton.icon(
                    onPressed: () async {
                      final Uri uri = Uri.parse(locationLink);
                      if (await canLaunchUrl(uri)) {
                        await launchUrl(uri);
                      } else {
                        // ignore: use_build_context_synchronously
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Could not open map.')),
                        );
                      }
                    },
                    icon: const Icon(Icons.map, color: Colors.blueAccent),
                    label: const Text(
                      "View on Maps",
                      style: TextStyle(color: Colors.blueAccent, fontSize: 16),
                    ),
                  ),

                const SizedBox(height: 20),

                // Category Section
                _buildInfoRow(
                  icon: Icons.category,
                  label: "Category",
                  value: toolData["category"] ?? "N/A",
                ),

                const SizedBox(height: 20),

                // Description Section
                const Text(
                  "Description",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  toolData["description"] ?? "No description available for this tool.",
                  style: const TextStyle(color: Colors.white70, fontSize: 16),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        color: Colors.white.withOpacity(0.1),
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: isAvailable ? () {
                  // TODO: Implement the Rent Now logic (e.g., navigate to a booking screen)
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Rent Now button pressed!')),
                  );
                } : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: isAvailable ? Colors.greenAccent : Colors.grey,
                  foregroundColor: isAvailable ? Colors.black : Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
                child: Text(
                  isAvailable ? "Rent Now" : "Not Available",
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow({required IconData icon, required String label, required String value}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Colors.white70),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(color: Colors.white70, fontSize: 16),
              ),
            ],
          ),
        ),
      ],
    );
  }
}