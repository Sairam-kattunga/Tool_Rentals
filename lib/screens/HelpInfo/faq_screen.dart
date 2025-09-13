import 'package:flutter/material.dart';

class FaqScreen extends StatelessWidget {
  const FaqScreen({super.key});

  final List<Map<String, String>> faqs = const [
    {
      "q": "How do I rent a tool?",
      "a": "Browse the catalog, select a tool, and confirm your booking. You'll receive a confirmation instantly."
    },
    {
      "q": "What payment methods are accepted?",
      "a": "We accept UPI, credit/debit cards, and net banking."
    },
    {
      "q": "Can I cancel my booking?",
      "a": "Yes, you can cancel up to 24 hours before pickup for a full refund."
    },
    {
      "q": "Is there a security deposit?",
      "a": "Yes, a refundable deposit may be required depending on the tool."
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("FAQs", style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF203a43),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0f2027), Color(0xFF203a43), Color(0xFF2c5364)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: faqs.length,
          itemBuilder: (context, index) {
            return Card(
              color: Colors.white.withOpacity(0.1),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ExpansionTile(
                title: Text(faqs[index]["q"]!, style: const TextStyle(color: Colors.white)),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(faqs[index]["a"]!, style: const TextStyle(color: Colors.white70)),
                  )
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
