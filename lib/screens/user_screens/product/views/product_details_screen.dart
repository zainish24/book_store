import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:my_library/components/cart_button.dart';
import 'package:my_library/components/custom_modal_bottom_sheet.dart';
import 'package:my_library/components/product/product_card.dart';
import 'package:my_library/constants.dart';
import 'package:my_library/screens/user_screens/product/views/product_buy_now_screen.dart';
import 'package:my_library/screens/user_screens/product/views/product_returns_screen.dart';
import 'package:my_library/screens/user_screens/reviews/view/services/review_service.dart';
import 'package:my_library/screens/user_screens/bookmark/views/services/wishlist_service.dart';

import 'package:my_library/route/screen_export.dart';
import 'components/notify_me_card.dart';
import 'components/product_images.dart';
import 'components/product_info.dart';
import 'components/product_list_tile.dart';
import 'components/product_detail_sheet.dart';
import 'components/shipping_info_sheet.dart';
import 'components/review_card.dart';

import 'package:my_library/models/product_model.dart';
import 'package:my_library/screens/user_screens/home/views/services/product_service.dart';

class ProductDetailsScreen extends StatelessWidget {
  final String productId;

  const ProductDetailsScreen({
    super.key,
    required this.productId,
  });

  @override
  Widget build(BuildContext context) {
    final productService = ProductService();

    return StreamBuilder<ProductModel?>(
      stream: productService.getProductById(productId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (!snapshot.hasData || snapshot.data == null) {
          return const Scaffold(
            body: Center(child: Text("Product not found")),
          );
        }

        final product = snapshot.data!;

        return Scaffold(
          bottomNavigationBar: product.inStock
              ? CartButton(
                  price: product.priceAfterDiscount ?? product.price,
                  press: () {
                    customModalBottomSheet(
                      context,
                      height: MediaQuery.of(context).size.height * 0.92,
                      child: ProductBuyNowScreen(productId: product.id),
                    );
                  },
                )
              : NotifyMeCard(
                  isNotify: false,
                  onChanged: (value) {},
                ),
          body: SafeArea(
            child: CustomScrollView(
              slivers: [
                /// App Bar
                SliverAppBar(
                  backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                  floating: true,
                  actions: [
                    /// ✅ Wishlist Button with Live State
                    StreamBuilder<bool>(
                      stream: WishlistService().isInWishlist(product.id),
                      builder: (context, snap) {
                        final isInWishlist = snap.data ?? false;
                        return IconButton(
                          onPressed: () {
                            if (isInWishlist) {
                              WishlistService().removeFromWishlist(product.id);
                            } else {
                              WishlistService().addToWishlist(product);
                            }
                          },
                          icon: SvgPicture.asset(
                            "assets/icons/Bookmark.svg",
                            color: isInWishlist
                                ? primaryColor
                                : Theme.of(context)
                                    .textTheme
                                    .bodyLarge!
                                    .color,
                          ),
                        );
                      },
                    ),
                  ],
                ),

                /// Product Images
                ProductImages(images: product.images),

                /// ✅ Product Info
                StreamBuilder<Map<String, dynamic>>(
                  stream: ReviewService().getReviewStats(product.id),
                  builder: (context, snap) {
                    if (!snap.hasData) {
                      return ProductInfo(
                        author: product.authorName,
                        title: product.title,
                        isAvailable: product.inStock,
                        description: product.description ?? "",
                        rating: 0,
                        numOfReviews: 0,
                      );
                    }
                    final stats = snap.data!;
                    return ProductInfo(
                      author: product.authorName,
                      title: product.title,
                      isAvailable: product.inStock,
                      description: product.description ?? "",
                      rating: stats["average"],
                      numOfReviews: stats["count"],
                    );
                  },
                ),

                /// Product Details
                ProductListTile(
                  svgSrc: "assets/icons/Product.svg",
                  title: "Product Details",
                  press: () {
                    customModalBottomSheet(
                      context,
                      height: MediaQuery.of(context).size.height * 0.92,
                      child: const ProductDetailSheet(),
                    );
                  },
                ),

                /// Shipping Info
                ProductListTile(
                  svgSrc: "assets/icons/Delivery.svg",
                  title: "Shipping Information",
                  press: () {
                    customModalBottomSheet(
                      context,
                      height: MediaQuery.of(context).size.height * 0.92,
                      child: const ShippingInfoSheet(),
                    );
                  },
                ),

                /// Returns
                ProductListTile(
                  svgSrc: "assets/icons/Return.svg",
                  title: "Returns",
                  isShowBottomBorder: true,
                  press: () {
                    customModalBottomSheet(
                      context,
                      height: MediaQuery.of(context).size.height * 0.92,
                      child: const ProductReturnsScreen(),
                    );
                  },
                ),

                /// Reviews Summary
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(defaultPadding),
                    child: StreamBuilder<Map<String, dynamic>>(
                      stream: ReviewService().getReviewStats(product.id),
                      builder: (context, snap) {
                        if (!snap.hasData) return const SizedBox();
                        final stats = snap.data!;
                        final dist = stats["distribution"] as Map<int, int>;
                        return ReviewCard(
                          rating: stats["average"],
                          numOfReviews: stats["count"],
                          numOfFiveStar: dist[5] ?? 0,
                          numOfFourStar: dist[4] ?? 0,
                          numOfThreeStar: dist[3] ?? 0,
                          numOfTwoStar: dist[2] ?? 0,
                          numOfOneStar: dist[1] ?? 0,
                        );
                      },
                    ),
                  ),
                ),

                /// Reviews Button
                ProductListTile(
                  svgSrc: "assets/icons/Chat.svg",
                  title: "Reviews",
                  isShowBottomBorder: true,
                  press: () {
                    Navigator.pushNamed(
                      context,
                      productReviewsScreenRoute,
                      arguments: {
                        'productId': product.id,
                        'productName': product.title,
                      },
                    );
                  },
                ),

                /// Related Products
                SliverPadding(
                  padding: const EdgeInsets.all(defaultPadding),
                  sliver: SliverToBoxAdapter(
                    child: Text(
                      "You may also like",
                      style: Theme.of(context).textTheme.titleSmall!,
                    ),
                  ),
                ),
                StreamBuilder<List<ProductModel>>(
                  stream: productService.getRelatedProducts(
                    productId: product.id,
                    categories: product.categories,
                  ),
                  builder: (context, relatedSnap) {
                    if (!relatedSnap.hasData) return const SliverToBoxAdapter();
                    final relatedProducts = relatedSnap.data!;
                    return SliverToBoxAdapter(
                      child: SizedBox(
                        height: 220,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: relatedProducts.length,
                          itemBuilder: (context, index) {
                            final rp = relatedProducts[index];
                            return Padding(
                              padding: EdgeInsets.only(
                                left: defaultPadding,
                                right: index == relatedProducts.length - 1
                                    ? defaultPadding
                                    : 0,
                              ),
                              child: ProductCard(
                                image: rp.images.isNotEmpty
                                    ? rp.images.first
                                    : product.images.first,
                                title: rp.title,
                                authorName: rp.authorName,
                                price: rp.price,
                                priceAfetDiscount: rp.priceAfterDiscount,
                                dicountpercent: rp.discountPercent,
                                press: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => ProductDetailsScreen(
                                        productId: rp.id,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  },
                ),

                const SliverToBoxAdapter(
                  child: SizedBox(height: defaultPadding),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
