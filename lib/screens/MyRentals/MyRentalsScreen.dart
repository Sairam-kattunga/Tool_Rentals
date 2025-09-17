import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

// Placeholder imports - ensure these files exist
import 'package:tool_rental_app/screens/RentTool/tool_detail_screen.dart';
import 'chat_screen.dart';

class MyRentalsScreen extends StatefulWidget {
  const MyRentalsScreen({super.key});

  @override
  State<MyRentalsScreen> createState() => _MyRentalsScreenState();
}

class _MyRentalsScreenState extends State<MyRentalsScreen> {
  static const Map<String, String> trackingSteps = {
    'pending': '1. Request Sent',
    'accepted': '2. Accepted by Owner',
    'collected-renter': '3. Renter Confirmed Collection',
    'collected': '3. Item Collected',
    'returned-renter': '4. Renter Confirmed Return',
    'returned': '4. Owner Confirmed Return',
    'completed': '5. Transaction Completed',
    'rejected': 'Request Rejected',
  };

  final DateFormat _dateFormat = DateFormat.yMMMd().add_jm();
  int _selectedIndex = 0; // 0 for Active, 1 for History
  int _historyTabIndex = 0; // 0 for Borrowed, 1 for Shared, 2 for Rejected

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

  String formatTimestamp(Timestamp? ts) {
    if (ts == null) return 'N/A';
    try {
      return _dateFormat.format(ts.toDate());
    } catch (e) {
      return 'N/A';
    }
  }

  Future<bool> _handleBackNavigation() async {
    Navigator.pushReplacementNamed(context, '/home');
    return false;
  }

