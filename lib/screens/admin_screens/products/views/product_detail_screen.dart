import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:my_library/constants.dart';
import 'package:my_library/models/product_model.dart';
import 'package:my_library/route/screen_export.dart';
import 'package:my_library/components/custom_dialog.dart';

class AdminProductDetailScreen extends StatefulWidget {
  final String productId;
  final ProductModel? initial;

  const AdminProductDetailScreen({
    super.key,
    required this.productId,
    this.initial,
  });

  @override
  State<AdminProductDetailScreen> createState() =>
      _AdminProductDetailScreenState();
}

class _AdminProductDetailScreenState extends State<AdminProductDetailScreen> {
  late final DocumentReference<Map<String, dynamic>> _ref;
  int _currentImage = 0;

  @override
  void initState() {
    super.initState();
    _ref = FirebaseFirestore.instance.collection('products').doc(widget.productId);
  }

  Future<void> _confirmDelete() async {
    final res = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: whiteColor,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            boxShadow: [BoxShadow(color: blackColor20, blurRadius: 12)],
          ),
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: blackColor10,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 14),
              const Icon(Icons.warning_amber_rounded, size: 56, color: warningColor),
              const SizedBox(height: 12),
              const Text(
                "Delete product?",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: blackColor,
                  fontFamily: grandisExtendedFont,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                "This action cannot be undone.",
                style: TextStyle(color: blackColor60, fontSize: 14),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context, false),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: blackColor20),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(defaultBorderRadious),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text("Cancel", style: TextStyle(color: blackColor)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () => Navigator.pop(context, true),
                      label: const Text("Delete"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: errorColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(defaultBorderRadious),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );

    if (res == true) {
      await _ref.delete();
      if (!mounted) return;
      Navigator.pop(context, true);
      CustomDialog.show(context, message: "Something went wrong", isError: true);
    }
  }

  void _goEdit(ProductModel p) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AdminProductAddEditScreen(productId: p.id, productData: p.toMap()),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: _ref.snapshots(),
      builder: (context, snap) {
        ProductModel? product;
        if (snap.hasData && snap.data!.exists) {
          product = ProductModel.fromFirestore(snap.data!);
        } else {
          product = widget.initial;
        }

        return Scaffold(
          backgroundColor: lightGreyColor,
          appBar: AppBar(
            title: Text(product?.title ?? "Product"),
            backgroundColor: primaryColor,
            centerTitle: true,
            elevation: 4,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
            ),
          ),
          body: (snap.connectionState == ConnectionState.waiting && product == null)
              ? const Center(child: CircularProgressIndicator(color: primaryColor))
              : (product == null)
                  ? const Center(child: Text("Product not found"))
                  : _DetailBody(
                      product: product,
                      currentImage: _currentImage,
                      onImageChanged: (i) => setState(() => _currentImage = i),
                      onEdit: () => _goEdit(product!),
                      onDelete: _confirmDelete,
                    ),
        );
      },
    );
  }
}

class _DetailBody extends StatelessWidget {
  final ProductModel product;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final int currentImage;
  final ValueChanged<int> onImageChanged;

  const _DetailBody({
    required this.product,
    required this.onEdit,
    required this.onDelete,
    required this.currentImage,
    required this.onImageChanged,
  });

  @override
  Widget build(BuildContext context) {
    final hasDiscount = (product.discountPercent ?? 0) > 0 && (product.priceAfterDiscount ?? 0) > 0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(defaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// --- Carousel with hero effect ---
          if (product.images.isNotEmpty)
            Column(
              children: [
                Hero(
                  tag: product.id,
                  child: CarouselSlider(
                    options: CarouselOptions(
                      height: 300,
                      enlargeCenterPage: true,
                      enableInfiniteScroll: product.images.length > 1,
                      autoPlay: product.images.length > 1,
                      viewportFraction: 0.9,
                      onPageChanged: (i, _) => onImageChanged(i),
                    ),
                    items: product.images.map((img) {
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(defaultBorderRadious * 1.5),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.network(img, fit: BoxFit.cover),
                            Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [Colors.black.withOpacity(0.2), Colors.transparent],
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter,
                                ),
                              ),
                            )
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: product.images.asMap().entries.map((entry) {
                    return AnimatedContainer(
                      duration: defaultDuration,
                      width: currentImage == entry.key ? 12 : 8,
                      height: 8,
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: currentImage == entry.key ? primaryColor : blackColor20,
                      ),
                    );
                  }).toList(),
                )
              ],
            ),

          const SizedBox(height: 20),

          /// --- Chips (status + categories) ---
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _chip(product.inStock ? "In Stock" : "Out of Stock",
                  product.inStock ? successColor : errorColor),

              ...product.categories.map((c) => _chip(c, primaryColor)),
              ...product.specialCategories.map((c) => _chip(c, warningColor)),

              if (product.rating != null)
                _chip("⭐ ${product.rating!.toStringAsFixed(1)}", blackColor60),
              if (product.reviewsCount != null)
                _chip("${product.reviewsCount} reviews", blackColor60),
            ],
          ),

          const SizedBox(height: 24),

          Text(
            product.title,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: blackColor,
              fontFamily: grandisExtendedFont,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Author: ${product.authorName}",
            style: const TextStyle(fontSize: 16, color: blackColor80),
          ),

          const SizedBox(height: 24),

          /// --- Price Card ---
          Card(
            elevation: 6,
            shadowColor: blackColor20,
            color: whiteColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(defaultBorderRadious * 1.5),
            ),
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (hasDiscount) ...[
                    Text(
                      "\$${(product.priceAfterDiscount ?? product.price).toStringAsFixed(2)}",
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: blackColor,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      "\$${product.price.toStringAsFixed(2)}",
                      style: const TextStyle(
                        fontSize: 16,
                        color: blackColor80,
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                  ] else ...[
                    Text(
                      "\$${product.price.toStringAsFixed(2)}",
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: blackColor,
                      ),
                    ),
                  ],
                  const Spacer(),
                  if (product.discountPercent != null && product.discountPercent! > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [primaryColor.withOpacity(0.85), primaryColor],
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        "${product.discountPercent}% OFF",
                        style: const TextStyle(color: whiteColor, fontWeight: FontWeight.bold),
                      ),
                    ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          /// --- Description ---
          Card(
            elevation: 3,
            shadowColor: blackColor20,
            color: whiteColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(defaultBorderRadious * 1.2),
            ),
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Details",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: blackColor,
                      fontFamily: grandisExtendedFont,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    (product.description?.trim().isNotEmpty ?? false)
                        ? product.description!.trim()
                        : "No description available.",
                    style: const TextStyle(color: blackColor80, fontSize: 15),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 30),

          /// --- Actions ---
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.edit, color: primaryColor),
                  onPressed: onEdit,
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: primaryColor),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(defaultBorderRadious),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  label: const Text(
                    "Edit",
                    style: TextStyle(color: primaryColor, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: onDelete,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: errorColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(defaultBorderRadious),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  label: const Text(
                    "Delete",
                    style: TextStyle(color: whiteColor, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _chip(String text, Color color) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(25),
          border: Border.all(color: color.withOpacity(0.3)),
          boxShadow: [
            BoxShadow(color: color.withOpacity(0.1), blurRadius: 4, offset: const Offset(0, 2)),
          ],
        ),
        child: Text(
          text,
          style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 13),
        ),
      );
}
