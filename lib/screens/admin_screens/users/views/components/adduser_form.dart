import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../../constants.dart';

class AdduserForm extends StatelessWidget {
  const AdduserForm({
    super.key,
    required this.formKey,
    required this.emailOrPhoneController,
    required this.nameController,
    required this.phoneController,
    required this.addressController,
    required this.passwordController,
    required this.confirmPasswordController,
    required this.countryValue,
    required this.onCountryChanged,
    required this.selectedImage,
    required this.onImagePickPressed,
    required this.role,
    required this.onRoleChanged,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController emailOrPhoneController;
  final TextEditingController nameController;
  final TextEditingController phoneController;
  final TextEditingController addressController;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;
  final String? countryValue;
  final Function(String?) onCountryChanged;

  final XFile? selectedImage;
  final VoidCallback onImagePickPressed;

  final String? role;
  final Function(String?) onRoleChanged;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        children: [
          // Profile Image Picker
          GestureDetector(
            onTap: onImagePickPressed,
            child: CircleAvatar(
              radius: 45,
              backgroundColor: const Color(0xFFE0E0E0),
              child: selectedImage == null
                  ? const Icon(Icons.camera_alt, size: 30, color: primaryColor)
                  : null,
            ),
          ),
          const SizedBox(height: defaultPadding),

          _buildTextField(
            controller: nameController,
            label: "Full Name",
            icon: Icons.person,
            validator: (value) =>
                value!.trim().isEmpty ? "Please enter your name" : null,
          ),

          _buildTextField(
            controller: phoneController,
            label: "Phone Number",
            icon: Icons.call,
            keyboardType: TextInputType.phone,
            validator: (value) =>
                value!.trim().isEmpty ? "Enter your phone number" : null,
          ),

          _buildTextField(
            controller: addressController,
            label: "Address",
            icon: Icons.location_on,
            validator: (value) =>
                value!.trim().isEmpty ? "Enter your address" : null,
          ),

          _buildDropdown(
            value: countryValue,
            label: "Select Country",
            icon: Icons.flag,
            items: const ["Pakistan", "USA", "UK", "Canada"],
            onChanged: onCountryChanged,
            validator: (value) =>
                value == null ? "Please select a country" : null,
          ),

          _buildTextField(
            controller: emailOrPhoneController,
            label: "Email Address",
            icon: Icons.email,
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value!.trim().isEmpty) return "Enter your email";
              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                  .hasMatch(value)) {
                return "Enter a valid email";
              }
              return null;
            },
          ),

          _buildTextField(
            controller: passwordController,
            label: "Password",
            icon: Icons.lock,
            obscureText: true,
            validator: (value) {
              if (value == null || value.isEmpty) return "Enter password";
              if (value.length < 8) return "Password must be at least 8 characters";
              if (!RegExp(r'[A-Z]').hasMatch(value)) return "Include at least one uppercase letter";
              if (!RegExp(r'[a-z]').hasMatch(value)) return "Include at least one lowercase letter";
              if (!RegExp(r'\d').hasMatch(value)) return "Include at least one number";
              if (!RegExp(r'[!@#\$&*~%^]').hasMatch(value)) return "Include at least one special character (!@#\$&*~%^)";
              return null;
            },
          ),

          _buildTextField(
            controller: confirmPasswordController,
            label: "Confirm Password",
            icon: Icons.lock,
            obscureText: true,
            validator: (value) {
              if (value == null || value.isEmpty) return "Re-enter your password";
              if (value != passwordController.text) return "Passwords do not match";
              return null;
            },
          ),

          // 👇 Role Dropdown
          _buildDropdown(
            value: role,
            label: "Select Role",
            icon: Icons.verified_user,
            items: const ["User", "Admin"],
            onChanged: onRoleChanged,
            validator: (value) =>
                value == null ? "Please select a role" : null,
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: defaultPadding),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: primaryColor),
          filled: true,
          fillColor: lightGreyColor,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(defaultBorderRadious),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String? value,
    required String label,
    required IconData icon,
    required List<String> items,
    required Function(String?) onChanged,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: defaultPadding),
      child: DropdownButtonFormField<String>(
        value: value,
        items: items
            .map((e) => DropdownMenuItem(value: e, child: Text(e)))
            .toList(),
        onChanged: onChanged,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: primaryColor),
          filled: true,
          fillColor: lightGreyColor,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(defaultBorderRadious),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}
