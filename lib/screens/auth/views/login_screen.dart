import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:my_library/constants.dart';
import 'package:my_library/route/route_constants.dart';
import 'components/login_form.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _loginUser() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    try {
      // Authenticate with Firebase
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
              email: _emailController.text.trim(),
              password: _passwordController.text.trim());

      // Fetch user details from Firestore
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection("users")
          .doc(userCredential.user!.uid)
          .get();

      if (userDoc.exists) {
        String role = (userDoc["role"] ?? "customer").toString().toLowerCase();

        // Show success dialog
        showCustomDialog(context, "Login successful", isError: false);

        // Navigate based on role
        if (role == "admin") {
          Navigator.pushNamedAndRemoveUntil(
            context,
            adminEntryPointScreenRoute,
            (route) => false,
          );
        } else {
          Navigator.pushNamedAndRemoveUntil(
            context,
            userEntryPointScreenRoute,
            (route) => false,
          );
        }

        // Clear inputs
        _emailController.clear();
        _passwordController.clear();
      } else {
        _showError("User data not found in database");
      }
    } on FirebaseAuthException catch (e) {
      String message = "Login failed";
      if (e.code == 'user-not-found') {
        message = "No user found with this email";
      } else if (e.code == 'wrong-password') {
        message = "Incorrect password";
      }
      _showError(message);
    } catch (e) {
      _showError("Error: ${e.toString()}");
    } finally {
      setState(() => _loading = false);
    }
  }

  // Custom error dialog
  void _showError(String message) {
    showCustomDialog(context, message, isError: true);
  }

  // Reusable custom dialog function
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
    final Size size = MediaQuery.of(context).size;

    return Stack(
      children: [
        Scaffold(
          body: SingleChildScrollView(
            child: Column(
              children: [
                Image.asset(
                  "assets/images/book1.jpg",
                  fit: BoxFit.cover,
                ),
                Padding(
                  padding: const EdgeInsets.all(defaultPadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Welcome back!",
                        style:
                            Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  color: blackColor,
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                      const SizedBox(height: defaultPadding / 2),
                      const Text(
                        "Log in with your data that you entered during your registration.",
                      ),
                      const SizedBox(height: defaultPadding),

                      // Login Form
                      LogInForm(
                        formKey: _formKey,
                        emailController: _emailController,
                        passwordController: _passwordController,
                      ),

                      Align(
                        child: TextButton(
                          child: const Text("Forgot password"),
                          onPressed: () {
                            Navigator.pushNamed(
                              context,
                              verificationMethodScreenRoute,
                            );
                          },
                        ),
                      ),
                      SizedBox(
                        height: size.height > 700
                            ? size.height * 0.1
                            : defaultPadding,
                      ),
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
                          onPressed: _loginUser,
                          child: const Text("Log in",
                              style: TextStyle(fontSize: 18)),
                        ),
                      ),
                      const SizedBox(height: defaultPadding),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("Don't have an account?"),
                          TextButton(
                            onPressed: () {
                              Navigator.pushNamed(context, signUpScreenRoute);
                            },
                            child: const Text(
                              "Sign up",
                              style: TextStyle(color: primaryColor),
                            ),
                          )
                        ],
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),

        // Custom theme loader overlay
        if (_loading)
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.4),
              child: Center(
                child: SizedBox(
                  width: 80,
                  height: 80,
                  child: CircularProgressIndicator(
                    color: primaryColor, // matches your theme
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
