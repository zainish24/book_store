import 'package:flutter/material.dart';
import 'package:my_library/components/Banner/S/banner_s_style_1.dart';
import 'package:my_library/components/Banner/S/banner_s_style_5.dart';
import 'package:my_library/constants.dart';
import 'package:my_library/route/screen_export.dart';

import 'components/drama.dart';
import 'components/poetry.dart';
import 'components/fiction.dart';
import 'components/non_fiction.dart';
import '../../product/views/components/offer_carousel_and_categories.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            const SliverToBoxAdapter(
              child: OffersCarouselAndCategories(
                currentRoute: homeScreenRoute,
                title: "All Categories",
              ),
            ),
            const SliverToBoxAdapter(child: Drama()),
            const SliverPadding(
              padding: EdgeInsets.symmetric(vertical: defaultPadding * 1.5),
              sliver: SliverToBoxAdapter(child: Poetry()),
            ),
            SliverToBoxAdapter(
              child: Column(
                children: [
                  BannerSStyle1(
                    title: "Discover \nNew Fiction",
                    subtitle: "Fresh Stories Await",
                    press: () {
                      Navigator.pushNamed(context, fictionScreenRoute);
                    },
                  ),
                  const SizedBox(height: defaultPadding / 4),
                ],
              ),
            ),
            const SliverToBoxAdapter(child: Fiction()),
            const SliverToBoxAdapter(child: NonFiction()),
            SliverToBoxAdapter(
              child: Column(
                children: [
                  const SizedBox(height: defaultPadding * 1.5),
                  BannerSStyle5(
                    title: "Explore \nNon-Fiction",
                    subtitle: "Wisdom & Knowledge",
                    bottomText: "Collection".toUpperCase(),
                    press: () {
                      Navigator.pushNamed(context, nonFictionScreenRoute);
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
