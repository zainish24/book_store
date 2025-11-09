// lib/screens/user_screens/profile/views/edit_profile_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:my_library/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:my_library/components/custom_dialog.dart'; // 👈 custom dialog

class EditProfileScreen extends StatefulWidget {
  final File? profileImage;
  final String fullName;
  final String email;
  final String phone;
  final String address;
  final String country;

  const EditProfileScreen({
    super.key,
    this.profileImage,
    this.fullName = '',
    this.email = '',
    this.phone = '',
    this.address = '',
    this.country = '',
  });

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  File? selectedImage;
  late TextEditingController nameController;
  late TextEditingController phoneController;
  late TextEditingController addressController;
  late TextEditingController emailController;
  String? selectedCountry;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    selectedImage = widget.profileImage;
    nameController = TextEditingController(text: widget.fullName);
    phoneController = TextEditingController(text: widget.phone);
    addressController = TextEditingController(text: widget.address);
    emailController = TextEditingController(text: widget.email);
    selectedCountry = widget.country;
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<String?> _uploadImageToCloudinary(File imageFile) async {
    const cloudName = "YOUR_CLOUD_NAME";
    const uploadPreset = "YOUR_UPLOAD_PRESET";
    const uploadUrl = "https://api.cloudinary.com/v1_1/$cloudName/image/upload";

    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(imageFile.path),
        'upload_preset': uploadPreset,
      });

      final response = await Dio().post(uploadUrl, data: formData);

      if (response.statusCode == 200) {
        return response.data["secure_url"];
      }
    } catch (e) {
      debugPrint("Image upload error: $e");
    }
    return null;
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception("User not logged in");

      String? imageUrl;

      if (selectedImage != null) {
        imageUrl = await _uploadImageToCloudinary(selectedImage!);
      }

      final updatedData = {
        "name": nameController.text,
        "email": emailController.text,
        "phone": phoneController.text,
        "address": addressController.text,
        "country": selectedCountry,
        if (imageUrl != null) "image": imageUrl,
      };

      await FirebaseFirestore.instance
          .collection("users")
          .doc(user.uid)
          .update(updatedData);

      Navigator.pop(context, {
        "profileImage": selectedImage,
        "fullName": nameController.text,
        "email": emailController.text,
        "phone": phoneController.text,
        "address": addressController.text,
        "country": selectedCountry,
        "imageUrl": imageUrl,
      });
    } catch (e) {
      debugPrint("Error saving profile: $e");
      CustomDialog.show(context,
          message: "Failed to update profile", isError: true);
    } finally {
      setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          backgroundColor: const Color(0xFFF7F7F9),
          appBar: AppBar(
            backgroundColor: const Color(0xFFF7F7F9),
            title: const Text("Edit Profile",
                style:
                    TextStyle(color: Colors.black, fontWeight: FontWeight.w700)),
            centerTitle: true,
            elevation: 0,
            iconTheme: const IconThemeData(color: Colors.black),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundImage: selectedImage != null
                            ? FileImage(selectedImage!)
                            : const AssetImage("assets/images/profile.png")
                                as ImageProvider,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: InkWell(
                          onTap: _pickImage,
                          child: const CircleAvatar(
                            backgroundColor: primaryColor,
                            radius: 18,
                            child:
                                Icon(Icons.edit, color: Colors.white, size: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _buildInputField(
                      "Full Name", "assets/icons/Profile.svg", nameController),
                  const SizedBox(height: 16),
                  _buildInputField(
                      "Phone Number", "assets/icons/Call.svg", phoneController,
                      keyboardType: TextInputType.phone),
                  const SizedBox(height: 16),
                  _buildInputField(
                      "Address", "assets/icons/Location.svg", addressController),
                  const SizedBox(height: 16),
                  _buildDropdown(),
                  const SizedBox(height: 16),
                  _buildInputField("Email Address", "assets/icons/Message.svg",
                      emailController,
                      keyboardType: TextInputType.emailAddress),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _saveProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text("Save Changes",
                          style: TextStyle(fontSize: 16, color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // Loading overlay
        if (_saving)
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.4),
              child: const Center(
                child: CircularProgressIndicator(
                  color: primaryColor,
                  strokeWidth: 6,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildInputField(
      String hint, String icon, TextEditingController controller,
      {TextInputType keyboardType = TextInputType.text}) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: (value) =>
          value == null || value.isEmpty ? "Enter $hint" : null,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        prefixIcon: Padding(
          padding: const EdgeInsets.all(12),
          child: SvgPicture.asset(
            icon,
            width: 24,
            height: 24,
            colorFilter:
                const ColorFilter.mode(Color(0xFFB0B0B0), BlendMode.srcIn),
          ),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildDropdown() {
    return DropdownButtonFormField<String>(
      value: selectedCountry,
      items: const [
        DropdownMenuItem(value: "USA", child: Text("USA")),
        DropdownMenuItem(value: "Canada", child: Text("Canada")),
        DropdownMenuItem(value: "UK", child: Text("UK")),
        DropdownMenuItem(value: "Australia", child: Text("Australia")),
        DropdownMenuItem(value: "Pakistan", child: Text("Pakistan")),
      ],
      onChanged: (value) {
        setState(() {
          selectedCountry = value!;
        });
      },
      decoration: InputDecoration(
        hintText: "Select Country",
        filled: true,
        fillColor: Colors.white,
        prefixIcon: Padding(
          padding: const EdgeInsets.all(12),
          child: SvgPicture.asset(
            "assets/icons/Location.svg",
            width: 24,
            height: 24,
            colorFilter:
                const ColorFilter.mode(Color(0xFFB0B0B0), BlendMode.srcIn),
          ),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