  void _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Could not launch phone app.")),
        );
      }
    }
  }

  void _copyToClipboard(BuildContext context, String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("ID copied to clipboard")),
    );
  }

  void _showTrackingDialog(BuildContext context, String currentStatus, Map<String, dynamic> rentalData, String docId, Map<String, dynamic> itemData, String itemType) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xFF0b2a33),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text("Rental Status", style: TextStyle(color: Colors.white)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ...trackingSteps.entries.map((step) {
                  final keys = trackingSteps.keys.toList();
                  final isCurrent = step.key == currentStatus;
                  final isCompleted = keys.indexOf(step.key) < keys.indexOf(currentStatus);
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 26,
                          height: 26,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isCompleted || isCurrent ? Colors.greenAccent : Colors.white54,
                          ),
                          child: Center(
                            child: Icon(
                              isCompleted ? Icons.check : Icons.circle,
                              color: Colors.black,
                              size: 14,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            step.value,
                            style: TextStyle(
                              color: isCurrent || isCompleted ? Colors.white : Colors.white54,
                              fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
                const SizedBox(height: 16),
                FutureBuilder<DocumentSnapshot>(
                  future: FirebaseFirestore.instance.collection('users').doc(rentalData['ownerId'] == FirebaseAuth.instance.currentUser!.uid ? rentalData['renterId'] : rentalData['ownerId']).get(),
                  builder: (context, userSnapshot) {
                    if (userSnapshot.connectionState == ConnectionState.waiting) return const CircularProgressIndicator();
                    if (!userSnapshot.hasData) return const SizedBox.shrink();
                    final otherUser = userSnapshot.data!.data() as Map<String, dynamic>;
                    final phoneNumber = otherUser['contact'] ?? '';
                    final isOwner = rentalData['ownerId'] == FirebaseAuth.instance.currentUser!.uid;

                    return ElevatedButton.icon(
                      onPressed: phoneNumber.isNotEmpty
                          ? () => _makePhoneCall(phoneNumber)
                          : null,
                      icon: const Icon(Icons.phone, color: Colors.green),
                      label: const Text("Call", style: TextStyle(color: Colors.black)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.greenAccent,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text("Close", style: TextStyle(color: Colors.white70)),
            ),
          ],
        );
      },
    );
  }

  void _showCompletedDialog(BuildContext context, Map<String, dynamic> rentalData, String itemType) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        final isOwner = rentalData['ownerId'] == FirebaseAuth.instance.currentUser!.uid;
        final itemIdKey = itemType == 'tool' ? 'toolId' : 'packageId';
        final itemId = rentalData[itemIdKey] ?? 'N/A';

        return AlertDialog(
          backgroundColor: const Color(0xFF0b2a33),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(rentalData['itemName'] ?? 'Item', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Status: ${rentalData['status']?.toUpperCase()}", style: const TextStyle(color: Colors.greenAccent)),
                const SizedBox(height: 8),
                Text(
                  isOwner
                      ? "Renter: ${rentalData['renterName'] ?? 'N/A'}"
                      : "Owner: ${rentalData['ownerName'] ?? 'N/A'}",
                  style: const TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 12),
                _buildHistoryInfoRow(label: "${itemType == 'tool' ? 'Tool' : 'Package'} ID", value: itemId),
                _buildHistoryInfoRow(label: "Requested On", value: formatTimestamp(rentalData['requestDate'])),
                _buildHistoryInfoRow(label: "Accepted On", value: formatTimestamp(rentalData['responseDate'])),
                _buildHistoryInfoRow(label: "Collected On", value: formatTimestamp(rentalData['collectedAt'])),
                _buildHistoryInfoRow(label: "Returned On", value: formatTimestamp(rentalData['returnedAt'])),
                _buildHistoryInfoRow(label: "Completed On", value: formatTimestamp(rentalData['completedAt'])),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text("Close", style: TextStyle(color: Colors.white70)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildHistoryInfoRow({required String label, required String value}) {
    if (value == 'N/A') return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Text(
            "$label: ",
            style: const TextStyle(color: Colors.white, fontSize: 14),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.white70, fontSize: 14),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (label.contains("ID"))
            IconButton(
              icon: const Icon(Icons.copy, color: Colors.white54, size: 14),
              onPressed: () => _copyToClipboard(context, value),
            ),
        ],
      ),
    );
  }

  Future<void> _handleRequest(BuildContext context, String docId, String newStatus, String itemType) async {
    try {
      final collectionName = 'rentalRequests';
      final docRef = FirebaseFirestore.instance.collection(collectionName).doc(docId);
      final doc = await docRef.get();
      if (!doc.exists) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Request not found.')));
        return;
      }
      final rentalData = doc.data() as Map<String, dynamic>;
      final currentUserId = FirebaseAuth.instance.currentUser!.uid;

      Map<String, dynamic> updateData = {'status': newStatus};

      if (newStatus == 'accepted') {
        updateData['responseDate'] = FieldValue.serverTimestamp();
      } else if (newStatus == 'collected' && rentalData['ownerId'] == currentUserId) {
        updateData['collectedAt'] = FieldValue.serverTimestamp();
      } else if (newStatus == 'returned' && rentalData['ownerId'] == currentUserId) {
        updateData['returnedAt'] = FieldValue.serverTimestamp();
      } else if (newStatus == 'completed' && rentalData['ownerId'] == currentUserId) {
        final completedDoc = {
          ...rentalData,
          'status': 'completed',
          'completedAt': FieldValue.serverTimestamp(),
          'participants': [rentalData['ownerId'], rentalData['renterId']],
        };
        await FirebaseFirestore.instance.collection('completedRentals').add(completedDoc);

        final itemRef = FirebaseFirestore.instance.collection('${itemType}s').doc(rentalData['${itemType}Id']);
        await itemRef.update({'isAvailable': true});
        await docRef.delete();
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Transaction completed and moved to history!')));
        return;
      } else if (newStatus == 'rejected') {
        final rejectedDoc = {
          ...rentalData,
          'status': 'rejected',
          'rejectedAt': FieldValue.serverTimestamp(),
          'participants': [rentalData['ownerId'], rentalData['renterId']],
        };
        await FirebaseFirestore.instance.collection('rejectedRentals').add(rejectedDoc);
        await docRef.delete();
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Request rejected and moved to history.')));
        return;
      }

      await docRef.update(updateData);

      if (newStatus == 'accepted') {
        final itemRef = FirebaseFirestore.instance.collection('${itemType}s').doc(rentalData['${itemType}Id']);
        await itemRef.update({'isAvailable': false});
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Request updated to $newStatus')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to update request: $e')));
    }
  }

  Widget _buildRentalRequestCard(BuildContext context, QueryDocumentSnapshot doc, String userType) {
    final rentalData = doc.data() as Map<String, dynamic>;
    final status = rentalData['status'] as String? ?? 'pending';

    final isPackage = rentalData['packageId'] != null;
    final itemType = isPackage ? 'package' : 'tool';
    final itemId = isPackage ? rentalData['packageId'] : rentalData['toolId'];

    if (itemId == null) {
      return Card(
        color: Colors.white.withOpacity(0.06),
        margin: const EdgeInsets.symmetric(vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: const ListTile(
          title: Text('Error: Item ID not found', style: TextStyle(color: Colors.redAccent)),
          subtitle: Text('This rental request is missing key information.', style: TextStyle(color: Colors.white70)),
        ),
      );
    }

    final collectionName = isPackage ? 'packages' : 'tools';
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection(collectionName).doc(itemId).get(),
      builder: (context, itemSnapshot) {
        if (itemSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: Colors.white70));
        }

        final itemData = itemSnapshot.data?.data() as Map<String, dynamic>? ?? {};
        final category = itemData['category'] ?? "Miscellaneous";
        final headerImage = _categoryImages[category] ?? "lib/assets/Categories/Miscellaneous.png";

        final title = itemData['title'] ?? itemData['name'] ?? rentalData['itemName'] ?? 'Item';
        final subtitle = userType == 'owner'
            ? "Renter: ${rentalData['renterName'] ?? 'N/A'}"
            : "Owner: ${rentalData['ownerName'] ?? 'N/A'}";

        return InkWell(
          onTap: () => _showTrackingDialog(context, status, rentalData, doc.id, itemData, itemType),
          child: Card(
            color: Colors.white.withOpacity(0.06),
            margin: const EdgeInsets.symmetric(vertical: 8),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.asset(
                      headerImage,
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          subtitle,
                          style: const TextStyle(color: Colors.white70, fontSize: 14),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Text(
                              "ID: $itemId",
                              style: const TextStyle(color: Colors.white54, fontSize: 12),
                            ),
                            IconButton(
                              icon: const Icon(Icons.copy, color: Colors.white54, size: 14),
                              onPressed: () => _copyToClipboard(context, itemId),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        _buildStatusBadge(status),
                      ],
                    ),
                  ),
                  _buildActionButtons(context, doc.id, rentalData, status, itemType),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildActionButtons(BuildContext context, String docId, Map<String, dynamic> rentalData, String status, String itemType) {
    bool isOwner = rentalData['ownerId'] == FirebaseAuth.instance.currentUser!.uid;

    if (isOwner) {
      switch (status) {
        case 'pending':
          return Flexible(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _handleRequest(context, docId, 'accepted', itemType),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.greenAccent),
                    child: const Text('Accept', style: TextStyle(color: Colors.black)),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _handleRequest(context, docId, 'rejected', itemType),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                    child: const Text('Reject', style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            ),
          );
        case 'collected-renter':
          return Flexible(
            child: ElevatedButton(
              onPressed: () => _handleRequest(context, docId, 'collected', itemType),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.greenAccent),
              child: const Text('Confirm Collection', style: TextStyle(color: Colors.black)),
            ),
          );
        case 'returned-renter':
          return Flexible(
            child: ElevatedButton(
              onPressed: () => _handleRequest(context, docId, 'returned', itemType),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.greenAccent),
              child: const Text('Confirm Return', style: TextStyle(color: Colors.black)),
            ),
          );
        case 'returned':
          return Flexible(
            child: ElevatedButton(
              onPressed: () => _handleRequest(context, docId, 'completed', itemType),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.greenAccent),
              child: const Text('Confirm & Close', style: TextStyle(color: Colors.black)),
            ),
          );
      }
    } else { // renter
      switch (status) {
        case 'accepted':
          return Flexible(
            child: ElevatedButton(
              onPressed: () => _handleRequest(context, docId, 'collected-renter', itemType),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.greenAccent),
              child: const Text('Item Collected', style: TextStyle(color: Colors.black)),
            ),
          );
        case 'collected':
          return Flexible(
            child: ElevatedButton(
              onPressed: () => _handleRequest(context, docId, 'returned-renter', itemType),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent),
              child: const Text('Return Item', style: TextStyle(color: Colors.white)),
            ),
          );
      }
    }
    return const SizedBox.shrink();
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    IconData icon;
    String text;

    switch (status) {
      case 'pending':
        color = Colors.orange;
        icon = Icons.access_time;
        text = 'Pending';
        break;
      case 'accepted':
        color = Colors.blueAccent;
        icon = Icons.check_circle_outline;
        text = 'Accepted';
        break;
      case 'collected':
      case 'collected-renter':
        color = Colors.green;
        icon = Icons.handshake;
        text = 'In Use';
        break;
      case 'returned-renter':
      case 'returned':
        color = Colors.teal;
        icon = Icons.autorenew;
        text = 'Returning';
        break;
      case 'completed':
        color = Colors.green;
        icon = Icons.done_all;
        text = 'Completed';
        break;
      case 'rejected':
        color = Colors.redAccent;
        icon = Icons.cancel;
        text = 'Rejected';
        break;
      default:
        color = Colors.grey;
        icon = Icons.help_outline;
        text = 'Unknown';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryList(String userId, String historyType) {
    Query query;
    if (historyType == 'borrowed') {
      query = FirebaseFirestore.instance
          .collection('completedRentals')
          .where('renterId', isEqualTo: userId)
          .orderBy('completedAt', descending: true);
    } else if (historyType == 'shared') {
      query = FirebaseFirestore.instance
          .collection('completedRentals')
          .where('ownerId', isEqualTo: userId)
          .orderBy('completedAt', descending: true);
    } else { // 'rejected'
      query = FirebaseFirestore.instance
          .collection('rejectedRentals')
          .where('participants', arrayContains: userId)
          .orderBy('rejectedAt', descending: true);
    }

    return StreamBuilder<QuerySnapshot>(
      stream: query.snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: Colors.greenAccent));
        }
        if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}", style: const TextStyle(color: Colors.white70)));
        }
        final docs = snapshot.data?.docs ?? [];
        if (docs.isEmpty) {
          return Padding(
            padding: const EdgeInsets.all(24.0),
            child: Center(child: Text("No ${historyType} items in your history.", style: const TextStyle(color: Colors.white70))),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final rentalData = docs[index].data() as Map<String, dynamic>;
            final isRenter = rentalData['renterId'] == userId;
            final isPackage = rentalData['packageId'] != null;
            final itemType = isPackage ? 'package' : 'tool';
            final itemIdKey = isPackage ? 'packageId' : 'toolId';
            final itemId = rentalData[itemIdKey] ?? 'N/A';
            final itemName = rentalData['itemName'] ?? 'Item';

            return Card(
              color: Colors.white.withOpacity(0.06),
              margin: const EdgeInsets.symmetric(vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                onTap: () {
                  if (historyType == 'rejected') {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('This request was rejected.')));
                  } else {
                    _showCompletedDialog(context, rentalData, itemType);
                  }
                },
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                title: Text(itemName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      historyType == 'borrowed'
                          ? "Rented from: ${rentalData['ownerName'] ?? 'N/A'}"
                          : "Rented by: ${rentalData['renterName'] ?? 'N/A'}",
                      style: const TextStyle(color: Colors.white70),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          "ID: $itemId",
                          style: const TextStyle(color: Colors.white54, fontSize: 12),
                        ),
                        IconButton(
                          icon: const Icon(Icons.copy, color: Colors.white54, size: 14),
                          onPressed: () => _copyToClipboard(context, itemId),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                  ],
                ),
                trailing: isRenter && historyType == 'borrowed'
                    ? IconButton(
                  icon: const Icon(Icons.rate_review, color: Colors.white70),
                  onPressed: () {
                    if (rentalData[itemIdKey] == null) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Item data not available for review.")));
                      return;
                    }
                    _showReviewDialog(context, rentalData, isPackage);
                  },
                )
                    : null, // Disable review button for owners and rejected items
              ),
            );
          },
        );
      },
    );
  }

  void _showReviewDialog(BuildContext context, Map<String, dynamic> rentalData, bool isPackage) {
    double rating = 5.0;
    final controller = TextEditingController();
    final reviewCollection = isPackage ? 'packageReviews' : 'toolReviews';
    final itemCollection = isPackage ? 'packages' : 'tools';
    final itemIdKey = isPackage ? 'packageId' : 'toolId';

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF0b2a33),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: const Text("Leave a Review", style: TextStyle(color: Colors.white)),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text("Review for: ${rentalData['itemName']}", style: const TextStyle(color: Colors.white70)),
                    const SizedBox(height: 16),
                    StarRating(
                      rating: rating,
                      enableInteraction: true,
                      onRatingChanged: (r) {
                        setState(() => rating = r.toDouble());
                      },
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: controller,
                      maxLines: 3,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Write your review...',
                        hintStyle: const TextStyle(color: Colors.white54),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.1),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text("Cancel", style: TextStyle(color: Colors.white70)),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final uid = FirebaseAuth.instance.currentUser!.uid;
                    final reviewerName = (await FirebaseFirestore.instance.collection('users').doc(uid).get()).data()?['name'] ?? 'User';

                    final itemRef = FirebaseFirestore.instance.collection(itemCollection).doc(rentalData[itemIdKey]);
                    FirebaseFirestore.instance.runTransaction((transaction) async {
                      final itemDoc = await transaction.get(itemRef);
                      if (itemDoc.exists) {
                        final currentRating = (itemDoc.data()?['averageRating'] as num?)?.toDouble() ?? 0.0;
                        final currentCount = (itemDoc.data()?['ratingCount'] as int?) ?? 0;
                        final newRating = ((currentRating * currentCount) + rating) / (currentCount + 1);
                        transaction.update(itemRef, {
                          'averageRating': newRating,
                          'ratingCount': currentCount + 1,
                        });
                      }
                    });

                    await FirebaseFirestore.instance.collection(reviewCollection).add({
                      itemIdKey: rentalData[itemIdKey],
                      'userId': uid,
                      'reviewerName': reviewerName,
                      'rating': rating,
                      'review': controller.text.trim(),
                      'createdAt': FieldValue.serverTimestamp(),
                    });

                    if (context.mounted) {
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Review submitted!')));
                    }
                  },
                  child: const Text("Submit"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildActiveRentalsTab(String userId) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 12),
          const Padding(
            padding: EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 8.0),
            child: Text("Items I'm Renting", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          ),
          _buildRentedItemsList(userId),
          const SizedBox(height: 8),
          const Padding(
            padding: EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 8.0),
            child: Text("Items I'm Renting Out", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          ),
          _buildItemsRentedOutList(userId),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildHistoryTab(String userId) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _historyTabIndex = 0;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _historyTabIndex == 0 ? Colors.greenAccent : Colors.white10,
                    foregroundColor: _historyTabIndex == 0 ? Colors.black : Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text("Borrowed Items", style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _historyTabIndex = 1;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _historyTabIndex == 1 ? Colors.greenAccent : Colors.white10,
                    foregroundColor: _historyTabIndex == 1 ? Colors.black : Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text("Shared Items", style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _historyTabIndex = 2;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _historyTabIndex == 2 ? Colors.greenAccent : Colors.white10,
                    foregroundColor: _historyTabIndex == 2 ? Colors.black : Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text("Rejected", style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: _historyTabIndex == 0
              ? _buildHistoryList(userId, 'borrowed')
              : _historyTabIndex == 1
              ? _buildHistoryList(userId, 'shared')
              : _buildHistoryList(userId, 'rejected'),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text("Please log in to view your rentals.")),
      );
    }

    return PopScope(
      canPop: false,
      onPopInvoked: (bool didPop) {
        if (didPop) return;
        Navigator.pushReplacementNamed(context, '/home');
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text("My Rentals", style: TextStyle(color: Colors.white)),
          backgroundColor: const Color(0xFF0b2a33),
          elevation: 2,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pushReplacementNamed(context, '/home'),
          ),
        ),
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF071018), Color(0xFF0b2a33), Color(0xFF12343d)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _selectedIndex = 0;
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _selectedIndex == 0 ? Colors.greenAccent : Colors.white10,
                          foregroundColor: _selectedIndex == 0 ? Colors.black : Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text("Active Rentals", style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _selectedIndex = 1;
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _selectedIndex == 1 ? Colors.greenAccent : Colors.white10,
                          foregroundColor: _selectedIndex == 1 ? Colors.black : Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text("History", style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: _selectedIndex == 0
                    ? _buildActiveRentalsTab(user.uid)
                    : _buildHistoryTab(user.uid),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRentedItemsList(String userId) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('rentalRequests')
          .where('renterId', isEqualTo: userId)
          .orderBy('requestDate', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(height: 200, child: Center(child: CircularProgressIndicator(color: Colors.greenAccent)));
        }
        if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}", style: const TextStyle(color: Colors.white70)));
        }
        final docs = snapshot.data?.docs.where((doc) => doc['status'] != 'rejected').toList() ?? [];
        if (docs.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(24.0),
            child: Center(child: Text("You have no active rental requests.", style: TextStyle(color: Colors.white70))),
          );
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            return _buildRentalRequestCard(context, docs[index], 'renter');
          },
        );
      },
    );
  }

  Widget _buildItemsRentedOutList(String userId) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('rentalRequests')
          .where('ownerId', isEqualTo: userId)
          .orderBy('requestDate', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(height: 200, child: Center(child: CircularProgressIndicator(color: Colors.greenAccent)));
        }
        if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}", style: const TextStyle(color: Colors.white70)));
        }
        final docs = snapshot.data?.docs.where((doc) => doc['status'] != 'rejected').toList() ?? [];
        if (docs.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(24.0),
            child: Center(child: Text("You have no incoming rental requests.", style: TextStyle(color: Colors.white70))),
          );
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            return _buildRentalRequestCard(context, docs[index], 'owner');
          },
        );
      },
    );
  }
}

