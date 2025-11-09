import 'package:flutter/material.dart';
import 'package:my_library/components/Banner/S/banner_s_style_1.dart';
import 'package:my_library/components/Banner/S/banner_s_style_5.dart';
import 'package:my_library/constants.dart';
import 'package:my_library/route/screen_export.dart';

import 'components/drama.dart';
import '../../product/views/components/offer_carousel_and_categories.dart';

class DramaScreen extends StatelessWidget {
  const DramaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            const SliverToBoxAdapter(
              child: OffersCarouselAndCategories(
                currentRoute: dramaScreenRoute,
                title: "Drama",
              ),
            ),
            SliverToBoxAdapter(
              child: Column(
                children: [
                  const SizedBox(height: defaultPadding),
                  BannerSStyle1(
                    title: "Drama \nSpecials",
                    subtitle: "Classic & Modern",
                    press: () {},
                  ),
                  const SizedBox(height: defaultPadding / 4),
                ],
              ),
            ),
            const SliverToBoxAdapter(child: Drama()),

            SliverToBoxAdapter(
              child: Column(
                children: [
                  const SizedBox(height: defaultPadding * 1.5),
                  BannerSStyle5(
                    title: "Stage & \nScreen",
                    subtitle: "Dramatic Reads",
                    bottomText: "Drama".toUpperCase(),
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
