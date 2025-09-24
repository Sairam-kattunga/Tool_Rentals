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

  /// Map each category to its corresponding local image
  final Map<String, String> _categoryImages = {
    "Home & Garden": "lib/assets/Categories/Home_Garden.png",
    "Automotive": "lib/assets/Categories/Automotive.png",
    "Electronics": "lib/assets/Categories/Electronics.png",
    "Construction": "lib/assets/Categories/Construction.png",
    "Events": "lib/assets/Categories/Events.png",
    "Sports & Outdoors": "lib/assets/Categories/Sports_Outdoors.png",
    "Medical & Health": "lib/assets/Categories/Medical_Health.png",
    "Office": "lib/assets/Categories/Office.png",
    "Photography & Video": "lib/assets/Categories/Photography_video.png",
    "Musical Instruments": "lib/assets/Categories/Musical_Instruments.png",
    "Party Supplies": "lib/assets/Categories/Party_Supplies.png",
    "Heavy Machinery": "lib/assets/Categories/Heavy_Machinary.png",
    "Miscellaneous": "lib/assets/Categories/Miscellaneous.png",
    "All": "lib/assets/Categories/All.png",
  };

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (bool didPop) {
        if (didPop) return;
        Navigator.pushReplacementNamed(context, '/home');
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
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            onChanged: (value) {
                              setState(() {
                                _searchQuery = value;
                              });
                            },
                            decoration: InputDecoration(
                              hintText: "Search by name, category, or tool ID...",
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
                        _buildSortButton(),
                      ],
                    ),
                  ),
                  _buildCategoryFilter(),
                  const SizedBox(height: 10),
                  Expanded(
                    child: StreamBuilder<QuerySnapshot>(
                      // Corrected: Always fetch all tools for local filtering
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

                        // Filter tools based on category and search query
                        var tools = snapshot.data!.docs.where((doc) {
                          final data = doc.data() as Map<String, dynamic>;
                          final category = (data["category"] ?? "").toString().toLowerCase();
                          final name = (data["name"] ?? "").toString().toLowerCase();
                          final docId = doc.id;

                          final categoryMatch = _selectedCategory == "All" || category == _selectedCategory.toLowerCase();

                          // Corrected: Local search logic for partial matches
                          final searchMatch = _searchQuery.isEmpty ||
                              docId.contains(_searchQuery) ||
                              name.contains(_searchQuery.toLowerCase()) ||
                              category.contains(_searchQuery.toLowerCase());

                          return categoryMatch && searchMatch;
                        }).toList();

                        // Sort the filtered list
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
                            childAspectRatio: 0.7,
                          ),
                          itemCount: tools.length,
                          itemBuilder: (context, index) {
                            final toolDoc = tools[index];
                            final docId = toolDoc.id;
                            return _buildToolGridItem(context, docId);
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

  Widget _buildCategoryFilter() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: InkWell(
        onTap: () async {
          final selected = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CategorySelectionScreen(
                categories: categories,
                categoryImages: _categoryImages,
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
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              const Icon(Icons.category, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  _selectedCategory,
                  style: const TextStyle(color: Colors.white, overflow: TextOverflow.ellipsis),
                ),
              ),
              const Icon(Icons.arrow_drop_down, color: Colors.white),
            ],
          ),
        ),
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

  Widget _buildToolGridItem(BuildContext context, String docId) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection("tools").doc(docId).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator(color: Colors.white));
        }

        final toolData = snapshot.data!.data() as Map<String, dynamic>;
        final bool isAvailable = toolData["available"] ?? false;
        final String category = toolData["category"] ?? "Miscellaneous";
        final String imagePath = _categoryImages[category] ?? "lib/assets/Categories/Miscellaneous.png";

        return InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ToolDetailScreen(
                  docId: docId,
                ),
              ),
            );
          },
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white24),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  child: Image.asset(
                    imagePath,
                    height: 100,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
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
                              maxLines: 1,
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
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: isAvailable
                                ? () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ToolDetailScreen(
                                    docId: docId,
                                  ),
                                ),
                              );
                            }
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isAvailable ? Colors.greenAccent : Colors.grey,
                              foregroundColor: isAvailable ? Colors.black : Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            ),
                            child: Text(isAvailable ? "Rent" : "Unavailable"),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// A simple StarRating widget for displaying star ratings
class StarRating extends StatelessWidget {
  final double rating;

  const StarRating({super.key, required this.rating});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
        5,
            (index) {
          int fullStars = rating.floor();
          double remainder = rating - fullStars;
          if (index < fullStars) {
            return const Icon(Icons.star, color: Colors.amber, size: 18);
          } else if (index == fullStars && remainder >= 0.5) {
            return const Icon(Icons.star_half, color: Colors.amber, size: 18);
          } else {
            return const Icon(Icons.star_border, color: Colors.amber, size: 18);
          }
        },
      ),
    );
  }
}