// Placeholder for ToolDetailScreen (from previous chats)
// This should be in a separate file.

// Placeholder for ChatScreen
class ChatScreen extends StatelessWidget {
  final String chatId;
  final String otherUserId;
  final String otherUserName;
  final String itemName; // Renamed for generic use

  const ChatScreen({
    super.key,
    required this.chatId,
    required this.otherUserId,
    required this.otherUserName,
    required this.itemName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(itemName)),
      body: Center(child: Text('Chat with $otherUserName')),
    );
  }
}

// Placeholder for StarRating
class StarRating extends StatelessWidget {
  final double rating;
  final bool enableInteraction;
  final ValueChanged<int>? onRatingChanged;

  const StarRating({
    super.key,
    required this.rating,
    this.enableInteraction = true,
    this.onRatingChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
        5,
            (index) {
          int starIndex = index + 1;
          IconData icon;
          if (starIndex <= rating.floor()) {
            icon = Icons.star;
          } else if (starIndex > rating.floor() && starIndex - rating <= 0.5) {
            icon = Icons.star_half;
          } else {
            icon = Icons.star_border;
          }

          return GestureDetector(
            onTap: enableInteraction
                ? () {
              if (onRatingChanged != null) onRatingChanged!(starIndex);
            }
                : null,
            child: Icon(
              icon,
              color: Colors.amber,
              size: 18,
            ),
          );
        },
      ),
    );
  }
}