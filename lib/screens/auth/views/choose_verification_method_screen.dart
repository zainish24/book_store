import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:email_otp/email_otp.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:my_library/components/custom_dialog.dart';

class ChooseVerificationMethodScreen extends StatefulWidget {
  const ChooseVerificationMethodScreen({super.key});

  @override
  State<ChooseVerificationMethodScreen> createState() =>
      _ChooseVerificationMethodScreenState();
}

class _ChooseVerificationMethodScreenState
    extends State<ChooseVerificationMethodScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  bool _loading = false;

  Future<void> _openEmailComposerFallback(String email, String otp) async {
    final Email mail = Email(
      body: 'Your verification code is: $otp\nIt will expire in 10 minutes.',
      subject: 'Password reset code',
      recipients: [email],
      isHTML: false,
    );
    try {
      await FlutterEmailSender.send(mail);
    } catch (e) {
      if (!mounted) return;
      CustomDialog.show(context,
          message: "Composer failed. OTP: $otp", isError: true);
    }
  }

  Future<void> _sendOtpViaEmailOtp() async {
    if (!_formKey.currentState!.validate()) return;

    final String email = emailController.text.trim().toLowerCase();
    setState(() => _loading = true);

    try {
      // ensure this email exists in your users collection
      final query = await FirebaseFirestore.instance
          .collection("users")
          .where("email", isEqualTo: email)
          .limit(1)
          .get();

      if (query.docs.isEmpty) {
        if (!mounted) return;
        CustomDialog.show(context, message: "Email not found", isError: true);

        setState(() => _loading = false);
        return;
      }

      // --- WEB: skip OTP and send Firebase password-reset email directly ---
      if (kIsWeb) {
        try {
          await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
          if (!mounted) return;
          CustomDialog.show(context,
              message: "Password reset email sent (web). Check inbox.",
              isError: false);

          if (!mounted) return;
          Navigator.pop(context); // go back or to login
        } catch (e) {
          if (!mounted) return;
          CustomDialog.show(context,
              message: "Failed to send reset email", isError: true);
        } finally {
          if (mounted) setState(() => _loading = false);
        }
        return;
      }

      // --- MOBILE (Android/iOS): try email_otp service ---
      bool sent = false;
      try {
        sent = await EmailOTP.sendOTP(email: email);
      } catch (sendEx) {
        debugPrint('EmailOTP.sendOTP exception: $sendEx');
      }

      if (sent) {
        if (!mounted) return;
        CustomDialog.show(context,
            message: "OTP sent to your email", isError: false);

        if (!mounted) return;
        Navigator.pushNamed(context, '/otp', arguments: {"email": email});
      } else {
        // fallback: save local OTP in Firestore and open composer for testing
        final otp = _generateLocalOtp(6);
        await FirebaseFirestore.instance.collection('password_otps').add({
          'email': email,
          'uid': query.docs.first.id,
          'otp': otp,
          'used': false,
          'createdAt': FieldValue.serverTimestamp(),
          'expiresAt': Timestamp.fromDate(
              DateTime.now().add(const Duration(minutes: 10))),
        });

        if (!mounted) return;
        CustomDialog.show(context,
            message: "Service failed — opened email composer as fallback.",
            isError: true);

        await _openEmailComposerFallback(email, otp);

        if (!mounted) return;
        Navigator.pushNamed(context, '/otp', arguments: {"email": email});
      }
    } catch (e) {
      if (!mounted) return;
      CustomDialog.show(context, message: "Unexpected Error", isError: true);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _generateLocalOtp(int len) {
    final rnd = DateTime.now().millisecondsSinceEpoch.remainder(1000000);
    return rnd.toString().padLeft(len, '0').substring(0, len);
  }

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(Icons.arrow_back, size: 28),
                    ),
                    const SizedBox(height: 40),
                    const Text(
                      'Password recovery',
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta',
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 40),
                    Center(
                      child: Image.asset(
                        'assets/Illustration/Password.png',
                        height: 200,
                      ),
                    ),
                    const SizedBox(height: 40),
                    const Text(
                      'Enter your email address',
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta',
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'We’ll send you an OTP to verify your account. (On Web we send a reset link.)',
                      style: TextStyle(
                        fontFamily: 'Grandis Extended',
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: 'Email Address',
                        prefixIcon: const Icon(Icons.email_outlined),
                        filled: true,
                        fillColor: const Color(0xFFF7F7F9),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Email is required';
                        } else if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w]{2,4}$')
                            .hasMatch(value)) {
                          return 'Enter a valid email';
                        }
                        return null;
                      },
                    ),
                    const Spacer(),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _loading ? null : _sendOtpViaEmailOtp,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF8D6CFF),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: _loading
                            ? const CircularProgressIndicator(
                                color: Colors.white)
                            : const Text(
                                kIsWeb ? 'Send reset email (Web)' : 'Next',
                                style: TextStyle(
                                  fontFamily: 'Plus Jakarta',
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ),
        if (_loading)
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.4),
              child: const Center(
                child: CircularProgressIndicator(color: Color(0xFF8D6CFF)),
              ),
            ),
          ),
      ],
    );
  }
}
