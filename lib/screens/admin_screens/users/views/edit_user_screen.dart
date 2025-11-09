// lib/screens/admin/admin_user_edit_screen.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:my_library/constants.dart';
import 'package:my_library/models/user_model.dart';
import 'services/user_service.dart';
import 'package:my_library/components/custom_dialog.dart';

class AdminUserEditScreen extends StatefulWidget {
  const AdminUserEditScreen({super.key});

  @override
  State<AdminUserEditScreen> createState() => _AdminUserEditScreenState();
}

class _AdminUserEditScreenState extends State<AdminUserEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final UserService _svc = UserService();

  bool _initialized = false;
  UserModel? user;

  late TextEditingController nameCtrl;
  late TextEditingController emailCtrl;
  late TextEditingController phoneCtrl;
  late TextEditingController addressCtrl;
  late TextEditingController countryCtrl;
  late ValueNotifier<String> role;
  late ValueNotifier<bool> active;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Prevent re-initializing after hot reload / rebuilds
    if (_initialized) return;

    final args = ModalRoute.of(context)?.settings.arguments;

    if (args == null) {
      // No arguments — inform user and pop back
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        CustomDialog.show(context,
            message: "No user data provided to edit screen", isError: false);

        Navigator.pop(context);
      });
      return;
    }

    if (args is UserModel) {
      user = args;
      _initControllersFromUser();
      setState(() => _initialized = true);
      return;
    }

    if (args is String) {
      // args is a user id — fetch from Firestore
      _loadUserById(args);
      return;
    }

    if (args is Map<String, dynamic>) {
      // If your app passes a map, try to construct a UserModel from it.
      try {
        final m = args;
        user = UserModel(
          id: m['id']?.toString() ?? '',
          name: (m['name'] ?? '') as String,
          email: (m['email'] ?? '') as String,
          phone: m['phone'] as String?,
          address: m['address'] as String?,
          country: m['country'] as String?,
          role: (m['role'] ?? 'User') as String,
          createdAt: (m['created_at'] is Timestamp)
              ? (m['created_at'] as Timestamp).toDate()
              : DateTime.tryParse(m['created_at']?.toString() ?? '') ??
                  DateTime.now(),
          isActive: m['isActive'] ?? true,
          image: m['image'] as String?,
        );
        _initControllersFromUser();
        setState(() => _initialized = true);
        return;
      } catch (_) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;

          CustomDialog.show(context,
              message: "SInvalid user data format", isError: true);

          Navigator.pop(context);
        });
        return;
      }
    }

    // Unknown argument type
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      CustomDialog.show(context, message: "Unsupported argument type", isError: true);
      
      Navigator.pop(context);
    });
  }

  Future<void> _loadUserById(String id) async {
    try {
      final doc =
          await FirebaseFirestore.instance.collection('users').doc(id).get();
      if (!doc.exists) throw Exception('User not found');
      user = UserModel.fromDoc(doc);
      _initControllersFromUser();
      if (!mounted) return;
      setState(() => _initialized = true);
    } catch (e) {
      if (!mounted) return;
      CustomDialog.show(context, message: "Failed to load user", isError: true);
      
      Navigator.pop(context);
    }
  }

  void _initControllersFromUser() {
    // user must be non-null when this is called
    final u = user!;
    nameCtrl = TextEditingController(text: u.name);
    emailCtrl = TextEditingController(text: u.email);
    phoneCtrl = TextEditingController(text: u.phone ?? '');
    addressCtrl = TextEditingController(text: u.address ?? '');
    countryCtrl = TextEditingController(text: u.country ?? '');
    role = ValueNotifier<String>(u.role);
    active = ValueNotifier<bool>(u.isActive);
  }

  @override
  void dispose() {
    // Dispose only when initialized (controllers created)
    if (_initialized) {
      nameCtrl.dispose();
      emailCtrl.dispose();
      phoneCtrl.dispose();
      addressCtrl.dispose();
      countryCtrl.dispose();
      role.dispose();
      active.dispose();
    }
    super.dispose();
  }

  void _update(BuildContext ctx) async {
    if (!_initialized) return;
    if (_formKey.currentState!.validate()) {
      final updated = UserModel(
        id: user!.id,
        name: nameCtrl.text.trim(),
        email: emailCtrl.text.trim(),
        phone: phoneCtrl.text.trim().isEmpty ? null : phoneCtrl.text.trim(),
        address:
            addressCtrl.text.trim().isEmpty ? null : addressCtrl.text.trim(),
        country:
            countryCtrl.text.trim().isEmpty ? null : countryCtrl.text.trim(),
        role: role.value,
        createdAt: user!.createdAt,
        isActive: active.value,
        image: user!.image,
      );
      await _svc.updateUser(updated);
      if (!mounted) return;
      Navigator.pop(ctx, updated);
      if (!mounted) return;
      CustomDialog.show(context, message: "User updated", isError: false);
    }
  }

  String? _req(String? v) =>
      (v == null || v.trim().isEmpty) ? 'Required' : null;
  String? _email(String? v) {
    if (v == null || v.trim().isEmpty) return 'Required';
    final r = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return r.hasMatch(v.trim()) ? null : 'Enter valid email';
  }

  @override
  Widget build(BuildContext context) {
    // Show a loading UI until controllers are ready
    if (!_initialized) {
      return Scaffold(
        backgroundColor: lightGreyColor,
        appBar: AppBar(
          backgroundColor: primaryColor,
          title: const Text('Edit User',
              style: TextStyle(
                  fontFamily: grandisExtendedFont,
                  fontWeight: FontWeight.bold)),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    // controllers are ready — render form
    return Scaffold(
      backgroundColor: lightGreyColor,
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: const Text('Edit User',
            style: TextStyle(
                fontFamily: grandisExtendedFont, fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(defaultPadding),
        child: Card(
          color: whiteColor,
          elevation: 2,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(defaultBorderRadious)),
          child: Padding(
            padding: const EdgeInsets.all(defaultPadding),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  _tf('Full Name', nameCtrl, Iconsax.user, validator: _req),
                  _tf('Email', emailCtrl, Iconsax.sms,
                      keyboard: TextInputType.emailAddress, validator: _email),
                  _tf('Phone', phoneCtrl, Iconsax.call,
                      keyboard: TextInputType.phone),
                  _tf('Address', addressCtrl, Iconsax.location),
                  _tf('Country', countryCtrl, Iconsax.global),
                  const SizedBox(height: 12),
                  ValueListenableBuilder<String>(
                      valueListenable: role,
                      builder: (_, r, __) {
                        return DropdownButtonFormField<String>(
                          value: r,
                          items: const [
                            DropdownMenuItem(
                                value: 'Admin', child: Text('Admin')),
                            DropdownMenuItem(
                                value: 'Manager', child: Text('Manager')),
                            DropdownMenuItem(
                                value: 'User', child: Text('User')),
                          ],
                          onChanged: (v) => role.value = v ?? r,
                          decoration: _decoration('Role', Iconsax.people),
                        );
                      }),
                  const SizedBox(height: 12),
                  ValueListenableBuilder<bool>(
                      valueListenable: active,
                      builder: (_, isActive, __) {
                        return SwitchListTile(
                          title: const Text('Active'),
                          value: isActive,
                          onChanged: (v) => active.value = v,
                          activeColor: primaryColor,
                          contentPadding: EdgeInsets.zero,
                        );
                      }),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _update(context),
                      icon: const Icon(Iconsax.tick_circle),
                      label: const Text('Save Changes'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: whiteColor,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(defaultBorderRadious)),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _tf(String label, TextEditingController c, IconData icon,
      {TextInputType keyboard = TextInputType.text,
      bool obscure = false,
      String? Function(String?)? validator}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: c,
        keyboardType: keyboard,
        obscureText: obscure,
        validator: validator,
        decoration: _decoration(label, icon),
      ),
    );
  }

  InputDecoration _decoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: whiteColor,
      prefixIcon: Icon(icon, color: primaryColor),
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(defaultBorderRadious),
          borderSide: BorderSide.none),
    );
  }
}
