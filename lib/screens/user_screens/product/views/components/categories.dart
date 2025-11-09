import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:my_library/route/screen_export.dart';
import 'package:my_library/user_entry_point.dart'; // Make sure this is imported

import '../../../../../constants.dart';

// For preview
class CategoryModel {
  final String name;
  final String? svgSrc, route;

  CategoryModel({
    required this.name,
    this.svgSrc,
    this.route,
  });
}

List<CategoryModel> demoCategories = [
  CategoryModel(name: "All Categories", route: homeScreenRoute),
  CategoryModel(
    name: "Fiction",
    svgSrc: "assets/icons/Sale.svg",
    route: fictionScreenRoute,
  ),
  CategoryModel(
    name: "Non-Fiction",
    svgSrc: "assets/icons/Man.svg",
    route: nonFictionScreenRoute,
  ),
  CategoryModel(
    name: "Poetry",
    svgSrc: "assets/icons/Woman.svg",
    route: poetryScreenRoute,
  ),
  CategoryModel(
    name: "Drama",
    svgSrc: "assets/icons/Woman.svg",
    route: dramaScreenRoute,
  ),
];
// End For Preview

class Categories extends StatelessWidget {
  final String? currentRoute;
  const Categories({
    super.key,
    this.currentRoute,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          ...List.generate(
            demoCategories.length,
            (index) {
              final category = demoCategories[index];
              final isActive =
                  currentRoute != null && currentRoute == category.route;

              return Padding(
                padding: EdgeInsets.only(
                  left: index == 0 ? defaultPadding : defaultPadding / 2,
                  right:
                      index == demoCategories.length - 1 ? defaultPadding : 0,
                ),
                child: CategoryBtn(
                    category: category.name,
                    svgSrc: category.svgSrc,
                    isActive: isActive,
                    press: () {
                      if (category.name == "Fiction") {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const UserEntryPoint(initialIndex: 1),
                          ),
                        );
                      } else if (category.name == "Non-Fiction") {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const UserEntryPoint(initialIndex: 2),
                          ),
                        );
                      } else if (category.name == "Poetry") {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const UserEntryPoint(initialIndex: 3),
                          ),
                        );
                      } else if (category.name == "Drama") {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const UserEntryPoint(initialIndex: 4),
                          ),
                        );
                      } else if (category.name == "All Categories") {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const UserEntryPoint(initialIndex: 0),
                          ),
                        );
                      }
                    }),
              );
            },
          ),
        ],
      ),
    );
  }
}

class CategoryBtn extends StatelessWidget {
  const CategoryBtn({
    super.key,
    required this.category,
    this.svgSrc,
    required this.isActive,
    required this.press,
  });

  final String category;
  final String? svgSrc;
  final bool isActive;
  final VoidCallback press;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: press,
      borderRadius: const BorderRadius.all(Radius.circular(30)),
      child: Container(
        height: 36,
        padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
        decoration: BoxDecoration(
          color: isActive ? primaryColor : Colors.transparent,
          border: Border.all(
            color:
                isActive ? Colors.transparent : Theme.of(context).dividerColor,
          ),
          borderRadius: const BorderRadius.all(Radius.circular(30)),
        ),
        child: Row(
          children: [
            if (svgSrc != null)
              SvgPicture.asset(
                svgSrc!,
                height: 20,
                colorFilter: ColorFilter.mode(
                  isActive ? Colors.white : Theme.of(context).iconTheme.color!,
                  BlendMode.srcIn,
                ),
              ),
            if (svgSrc != null) const SizedBox(width: defaultPadding / 2),
            Text(
              category,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: isActive
                    ? Colors.white
                    : Theme.of(context).textTheme.bodyLarge!.color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
