import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:my_library/screens/auth/views/login_screen.dart';
import '../../../../constants.dart';
import 'components/sign_up_form.dart';
import '../../../../route/route_constants.dart';
import 'terms_of_services_screen.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();

  final emailOrPhoneController = TextEditingController();
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final addressController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  String? _selectedCountry;
  bool _isTermsAccepted = false;
  String? _termsError;
  XFile? _selectedImage;
  String? imageurl;
  bool _loading = false;
  final ImagePicker _picker = ImagePicker();

  /// Default role
  final String _role = "User";

  Future<void> _pickImage() async {
    final XFile? image =
        await _picker.pickImage(source: ImageSource.gallery, imageQuality: 75);
    if (image != null) {
      setState(() {
        _selectedImage = image;
      });
    }
  }

  Future<void> _validateAndContinue() async {
    setState(() {
      _loading = true;
      _termsError = _isTermsAccepted ? null : "Please accept Terms of Service";
    });

    if (!_isTermsAccepted) {
      setState(() => _loading = false);
      return;
    }

    if (_selectedImage == null) {
      showCustomDialog(context, "Please select an image", isError: true);
      setState(() => _loading = false);
      return;
    }

    if (!_formKey.currentState!.validate()) {
      setState(() => _loading = false);
      return;
    }

    try {
      // Upload image to Cloudinary
      final uri = Uri.parse("https://api.cloudinary.com/v1_1/dflrecddn/upload");
      final req = http.MultipartRequest('POST', uri)
        ..fields['upload_preset'] = 'Ecommerce';

      final bytes = await _selectedImage!.readAsBytes();
      final filename = path.basename(_selectedImage!.path);

      req.files.add(
        http.MultipartFile.fromBytes('file', bytes, filename: filename),
      );

      final res = await req.send();

      if (res.statusCode == 200) {
        final resString = await res.stream.bytesToString();
        final jsonMap = jsonDecode(resString);
        imageurl = jsonMap['secure_url'];
      } else {
        debugPrint("Upload failed: ${res.statusCode}");
        setState(() => _loading = false);
        return;
      }

      // Firebase Auth
      UserCredential authuser = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
              email: emailOrPhoneController.text.trim(),
              password: passwordController.text.trim());

      // Save user data in Firestore
      Map<String, dynamic> userdata = {
        'id': authuser.user!.uid,
        'name': nameController.text.trim(),
        'email': emailOrPhoneController.text.trim(),
        'phone': phoneController.text.trim(),
        'address': addressController.text.trim(),
        'country': _selectedCountry,
        'image': imageurl,
        'role': _role,
        'created_at': DateTime.now(),
      };

      await FirebaseFirestore.instance
          .collection("users")
          .doc(authuser.user!.uid)
          .set(userdata);

      showCustomDialog(context, "Register successful", isError: false);

      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (_) => const LoginScreen()));
    } catch (e) {
      showCustomDialog(context, "Error: ${e.toString()}", isError: true);
    } finally {
      setState(() => _loading = false);
    }
  }

  // Custom themed dialog function
  void showCustomDialog(BuildContext context, String message,
      {bool isError = true}) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(defaultBorderRadious),
          ),
          elevation: 5,
          backgroundColor:
              isError ? Colors.red.shade600 : Colors.green.shade600,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isError ? Icons.error_outline : Icons.check_circle_outline,
                  color: Colors.white,
                  size: 48,
                ),
                const SizedBox(height: 16),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(defaultBorderRadious),
                      ),
                    ),
                    child: Text(
                      "OK",
                      style: TextStyle(
                        color: isError ? Colors.red.shade600 : Colors.green.shade600,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          backgroundColor: whiteColor,
          body: SingleChildScrollView(
            child: Column(
              children: [
                Image.network(
                  "https://plus.unsplash.com/premium_photo-1703701579660-8481915a7991?w=600&auto=format&fit=crop&q=60&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MTN8fGxpYnJhcnl8ZW58MHx8MHx8fDA%3D",
                  fit: BoxFit.cover,
                  width: double.infinity,
                ),
                Padding(
                  padding: const EdgeInsets.all(defaultPadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Let’s get started!",
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall
                            ?.copyWith(
                                color: blackColor, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: defaultPadding / 2),
                      const Text(
                        "Please enter your valid data to create an account.",
                        style: TextStyle(color: blackColor60),
                      ),
                      const SizedBox(height: defaultPadding),

                      // SignUp Form
                      SignUpForm(
                        formKey: _formKey,
                        emailOrPhoneController: emailOrPhoneController,
                        nameController: nameController,
                        phoneController: phoneController,
                        addressController: addressController,
                        passwordController: passwordController,
                        confirmPasswordController: confirmPasswordController,
                        countryValue: _selectedCountry,
                        onCountryChanged: (val) {
                          setState(() => _selectedCountry = val);
                        },
                        selectedImage: _selectedImage,
                        onImagePickPressed: _pickImage,
                        role: _role,
                      ),
                      const SizedBox(height: defaultPadding),

                      // Terms & Conditions
                      Row(
                        children: [
                          Checkbox(
                            value: _isTermsAccepted,
                            onChanged: (val) {
                              setState(() {
                                _isTermsAccepted = val ?? false;
                                _termsError = null;
                              });
                            },
                            activeColor: primaryColor,
                          ),
                          Expanded(
                            child: Text.rich(
                              TextSpan(
                                text: "I agree with the",
                                style: const TextStyle(color: blackColor60),
                                children: [
                                  TextSpan(
                                    text: " Terms of service ",
                                    style: const TextStyle(
                                      color: primaryColor,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) =>
                                                TermsOfServicesScreen(
                                              onAccepted: () {
                                                setState(() {
                                                  _isTermsAccepted = true;
                                                  _termsError = null;
                                                });
                                                Navigator.pop(context);
                                              },
                                            ),
                                          ),
                                        );
                                      },
                                  ),
                                  const TextSpan(text: "& privacy policy."),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (_termsError != null)
                        Padding(
                          padding: const EdgeInsets.only(left: 12.0),
                          child: Text(
                            _termsError!,
                            style: const TextStyle(
                                color: errorColor, fontSize: 12),
                          ),
                        ),
                      const SizedBox(height: defaultPadding * 1.5),

                      // Continue Button
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(defaultBorderRadious),
                            ),
                          ),
                          onPressed: _validateAndContinue,
                          child: const Text("Continue",
                              style: TextStyle(fontSize: 18)),
                        ),
                      ),

                      const SizedBox(height: defaultPadding),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("Already have an account?"),
                          TextButton(
                            onPressed: () {
                              Navigator.pushNamed(context, logInScreenRoute);
                            },
                            child: const Text(
                              "Log in",
                              style: TextStyle(color: primaryColor),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        // Loader Overlay
        if (_loading)
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.4),
              child: Center(
                child: SizedBox(
                  width: 80,
                  height: 80,
                  child: CircularProgressIndicator(
                    color: primaryColor,
                    strokeWidth: 6,
                  ),
                ),
              ),
            ),
          )
      ],
    );
  }
}
