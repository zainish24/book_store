import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:my_library/constants.dart';
import 'package:my_library/models/product_model.dart';
import 'package:my_library/screens/admin_screens/reviews/views/components/admin_product_review_screen.dart';
import 'package:my_library/screens/admin_screens/admin/views/components/offers_carousel.dart';

class AdminReviewListScreen extends StatefulWidget {
  const AdminReviewListScreen({super.key});

  @override
  State<AdminReviewListScreen> createState() => _AdminReviewListScreenState();
}

class _AdminReviewListScreenState extends State<AdminReviewListScreen> {
  // Type-safe products reference
  final productsRef = FirebaseFirestore.instance
      .collection('products')
      .withConverter<ProductModel>(
        fromFirestore: (snapshot, _) => ProductModel.fromFirestore(snapshot),
        toFirestore: (product, _) => product.toMap(),
      );

  // Fetch all products that have at least one review
  Future<List<ProductModel>> _fetchProductsWithReviews() async {
    final reviewDocs = await FirebaseFirestore.instance.collectionGroup('reviews').get();

    final Set<String> productIds = {};
    for (var rd in reviewDocs.docs) {
      final pid = rd.reference.parent.parent?.id;
      if (pid != null) productIds.add(pid);
    }

    if (productIds.isEmpty) return [];

    final futures = productIds.map((id) => productsRef.doc(id).get()).toList();
    final snaps = await Future.wait(futures);

    final products = snaps.where((s) => s.exists).map((s) => s.data()!).toList();

    // Optional: sort by title
    products.sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));

    return products;
  }

  // Build product card similar to AdminProductListScreen
  Widget _buildProductTile(ProductModel product) {
    return Container(
      decoration: BoxDecoration(
        color: whiteColor,
        borderRadius: BorderRadius.circular(defaultBorderRadious),
        boxShadow: [
          BoxShadow(
            color: blackColor20.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(defaultBorderRadious),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => AdminProductReviewsScreen(
                productId: product.id,
                productName: product.title,
              ),
            ),
          );
        },
        child: Row(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(defaultBorderRadious),
                bottomLeft: Radius.circular(defaultBorderRadious),
              ),
              child: Image.network(
                product.images.isNotEmpty ? product.images.first : productDemoImg1,
                width: 100,
                height: 100,
                fit: BoxFit.cover,
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(14.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: blackColor,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    RatingBarIndicator(
                      rating: product.rating ?? 0,
                      itemBuilder: (context, _) =>
                          const Icon(Icons.star, color: Colors.amber),
                      itemSize: 14,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "${product.reviewsCount ?? 0} reviews",
                      style: const TextStyle(
                        fontSize: 13,
                        color: blackColor60,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(right: 10.0),
              child: Icon(
                Icons.arrow_forward_ios_rounded,
                color: primaryColor,
                size: 22,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightGreyColor,
      body: CustomScrollView(
        slivers: [
          // 🔹 Carousel at the top
          SliverToBoxAdapter(
            child: SizedBox(
              height: 200,
              child: OffersCarousel(),
            ),
          ),

          // 🔹 Product List
          FutureBuilder<List<ProductModel>>(
            future: _fetchProductsWithReviews(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SliverToBoxAdapter(
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              if (snapshot.hasError) {
                return SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      "Error loading products:\n${snapshot.error}",
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: errorColor),
                    ),
                  ),
                );
              }

              final products = snapshot.data ?? [];

              if (products.isEmpty) {
                return const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Center(
                      child: Text(
                        "No products with reviews",
                        style: TextStyle(
                          color: blackColor60,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                );
              }

              return SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: defaultPadding, vertical: 8),
                      child: _buildProductTile(products[index]),
                    );
                  },
                  childCount: products.length,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
