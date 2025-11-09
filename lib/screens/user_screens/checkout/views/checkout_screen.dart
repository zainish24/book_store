// lib/screens/user_screens/checkout/views/checkout_screen.dart
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:my_library/constants.dart';
import 'package:my_library/route/screen_export.dart';
import 'package:my_library/screens/user_screens/checkout/views/services/cart_service.dart';
import 'package:my_library/models/cart_model.dart';
import 'package:my_library/components/custom_dialog.dart'; // 👈 import custom dialog

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  bool _loading = false;

  /// 👉 Generate Unique Order Number
  String _generateOrderNumber() {
    final now = DateTime.now().millisecondsSinceEpoch;
    final rnd = Random().nextInt(999);
    return '#ORD${now.toString().substring(now.toString().length - 6)}${rnd.toString().padLeft(3, '0')}';
  }

  /// 👉 Place Order
  Future<void> _placeOrder(BuildContext context, CartService cart) async {
    if (cart.items.isEmpty) {
      CustomDialog.show(context, message: "Cart is empty", isError: true);
      return;
    }

    setState(() => _loading = true);

    final user = FirebaseAuth.instance.currentUser;
    final userId = user?.uid ?? 'guest';
    final userEmail = user?.email ?? '';

    // 👉 Fetch default address
    String? fullAddress;
    String? phone;
    String? fullName;

    if (user != null) {
      final addrSnap = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('addresses')
          .where('isDefault', isEqualTo: true)
          .limit(1)
          .get();

      if (addrSnap.docs.isNotEmpty) {
        final addr = addrSnap.docs.first.data();
        fullAddress = addr['address'];
        phone = addr['phone'];
        fullName = addr['fullName'];
      }
    }

    final orderNumber = _generateOrderNumber();
    final amount = cart.total;

    final orderData = {
      'orderNumber': orderNumber,
      'userId': userId,
      'userEmail': userEmail,
      'totalAmount': amount,
      'status': 'Pending',
      'orderDate': FieldValue.serverTimestamp(),
      'address': fullAddress ?? 'No address provided',
      'phone': phone ?? '',
      'fullName': fullName ?? '',
    };

    final batch = FirebaseFirestore.instance.batch();
    final clientOrdersRef =
        FirebaseFirestore.instance.collection('client_orders');
    final newOrderDoc = clientOrdersRef.doc();

    try {
      // Save order
      batch.set(newOrderDoc, orderData);

      // Save items
      for (final CartItem it in cart.items) {
        final itemDoc = newOrderDoc.collection('order_items').doc();
        batch.set(itemDoc, {
          'productId': it.productId,
          'productName': it.title,
          'price': it.discountedPrice,
          'quantity': it.qty,
          'total': (it.discountedPrice * it.qty),
        });

        // Decrement product stock
        final productRef =
            FirebaseFirestore.instance.collection('products').doc(it.productId);
        try {
          batch.update(productRef, {'quantity': FieldValue.increment(-it.qty)});
        } catch (e) {
          debugPrint('Could not queue stock decrement for ${it.productId}: $e');
        }
      }

      await batch.commit();
      cart.clear();

      setState(() => _loading = false);

      CustomDialog.show(context,
          message: "Order placed successfully!\nOrder No: $orderNumber",
          isError: false);

      Navigator.pushReplacementNamed(
        context,
        thanksForOrderScreenRoute,
        arguments: {
          'orderId': newOrderDoc.id,
          'orderNumber': orderNumber,
          'amount': amount,
          'email': userEmail,
        },
      );
    } catch (e, st) {
      setState(() => _loading = false);
      debugPrint('placeOrder failed: $e\n$st');
      CustomDialog.show(context,
          message: "Failed to place order: ${e.toString()}", isError: true);
    }
  }

  /// 👉 Themed Card Wrapper
  Widget _themedCard(BuildContext context, {required Widget child}) {
    return Container(
      margin: const EdgeInsets.only(bottom: defaultPadding),
      padding: const EdgeInsets.all(defaultPadding),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(defaultBorderRadious),
        boxShadow: [
          BoxShadow(
            color: blackColor.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: blackColor5),
      ),
      child: child,
    );
  }

  /// 👉 Dynamic Address Card
  Widget _buildAddressCard(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return _noAddressWidget(context);

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('addresses')
          .where('isDefault', isEqualTo: true)
          .limit(1)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _loadingAddressWidget(context);
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return _noAddressWidget(context);
        }

        final addr = snapshot.data!.docs.first.data() as Map<String, dynamic>;
        return _themedCard(
          context,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const CircleAvatar(
                    radius: 22,
                    child: Icon(Icons.home, color: primaryColor),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(addr['fullName'] ?? '',
                            style: Theme.of(context).textTheme.bodyLarge),
                        const SizedBox(height: 4),
                        Text(addr['address'] ?? '',
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(color: blackColor40)),
                        const SizedBox(height: 4),
                        Text(addr['phone'] ?? '',
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(color: blackColor40)),
                      ],
                    ),
                  ),
                  const Icon(Icons.location_on_outlined, color: blackColor20),
                ],
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pushNamed(context, addressesScreenRoute);
                  },
                  icon: const Icon(Icons.swap_horiz, color: primaryColor),
                  label: const Text(
                    "Change Address",
                    style: TextStyle(
                        color: primaryColor, fontWeight: FontWeight.w600),
                  ),
                ),
              )
            ],
          ),
        );
      },
    );
  }

  Widget _loadingAddressWidget(BuildContext context) =>
      _themedCard(context, child: const Center(child: CircularProgressIndicator()));

  Widget _noAddressWidget(BuildContext context) => _themedCard(
        context,
        child: const Row(
          children: [
            Icon(Icons.error_outline, color: Colors.red),
            SizedBox(width: 8),
            Expanded(
              child: Text("No default address found. Please add one."),
            ),
          ],
        ),
      );

  /// 👉 Payment Method
  Widget _buildPaymentMethod(BuildContext context) {
    return _themedCard(
      context,
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: const Icon(Icons.credit_card, color: primaryColor),
        title: const Text("Payment method",
            style: TextStyle(color: blackColor, fontWeight: FontWeight.w500)),
        trailing: const Icon(Icons.chevron_right, color: blackColor40),
        onTap: () {
          Navigator.pushNamed(context, paymentMethodScreenRoute);
        },
      ),
    );
  }

  /// 👉 Order Summary
  Widget _buildOrderSummary(BuildContext context, CartService cart) {
    return _themedCard(
      context,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Order Summary",
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          _SummaryRow("Subtotal", "\$${cart.subtotal.toStringAsFixed(2)}"),
          const _SummaryRow("Shipping Fee", "Free", isGreen: true),
          const Divider(height: 32),
          _SummaryRow("Total (Incl. VAT)", "\$${cart.total.toStringAsFixed(2)}",
              isBold: true),
          const SizedBox(height: 8),
          _SummaryRow("Estimated VAT", "\$${cart.vat.toStringAsFixed(2)}"),
        ],
      ),
    );
  }

  /// 👉 Product Preview
  Widget _buildProductPreviewList(BuildContext context, CartService cart) {
    if (cart.items.isEmpty) {
      return _themedCard(context, child: const Text("No items in your cart"));
    }
    return _themedCard(
      context,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: cart.items
            .map((it) => Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(defaultBorderRadious),
                        child: Image.network(it.image,
                            height: 48, width: 48, fit: BoxFit.cover),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(it.title,
                                style: const TextStyle(
                                    fontSize: 12, color: blackColor40)),
                            const SizedBox(height: 4),
                            Text(
                                "${it.qty} × \$${it.discountedPrice.toStringAsFixed(2)}",
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: blackColor)),
                          ],
                        ),
                      )
                    ],
                  ),
                ))
            .toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartService>(context);

    return Stack(
      children: [
        Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: AppBar(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            elevation: 0,
            centerTitle: true,
            leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: blackColor),
                onPressed: () => Navigator.pop(context)),
            title: Text("Checkout",
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.w600)),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(defaultPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildAddressCard(context),
                _buildPaymentMethod(context),
                _buildOrderSummary(context, cart),
                Text("Review your order",
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: defaultPadding),
                _buildProductPreviewList(context, cart),
                const SizedBox(height: 100), // space above button
              ],
            ),
          ),
          bottomNavigationBar: SafeArea(
            minimum: const EdgeInsets.all(defaultPadding),
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () => _placeOrder(context, cart),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                ),
                child: const Text("Complete Order",
                    style: TextStyle(color: whiteColor, fontSize: 16)),
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
              )),
            ),
          ),
      ],
    );
  }
}

/// 👉 Reusable Summary Row
class _SummaryRow extends StatelessWidget {
  final String title;
  final String value;
  final bool isBold;
  final bool isGreen;

  const _SummaryRow(this.title, this.value,
      {this.isBold = false, this.isGreen = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title,
              style: TextStyle(
                  color: blackColor60,
                  fontSize: 14,
                  fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
          Text(value,
              style: TextStyle(
                  fontSize: 14,
                  color: isGreen ? successColor : blackColor,
                  fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
        ],
      ),
    );
  }
}
