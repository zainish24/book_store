import 'package:flutter/material.dart';

import 'package:my_library/components/Banner/L/banner_l.dart';

import '../../../constants.dart';

class BannerLStyle1 extends StatelessWidget {
  const BannerLStyle1({
    super.key,
    this.image = "https://images.unsplash.com/photo-1526243741027-444d633d7365?w=600&auto=format&fit=crop&q=60&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MTMwfHxsaWJyYXJ5fGVufDB8fDB8fHww",
    required this.title,
    required this.press,
    this.subtitle,
  });
  final String? image;
  final String title;
  final String? subtitle;

  final VoidCallback press;

  @override
  Widget build(BuildContext context) {
    return BannerL(
      image: image!,
      press: press,
      children: [
        Padding(
          padding: const EdgeInsets.all(defaultPadding),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              DefaultTextStyle(
                style: const TextStyle(
                  fontFamily: grandisExtendedFont,
                  fontSize: 60,
                  height: 1.2,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                ),
              ),
              if (subtitle != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: defaultPadding / 2,
                      vertical: defaultPadding / 8),
                  color: Colors.white70,
                  child: Text(
                    subtitle!,
                    style: const TextStyle(
                      color: Colors.black54,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              const SizedBox(height: defaultPadding),
              Text(
                title.toUpperCase(),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: grandisExtendedFont,
                  fontSize: 31,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  height: 1,
                ),
              ),
              const Spacer(),
              const Text(
                "my_library now  >",
                style: TextStyle(
                  fontFamily: grandisExtendedFont,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
              const Spacer(),
            ],
          ),
        ),
      ],
    );
  }
}
