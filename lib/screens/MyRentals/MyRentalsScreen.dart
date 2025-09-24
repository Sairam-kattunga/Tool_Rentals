import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

// Placeholder imports - ensure these files exist in your project
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

  final DateFormat _dateFormat = DateFormat.yMMMd().add_jm();

  String formatTimestamp(dynamic ts) {
    if (ts == null) return 'N/A';
    if (ts is Timestamp) {
      try {
        return _dateFormat.format(ts.toDate());
      } catch (_) {
        return ts.toString();
      }
    }
    return ts.toString();
  }

  void _copyToClipboard(BuildContext context, String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("ID copied to clipboard")),
    );
  }

  Future<void> _showTrackingDialog(BuildContext context, String currentStatus, Map<String, dynamic> rentalData, String docId, Map<String, dynamic> itemData, String itemType) {
    return showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        final keys = trackingSteps.keys.toList();
        return AlertDialog(
          backgroundColor: const Color(0xFF0b2a33),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text("Rental Status", style: TextStyle(color: Colors.white)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ...trackingSteps.entries.map((step) {
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
                    if (!userSnapshot.hasData || userSnapshot.data?.data() == null) return const SizedBox.shrink();
                    final otherUser = userSnapshot.data!.data() as Map<String, dynamic>;
                    final phoneNumber = (otherUser['contact'] ?? otherUser['phone'] ?? '').toString();
                    final otherUserName = (otherUser['name'] ?? otherUser['displayName'] ?? '').toString();

                    return Row(
                      children: [
                        ElevatedButton.icon(
                          onPressed: phoneNumber.isNotEmpty ? () => _makePhoneCall(phoneNumber) : null,
                          icon: const Icon(Icons.phone, color: Colors.black),
                          label: const Text("Call", style: TextStyle(color: Colors.black)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.greenAccent,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton.icon(
                          onPressed: () {
                            // Create a deterministic chatId
                            final currentUid = FirebaseAuth.instance.currentUser!.uid;
                            final otherUid = (rentalData['ownerId'] == currentUid) ? rentalData['renterId'] : rentalData['ownerId'];
                            final itemId = rentalData['toolId'] ?? rentalData['packageId'] ?? docId;
                            final ids = [currentUid, otherUid, itemId].where((e) => e != null).map((e) => e.toString()).toList();
                            ids.sort();
                            final chatId = ids.join('_');
                            Navigator.push(context, MaterialPageRoute(builder: (_) => ChatScreen(chatId: chatId, otherUserId: otherUid ?? '', otherUserName: otherUserName, itemName: (itemData['title'] ?? itemData['name'] ?? rentalData['itemName'] ?? 'Item').toString())));
                          },
                          icon: const Icon(Icons.chat, color: Colors.black),
                          label: const Text("Message", style: TextStyle(color: Colors.black)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white10,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ],
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
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                _showDetailsDialog(context, rentalData, itemData);
              },
              child: const Text("View Details", style: TextStyle(color: Colors.greenAccent)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showDetailsDialog(BuildContext context, Map<String, dynamic> rentalData, Map<String, dynamic> itemData) {
    final itemId = rentalData['toolId'] ?? rentalData['packageId'] ?? 'N/A';
    final itemName = rentalData['toolName'] ?? rentalData['packageName'] ?? itemData['title'] ?? itemData['name'] ?? rentalData['itemName'] ?? 'Item';
    final pricePerDay = rentalData['pricePerDay']?.toString() ?? rentalData['totalPrice']?.toString() ?? itemData['price']?.toString() ?? 'N/A';
    final status = rentalData['status']?.toString() ?? 'N/A';
    final ownerName = rentalData['ownerName'] ?? itemData['ownerName'] ?? 'N/A';
    final renterName = rentalData['renterName'] ?? rentalData['requesterName'] ?? 'N/A';
    final participants = (rentalData['participants'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [];

    return showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xFF0b2a33),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(itemName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Status: ${status.toUpperCase()}", style: TextStyle(color: status == 'rejected' ? Colors.redAccent : Colors.greenAccent)),
                const SizedBox(height: 8),
                Text("Owner: $ownerName", style: const TextStyle(color: Colors.white70)),
                const SizedBox(height: 4),
                Text("Renter: $renterName", style: const TextStyle(color: Colors.white70)),
                const SizedBox(height: 12),
                _infoRow("Item ID", itemId, showCopy: true),
                _infoRow("Price Per Day", "₹$pricePerDay"),
                _infoRow("Requested On", formatTimestamp(rentalData['requestDate'])),
                _infoRow("Responded On", formatTimestamp(rentalData['responseDate'])),
                if (rentalData['collectedAt'] != null) _infoRow("Collected On", formatTimestamp(rentalData['collectedAt'])),
                if (rentalData['returnedAt'] != null) _infoRow("Returned On", formatTimestamp(rentalData['returnedAt'])),
                if (rentalData['completedAt'] != null) _infoRow("Completed On", formatTimestamp(rentalData['completedAt'])),
                if (rentalData['rejectedAt'] != null) _infoRow("Rejected On", formatTimestamp(rentalData['rejectedAt'])),
                if (participants.isNotEmpty) _infoRow("Participants", participants.join(', ')),
                const SizedBox(height: 8),
                if (rentalData['notes'] != null) ...[
                  const Text("Notes:", style: TextStyle(color: Colors.white70)),
                  const SizedBox(height: 4),
                  Text(rentalData['notes'].toString(), style: const TextStyle(color: Colors.white54)),
                ],
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

  Widget _infoRow(String label, String value, {bool showCopy = false}) {
    if (value == 'N/A' || value.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Text("$label: ", style: const TextStyle(color: Colors.white, fontSize: 14)),
          Expanded(child: Text(value, style: const TextStyle(color: Colors.white70, fontSize: 14))),
          if (showCopy)
            IconButton(
              icon: const Icon(Icons.copy, color: Colors.white54, size: 16),
              onPressed: () => _copyToClipboard(context, value),
            ),
        ],
      ),
    );
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Could not launch phone app.")));
      }
    }
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
        // Move to completedRentals
        final completedDoc = {
          ...rentalData,
          'status': 'completed',
          'completedAt': FieldValue.serverTimestamp(),
          'participants': [rentalData['ownerId'], rentalData['renterId']],
        };
        await FirebaseFirestore.instance.collection('completedRentals').add(completedDoc);

        // mark item available again
        final itemIdKey = rentalData.containsKey('packageId') ? 'packageId' : 'toolId';
        final itemId = rentalData[itemIdKey];
        if (itemId != null) {
          final itemRef = FirebaseFirestore.instance.collection(itemType == 'package' ? 'packages' : 'tools').doc(itemId);
          await itemRef.update({'isAvailable': true});
        }

        await docRef.delete();
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Transaction completed and moved to history!')));
        return;
      } else if (newStatus == 'rejected') {
        // Move to rejectedRentals
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

      // Normal update of rentalRequests
      await docRef.update(updateData);

      if (newStatus == 'accepted') {
        final itemIdKey = rentalData.containsKey('packageId') ? 'packageId' : 'toolId';
        final itemId = rentalData[itemIdKey];
        if (itemId != null) {
          final itemRef = FirebaseFirestore.instance.collection(itemType == 'package' ? 'packages' : 'tools').doc(itemId);
          await itemRef.update({'isAvailable': false});
        }
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Request updated to $newStatus')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to update request: $e')));
    }
  }

  Future<void> _cancelRental(BuildContext context, String docId, Map<String, dynamic> rentalData) {
    return showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xFF0b2a33),
          title: const Text("Confirm Cancellation", style: TextStyle(color: Colors.white)),
          content: const Text("Are you sure you want to cancel this rental request? This action cannot be undone and will move it to your history.", style: TextStyle(color: Colors.white70)),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text("No", style: TextStyle(color: Colors.white70)),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                try {
                  final rejectedDoc = {
                    ...rentalData,
                    'status': 'rejected',
                    'rejectedAt': FieldValue.serverTimestamp(),
                    'participants': [rentalData['ownerId'], rentalData['renterId']],
                  };
                  await FirebaseFirestore.instance.collection('rejectedRentals').add(rejectedDoc);
                  await FirebaseFirestore.instance.collection('rentalRequests').doc(docId).delete();
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Request cancelled and moved to history.')));
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to cancel request: $e')));
                  }
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
              child: const Text("Yes, Cancel", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildRentalRequestCard(BuildContext context, QueryDocumentSnapshot doc, String userType) {
    final rentalData = (doc.data() as Map<String, dynamic>?) ?? {};
    final status = (rentalData['status'] as String?) ?? 'pending';

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
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 24.0),
            child: Center(child: CircularProgressIndicator(color: Colors.greenAccent)),
          );
        }

        final itemData = (itemSnapshot.data?.data() as Map<String, dynamic>?) ?? {};
        final category = (itemData['category'] ?? 'Miscellaneous').toString();
        final headerImage = _categoryImages[category] ?? _categoryImages['Miscellaneous']!;
        final // prefer the request-level totalPrice (if present), then pricePerDay, then itemData price
        price = rentalData['totalPrice']?.toString() ?? rentalData['pricePerDay']?.toString() ?? itemData['price']?.toString() ?? 'N/A';
        final averageRating = (itemData['averageRating'] as num?)?.toDouble() ?? 0.0;

        final title = (itemData['title'] ?? itemData['name'] ?? rentalData['toolName'] ?? rentalData['packageName'] ?? rentalData['itemName'] ?? 'Item').toString();
        final subtitle = userType == 'owner' ? "Renter: ${rentalData['renterName'] ?? 'N/A'}" : "Owner: ${rentalData['ownerName'] ?? 'N/A'}";

        return InkWell(
          onTap: () => _showTrackingDialog(context, status, rentalData, doc.id, itemData, itemType),
          child: Card(
            color: Colors.white.withOpacity(0.06),
            margin: const EdgeInsets.symmetric(vertical: 8),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Stack(
                children: [
                  Row(
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
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16), overflow: TextOverflow.ellipsis),
                            const SizedBox(height: 4),
                            Text(subtitle, style: const TextStyle(color: Colors.white70, fontSize: 13), overflow: TextOverflow.ellipsis),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(Icons.currency_rupee, color: Colors.greenAccent, size: 16),
                                const SizedBox(width: 6),
                                Text(price, style: const TextStyle(color: Colors.greenAccent, fontSize: 15)),
                                const Spacer(),
                                if (averageRating > 0)
                                  Row(
                                    children: [
                                      Text(averageRating.toStringAsFixed(1), style: const TextStyle(color: Colors.white70)),
                                      const SizedBox(width: 4),
                                      const Icon(Icons.star, color: Colors.amber, size: 16),
                                    ],
                                  ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            _buildStatusBadge(status),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildActionButtons(context, doc.id, rentalData, status, itemType),
                          const SizedBox(height: 6),
                          IconButton(
                            tooltip: 'Details',
                            onPressed: () => _showDetailsDialog(context, rentalData, itemData),
                            icon: const Icon(Icons.info_outline, color: Colors.white70),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Positioned(
                    top: 0,
                    right: 0,
                    child: IconButton(
                      icon: const Icon(Icons.close, color: Colors.redAccent),
                      onPressed: () => _cancelRental(context, doc.id, rentalData),
                    ),
                  ),
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
                SizedBox(
                  width: 110,
                  child: ElevatedButton(
                    onPressed: () => _handleRequest(context, docId, 'accepted', itemType),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.greenAccent),
                    child: const Text('Accept', style: TextStyle(color: Colors.black)),
                  ),
                ),
                const SizedBox(width: 6),
                SizedBox(
                  width: 110,
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
        case 'collected':
          return Flexible(
            child: SizedBox(
              width: 160,
              child: ElevatedButton(
                onPressed: () => _handleRequest(context, docId, 'returned', itemType),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.greenAccent),
                child: const Text('Confirm Return', style: TextStyle(color: Colors.black)),
              ),
            ),
          );
        case 'returned':
          return Flexible(
            child: SizedBox(
              width: 160,
              child: ElevatedButton(
                onPressed: () => _handleRequest(context, docId, 'completed', itemType),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.greenAccent),
                child: const Text('Confirm & Close', style: TextStyle(color: Colors.black)),
              ),
            ),
          );
      }
    } else {
      // renter side
      switch (status) {
        case 'accepted':
          return Flexible(
            child: SizedBox(
              width: 140,
              child: ElevatedButton(
                onPressed: () => _handleRequest(context, docId, 'collected-renter', itemType),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.greenAccent),
                child: const Text('Item Collected', style: TextStyle(color: Colors.black)),
              ),
            ),
          );
        case 'collected':
          return Flexible(
            child: SizedBox(
              width: 140,
              child: ElevatedButton(
                onPressed: () => _handleRequest(context, docId, 'returned-renter', itemType),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent),
                child: const Text('Return Item', style: TextStyle(color: Colors.white)),
              ),
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
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(text, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold)),
        ],
      ),
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
          child: _buildActiveRentalsTab(user.uid),
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
        final docs = snapshot.data?.docs.where((doc) => (doc.data() as Map<String, dynamic>?)?['status'] != 'rejected').toList() ?? [];
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
        final docs = snapshot.data?.docs.where((doc) => (doc.data() as Map<String, dynamic>?)?['status'] != 'rejected').toList() ?? [];
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

// StarRating widget included in the same file.
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

// Placeholder for ToolDetailScreen (if you need it elsewhere)
class ToolDetailScreen extends StatelessWidget {
  const ToolDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tool Detail'),
      ),
      body: const Center(
        child: Text('This is the Tool Detail Screen'),
      ),
    );
  }
}

// Placeholder for ChatScreen (kept from your original file)
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
