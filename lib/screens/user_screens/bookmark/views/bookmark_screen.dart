import 'package:flutter/material.dart';
import 'package:my_library/components/product/product_card.dart';
import 'package:my_library/models/product_model.dart';
import 'package:my_library/route/route_constants.dart';
import 'package:my_library/screens/user_screens/bookmark/views/services/wishlist_service.dart';
import '../../../../constants.dart';

class BookmarkScreen extends StatelessWidget {
  const BookmarkScreen({super.key});

  Widget _buildEmptyState(BuildContext context) {
    final bool isSmallScreen = MediaQuery.of(context).size.width < 600;
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(defaultPadding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.favorite_border,
              size: isSmallScreen ? 64 : 80,
              color: blackColor40,
            ),
            const SizedBox(height: 16),
            Text(
              "Your wishlist is empty",
              style: TextStyle(
                fontSize: isSmallScreen ? 16 : 18,
                fontWeight: FontWeight.w600,
                color: blackColor60,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Add some books to your wishlist",
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
                "Explore Books",
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

  Widget _buildLoadingState() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(defaultPadding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: errorColor,
            ),
            const SizedBox(height: 16),
            Text(
              "Something went wrong",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: blackColor60,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: const TextStyle(
                fontSize: 14,
                color: blackColor40,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  int _calculateCrossAxisCount(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    
    if (screenWidth > 1200) return 4; // Desktop
    if (screenWidth > 800) return 3;  // Tablet landscape
    if (screenWidth > 600) return 2;  // Tablet portrait
    return 2; // Mobile
  }

  double _calculateChildAspectRatio(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    
    if (screenWidth > 1200) return 0.62; // Desktop - more compact
    if (screenWidth > 800) return 0.66;  // Tablet landscape
    if (screenWidth > 600) return 0.68;  // Tablet portrait
    return 0.72; // Mobile - taller cards for better touch
  }

  @override
  Widget build(BuildContext context) {
    final bool isSmallScreen = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: whiteColor,
        elevation: 0,
        centerTitle: true,
        title: Text(
          "My Wishlist",
          style: TextStyle(
            color: blackColor,
            fontWeight: FontWeight.w600,
            fontSize: isSmallScreen ? 16 : 18,
          ),
        ),
        
      ),
      body: StreamBuilder<List<ProductModel>>(
        stream: WishlistService().getWishlist(),
        builder: (context, snapshot) {
          // Loading state
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildLoadingState();
          }

          // Error state
          if (snapshot.hasError) {
            return _buildErrorState(snapshot.error.toString());
          }

          // Empty state
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return _buildEmptyState(context);
          }

          final wishlist = snapshot.data!;

          return CustomScrollView(
            slivers: [
              // Header with item count
              SliverPadding(
                padding: const EdgeInsets.only(
                  top: defaultPadding,
                  left: defaultPadding,
                  right: defaultPadding,
                ),
                sliver: SliverToBoxAdapter(
                  child: Text(
                    "${wishlist.length} ${wishlist.length == 1 ? 'item' : 'items'} in wishlist",
                    style: TextStyle(
                      fontSize: isSmallScreen ? 14 : 15,
                      color: blackColor60,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),

              // Grid view
              SliverPadding(
                padding: const EdgeInsets.symmetric(
                  horizontal: defaultPadding,
                  vertical: defaultPadding,
                ),
                sliver: SliverGrid(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: _calculateCrossAxisCount(context),
                    mainAxisSpacing: defaultPadding,
                    crossAxisSpacing: defaultPadding,
                    childAspectRatio: _calculateChildAspectRatio(context),
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (BuildContext context, int index) {
                      final product = wishlist[index];
                      return ProductCard(
                        image: product.images.isNotEmpty
                            ? product.images.first
                            : "",
                        authorName: product.authorName,
                        title: product.title,
                        price: product.price,
                        priceAfetDiscount: product.priceAfterDiscount,
                        dicountpercent: product.discountPercent,
                        press: () {
                          Navigator.pushNamed(
                            context,
                            productDetailsScreenRoute,
                            arguments: product.id,
                          );
                        },
                      );
                    },
                    childCount: wishlist.length,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}