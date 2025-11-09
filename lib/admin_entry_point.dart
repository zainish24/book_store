import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:my_library/constants.dart';
import 'package:my_library/route/screen_export.dart';

class AdminEntryPoint extends StatefulWidget {
  const AdminEntryPoint({super.key});

  @override
  State<AdminEntryPoint> createState() => _AdminEntryPointState();
}

class _AdminEntryPointState extends State<AdminEntryPoint> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const AdminDashboardScreen(),
    const AdminProductListScreen(),
    const AdminAllOrdersTabScreen(),
    const AdminUserListScreen(),
    const AdminReviewScreen()
  ];

  final List<List<String>> _items = [
    ['Dashboard', 'assets/icons/home.svg'],
    ['Products', 'assets/icons/Product.svg'],
    ['Orders', 'assets/icons/Order.svg'],
    ['Users', 'assets/icons/User.svg'],
    ['Reviews', 'assets/icons/marketing.svg'],
  ];

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDesktop = MediaQuery.of(context).size.width >= 900;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: theme.colorScheme.background,
      drawer: isDesktop
          ? null
          : Drawer(
              child: SafeArea(child: _buildDrawerContent(theme, isDesktop)),
            ),
      body: Row(
        children: [
          if (isDesktop)
            Container(
              width: 260,
              decoration: BoxDecoration(
                color: theme.cardColor,
                border: Border(
                  right: BorderSide(color: theme.dividerColor, width: 0.5),
                ),
              ),
              child: _buildDrawerContent(theme, isDesktop),
            ),
          Expanded(
            child: Column(
              children: [
                if (!isDesktop)
                  AppBar(
                    elevation: 0,
                    centerTitle: false,
                    backgroundColor: theme.colorScheme.background,
                    automaticallyImplyLeading: false,
                    leading: IconButton(
                      icon: Icon(Icons.menu,
                          color: theme.colorScheme.onBackground),
                      onPressed: () => _scaffoldKey.currentState?.openDrawer(),
                    ),
                    title: Text(
                      "My Library", // ✅ Static title
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.onBackground,
                        fontWeight: FontWeight.bold,
                        fontFamily: grandisExtendedFont,
                        fontSize: 20,
                        letterSpacing: 1.1,
                      ),
                    ),
                  ),

                // 👇 This was missing — now your screens render properly
                Expanded(
                  child: _screens[_selectedIndex],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerContent(ThemeData theme, bool isDesktop) {
    return Column(
      children: [
        _buildLogoSection(theme),
        const Divider(height: 1),
        Expanded(
          child: ListView.builder(
            itemCount: _items.length,
            padding: const EdgeInsets.symmetric(vertical: defaultPadding),
            itemBuilder: (context, i) {
              final isSelected = _selectedIndex == i;
              return InkWell(
                onTap: () {
                  setState(() => _selectedIndex = i);
                  if (!isDesktop) Navigator.pop(context); // Close drawer
                },
                borderRadius: BorderRadius.circular(defaultBorderRadious),
                child: Container(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  padding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? primaryColor.withOpacity(0.12)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(defaultBorderRadious),
                  ),
                  child: Row(
                    children: [
                      SvgPicture.asset(
                        _items[i][1],
                        width: 22,
                        height: 22,
                        color: isSelected
                            ? primaryColor
                            : theme.colorScheme.onBackground.withOpacity(0.6),
                      ),
                      const SizedBox(width: 14),
                      Text(
                        _items[i][0],
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.normal,
                          color: isSelected
                              ? theme.colorScheme.onBackground
                              : theme.colorScheme.onBackground.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildLogoSection(ThemeData theme) {
    return Container(
      height: 100,
      padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
      alignment: Alignment.centerLeft,
      child: Row(
        children: [
          _logoIcon(),
          const SizedBox(width: 12),
          Text(
            "Admin Panel",
            style: theme.textTheme.titleLarge?.copyWith(
              fontFamily: grandisExtendedFont,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onBackground,
            ),
          )
        ],
      ),
    );
  }

  Widget _logoIcon() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: primaryColor.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: SvgPicture.asset(
        'assets/icons/User.svg',
        width: 24,
        height: 24,
        color: primaryColor,
      ),
    );
  }
}
