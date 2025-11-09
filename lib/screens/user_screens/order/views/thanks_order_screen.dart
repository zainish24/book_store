// lib/screens/user_screens/checkout/views/thanks_for_order_screen.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:my_library/constants.dart';
import 'package:my_library/route/screen_export.dart';

class ThanksForOrderScreen extends StatelessWidget {
  const ThanksForOrderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // route args (may be null)
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    // prefer currently signed-in user's email (dynamic)
    final currentUser = FirebaseAuth.instance.currentUser;
    final signedInEmail = currentUser?.email;

    // fallback to route-arg email or placeholder
    final argEmail = args?['email'] as String?;
    final emailToShow = signedInEmail ?? argEmail ?? 'your.email@example.com';

    final orderNumber = args?['orderNumber'] as String? ?? '#---';
    final amount = (args?['amount'] as num?)?.toDouble() ?? 0.0;

    return Scaffold(
      backgroundColor: whiteColor,
      appBar: AppBar(
        backgroundColor: whiteColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: blackColor),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Text(
          "Order",
          style: TextStyle(
            color: blackColor,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(icon: const Icon(Icons.ios_share, color: blackColor), onPressed: () {}),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(defaultPadding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // centered success image
            Center(
              child: Image.asset(
                Theme.of(context).brightness == Brightness.light
                    ? 'assets/Illustration/success.png'
                    : 'assets/Illustration/success_dark.png',
                height: 220,
              ),
            ),
            const SizedBox(height: 28),
            const Text(
              "Thanks for your order",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: blackColor),
            ),
            const SizedBox(height: 8),
            Text.rich(
              TextSpan(
                children: [
                  const TextSpan(
                    text: "You’ll receive an email at ",
                    style: TextStyle(color: blackColor60, fontSize: 14),
                  ),
                  TextSpan(
                    text: emailToShow,
                    style: const TextStyle(color: blackColor, fontWeight: FontWeight.w600),
                  ),
                  const TextSpan(
                    text: " once your order is confirmed.",
                    style: TextStyle(color: blackColor60, fontSize: 14),
                  ),
                ],
              ),
              textAlign: TextAlign.center,
            ),

            // small order summary line (optional, unobtrusive)
            if (orderNumber != '#---' || amount > 0) ...[
              const SizedBox(height: 20),
              Text(
                'Order: $orderNumber  •  Total: \$${amount.toStringAsFixed(2)}',
                style: const TextStyle(color: blackColor60),
              ),
            ],

            const SizedBox(height: 36),

            // Continue / Track buttons
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushNamed(context, orderProcessingScreenRoute);
                },
                icon: const Icon(Icons.track_changes, color: whiteColor),
                label: const Text("Track order", style: TextStyle(color: whiteColor, fontSize: 16)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  Navigator.pushNamedAndRemoveUntil(context, userEntryPointScreenRoute, (r) => false);
                },
                child: const Text("Continue shopping"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
