// policies_screen.dart
import 'package:flutter/material.dart';

class PoliciesScreen extends StatefulWidget {
  const PoliciesScreen({super.key});

  @override
  State<PoliciesScreen> createState() => _PoliciesScreenState();
}

class _PoliciesScreenState extends State<PoliciesScreen> {
  int? _expandedIndex; // Track which tile is open

  final List<Map<String, String>> _policies = [
    {
      "title": "Return & Refund Policy",
      "content": """
Our return and refund framework has been designed in accordance with industry practices and consumer protection regulations. Refund eligibility is subject to the following conditions:

1. **Tool Condition** – The rented equipment must be returned in its original state, free from unauthorized modifications, tampering, or damage beyond reasonable wear and tear.
2. **Timeline** – Refund requests must be initiated within 48 hours of the rental transaction. Delays beyond this window may result in automatic rejection of the claim.
3. **Verification** – All claims are subject to inspection, digital logs, and geo-tracking validations to ensure authenticity.
4. **Processing** – Approved refunds will be initiated within 7-10 business days via the original payment method.

⚠️ *Please note:* Refunds are not guaranteed if the user violates our Terms of Use or provides inaccurate information at the time of booking.
"""
    },
    {
      "title": "Terms & Conditions / Terms of Use",
      "content": """
By accessing this application, you agree to be legally bound by the following terms:

1. **User Responsibility** – Users must maintain the confidentiality of their login credentials and are solely accountable for all activity conducted through their account.
2. **License of Use** – We grant you a limited, non-transferable, revocable license to use this app. Reverse engineering, scraping, or exploiting system vulnerabilities is strictly prohibited.
3. **Intellectual Property** – All logos, APIs, algorithms, and database schemas are proprietary assets protected under the Intellectual Property Act and international treaties.
4. **Breach of Terms** – Violation may result in suspension, permanent ban, or legal action under applicable cyber laws.

💡 These terms are enforceable under the Information Technology Act, 2000 and corresponding regulations where applicable.
"""
    },
    {
      "title": "Privacy Policy",
      "content": """
We employ enterprise-grade encryption and adhere to global data protection standards (GDPR, CCPA, IT Act 2000). The following apply:

- **Data Collection**: We collect identifiers (email, phone), geolocation, device metadata, and transaction history to ensure secure rentals.
- **Data Usage**: Collected data is used for identity verification, fraud detection, AI-driven personalization, and analytics.
- **Data Retention**: Personal data is stored for a minimum of 5 years, or longer where legally mandated.
- **Third-Party Sharing**: Select anonymized data may be shared with law enforcement, insurers, or credit verification agencies, subject to lawful requests.

🔒 *We apply AES-256 encryption for storage and TLS 1.3 for transmission.*
"""
    },
    {
      "title": "Data Security & Compliance",
      "content": """
Our systems are continuously monitored with multi-layered cybersecurity protocols:

- **Infrastructure Security**: All data is hosted on ISO/IEC 27001 and SOC 2 certified servers.
- **Authentication**: Multi-factor authentication (MFA) is required for internal administrative access.
- **Audit Trails**: Immutable logs are maintained for all transactions using blockchain-backed integrity checks.
- **Compliance**: We comply with GDPR (EU), HIPAA (US), IT Act (India), and other regional regulatory frameworks.

Failure to comply with security standards by users (such as sharing login credentials) may result in service denial without liability.
"""
    },
    {
      "title": "Liability & Disclaimer",
      "content": """
The company shall not be liable for:

- Losses arising due to user negligence, misuse, or unauthorized third-party access.
- Downtime caused by force majeure events including natural disasters, cyberattacks, or governmental actions.
- Indirect or consequential damages beyond the rental fee paid.

Our total liability under any claim shall not exceed the total rental value of the disputed transaction.
"""
    },
    {
      "title": "Governing Law & Jurisdiction",
      "content": """
These policies and any disputes shall be governed by and construed under the laws of India. Users expressly agree that:

- Any disputes shall be subject to arbitration under the Arbitration and Conciliation Act, 1996.
- Courts in Andhra Pradesh, India shall have exclusive jurisdiction.
- International users are bound to comply with their local laws in addition to these terms.

⚖️ *By using this app, you acknowledge the legally binding nature of these policies.*
"""
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Policies", style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF203a43),
        elevation: 0,
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
        child: ListView.builder(
          itemCount: _policies.length,
          itemBuilder: (context, index) {
            return _buildPolicyTile(
              index,
              _policies[index]["title"]!,
              _policies[index]["content"]!,
            );
          },
        ),
      ),
    );
  }

  Widget _buildPolicyTile(int index, String title, String content) {
    return Card(
      color: Colors.white.withOpacity(0.1),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        key: Key(index.toString()), // ensures state is tied to index
        initiallyExpanded: _expandedIndex == index,
        onExpansionChanged: (expanded) {
          setState(() {
            _expandedIndex = expanded ? index : null;
          });
        },
        title: Text(
          title,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconColor: Colors.white70,
        collapsedIconColor: Colors.white70,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              content,
              style: const TextStyle(color: Colors.white70, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}
