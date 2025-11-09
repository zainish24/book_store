import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:my_library/constants.dart';
import 'package:my_library/route/screen_export.dart';

class UserEntryPoint extends StatefulWidget {
  final int initialIndex;
  const UserEntryPoint({super.key, this.initialIndex = 0});

  @override
  State<UserEntryPoint> createState() => _EntryPointState();
}

class _EntryPointState extends State<UserEntryPoint> {
  late int _currentIndex;

  final List<Widget> _pages = const [
    HomeScreen(), // index 0
    FictionScreen(), // index 1
    NonFictionScreen(), // index 2
    PoetryScreen(), // index 3
    DramaScreen(), // index 4
    DiscoverScreen(), // index 5 (nav: 1)
    BookmarkScreen(), // index 6 (nav: 2)
    CartScreen(), // index 7 (nav: 3)
    ProfileScreen(), // index 8 (nav: 4)
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  // Simplified SVG icon method
  Widget _buildSvgIcon(String assetPath, bool isActive, BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final inactiveColor = isDark ? Colors.grey.shade400 : Colors.grey.shade600;
    
    return SvgPicture.asset(
      assetPath,
      height: 24,
      width: 24,
      colorFilter: ColorFilter.mode(
        isActive ? primaryColor : inactiveColor,
        BlendMode.srcIn,
      ),
    );
  }

  // Get the navigation index
  int get _navIndex {
    final navIndices = [0, 5, 6, 7, 8];
    return navIndices.contains(_currentIndex) 
        ? navIndices.indexOf(_currentIndex) 
        : 0;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        leading: const SizedBox(),
        leadingWidth: 0,
        centerTitle: false,
        elevation: 0,
        title: Text(
          "My Library",
          style: TextStyle(
            fontFamily: grandisExtendedFont,
            fontSize: 22,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
            color: isDark ? whiteColor : blackColor,
          ),
        ),
      ),
      body: PageTransitionSwitcher(
        duration: defaultDuration,
        transitionBuilder: (child, animation, secondAnimation) {
          return FadeThroughTransition(
            animation: animation,
            secondaryAnimation: secondAnimation,
            child: child,
          );
        },
        child: _pages[_currentIndex],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.only(top: defaultPadding / 2),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF101015) : Colors.white,
          boxShadow: [
            if (!isDark)
              BoxShadow(
                offset: const Offset(0, -2),
                blurRadius: 4,
                color: Colors.black.withOpacity(0.1),
              ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _navIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = [0, 5, 6, 7, 8][index];
            });
          },
          backgroundColor: Colors.transparent,
          elevation: 0,
          type: BottomNavigationBarType.fixed,
          selectedFontSize: 12,
          unselectedFontSize: 12,
          selectedItemColor: primaryColor,
          unselectedItemColor: Colors.grey,
          showSelectedLabels: true,
          showUnselectedLabels: true,
          items: [
            BottomNavigationBarItem(
              icon: _buildSvgIcon("assets/icons/book.svg", _navIndex == 0, context),
              activeIcon: _buildSvgIcon("assets/icons/book.svg", true, context),
              label: "Shop",
            ),
            BottomNavigationBarItem(
              icon: _buildSvgIcon("assets/icons/Category.svg", _navIndex == 1, context),
              activeIcon: _buildSvgIcon("assets/icons/Category.svg", true, context),
              label: "Discover",
            ),
            BottomNavigationBarItem(
              icon: _buildSvgIcon("assets/icons/Bookmark.svg", _navIndex == 2, context),
              activeIcon: _buildSvgIcon("assets/icons/Bookmark.svg", true, context),
              label: "Bookmark",
            ),
            BottomNavigationBarItem(
              icon: _buildSvgIcon("assets/icons/Bag.svg", _navIndex == 3, context),
              activeIcon: _buildSvgIcon("assets/icons/Bag.svg", true, context),
              label: "Cart",
            ),
            BottomNavigationBarItem(
              icon: _buildSvgIcon("assets/icons/Profile.svg", _navIndex == 4, context),
              activeIcon: _buildSvgIcon("assets/icons/Profile.svg", true, context),
              label: "Profile",
            ),
          ],
        ),
      ),
    );
  }
}