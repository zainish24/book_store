import 'package:flutter/material.dart';
import 'package:my_library/route/route_constants.dart';
import '/constants.dart';

class NoAddressScreen extends StatelessWidget {
  const NoAddressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteColor,
      appBar: AppBar(
        backgroundColor: whiteColor,
        elevation: 0,
        centerTitle: true,
        leading: const BackButton(color: blackColor),
        title: const Text(
          'My Addresses',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            fontFamily: grandisExtendedFont,
            color: blackColor,
          ),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(defaultPadding),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.location_off, size: 64, color: greyColor),
              const SizedBox(height: 20),
              const Text(
                "No saved addresses yet",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  fontFamily: grandisExtendedFont,
                  color: blackColor,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                "Add your first delivery address to speed up checkout.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  fontFamily: grandisExtendedFont,
                  color: blackColor60,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, addNewAddressesScreenRoute);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(defaultBorderRadious),
                  ),
                ),
                child: const Text(
                  "Add Address",
                  style: TextStyle(
                    fontFamily: grandisExtendedFont,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
