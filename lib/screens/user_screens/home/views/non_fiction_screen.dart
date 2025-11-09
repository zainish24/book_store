import 'package:flutter/material.dart';
import 'package:my_library/components/Banner/S/banner_s_style_1.dart';
import 'package:my_library/components/Banner/S/banner_s_style_5.dart';
import 'package:my_library/constants.dart';
import 'package:my_library/route/screen_export.dart';

import 'components/non_fiction.dart';
import '../../product/views/components/offer_carousel_and_categories.dart';

class NonFictionScreen extends StatelessWidget {
  const NonFictionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            const SliverToBoxAdapter(
              child: OffersCarouselAndCategories(
                currentRoute: nonFictionScreenRoute,
                title: "Non_Fiction",
              ),
            ),
            
            SliverToBoxAdapter(
              child: Column(
                children: [
                  const SizedBox(height: defaultPadding),
                  BannerSStyle1(
                    title: "New \narrival",
                    subtitle: "SPECIAL OFFER",
                    press: () {
                      Navigator.pushNamed(context, "");
                    },
                  ),
                  const SizedBox(height: defaultPadding / 4),
                ],
              ),
            ),
            const SliverToBoxAdapter(child: NonFiction()),
            SliverToBoxAdapter(
              child: Column(
                children: [
                  const SizedBox(height: defaultPadding * 1.5),
                  BannerSStyle5(
                    title: "Black \nfriday",
                    subtitle: "50% Off",
                    bottomText: "Collection".toUpperCase(),
                    press: () {
                      Navigator.pushNamed(context, "");
                    },
                  ),
                  const SizedBox(height: defaultPadding / 4),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
