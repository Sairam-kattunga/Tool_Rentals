import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ToolDetailScreen extends StatelessWidget {
  final Map<String, dynamic> toolData;
  final Map<String, String> categoryImages; // pass category → image map

  const ToolDetailScreen({
    super.key,
    required this.toolData,
    required this.categoryImages,
  });

  @override
  Widget build(BuildContext context) {
    final bool isAvailable = toolData["available"] ?? false;
    final String city = toolData["city"] ?? "N/A";
    final String locationLink = toolData["location"] ?? "N/A";
    final String category = toolData["category"] ?? "Miscellaneous";
    final String headerImage =
    // Corrected fallback image path to match the asset structure
    categoryImages[category] ?? "lib/assets/Categories/Miscellaneous.png";

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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 🔹 Header Image with overlay
                Stack(
                  children: [
                    Image.asset(
                      headerImage,
                      height: 220,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                    Container(
                      height: 220,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.black.withOpacity(0.6),
                            Colors.transparent
                          ],
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                        ),
                      ),
                    ),
                    Positioned(
                      left: 16,
                      bottom: 16,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            toolData["name"] ?? "Tool",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            isAvailable ? "Available" : "Not Available",
                            style: TextStyle(
                              color: isAvailable
                                  ? Colors.greenAccent
                                  : Colors.redAccent,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                // 🔹 Details Section
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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
                            try {
                              if (!await launchUrl(uri)) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text('Could not open map.')),
                                );
                              }
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('An error occurred.')),
                              );
                            }
                          },
                          icon: const Icon(Icons.map, color: Colors.blueAccent),
                          label: const Text(
                            "View on Maps",
                            style: TextStyle(
                                color: Colors.blueAccent, fontSize: 16),
                          ),
                        ),

                      const SizedBox(height: 20),

                      // Category Section
                      _buildInfoRow(
                        icon: Icons.category,
                        label: "Category",
                        value: category,
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
                        toolData["description"] ??
                            "No description available for this tool.",
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 16),
                      ),
                    ],
                  ),
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
                onPressed: isAvailable
                    ? () {
                  // TODO: Implement booking flow
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Rent Now button pressed!')),
                  );
                }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                  isAvailable ? Colors.greenAccent : Colors.grey,
                  foregroundColor:
                  isAvailable ? Colors.black : Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)),
                ),
                child: Text(
                  isAvailable ? "Rent Now" : "Not Available",
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
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