import 'package:flutter/material.dart';
import 'package:my_library/components/Banner/S/banner_s_style_1.dart';
import 'package:my_library/components/Banner/S/banner_s_style_5.dart';
import 'package:my_library/constants.dart';
import 'package:my_library/route/screen_export.dart';

import 'components/fiction.dart';
import '../../product/views/components/offer_carousel_and_categories.dart';

class FictionScreen extends StatelessWidget {
  const FictionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            const SliverToBoxAdapter(
              child: OffersCarouselAndCategories(
                currentRoute: fictionScreenRoute,
                title: "Fiction",
              ),
            ),
            SliverToBoxAdapter(
              child: Column(
                children: [
                  const SizedBox(height: defaultPadding),
                  BannerSStyle1(
                    title: "Fiction \nHighlights",
                    subtitle: "Dive Into Stories",
                    press: () {},
                  ),
                  const SizedBox(height: defaultPadding / 4),
                ],
              ),
            ),
            const SliverToBoxAdapter(child: Fiction()),
            SliverToBoxAdapter(
              child: Column(
                children: [
                  const SizedBox(height: defaultPadding * 1.5),
                  BannerSStyle5(
                    title: "New Fiction \nCollection",
                    subtitle: "Top Reads",
                    bottomText: "Books".toUpperCase(),
                    press: () {},
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
