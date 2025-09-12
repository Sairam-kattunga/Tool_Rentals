// category_selection_screen.dart
import 'package:flutter/material.dart';

class CategorySelectionScreen extends StatefulWidget {
  final List<String> categories;
  final Map<String, String> categoryImages; // Updated: Map category → image path
  final String initialCategory;

  const CategorySelectionScreen({
    super.key,
    required this.categories,
    required this.categoryImages,
    required this.initialCategory,
  });

  @override
  State<CategorySelectionScreen> createState() => _CategorySelectionScreenState();
}

class _CategorySelectionScreenState extends State<CategorySelectionScreen> {
  late String _selectedCategory;

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.initialCategory;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Select a Category", style: TextStyle(color: Colors.white)),
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
          SafeArea(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1,
              ),
              itemCount: widget.categories.length,
              itemBuilder: (context, index) {
                final cat = widget.categories[index];
                final isSelected = cat == _selectedCategory;
                return _buildCategoryGridItem(cat, isSelected);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryGridItem(String cat, bool isSelected) {
    // Corrected fallback image path to match the rest of the app's asset structure
    final imagePath = widget.categoryImages[cat] ?? "assets/category/miscellaneous.png";

    return InkWell(
      onTap: () {
        Navigator.pop(context, cat); // Return selected category
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? Colors.greenAccent : Colors.white24,
            width: isSelected ? 3.0 : 1.0,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(
                imagePath,
                fit: BoxFit.cover,
              ),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.black.withOpacity(0.6), Colors.transparent],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                  ),
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    cat,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: isSelected ? Colors.greenAccent : Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      shadows: [
                        Shadow(
                          blurRadius: 6,
                          color: Colors.black,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}