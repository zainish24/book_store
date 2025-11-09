import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:my_library/components/network_image_with_loader.dart';
import 'package:my_library/constants.dart';
import 'package:my_library/route/screen_export.dart';
import 'package:my_library/components/custom_dialog.dart'; // 👈 yeh use hoga

import 'components/profile_card.dart';
import 'components/profile_menu_item_list_tile.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<void> _confirmLogout(BuildContext context) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Logout Confirmation"),
        content: const Text("Are you sure you want to log out?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              "Logout",
              style: TextStyle(color: errorColor),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await FirebaseAuth.instance.signOut();

      if (context.mounted) {
        // Success dialog
        CustomDialog.show(
          context,
          message: "You have been logged out successfully",
          isError: false,
        );

        // Wait a little so dialog is visible before navigation
        await Future.delayed(const Duration(seconds: 1));

        if (context.mounted) {
          Navigator.pushReplacementNamed(context, logInScreenRoute);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final String uid = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      body: StreamBuilder<DocumentSnapshot>(
        stream:
            FirebaseFirestore.instance.collection("users").doc(uid).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text("No profile found"));
          }

          var userData = snapshot.data!.data() as Map<String, dynamic>;

          return ListView(
            children: [
              ProfileCard(
                name: userData["name"] ?? "Guest",
                email: userData["email"] ?? "",
                imageSrc: userData["photoUrl"] ?? "assets/images/profile.png",
                press: () {
                  Navigator.pushNamed(context, profileSummaryRoute);
                },
              ),

              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: defaultPadding, vertical: defaultPadding * 1.5),
                child: GestureDetector(
                  onTap: () {},
                  child: const AspectRatio(
                    aspectRatio: 1.8,
                    child: NetworkImageWithLoader(
                        "https://i.imgur.com/dz0BBom.png"),
                  ),
                ),
              ),

              // 🔹 Account Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
                child: Text("Account",
                    style: Theme.of(context).textTheme.titleSmall),
              ),
              const SizedBox(height: defaultPadding / 2),

              ProfileMenuListTile(
                text: "Orders",
                svgSrc: "assets/icons/Order.svg",
                press: () => Navigator.pushNamed(context, ordersScreenRoute),
              ),
              ProfileMenuListTile(
                text: "Wishlist",
                svgSrc: "assets/icons/Wishlist.svg",
                press: () => Navigator.pushNamed(context, bookmarkScreenRoute),
              ),
              ProfileMenuListTile(
                text: "Addresses",
                svgSrc: "assets/icons/Address.svg",
                press: () => Navigator.pushNamed(context, addressesScreenRoute),
              ),
              ProfileMenuListTile(
                text: "Payment",
                svgSrc: "assets/icons/card.svg",
                press: () =>
                    Navigator.pushNamed(context, paymentMethodScreenRoute),
              ),

              const SizedBox(height: defaultPadding),

              
              // 🔹 Logout
              ListTile(
                onTap: () => _confirmLogout(context),
                minLeadingWidth: 24,
                leading: SvgPicture.asset(
                  "assets/icons/Logout.svg",
                  height: 24,
                  width: 24,
                  colorFilter:
                      const ColorFilter.mode(errorColor, BlendMode.srcIn),
                ),
                title: const Text(
                  "Log Out",
                  style: TextStyle(color: errorColor, fontSize: 14, height: 1),
                ),
              )
            ],
          );
        },
      ),
    );
  }
}
