import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:my_library/components/cart_button.dart';
import 'package:my_library/components/custom_modal_bottom_sheet.dart';
import 'package:my_library/components/network_image_with_loader.dart';
import 'package:my_library/screens/user_screens/product/views/added_to_cart_message_screen.dart';

import 'package:provider/provider.dart';
import 'package:my_library/screens/user_screens/checkout/views/services/cart_service.dart';
import 'package:my_library/models/cart_model.dart';

import '/../../constants.dart';
import 'package:my_library/models/product_model.dart';
import 'components/product_quantity.dart';
import 'components/unit_price.dart';
import 'package:my_library/screens/user_screens/home/views/services/product_service.dart';

class ProductBuyNowScreen extends StatefulWidget {
  final String productId;

  const ProductBuyNowScreen({super.key, required this.productId});

  @override
  State<ProductBuyNowScreen> createState() => _ProductBuyNowScreenState();
}

class _ProductBuyNowScreenState extends State<ProductBuyNowScreen> {
  int quantity = 1;
  int selectedColor = 0;
  int selectedSize = 0;
  ProductModel? product;

  @override
  void initState() {
    super.initState();
    final productService = ProductService();
    productService.getProductById(widget.productId).listen((data) {
      if (mounted) {
        setState(() {
          product = data;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (product == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      bottomNavigationBar: CartButton(
        price: (product!.priceAfterDiscount ?? product!.price) * quantity,
        title: "Add to cart",
        subTitle: "Total price",
        press: () {
          final cart = Provider.of<CartService>(context, listen: false);

          final newItem = CartItem(
            productId: product!.id,
            title: product!.title,
            image: product!.images.isNotEmpty
                ? product!.images.first
                : productDemoImg1,
            price: product!.price,
            discountedPrice: product!.priceAfterDiscount ?? product!.price,
            qty: quantity,
            selectedColorIndex: selectedColor,
            selectedSizeIndex: selectedSize,
          );

          cart.addItem(newItem);

          customModalBottomSheet(
            context,
            isDismissible: false,
            child: const AddedToCartMessageScreen(),
          );
        },
      ),
      body: Column(
        children: [
          /// Header
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: defaultPadding / 2,
              vertical: defaultPadding,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const BackButton(),
                Text(
                  product!.title,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                IconButton(
                  onPressed: () {},
                  icon: SvgPicture.asset(
                    "assets/icons/Bookmark.svg",
                    color: Theme.of(context).textTheme.bodyLarge!.color,
                  ),
                ),
              ],
            ),
          ),

          /// Body
          Expanded(
            child: CustomScrollView(
              slivers: [
                /// Product Image
                SliverToBoxAdapter(
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: defaultPadding),
                    child: AspectRatio(
                      aspectRatio: 1.05,
                      child: NetworkImageWithLoader(
                        product!.images.isNotEmpty
                            ? product!.images.first
                            : productDemoImg1,
                      ),
                    ),
                  ),
                ),

                /// Price & Quantity
                SliverPadding(
                  padding: const EdgeInsets.all(defaultPadding),
                  sliver: SliverToBoxAdapter(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: UnitPrice(
                            price: product!.price,
                            priceAfterDiscount:
                                product!.priceAfterDiscount ?? product!.price,
                          ),
                        ),
                        ProductQuantity(
                          numOfItem: quantity,
                          onIncrement: () {
                            setState(() {
                              quantity++;
                            });
                          },
                          onDecrement: () {
                            if (quantity > 1) {
                              setState(() {
                                quantity--;
                              });
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
