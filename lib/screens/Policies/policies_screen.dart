import 'package:flutter/material.dart';

class PoliciesScreen extends StatefulWidget {
  const PoliciesScreen({super.key});

  @override
  State<PoliciesScreen> createState() => _PoliciesScreenState();
}

class _PoliciesScreenState extends State<PoliciesScreen> {
  int? _expandedIndex;

  final List<Map<String, String>> _policies = [
    {
      "title": "Rental and Refund Policy",
      "content": """
Our rental and refund policy is designed to ensure fair and transparent transactions for all users. We strive to process all requests efficiently and in compliance with our terms.

1.  Eligibility for Refund: To be eligible for a refund, the rented item must be returned in the condition it was received, with no damage beyond normal wear and tear. All components must be present.
2.  Refund Request Timeline: Users must initiate a refund request within 48 hours of the scheduled return time. Requests submitted after this period may be declined.
3.  Verification Process: All refund claims undergo a thorough verification process, including an inspection of the returned item and a review of all rental logs and communications.
4.  Processing Time: Approved refunds will be processed within 7-10 business days and credited to the original payment method.

Disclaimer: Refunds are not issued for issues arising from user negligence or violations of our Terms of Service.
"""
    },
    {
      "title": "Terms of Service",
      "content": """
By using this application, you agree to be bound by our Terms of Service. These terms govern your use of our platform and its services.

1.  User Conduct: You are solely responsible for all activity on your account. You agree to use our services responsibly and in compliance with all applicable laws.
2.  Account Security: You are responsible for safeguarding your login credentials. We are not liable for any loss or damage arising from unauthorized access to your account.
3.  Intellectual Property: All content, including trademarks, logos, and software, is our proprietary property. Any unauthorized use is strictly prohibited.
4.  Dispute Resolution: All disputes arising from these terms will be resolved through arbitration in accordance with the laws of India.

Please note: We reserve the right to suspend or terminate your account for any breach of these terms.
"""
    },
    {
      "title": "Privacy Policy",
      "content": """
Your privacy is our priority. This policy outlines how we collect, use, and protect your personal information.

1.  Information We Collect: We collect personal information such as your name, contact details, location data, and transaction history to facilitate a seamless rental experience.
2.  How We Use Your Information: Your data is used to process transactions, improve our services, and ensure the security of our platform. We do not sell your personal information to third parties.
3.  Data Security: We implement a range of security measures to protect your data from unauthorized access, alteration, or disclosure.
4.  Third-Party Disclosure: We may share your information with trusted third parties, such as payment processors and legal authorities, only when necessary and in compliance with this policy.

Data is stored and processed securely, adhering to global data protection regulations.
"""
    },
    {
      "title": "Data Security and Compliance",
      "content": """
We are committed to maintaining a secure and compliant platform. Our security measures include:

1.  Encryption: All data transmitted between your device and our servers is encrypted using industry-standard protocols.
2.  Access Control: We enforce strict access controls to ensure that only authorized personnel can access sensitive information.
3.  Regular Audits: Our systems undergo regular security audits and vulnerability assessments to protect against emerging threats.
4.  Compliance: We operate in full compliance with the Information Technology Act, 2000, and other relevant data protection laws.

Your security is paramount. We continuously monitor our systems to protect your data.
"""
    },
    {
      "title": "Liability and Disclaimer",
      "content": """
This section outlines the limitations of our liability concerning your use of the application.

1.  Limitation of Liability: We are not liable for any indirect, incidental, or consequential damages resulting from your use of the app or its services.
2.  Tool Condition: While we provide a platform for rental, we are not responsible for the condition or performance of the rented items. All rental agreements are between the user and the tool owner.
3.  Disclaimer of Warranties: The application and its services are provided "as is" without any warranties, either express or implied.
4.  User Responsibility: You agree to use the services at your own risk.

Note: Our total liability for any claim shall not exceed the amount paid by you for the specific service in question.
"""
    },
    {
      "title": "Governing Law and Jurisdiction",
      "content": """
These terms and conditions are governed by the laws of India. Any legal action or dispute arising out of this agreement shall be handled as follows:

1.  Jurisdiction: The courts in Andhra Pradesh, India shall have exclusive jurisdiction over any disputes.
2.  Arbitration: Disputes may be subject to arbitration as per the Arbitration and Conciliation Act, 1996.
3.  International Users: Users outside of India must comply with their local laws in addition to these terms.

By using this service, you consent to this jurisdiction and agree to resolve disputes in accordance with these terms.
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
            final isExpanded = _expandedIndex == index;
            return Card(
              color: Colors.white.withOpacity(0.1),
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ExpansionTile(
                key: ValueKey(index),
                initiallyExpanded: isExpanded,
                onExpansionChanged: (expanded) {
                  setState(() {
                    _expandedIndex = expanded ? index : null;
                  });
                },
                title: Text(
                  _policies[index]["title"]!,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                iconColor: Colors.greenAccent,
                collapsedIconColor: Colors.white70,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: Text(
                      _policies[index]["content"]!,
                      style: const TextStyle(
                        color: Colors.white70,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.justify,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}