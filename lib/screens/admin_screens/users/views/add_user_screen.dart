// lib/screens/admin_screens/users/views/add_user_screen.dart
import 'dart:convert';
import 'dart:io'; // required for File(...) on mobile. Remove/conditional-import for web builds.
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:my_library/constants.dart';
import 'package:my_library/models/user_model.dart';
import 'package:my_library/components/custom_dialog.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;

class AdminUserAddScreen extends StatefulWidget {
  const AdminUserAddScreen({super.key});

  @override
  State<AdminUserAddScreen> createState() => _AdminUserAddScreenState();
}

class _AdminUserAddScreenState extends State<AdminUserAddScreen> {
  final _formKey = GlobalKey<FormState>();

  final emailCtrl = TextEditingController();
  final nameCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final addressCtrl = TextEditingController();
  String? country;
  String role = 'Admin';
  XFile? _selectedImage;
  String? imageUrl;
  bool _loading = false;
  final _picker = ImagePicker();

  @override
  void dispose() {
    emailCtrl.dispose();
    nameCtrl.dispose();
    phoneCtrl.dispose();
    addressCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? image =
        await _picker.pickImage(source: ImageSource.gallery, imageQuality: 75);
    if (image != null) {
      setState(() => _selectedImage = image);
    }
  }

  Future<void> _uploadImageToCloudinary() async {
    if (_selectedImage == null) return;
    final uri = Uri.parse('https://api.cloudinary.com/v1_1/dflrecddn/upload');
    final req = http.MultipartRequest('POST', uri)
      ..fields['upload_preset'] = 'Ecommerce';

    final bytes = await _selectedImage!.readAsBytes();
    final filename = path.basename(_selectedImage!.path);
    req.files.add(http.MultipartFile.fromBytes('file', bytes, filename: filename));
    final res = await req.send();
    if (res.statusCode == 200) {
      final s = await res.stream.bytesToString();
      final map = jsonDecode(s);
      imageUrl = map['secure_url'];
    } else {
      throw Exception('Image upload failed with status ${res.statusCode}');
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    try {
      await _uploadImageToCloudinary();

      // generate Firestore doc id and save
      final docRef = FirebaseFirestore.instance.collection('users').doc();
      final user = UserModel(
        id: docRef.id,
        name: nameCtrl.text.trim(),
        email: emailCtrl.text.trim(),
        phone: phoneCtrl.text.trim().isEmpty ? null : phoneCtrl.text.trim(),
        address: addressCtrl.text.trim().isEmpty ? null : addressCtrl.text.trim(),
        country: country,
        role: role,
        createdAt: DateTime.now(),
        isActive: true,
        image: imageUrl,
      );

      await docRef.set(user.toMap());

      // use mounted check before accessing context after async gap
      if (!mounted) return;
      CustomDialog.show(context, message: "User Created", isError: false);
      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        CustomDialog.show(context, message: "Login successful", isError: true);
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Avatar: show local file on mobile; for web you may want to show a preview differently

    return Stack(
      children: [
        Scaffold(
          backgroundColor: whiteColor,
          appBar: AppBar(backgroundColor: primaryColor, title: const Text('Add User')),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(defaultPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: _pickImage,
                  child: _selectedImage == null
                      ? CircleAvatar(radius: 45, backgroundColor: const Color(0xFFE0E0E0), child: const Icon(Icons.person))
                      : (!kIsWeb
                          ? CircleAvatar(radius: 45, backgroundImage: FileImage(File(_selectedImage!.path)))
                          : CircleAvatar(radius: 45, backgroundColor: const Color(0xFFE0E0E0), child: const Icon(Icons.check))),
                ),
                const SizedBox(height: defaultPadding),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: nameCtrl,
                        decoration: const InputDecoration(labelText: 'Full Name'),
                        validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: emailCtrl,
                        decoration: const InputDecoration(labelText: 'Email'),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) return 'Required';
                          final r = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                          return r.hasMatch(v.trim()) ? null : 'Enter valid email';
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(controller: phoneCtrl, decoration: const InputDecoration(labelText: 'Phone')),
                      const SizedBox(height: 12),
                      TextFormField(controller: addressCtrl, decoration: const InputDecoration(labelText: 'Address')),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: country,
                        items: const [
                          DropdownMenuItem(value: 'Pakistan', child: Text('Pakistan')),
                          DropdownMenuItem(value: 'USA', child: Text('USA')),
                          DropdownMenuItem(value: 'UK', child: Text('UK')),
                        ],
                        onChanged: (v) => setState(() => country = v),
                        decoration: const InputDecoration(labelText: 'Country'),
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: role,
                        items: const [
                          DropdownMenuItem(value: 'Admin', child: Text('Admin')),
                          DropdownMenuItem(value: 'User', child: Text('User')),
                        ],
                        onChanged: (v) => setState(() => role = v ?? role),
                        decoration: const InputDecoration(labelText: 'Role'),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(onPressed: _save, child: const Text('Create User')),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
        if (_loading)
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.4),
              child: const Center(child: CircularProgressIndicator()),
            ),
          )
      ],
    );
  }
}
