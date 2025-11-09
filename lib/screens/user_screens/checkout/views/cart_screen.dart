// lib/screens/user_screens/cart/views/cart_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:my_library/constants.dart';
import 'package:my_library/components/cart_button.dart';
import 'package:my_library/route/screen_export.dart';
import 'package:my_library/screens/user_screens/checkout/views/services/cart_service.dart';
import 'package:my_library/models/cart_model.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  Widget _qtyBox(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: lightGreyColor,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Icon(icon, size: 16, color: blackColor),
      ),
    );
  }

  Widget _buildCartItem(CartItem item, int index, CartService cart, BuildContext context) {
    final bool isSmallScreen = MediaQuery.of(context).size.width < 600;
    
    return Padding(
      padding: const EdgeInsets.only(bottom: defaultPadding),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(defaultBorderRadious),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product Image
              ClipRRect(
                borderRadius: BorderRadius.circular(defaultBorderRadious),
                child: Image.network(
                  item.image,
                  height: isSmallScreen ? 60 : 80,
                  width: isSmallScreen ? 60 : 80,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: defaultPadding),
              
              // Product Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Product Title
                    Text(
                      item.title,
                      style: TextStyle(
                        fontSize: isSmallScreen ? 14 : 15,
                        fontWeight: FontWeight.w600,
                        color: blackColor,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    
                    // Price Row
                    Row(
                      children: [
                        Text(
                          "\$${item.discountedPrice.toStringAsFixed(2)}",
                          style: const TextStyle(
                            color: Color(0xFF31B0D8),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          "\$${item.price.toStringAsFixed(2)}",
                          style: const TextStyle(
                            decoration: TextDecoration.lineThrough,
                            color: blackColor40,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    
                    // Quantity Controls and Delete
                    Row(
                      children: [
                        _qtyBox(Icons.remove, () => cart.decreaseQty(index)),
                        const SizedBox(width: 12),
                        Text(
                          "${item.qty}",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: blackColor,
                          ),
                        ),
                        const SizedBox(width: 12),
                        _qtyBox(Icons.add, () => cart.increaseQty(index)),
                        const Spacer(),
                        GestureDetector(
                          onTap: () => _showDeleteDialog(context, index, cart),
                          child: Icon(
                            Icons.delete_outline,
                            color: blackColor40,
                            size: isSmallScreen ? 18 : 20,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, int index, CartService cart) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Remove Item"),
          content: const Text("Are you sure you want to remove this item from your cart?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                cart.removeAt(index);
                Navigator.of(context).pop();
              },
              child: const Text(
                "Remove",
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildOrderSummary(CartService cart, BuildContext context) {
    final bool isSmallScreen = MediaQuery.of(context).size.width < 600;
    
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isSmallScreen ? defaultPadding * 0.8 : defaultPadding),
      decoration: BoxDecoration(
        color: whiteColor,
        borderRadius: BorderRadius.circular(defaultBorderRadious),
        border: Border.all(color: blackColor5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Order Summary",
            style: TextStyle(
              fontSize: isSmallScreen ? 15 : 16,
              fontWeight: FontWeight.bold,
              color: blackColor,
            ),
          ),
          const SizedBox(height: 16),
          _SummaryRow("Subtotal", "\$${cart.subtotal.toStringAsFixed(2)}"),
          const _SummaryRow("Shipping Fee", "Free", isGreen: true),
          const Divider(height: 24),
          _SummaryRow("Total (Incl. VAT)", "\$${cart.total.toStringAsFixed(2)}", isBold: true),
          const SizedBox(height: 6),
          _SummaryRow("Estimated VAT", "\$${cart.vat.toStringAsFixed(2)}"),
        ],
      ),
    );
  }

  Widget _buildEmptyCart(BuildContext context) {
    final bool isSmallScreen = MediaQuery.of(context).size.width < 600;
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(defaultPadding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.shopping_cart_outlined,
              size: isSmallScreen ? 64 : 80,
              color: blackColor40,
            ),
            const SizedBox(height: 16),
            Text(
              "Your cart is empty",
              style: TextStyle(
                fontSize: isSmallScreen ? 16 : 18,
                fontWeight: FontWeight.w600,
                color: blackColor60,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Add some items to get started",
              style: TextStyle(
                fontSize: isSmallScreen ? 14 : 15,
                color: blackColor40,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(
                  horizontal: isSmallScreen ? 24 : 32,
                  vertical: isSmallScreen ? 12 : 16,
                ),
              ),
              child: Text(
                "Continue Shopping",
                style: TextStyle(
                  fontSize: isSmallScreen ? 14 : 15,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildCouponSection(BuildContext context) {
    final bool isSmallScreen = MediaQuery.of(context).size.width < 600;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Your Coupon code",
          style: TextStyle(
            fontSize: isSmallScreen ? 16 : 18,
            fontWeight: FontWeight.bold,
            color: blackColor,
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          decoration: InputDecoration(
            hintText: "Type coupon code",
            hintStyle: const TextStyle(color: blackColor40),
            filled: true,
            fillColor: lightGreyColor,
            prefixIcon: const Icon(Icons.confirmation_number_outlined, color: blackColor40),
            suffixIcon: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(defaultBorderRadious),
                    bottomRight: Radius.circular(defaultBorderRadious),
                  ),
                ),
              ),
              child: Text(
                "Apply",
                style: TextStyle(
                  fontSize: isSmallScreen ? 12 : 14,
                  color: whiteColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            border: OutlineInputBorder(
              borderSide: BorderSide.none,
              borderRadius: BorderRadius.circular(defaultBorderRadious),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartService>(context);
    final bool isSmallScreen = MediaQuery.of(context).size.width < 600;
    final bool isLargeScreen = MediaQuery.of(context).size.width > 1200;

    return Scaffold(
      backgroundColor: whiteColor,
      appBar: AppBar(
        backgroundColor: whiteColor,
        elevation: 0,
        centerTitle: true,
        title: Text(
          "Cart",
          style: TextStyle(
            color: blackColor,
            fontWeight: FontWeight.w600,
            fontSize: isSmallScreen ? 16 : 18,
          ),
        ),
        // Back arrow removed as requested
        actions: [
          IconButton(
            icon: Icon(
              Icons.share_outlined, 
              color: blackColor,
              size: isSmallScreen ? 20 : 24,
            ),
            onPressed: () {},
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: isSmallScreen ? defaultPadding * 0.8 : defaultPadding,
            vertical: isSmallScreen ? defaultPadding * 0.5 : defaultPadding,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Text(
                "Review your order",
                style: TextStyle(
                  fontSize: isSmallScreen ? 16 : 18,
                  fontWeight: FontWeight.bold,
                  color: blackColor,
                ),
              ),
              const SizedBox(height: defaultPadding),

              // Responsive Layout for larger screens
              if (isLargeScreen && cart.items.isNotEmpty)
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Cart Items
                      Expanded(
                        flex: 2,
                        child: Column(
                          children: [
                            Expanded(
                              child: ListView.builder(
                                itemCount: cart.items.length,
                                itemBuilder: (context, index) => 
                                  _buildCartItem(cart.items[index], index, cart, context),
                              ),
                            ),
                            const SizedBox(height: defaultPadding),
                            _buildCouponSection(context),
                          ],
                        ),
                      ),
                      const SizedBox(width: defaultPadding),
                      
                      // Order Summary and Checkout
                      Expanded(
                        flex: 1,
                        child: Column(
                          children: [
                            _buildOrderSummary(cart, context),
                            const SizedBox(height: defaultPadding),
                            CartButton(
                              price: cart.total,
                              title: "Checkout",
                              subTitle: "Total (Incl. VAT)",
                              press: () {
                                Navigator.pushNamed(context, checkoutScreenRoute);
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                )
              else
                // Mobile/Tablet Layout
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Cart Items
                      Expanded(
                        flex: cart.items.isEmpty ? 1 : 3,
                        child: cart.items.isEmpty
                            ? _buildEmptyCart(context)
                            : ListView.builder(
                                itemCount: cart.items.length,
                                itemBuilder: (context, index) => 
                                  _buildCartItem(cart.items[index], index, cart, context),
                              ),
                      ),

                      if (cart.items.isNotEmpty) ...[
                        const SizedBox(height: defaultPadding),
                        
                        // Coupon Section
                        _buildCouponSection(context),
                        const SizedBox(height: defaultPadding * 1.5),

                        // Order Summary
                        _buildOrderSummary(cart, context),
                        const SizedBox(height: defaultPadding),

                        // Checkout Button
                        CartButton(
                          price: cart.total,
                          title: "Checkout",
                          subTitle: "Total (Incl. VAT)",
                          press: () {
                            Navigator.pushNamed(context, checkoutScreenRoute);
                          },
                        ),
                      ],
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String title;
  final String value;
  final bool isBold;
  final bool isGreen;

  const _SummaryRow(this.title, this.value, {this.isBold = false, this.isGreen = false});

  @override
  Widget build(BuildContext context) {
    final bool isSmallScreen = MediaQuery.of(context).size.width < 600;
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              color: blackColor60,
              fontSize: isSmallScreen ? 13 : 14,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isSmallScreen ? 13 : 14,
              color: isGreen ? successColor : blackColor,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}