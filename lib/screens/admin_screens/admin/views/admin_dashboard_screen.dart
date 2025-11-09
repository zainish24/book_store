import 'package:flutter/material.dart';
import 'package:my_library/components/Banner/S/banner_s_style_5.dart';
import 'package:my_library/constants.dart';
import 'package:my_library/route/screen_export.dart';
import 'components/offers_carousel.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightGreyColor,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
             const SliverToBoxAdapter(
              child: OffersCarousel(),
            ),

            /// 🔹 Dashboard Cards as SliverGrid
            SliverPadding(
              padding: const EdgeInsets.all(defaultPadding),
              sliver: SliverGrid(
                delegate: SliverChildListDelegate([
                  _DashboardCard(
                    title: "Orders",
                    icon: Icons.shopping_bag_outlined,
                    color: primaryColor,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const AdminAllOrdersTabScreen(),
                      ),
                    ),
                  ),
                  _DashboardCard(
                    title: "Books",
                    icon: Icons.menu_book_outlined,
                    color: primaryColor,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const AdminProductListScreen(),
                      ),
                    ),
                  ),
                  _DashboardCard(
                    title: "Readers",
                    icon: Icons.people_alt_outlined,
                    color: primaryColor,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const AdminUserListScreen(),
                      ),
                    ),
                  ),
                  _DashboardCard(
                    title: "Reviews",
                    icon: Icons.reviews_outlined,
                    color: primaryColor,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const AdminReviewScreen(),
                      ),
                    ),
                  ),
                ]),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: defaultPadding,
                  crossAxisSpacing: defaultPadding,
                  childAspectRatio: 1, // square cards
                ),
              ),
            ),

            /// Second Banner
            SliverToBoxAdapter(
              child: Column(
                children: [
                  const SizedBox(height: defaultPadding * 1.5),
                  BannerSStyle5(
                    title: "Explore \nNon-Fiction",
                    subtitle: "Wisdom & Knowledge",
                    bottomText: "COLLECTION",
                    press: () {
                      Navigator.pushNamed(context, "");
                    },
                  ),
                  const SizedBox(height: defaultPadding),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DashboardCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _DashboardCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: whiteColor,
      borderRadius: BorderRadius.circular(defaultBorderRadious),
      elevation: 5,
      child: InkWell(
        borderRadius: BorderRadius.circular(defaultBorderRadious),
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: color.withOpacity(0.15),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: blackColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
