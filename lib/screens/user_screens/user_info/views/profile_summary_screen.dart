import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:my_library/constants.dart';
import 'edit_profile_screen.dart';
import 'package:my_library/route/route_constants.dart';

class ProfileSummaryScreen extends StatefulWidget {
  const ProfileSummaryScreen({super.key});

  @override
  State<ProfileSummaryScreen> createState() => _ProfileSummaryScreenState();
}

class _ProfileSummaryScreenState extends State<ProfileSummaryScreen> {
  File? profileImage;
  String fullName = "";
  String email = "";
  String phone = "";
  String address = "";
  String country = "";
  String? imageUrl;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        DocumentSnapshot snapshot = await FirebaseFirestore.instance
            .collection("users")
            .doc(user.uid)
            .get();

        if (snapshot.exists) {
          final data = snapshot.data() as Map<String, dynamic>;
          setState(() {
            fullName = data['name'] ?? "";
            email = data['email'] ?? "";
            phone = data['phone'] ?? "";
            address = data['address'] ?? "";
            country = data['country'] ?? "";
            imageUrl = data['image'];
            _loading = false;
          });
        }
      }
    } catch (e) {
      debugPrint("Error loading user data: $e");
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F9),
      appBar: _buildAppBar(),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Column(
                children: [
                  _buildProfileHeader(),
                  const SizedBox(height: 24),
                  _buildProfileItem("Full Name", fullName),
                  _buildProfileItem("Email", email),
                  _buildProfileItem("Phone Number", phone),
                  _buildProfileItem("Address", address),
                  _buildProfileItem("Country", country),
                  const SizedBox(height: 20),
                  _buildChangePasswordTile(),
                ],
              ),
            ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFFF7F7F9),
      elevation: 0,
      centerTitle: true,
      iconTheme: const IconThemeData(color: Colors.black),
      title: const Text(
        "My Profile",
        style: TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.w700,
          fontSize: 20,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () async {
            final updatedData = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => EditProfileScreen(
                  profileImage: profileImage,
                  fullName: fullName,
                  email: email,
                  phone: phone,
                  address: address,
                  country: country,
                ),
              ),
            );
            if (updatedData != null) {
              setState(() {
                profileImage = updatedData["profileImage"];
                fullName = updatedData["fullName"];
                email = updatedData["email"];
                phone = updatedData["phone"];
                address = updatedData["address"];
                country = updatedData["country"];
                imageUrl = updatedData["imageUrl"] ?? imageUrl;
              });
            }
          },
          child: const Text(
            "Edit",
            style: TextStyle(
              color: primaryColor,
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
        )
      ],
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundImage: profileImage != null
                ? FileImage(profileImage!)
                : (imageUrl != null && imageUrl!.isNotEmpty
                    ? NetworkImage(imageUrl!)
                    : const AssetImage("assets/images/profile.png"))
                as ImageProvider,
          ),
          const SizedBox(height: 12),
          Text(fullName,
              style:
                  const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(email,
              style: const TextStyle(color: Colors.grey, fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildProfileItem(String title, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(color: Colors.grey, fontSize: 14)),
          Flexible(
            child: Text(
              value.isNotEmpty ? value : "-",
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChangePasswordTile() {
    return InkWell(
      onTap: () {
        Navigator.pushNamed(context, verificationMethodScreenRoute);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Change Password", style: TextStyle(color: Colors.grey)),
            Icon(Icons.arrow_forward_ios, size: 16, color: primaryColor)
          ],
        ),
      ),
    );
  }
}
