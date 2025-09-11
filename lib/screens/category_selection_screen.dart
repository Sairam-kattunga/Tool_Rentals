import 'package:flutter/material.dart';

class CategorySelectionScreen extends StatefulWidget {
  final List<String> categories;
  final Map<String, IconData> categoryIcons;
  final String initialCategory;

  const CategorySelectionScreen({
    super.key,
    required this.categories,
    required this.categoryIcons,
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
                childAspectRatio: 1.2,
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
    final iconData = widget.categoryIcons[cat] ?? Icons.category;
    return InkWell(
      onTap: () {
        // Pop the screen and return the selected category name
        Navigator.pop(context, cat);
      },
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? Colors.greenAccent.withOpacity(0.2) : Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? Colors.greenAccent : Colors.white24,
            width: isSelected ? 2.0 : 1.0,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              iconData,
              color: isSelected ? Colors.greenAccent : Colors.white,
              size: 40,
            ),
            const SizedBox(height: 8),
            Text(
              cat,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isSelected ? Colors.greenAccent : Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}