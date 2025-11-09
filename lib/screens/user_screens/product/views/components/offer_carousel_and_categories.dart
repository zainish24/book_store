import 'package:flutter/material.dart';

import '../../../../../constants.dart';
import 'categories.dart';
import 'offers_carousel.dart';

class OffersCarouselAndCategories extends StatelessWidget {
  final String? currentRoute;
  final String title;

  const OffersCarouselAndCategories({
    super.key,
    this.currentRoute,
    this.title = "Categories", // default fallback
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // While loading use 👇
        // const OffersSkelton(),
        const OffersCarousel(),
        const SizedBox(height: defaultPadding / 2),
        Padding(
          padding: const EdgeInsets.all(defaultPadding),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleSmall,
          ),
        ),
        // Pass currentRoute to highlight correct category
        Categories(currentRoute: currentRoute),
      ],
    );
  }
}
