import 'package:flutter/material.dart';

class TermsOfServicesScreen extends StatelessWidget {
  final VoidCallback onAccepted;

  const TermsOfServicesScreen({super.key, required this.onAccepted});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Terms of Service"),
        backgroundColor: const Color(0xFF8D6CFF),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: ListView(
          children: [
            const Text(
              "Welcome to ShopEasy!",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                fontFamily: 'Plus Jakarta',
              ),
            ),
            const SizedBox(height: 16),
            Text(
              "Please read these Terms of Service carefully before using our application. By signing up or using our services, you agree to be bound by these terms.",
              style: TextStyle(
                fontSize: 16,
                fontFamily: 'Grandis Extended',
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 24),
            _buildSectionTitle("1. Account Creation"),
            _buildSectionText(
                "You must provide accurate information during sign-up. Keep your login details confidential."),
            _buildSectionTitle("2. Shopping & Orders"),
            _buildSectionText(
                "All purchases are subject to availability and our delivery policies. We reserve the right to cancel orders if needed."),
            _buildSectionTitle("3. Payments"),
            _buildSectionText(
                "We use secure payment gateways. Prices may change without notice but will not affect confirmed orders."),
            _buildSectionTitle("4. Privacy"),
            _buildSectionText(
                "We are committed to protecting your privacy. Read our privacy policy to understand how we handle your data."),
            _buildSectionTitle("5. Returns & Refunds"),
            _buildSectionText(
                "Return requests must be made within 7 days of delivery. Refunds are processed as per our policy."),
            _buildSectionTitle("6. Changes to Terms"),
            _buildSectionText(
                "We may update these terms at any time. Continued use of the app means you accept the changes."),
            const SizedBox(height: 24),
            const Text(
              "Thank you for shopping with ShopEasy!",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                fontFamily: 'Plus Jakarta',
              ),
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onAccepted,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8D6CFF),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  "Accept & Go Back",
                  style: TextStyle(
                    fontSize: 16,
                    fontFamily: 'Plus Jakarta',
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, top: 16.0),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          fontFamily: 'Plus Jakarta',
        ),
      ),
    );
  }

  Widget _buildSectionText(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 14,
        fontFamily: 'Grandis Extended',
        color: Colors.black87,
      ),
    );
  }
}
