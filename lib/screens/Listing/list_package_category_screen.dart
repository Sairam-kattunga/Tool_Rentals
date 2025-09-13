// lib/screens/ToolPackage/list_package_category_screen.dart

import 'package:flutter/material.dart';
import 'package:tool_rental_app/screens/Listing/list_package_screen.dart';

class ListPackageCategoryScreen extends StatefulWidget {
  const ListPackageCategoryScreen({super.key});

  @override
  State<ListPackageCategoryScreen> createState() => _ListPackageCategoryScreenState();
}

class _ListPackageCategoryScreenState extends State<ListPackageCategoryScreen> {
  final List<String> categories = [
    "Home & Garden", "Automotive", "Electronics", "Construction",
    "Events", "Sports & Outdoors", "Medical & Health", "Office",
    "Photography & Video", "Musical Instruments", "Party Supplies",
    "Heavy Machinery", "Miscellaneous"
  ];

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
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("List a Package", style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF203a43),
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0f2027), Color(0xFF203a43), Color(0xFF2c5364)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0),
              child: Center(
                child: Text(
                  "Select package category",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                    shadows: [
                      Shadow(
                        blurRadius: 6.0,
                        color: Colors.black,
                        offset: Offset(2, 2),
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.0,
                  ),
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    return _buildCategoryCard(categories[index]);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryCard(String category) {
    final imageName = _categoryImages[category];

    return InkWell(
      onTap: () {
        // Navigate to the ListPackageScreen, passing the selected category
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => ListPackageScreen(selectedCategory: category),
          ),
        );
      },
      child: Card(
        color: Colors.white.withOpacity(0.08),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (imageName != null)
              Image.asset(
                imageName,
                fit: BoxFit.cover,
                color: Colors.black.withOpacity(0.4),
                colorBlendMode: BlendMode.darken,
              )
            else
              Container(
                color: Colors.black.withOpacity(0.4),
                child: const Center(child: Icon(Icons.category, color: Colors.white, size: 50)),
              ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  category,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    shadows: [
                      Shadow(
                        blurRadius: 8.0,
                        color: Colors.black,
                        offset: Offset(2.0, 2.0),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}