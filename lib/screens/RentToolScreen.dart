import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'tool_detail_screen.dart';
import 'category_selection_screen.dart';

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
    "All", "Home & Garden", "Automotive", "Electronics", "Construction",
    "Events", "Sports & Outdoors", "Medical & Health", "Office",
    "Photography & Video", "Musical Instruments", "Party Supplies",
    "Heavy Machinery", "Miscellaneous"
  ];

  final Map<String, IconData> _categoryIcons = {
    "All": Icons.apps,
    "Home & Garden": Icons.home_filled,
    "Automotive": Icons.directions_car,
    "Electronics": Icons.devices,
    "Construction": Icons.construction,
    "Events": Icons.celebration,
    "Sports & Outdoors": Icons.directions_bike,
    "Medical & Health": Icons.medical_services,
    "Office": Icons.business_center,
    "Photography & Video": Icons.camera_alt,
    "Musical Instruments": Icons.piano,
    "Party Supplies": Icons.emoji_events,
    "Heavy Machinery": Icons.engineering,
    "Miscellaneous": Icons.category,
  };

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
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
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
                  _buildCategoryAndSortBar(),
                  const SizedBox(height: 10),
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
                              return (priceA).compareTo(priceB);
                            case "Price: High to Low":
                              return (priceB).compareTo(priceA);
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

                        return GridView.builder(
                          padding: const EdgeInsets.all(16),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            childAspectRatio: 0.8,
                          ),
                          itemCount: tools.length,
                          itemBuilder: (context, index) {
                            final toolData = tools[index].data() as Map<String, dynamic>;
                            return _buildToolGridItem(context, toolData);
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

  Widget _buildCategoryAndSortBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () async {
                final selected = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CategorySelectionScreen(
                      categories: categories,
                      categoryIcons: _categoryIcons,
                      initialCategory: _selectedCategory,
                    ),
                  ),
                );
                if (selected != null && selected is String) {
                  setState(() {
                    _selectedCategory = selected;
                  });
                }
              },
              icon: Icon(_categoryIcons[_selectedCategory] ?? Icons.category, color: Colors.white),
              label: Text(
                _selectedCategory,
                style: const TextStyle(color: Colors.white, overflow: TextOverflow.ellipsis),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white.withOpacity(0.1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
          const SizedBox(width: 10),
          _buildSortButton(),
        ],
      ),
    );
  }

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

  Widget _buildToolGridItem(BuildContext context, Map<String, dynamic> toolData) {
    final bool isAvailable = toolData["available"] ?? false;
    final String category = toolData["category"] ?? "Miscellaneous";
    final IconData categoryIcon = _categoryIcons[category] ?? Icons.category;

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ToolDetailScreen(toolData: toolData),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white24),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Align(
              alignment: Alignment.topRight,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isAvailable ? Colors.green.withOpacity(0.2) : Colors.red.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  isAvailable ? "Available" : "Not Available",
                  style: TextStyle(
                    color: isAvailable ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: Icon(categoryIcon, color: Colors.white, size: 48),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    toolData["name"] ?? "Tool",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "₹${toolData["pricePerDay"]?.toStringAsFixed(2) ?? '0.00'} / day",
                    style: const TextStyle(
                      color: Colors.greenAccent,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ToolDetailScreen(toolData: toolData),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: isAvailable ? Colors.greenAccent : Colors.grey,
                  foregroundColor: isAvailable ? Colors.black : Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
                child: const Text("Rent"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}