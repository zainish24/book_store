// lib/screens/user_screens/product/views/added_to_cart_message_screen.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:my_library/constants.dart';
import 'package:my_library/route/screen_export.dart';
import 'package:my_library/screens/user_screens/checkout/views/services/cart_service.dart';
import 'package:my_library/models/cart_model.dart';
import 'package:my_library/components/custom_dialog.dart'; // 👈 import custom dialog

class AddedToCartMessageScreen extends StatefulWidget {
  const AddedToCartMessageScreen({super.key});

  @override
  State<AddedToCartMessageScreen> createState() =>
      _AddedToCartMessageScreenState();
}

class _AddedToCartMessageScreenState extends State<AddedToCartMessageScreen> {
  bool _loading = false;

  Future<void> _syncCartToFirestoreIfSignedIn(BuildContext context) async {
    final cart = Provider.of<CartService>(context, listen: false);
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      CustomDialog.show(context,
          message:
              'You are not signed in — cart saved locally.', isError: true);
      return;
    }

    setState(() => _loading = true);

    try {
      final items = cart.items.map((CartItem i) => i.toMap()).toList();

      final docRef = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('cart')
          .doc('active');

      await docRef.set({
        'items': items,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      CustomDialog.show(context,
          message: 'Cart synced to your account.', isError: false);
    } catch (e) {
      debugPrint('Failed to sync cart: $e');
      CustomDialog.show(context,
          message: 'Failed to sync cart — continuing to checkout.', isError: true);
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
              child: Column(
                children: [
                  const Spacer(),
                  Image.asset(
                    Theme.of(context).brightness == Brightness.light
                        ? "assets/Illustration/success.png"
                        : "assets/Illustration/success_dark.png",
                    height: MediaQuery.of(context).size.height * 0.3,
                  ),
                  const Spacer(flex: 2),
                  Text(
                    "Added to cart",
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall!
                        .copyWith(fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: defaultPadding / 2),
                  const Text(
                    "Click the checkout button to complete the purchase process.",
                    textAlign: TextAlign.center,
                  ),
                  const Spacer(flex: 2),
                  OutlinedButton(
                    onPressed: () {
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        userEntryPointScreenRoute,
                        (route) => route.isFirst,
                      );
                    },
                    child: const Text("Continue shopping"),
                  ),
                  const SizedBox(height: defaultPadding),
                  ElevatedButton(
                    onPressed: () async {
                      // 1) sync cart to Firestore if user signed in
                      await _syncCartToFirestoreIfSignedIn(context);

                      // 2) navigate to checkout screen
                      Navigator.pushNamed(context, checkoutScreenRoute);
                    },
                    child: const Text("Checkout"),
                  ),
                  const Spacer(),
                ],
              ),
            ),
          ),
        ),

        // Loader overlay
        if (_loading)
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.4),
              child: const Center(
                child: CircularProgressIndicator(
                  color: primaryColor,
                  strokeWidth: 6,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
