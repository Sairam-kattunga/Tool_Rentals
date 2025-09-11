import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

class RentToolScreen extends StatefulWidget {
  const RentToolScreen({super.key});

  @override
  State<RentToolScreen> createState() => _RentToolScreenState();
}

class _RentToolScreenState extends State<RentToolScreen> {
  String _searchQuery = "";
  String _selectedCategory = "All";
  String _sortOption = "Price: Low to High";

  final List<String> categories = [
    "All", "Accommodation & Spaces", "Audio & Video Equipment", "Automobiles & Vehicles",
    "Books", "Catering & Wedding Supplies", "Computers & Accessories",
    "Construction Equipment", "Electronics & Gadgets",
    "Engineering Machinery / Heavy Equipment", "Events & Party Supplies",
    "Farm & Agricultural Equipment", "Fitness & Sports Equipment",
    "Fishing Gear & Nets", "Fly & Floats (Boats, Water Sports Gear)",
    "Furniture & Decor", "Garden Tools & Outdoor Equipment",
    "Generators & Power Equipment", "Heavy Vehicles & Earthmovers",
    "Home Appliances & Utilities", "Lifestyle Products",
    "Medical Equipment & Services", "Mobile Phones & Tablets",
    "Musical Instruments", "Office Equipment & Supplies",
    "Outdoor Camping Gear", "Pets & Plants",
    "Security & Safety Equipment", "Other Products"
  ];

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushReplacementNamed(context, '/home');
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Rent a Tool", style: TextStyle(color: Colors.white)),
          backgroundColor: const Color(0xFF203a43),
          elevation: 0,
          centerTitle: true,
          iconTheme: const IconThemeData(color: Colors.white),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/home');
            },
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
              child: Column(
                children: [
                  // Search, Category, and Sort Row
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            onChanged: (value) => setState(() => _searchQuery = value.toLowerCase()),
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
                        const SizedBox(width: 10),
                        // Category Selection Button
                        _buildCategoryButton(),
                        const SizedBox(width: 10),
                        _buildSortButton(),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Tool List
                  Expanded(
                    child: StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance.collection("tools").snapshots(),
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
                              "No tools available.",
                              style: TextStyle(color: Colors.white70, fontSize: 18),
                            ),
                          );
                        }

                        var tools = snapshot.data!.docs.where((doc) {
                          final data = doc.data() as Map<String, dynamic>;
                          final name = (data["name"] ?? "").toString().toLowerCase();
                          final category = (data["category"] ?? "").toString().toLowerCase();
                          final categoryMatch = _selectedCategory == "All" || category == _selectedCategory.toLowerCase();
                          final searchMatch = name.contains(_searchQuery) || category.contains(_searchQuery);
                          return categoryMatch && searchMatch;
                        }).toList();

                        tools.sort((a, b) {
                          final dataA = a.data() as Map<String, dynamic>;
                          final dataB = b.data() as Map<String, dynamic>;
                          final priceA = dataA["pricePerDay"] ?? 0.0;
                          final priceB = dataB["pricePerDay"] ?? 0.0;
                          final availA = dataA["available"] ?? false;
                          final availB = dataB["available"] ?? false;

                          switch (_sortOption) {
                            case "Price: Low to High":
                              return priceA.compareTo(priceB);
                            case "Price: High to Low":
                              return priceB.compareTo(priceA);
                            case "Availability First":
                              return availB.toString().compareTo(availA.toString());
                            default:
                              return 0;
                          }
                        });

                        if (tools.isEmpty) {
                          return const Center(
                            child: Text("No tools match your filters.", style: TextStyle(color: Colors.white70, fontSize: 18)),
                          );
                        }

                        return ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: tools.length,
                          itemBuilder: (context, index) {
                            final toolData = tools[index].data() as Map<String, dynamic>;
                            return _buildToolCard(context, toolData);
                          },
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

  // New method for the category selection button
  Widget _buildCategoryButton() {
    return ElevatedButton.icon(
      onPressed: () => _showCategoryGridDialog(),
      icon: const Icon(Icons.category, color: Colors.white),
      label: Text(
        _selectedCategory,
        style: const TextStyle(color: Colors.white),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white.withOpacity(0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }

  // New method to show the category grid dialog
  void _showCategoryGridDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF0f2027),
          title: const Text("Select a Category", style: TextStyle(color: Colors.white)),
          content: SizedBox(
            width: double.maxFinite,
            child: GridView.builder(
              shrinkWrap: true,
              itemCount: categories.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 2.5,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemBuilder: (context, index) {
                final cat = categories[index];
                final isSelected = cat == _selectedCategory;
                // You can add images here by mapping category names to image assets
                // final String imageAsset = "assets/images/${cat.toLowerCase().replaceAll(' ', '_')}.png";
                return InkWell(
                  onTap: () {
                    setState(() {
                      _selectedCategory = cat;
                    });
                    Navigator.of(context).pop();
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.greenAccent.withOpacity(0.2) : Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: isSelected ? Colors.greenAccent : Colors.white24),
                    ),
                    child: Center(
                      child: Text(
                        cat,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: isSelected ? Colors.greenAccent : Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Close", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  // Existing `_buildSortButton` and `_buildToolCard` methods can be kept as they are.
  Widget _buildSortButton() {
    return PopupMenuButton<String>(
      onSelected: (String result) {
        setState(() {
          _sortOption = result;
        });
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
        const PopupMenuItem<String>(
          value: 'Price: Low to High',
          child: Text('Price: Low to High'),
        ),
        const PopupMenuItem<String>(
          value: 'Price: High to Low',
          child: Text('Price: High to Low'),
        ),
        const PopupMenuItem<String>(
          value: 'Availability First',
          child: Text('Availability First'),
        ),
      ],
      icon: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Icon(Icons.sort, color: Colors.white),
      ),
    );
  }

  Widget _buildToolCard(BuildContext context, Map<String, dynamic> toolData) {
    final bool isAvailable = toolData["available"] ?? false;
    final String city = toolData["city"] ?? "N/A";
    final String location = toolData["location"] ?? "N/A";

    return InkWell(
      onTap: () => _showToolDetailsDialog(context, toolData),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white24),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    toolData["name"] ?? "Tool",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "₹${toolData["pricePerDay"]?.toStringAsFixed(2) ?? '0.00'} / day",
                    style: const TextStyle(
                      color: Colors.greenAccent,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              children: [
                Text(
                  isAvailable ? "Available" : "Not Available",
                  style: TextStyle(
                    color: isAvailable ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: isAvailable ? () => _showToolDetailsDialog(context, toolData) : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isAvailable ? Colors.greenAccent : Colors.grey,
                    foregroundColor: isAvailable ? Colors.black : Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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

  void _showToolDetailsDialog(BuildContext context, Map<String, dynamic> toolData) {
    final bool isAvailable = toolData["available"] ?? false;
    final String city = toolData["city"] ?? "N/A";
    final String locationLink = toolData["location"] ?? "N/A";

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF203a43),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            toolData["name"] ?? "Tool Details",
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    const Icon(Icons.location_city, color: Colors.white70),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        city,
                        style: const TextStyle(color: Colors.white, fontSize: 16),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 12),
                    TextButton.icon(
                      onPressed: () async {
                        if (locationLink == "N/A") {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Location link not available.')),
                          );
                          return;
                        }

                        final Uri uri = Uri.parse(locationLink);
                        if (await canLaunchUrl(uri)) {
                          await launchUrl(uri);
                        } else {
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
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  "Category: ${toolData["category"] ?? "N/A"}",
                  style: const TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 12),
                Text(
                  toolData["description"] ?? "No description available.",
                  style: const TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "₹${toolData["pricePerDay"]?.toStringAsFixed(2) ?? '0.00'} / day",
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
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Close", style: TextStyle(color: Colors.white)),
            ),
            ElevatedButton(
              onPressed: isAvailable ? () {} : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: isAvailable ? Colors.greenAccent : Colors.grey,
                foregroundColor: isAvailable ? Colors.black : Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
              child: const Text("Rent Now"),
            ),
          ],
        );
      },
    );
  }
}