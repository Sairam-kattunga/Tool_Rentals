import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tool_rental_app/widgets/animated_button.dart';
import 'package:tool_rental_app/screens/UserAccount/AddAddressScreen.dart'; // To navigate to the 'Add Address' form

class SelectAddressScreen extends StatefulWidget {
  final Map<String, dynamic> toolData;

  const SelectAddressScreen({super.key, required this.toolData});

  @override
  State<SelectAddressScreen> createState() => _SelectAddressScreenState();
}

class _SelectAddressScreenState extends State<SelectAddressScreen> {
  String? _selectedAddressId;
  bool _isLoading = false;

  Future<void> _saveTool() async {
    if (_selectedAddressId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select an address.")),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception("User not logged in");
      }

      final addressDoc = await FirebaseFirestore.instance
          .collection('userAddresses')
          .doc(_selectedAddressId)
          .get();

      if (!addressDoc.exists) {
        throw Exception("Selected address not found.");
      }

      final addressData = addressDoc.data() as Map<String, dynamic>;

      final docRef = FirebaseFirestore.instance.collection("tools").doc();
      await docRef.set({
        "ownerId": user.uid,
        ...widget.toolData,
        "city": addressData['city'],
        "location": addressData['location'],
        "createdAt": FieldValue.serverTimestamp(),
      });

      setState(() => _isLoading = false);
      _showSuccessDialog();
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${e.toString()}")),
      );
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF203a43),
        title: const Text("Success", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: const Text("Your tool has been listed successfully!", style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.pushReplacementNamed(context, '/home');
            },
            child: const Text("OK", style: TextStyle(color: Colors.greenAccent)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Select Address", style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF203a43),
        iconTheme: const IconThemeData(color: Colors.white),
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
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(16.0, 24.0, 16.0, 16.0),
              child: Column(
                children: [
                  Text(
                    "Select an Address",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Choose the address where your tool is located.",
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.add_circle, color: Colors.greenAccent),
              title: const Text('Add a New Address',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.white70),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const AddAddressScreen()),
                );
              },
            ),
            const Divider(color: Colors.white24, height: 1),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('userAddresses').where('ownerId', isEqualTo: user!.uid).snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator(color: Colors.greenAccent));
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.white70)));
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text('No addresses found. Add one to continue.', style: TextStyle(color: Colors.white70)));
                  }

                  final addresses = snapshot.data!.docs;
                  return ListView.builder(
                    itemCount: addresses.length,
                    itemBuilder: (context, index) {
                      final address = addresses[index].data() as Map<String, dynamic>;
                      final addressId = addresses[index].id;
                      final isSelected = _selectedAddressId == addressId;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.greenAccent.withOpacity(0.2) : Colors.white.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected ? Colors.greenAccent : Colors.white10,
                            width: 1.5,
                          ),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                          title: Text(address['addressName'] ?? 'Unnamed Address', style: TextStyle(color: Colors.white, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
                          subtitle: Text('${address['street']}, ${address['city']}, ${address['state']}', style: const TextStyle(color: Colors.white70)),
                          trailing: isSelected ? const Icon(Icons.check_circle_rounded, color: Colors.greenAccent, size: 24) : null,
                          onTap: () {
                            setState(() {
                              _selectedAddressId = isSelected ? null : addressId;
                            });
                          },
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            if (_isLoading)
              const Padding(
                padding: EdgeInsets.all(24.0),
                child: CircularProgressIndicator(color: Colors.greenAccent),
              )
            else
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: SizedBox(
                  width: double.infinity,
                  child: AnimatedButton(
                    text: "List Tool",
                    onTap: _saveTool,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}