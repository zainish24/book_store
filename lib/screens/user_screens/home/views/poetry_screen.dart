import 'package:flutter/material.dart';
import 'package:my_library/components/Banner/S/banner_s_style_1.dart';
import 'package:my_library/components/Banner/S/banner_s_style_5.dart';
import 'package:my_library/constants.dart';
import 'package:my_library/route/screen_export.dart';

import 'components/poetry.dart';
import '../../product/views/components/offer_carousel_and_categories.dart';

class PoetryScreen extends StatelessWidget {
  const PoetryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            const SliverToBoxAdapter(
              child: OffersCarouselAndCategories(
                currentRoute: poetryScreenRoute,
                title: "Poetry",
              ),
            ),
            SliverToBoxAdapter(
              child: Column(
                children: [
                  const SizedBox(height: defaultPadding ),
                  BannerSStyle1(
                    title: "Poetry \nSpotlight",
                    subtitle: "Words That Inspire",
                    press: () {},
                  ),
                  const SizedBox(height: defaultPadding / 4),
                ],
              ),
            ),
            const SliverToBoxAdapter(child: Poetry()),
            SliverToBoxAdapter(
              child: Column(
                children: [
                  const SizedBox(height: defaultPadding * 1.5),
                  BannerSStyle5(
                    title: "Poetry \nCollection",
                    subtitle: "Timeless Verses",
                    bottomText: "Poetry".toUpperCase(),
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
