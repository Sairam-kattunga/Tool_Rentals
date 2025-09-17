import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'edit_tool_screen.dart'; // Assume this screen exists
import 'edit_package_screen.dart'; // Assume this screen exists

class MyToolsScreen extends StatefulWidget {
  const MyToolsScreen({super.key});

  @override
  State<MyToolsScreen> createState() => _MyToolsScreenState();
}

class _MyToolsScreenState extends State<MyToolsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String _searchQuery = "";
  String _sortOption = "Name: A-Z";

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // --- Tool-Specific Dialogs ---
  void _showToolOptionsDialog(BuildContext context, String docId, Map<String, dynamic> toolData) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xFF203a43),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(toolData["name"] ?? "Tool Options", style: const TextStyle(color: Colors.white)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.edit, color: Colors.blueAccent),
                title: const Text("Edit Tool Details", style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.of(dialogContext).pop();
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => EditToolScreen(
                        docId: docId,
                        initialData: toolData,
                      ),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete_forever, color: Colors.redAccent),
                title: const Text("Delete Tool", style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.of(dialogContext).pop();
                  _confirmAndDeleteTool(context, docId, toolData["name"]);
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text("Cancel", style: TextStyle(color: Colors.white70)),
            ),
          ],
        );
      },
    );
  }

  void _confirmAndDeleteTool(BuildContext context, String docId, String toolName) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xFF203a43),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text("Confirm Deletion", style: TextStyle(color: Colors.white)),
          content: Text(
            "Are you sure you want to delete '$toolName'?",
            style: const TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text("Cancel", style: TextStyle(color: Colors.white70)),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  await FirebaseFirestore.instance.collection("tools").doc(docId).delete();
                  if (dialogContext.mounted) {
                    Navigator.of(dialogContext).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Tool '$toolName' deleted successfully.")),
                    );
                  }
                } catch (e) {
                  if (dialogContext.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Error deleting tool: $e")),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text("Delete"),
            ),
          ],
        );
      },
    );
  }

  // --- Package-Specific Dialogs ---
  void _showPackageOptionsDialog(BuildContext context, String docId, Map<String, dynamic> packageData) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xFF203a43),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(packageData["title"] ?? "Package Options", style: const TextStyle(color: Colors.white)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.edit, color: Colors.blueAccent),
                title: const Text("Edit Package Details", style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.of(dialogContext).pop();
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => EditPackageScreen(
                        docId: docId,
                        initialData: packageData,
                      ),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete_forever, color: Colors.redAccent),
                title: const Text("Delete Package", style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.of(dialogContext).pop();
                  _confirmAndDeletePackage(context, docId, packageData["title"]);
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text("Cancel", style: TextStyle(color: Colors.white70)),
            ),
          ],
        );
      },
    );
  }

  void _confirmAndDeletePackage(BuildContext context, String docId, String packageName) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xFF203a43),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text("Confirm Deletion", style: TextStyle(color: Colors.white)),
          content: Text(
            "Are you sure you want to delete '$packageName'?",
            style: const TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text("Cancel", style: TextStyle(color: Colors.white70)),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  await FirebaseFirestore.instance.collection("packages").doc(docId).delete();
                  if (dialogContext.mounted) {
                    Navigator.of(dialogContext).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Package '$packageName' deleted successfully.")),
                    );
                  }
                } catch (e) {
                  if (dialogContext.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Error deleting package: $e")),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text("Delete"),
            ),
          ],
        );
      },
    );
  }

  // --- Main Build Method and Widgets ---
  Future<bool> _handleBackNavigation() async {
    Navigator.pushReplacementNamed(context, '/home');
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;
    if (user == null) {
      return const Center(child: Text("Please log in to view your tools."));
    }

    return WillPopScope(
      onWillPop: _handleBackNavigation,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("My Listings", style: TextStyle(color: Colors.white)),
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
          bottom: TabBar(
            controller: _tabController,
            labelColor: Colors.greenAccent,
            unselectedLabelColor: Colors.white70,
            indicatorColor: Colors.greenAccent,
            tabs: const [
              Tab(text: "My Tools"),
              Tab(text: "My Packages"),
            ],
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
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildToolsList(user),
                  _buildPackagesList(user),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchAndSortBar() {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              onChanged: (value) => setState(() => _searchQuery = value.toLowerCase()),
              decoration: InputDecoration(
                hintText: "Search your listings...",
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
    );
  }

  Widget _buildToolsList(User user) {
    return Column(
      children: [
        _buildSearchAndSortBar(),
        Expanded(
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

              var tools = snapshot.data!.docs.where((doc) {
                final data = doc.data() as Map<String, dynamic>;
                final name = (data["name"] ?? "").toString().toLowerCase();
                final category = (data["category"] ?? "").toString().toLowerCase();
                final searchMatch = name.contains(_searchQuery) || category.contains(_searchQuery);
                return searchMatch;
              }).toList();

              tools.sort((a, b) {
                final dataA = a.data() as Map<String, dynamic>;
                final dataB = b.data() as Map<String, dynamic>;
                final nameA = dataA["name"] ?? "";
                final nameB = dataB["name"] ?? "";
                final priceA = dataA["pricePerDay"] ?? 0.0;
                final priceB = dataB["pricePerDay"] ?? 0.0;
                final availA = dataA["available"] ?? false;
                final availB = dataB["available"] ?? false;

                switch (_sortOption) {
                  case "Name: A-Z":
                    return nameA.compareTo(nameB);
                  case "Name: Z-A":
                    return nameB.compareTo(nameA);
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

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: ListView.builder(
                  itemCount: tools.length,
                  itemBuilder: (context, index) {
                    final toolDoc = tools[index];
                    final toolData = toolDoc.data() as Map<String, dynamic>;
                    return _buildMyToolCard(context, toolData, toolDoc.id);
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPackagesList(User user) {
    return Column(
      children: [
        _buildSearchAndSortBar(),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection("packages")
                .where("userId", isEqualTo: user.uid)
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
                    "You have no packages listed.",
                    style: TextStyle(color: Colors.white70, fontSize: 18),
                  ),
                );
              }

              var packages = snapshot.data!.docs.where((doc) {
                final data = doc.data() as Map<String, dynamic>;
                final name = (data["title"] ?? "").toString().toLowerCase();
                final category = (data["category"] ?? "").toString().toLowerCase();
                final searchMatch = name.contains(_searchQuery) || category.contains(_searchQuery);
                return searchMatch;
              }).toList();

              packages.sort((a, b) {
                final dataA = a.data() as Map<String, dynamic>;
                final dataB = b.data() as Map<String, dynamic>;
                final nameA = dataA["title"] ?? "";
                final nameB = dataB["title"] ?? "";
                final priceA = dataA["dailyRate"] ?? 0.0;
                final priceB = dataB["dailyRate"] ?? 0.0;
                final availA = dataA["isAvailable"] ?? false;
                final availB = dataB["isAvailable"] ?? false;

                switch (_sortOption) {
                  case "Name: A-Z":
                    return nameA.compareTo(nameB);
                  case "Name: Z-A":
                    return nameB.compareTo(nameA);
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

              if (packages.isEmpty) {
                return const Center(
                  child: Text("No packages match your filters.", style: TextStyle(color: Colors.white70, fontSize: 18)),
                );
              }

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: ListView.builder(
                  itemCount: packages.length,
                  itemBuilder: (context, index) {
                    final packageDoc = packages[index];
                    final packageData = packageDoc.data() as Map<String, dynamic>;
                    return _buildMyPackageCard(context, packageData, packageDoc.id);
                  },
                ),
              );
            },
          ),
        ),
      ],
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
        const PopupMenuItem<String>(value: 'Name: A-Z', child: Text('Name: A-Z')),
        const PopupMenuItem<String>(value: 'Name: Z-A', child: Text('Name: Z-A')),
        const PopupMenuItem<String>(value: 'Price: Low to High', child: Text('Price: Low to High')),
        const PopupMenuItem<String>(value: 'Price: High to Low', child: Text('Price: High to Low')),
        const PopupMenuItem<String>(value: 'Availability First', child: Text('Availability First')),
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

  Widget _buildMyToolCard(BuildContext context, Map<String, dynamic> toolData, String docId) {
    final bool isAvailable = toolData["available"] ?? false;

    return InkWell(
      onTap: () => _showToolOptionsDialog(context, docId, toolData),
      child: Card(
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
                style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text("Category: ${toolData["category"] ?? "N/A"}", style: const TextStyle(color: Colors.white70)),
              const SizedBox(height: 8),
              Text(toolData["description"] ?? "", style: const TextStyle(color: Colors.white, fontStyle: FontStyle.italic)),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "₹${toolData["pricePerDay"]?.toStringAsFixed(2) ?? '0.00'} / day",
                    style: const TextStyle(color: Colors.greenAccent, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Switch(
                    value: isAvailable,
                    onChanged: (bool newValue) {
                      FirebaseFirestore.instance.collection("tools").doc(docId).update({"available": newValue});
                    },
                    activeColor: Colors.lightGreenAccent,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMyPackageCard(BuildContext context, Map<String, dynamic> packageData, String docId) {
    final bool isAvailable = packageData["isAvailable"] ?? false;

    return InkWell(
      onTap: () => _showPackageOptionsDialog(context, docId, packageData),
      child: Card(
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
                packageData["title"] ?? "Package",
                style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text("Category: ${packageData["category"] ?? "N/A"}", style: const TextStyle(color: Colors.white70)),
              const SizedBox(height: 8),
              if (packageData["tools"] != null && (packageData["tools"] as List).isNotEmpty)
                Text("Tools: ${(packageData["tools"] as List).join(', ')}", style: const TextStyle(color: Colors.white70)),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "₹${packageData["dailyRate"]?.toStringAsFixed(2) ?? '0.00'} / day",
                    style: const TextStyle(color: Colors.greenAccent, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Switch(
                    value: isAvailable,
                    onChanged: (bool newValue) {
                      FirebaseFirestore.instance.collection("packages").doc(docId).update({"isAvailable": newValue});
                    },
                    activeColor: Colors.lightGreenAccent,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
//Now make this code more functional, organized and make sure the code looks more clean by removing unnecessary things, and also add an option to delete the listings in this screen and also make sure the user can be able to see the details of the listings he posted by clicking the card. Give me an updated code