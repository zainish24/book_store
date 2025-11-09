import 'package:flutter/material.dart';
import 'package:my_library/route/route_constants.dart';
import '../../../../constants.dart';

class PaymentMethodScreen extends StatelessWidget {
  const PaymentMethodScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
          "Payment method",
          style: TextStyle(
            color: blackColor,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.info_outline, color: blackColor),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Center(
              child: Image.asset(
                'assets/Illustration/PayWithCash_lightTheme.png',
                height: 200,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              "Pay with cash",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: blackColor,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              "A my_librarylon refundable \$24.00 will be charged to use cash on delivery. "
              "If you want to save this amount please switch to Pay with Card.",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: blackColor60,
                fontSize: 14,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 40),

            /// Confirm Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  // Handle payment confirmation
                  Navigator.pushNamed(context, checkoutScreenRoute);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Text(
                  "Confirm",
                  style: TextStyle(color: whiteColor, fontSize: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
