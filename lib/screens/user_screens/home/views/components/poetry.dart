import 'package:flutter/material.dart';
import 'package:my_library/components/product/product_card.dart';
import 'package:my_library/models/product_model.dart';
import 'package:my_library/screens/user_screens/product/views/product_details_screen.dart';
import '../../../../../constants.dart';
import '../services/product_service.dart';

class Poetry extends StatelessWidget {
  const Poetry({super.key});

  @override
  Widget build(BuildContext context) {
    final productService = ProductService();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: defaultPadding / 2),
        Padding(
          padding: const EdgeInsets.all(defaultPadding),
          child: Text(
            "Poetry",
            style: Theme.of(context).textTheme.titleSmall,
          ),
        ),
        SizedBox(
          height: 220,
          child: StreamBuilder<List<ProductModel>>(
            stream: productService.getProductsBySpecialCategory("Poetry"),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text("No poetry books found"));
              }

              final products = snapshot.data!;
              return ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: products.length,
                itemBuilder: (context, index) {
                  final product = products[index];
                  return Padding(
                    padding: EdgeInsets.only(
                      left: defaultPadding,
                      right: index == products.length - 1 ? defaultPadding : 0,
                    ),
                    child: ProductCard(
                      image: product.images.isNotEmpty ? product.images.first : '',
                      authorName: product.authorName,
                      title: product.title,
                      price: product.price,
                      priceAfetDiscount: product.priceAfterDiscount,
                      dicountpercent: product.discountPercent,
                      press: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ProductDetailsScreen(productId: product.id),
                          ),
                        );
                      },
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
