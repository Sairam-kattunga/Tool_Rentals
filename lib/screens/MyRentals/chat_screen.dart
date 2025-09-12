import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ChatScreen extends StatefulWidget {
  final String chatId;
  final String otherUserId;
  final String otherUserName;
  final String toolName;

  const ChatScreen({
    super.key,
    required this.chatId,
    required this.otherUserId,
    required this.otherUserName,
    required this.toolName,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _msgController = TextEditingController();
  final _scrollController = ScrollController();
  final _messagesRef = FirebaseFirestore.instance.collection('chats');
  String get _uid => FirebaseAuth.instance.currentUser!.uid;

  Future<void> _sendMessage() async {
    final text = _msgController.text.trim();
    if (text.isEmpty) return;

    final message = {
      'text': text,
      'senderId': _uid,
      'timestamp': FieldValue.serverTimestamp(),
    };

    final chatDocRef = _messagesRef.doc(widget.chatId);
    final messagesCol = chatDocRef.collection('messages');

    try {
      // Use a batch write for atomic updates to prevent data inconsistencies
      final batch = FirebaseFirestore.instance.batch();

      // 1. Update the chat document
      batch.set(
        chatDocRef,
        {
          'participants': [widget.otherUserId, _uid],
          'lastMessage': text,
          'lastUpdated': FieldValue.serverTimestamp(),
          'toolName': widget.toolName,
        },
        SetOptions(merge: true),
      );

      // 2. Add the new message
      batch.set(messagesCol.doc(), message); // Use .doc() for a new document with a unique ID

      await batch.commit();

      _msgController.clear();
      _scrollToBottom();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send: $e')),
      );
    }
  }

  void _scrollToBottom() {
    // Add a small delay to allow the ListView to rebuild
    Timer(const Duration(milliseconds: 300), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _msgController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.otherUserName, style: const TextStyle(color: Colors.white)),
            Text(widget.toolName, style: const TextStyle(fontSize: 12, color: Colors.white70)),
          ],
        ),
        backgroundColor: const Color(0xFF0b2a33),
        iconTheme: const IconThemeData(color: Colors.white),
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
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _messagesRef.doc(widget.chatId).collection('messages').orderBy('timestamp', descending: false).snapshots(),
                builder: (context, snap) {
                  if (snap.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator(color: Colors.greenAccent));
                  }
                  if (snap.hasError) {
                    return Center(child: Text('Error: ${snap.error}', style: const TextStyle(color: Colors.redAccent)));
                  }
                  final docs = snap.data?.docs ?? [];
                  if (docs.isEmpty) {
                    return const Center(
                      child: Text('No messages yet - start the conversation', style: TextStyle(color: Colors.white70)),
                    );
                  }
                  return ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(12),
                    itemCount: docs.length,
                    itemBuilder: (context, idx) {
                      final m = docs[idx].data() as Map<String, dynamic>;
                      final isMe = (m['senderId'] == _uid);
                      final text = m['text'] ?? '';
                      final ts = (m['timestamp'] as Timestamp?)?.toDate();
                      return Align(
                        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                          decoration: BoxDecoration(
                            color: isMe ? Colors.greenAccent.withOpacity(0.8) : Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.only(
                              topLeft: const Radius.circular(12),
                              topRight: const Radius.circular(12),
                              bottomLeft: isMe ? const Radius.circular(12) : const Radius.circular(0),
                              bottomRight: isMe ? const Radius.circular(0) : const Radius.circular(12),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(text, style: TextStyle(color: isMe ? Colors.black : Colors.white70)),
                              const SizedBox(height: 6),
                              Text(ts != null ? DateFormat.jm().format(ts) : '', style: TextStyle(color: isMe ? Colors.black54 : Colors.white54, fontSize: 10)),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            Container(
              color: const Color(0xFF071018),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: SafeArea(
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _msgController,
                        textCapitalization: TextCapitalization.sentences,
                        decoration: const InputDecoration(
                          hintText: 'Write a message...',
                          hintStyle: TextStyle(color: Colors.white54),
                          border: InputBorder.none,
                        ),
                        style: const TextStyle(color: Colors.white),
                        onSubmitted: (value) => _sendMessage(),
                      ),
                    ),
                    IconButton(
                      onPressed: _sendMessage,
                      icon: const Icon(Icons.send, color: Colors.greenAccent),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}