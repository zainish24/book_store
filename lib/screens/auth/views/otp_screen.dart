import 'dart:async';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:email_otp/email_otp.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '/route/route_constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';

class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final _formKey = GlobalKey<FormState>();
  final List<TextEditingController> _controllers =
      List.generate(6, (_) => TextEditingController()); // 6-digit OTP
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  int _secondsRemaining = 30;
  Timer? _timer;
  bool _busy = false;
  String? _email;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map) {
      _email = args['email'] as String?;
    }
    _startTimer();
  }

  void _startTimer() {
    _secondsRemaining = 30;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (_secondsRemaining > 0) {
        setState(() => _secondsRemaining--);
      } else {
        timer.cancel();
      }
    });
  }

  Future<void> _openComposerWithOtp(String email, String otp) async {
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
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Composer open failed. OTP: $otp'),
        backgroundColor: Colors.orange,
      ));
    }
  }

  Future<void> _resendCode() async {
    if (_email == null) return;
    setState(() => _busy = true);

    try {
      if (kIsWeb) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Resend not supported on web. Use mobile emulator/device.'),
          backgroundColor: Colors.orange,
        ));
        return;
      }

      bool sent = false;
      try {
        sent = await EmailOTP.sendOTP(email: _email!);
      } catch (ex) {
        debugPrint('EmailOTP.sendOTP exception on resend: $ex');
      }

      if (sent) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('OTP resent'),
          backgroundColor: Colors.green,
        ));
        _startTimer();
      } else {
        // fallback: create OTP in Firestore and open composer
        final otp = _generateLocalOtp(6);
        await FirebaseFirestore.instance.collection('password_otps').add({
          'email': _email,
          'uid': null,
          'otp': otp,
          'used': false,
          'createdAt': FieldValue.serverTimestamp(),
          'expiresAt': Timestamp.fromDate(DateTime.now().add(const Duration(minutes: 10))),
        });

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Service failed — opened composer with OTP fallback.'),
          backgroundColor: Colors.orange,
        ));

        await _openComposerWithOtp(_email!, otp);
        _startTimer();
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error resending OTP: ${e.toString()}'),
        backgroundColor: Colors.red,
      ));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  String _generateLocalOtp(int len) {
    final rnd = DateTime.now().millisecondsSinceEpoch.remainder(1000000);
    return rnd.toString().padLeft(len, '0').substring(0, len);
  }

  void _onOtpChanged(String value, int index) {
    if (value.length == 1 && index < _focusNodes.length - 1) {
      _focusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
  }

  Future<void> _confirm() async {
    if (!_formKey.currentState!.validate()) return;
    final String code = _controllers.map((c) => c.text).join();
    if (_email == null) return;

    setState(() => _busy = true);
    try {
      if (kIsWeb) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Verification not supported on web. Use mobile emulator/device.'),
          backgroundColor: Colors.orange,
        ));
        return;
      }

      bool verified = false;
      try {
        verified = await EmailOTP.verifyOTP(otp: code);
      } catch (ex) {
        debugPrint('EmailOTP.verifyOTP exception: $ex');
      }

      if (verified) {
        // verified — use Firebase's safe reset email (no admin needed)
        await FirebaseAuth.instance.sendPasswordResetEmail(email: _email!);

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('OTP verified. Password reset email sent. Check your inbox.'),
          backgroundColor: Colors.green,
        ));

        if (!mounted) return;
        Navigator.pushNamedAndRemoveUntil(context, logInScreenRoute, (route) => false);
      } else {
        // fallback: check local Firestore OTP documents
        final q = await FirebaseFirestore.instance
            .collection('password_otps')
            .where('email', isEqualTo: _email)
            .where('otp', isEqualTo: code)
            .where('used', isEqualTo: false)
            .orderBy('createdAt', descending: true)
            .limit(1)
            .get();

        if (q.docs.isNotEmpty) {
          final doc = q.docs.first;
          final data = doc.data();
          final Timestamp? expires = data['expiresAt'] as Timestamp?;
          if (expires != null && expires.toDate().isBefore(DateTime.now())) {
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Code expired'), backgroundColor: Colors.red));
          } else {
            await doc.reference.update({'used': true, 'usedAt': FieldValue.serverTimestamp()});
            await FirebaseAuth.instance.sendPasswordResetEmail(email: _email!);
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('OTP verified (fallback). Password reset email sent.'), backgroundColor: Colors.green));
            if (!mounted) return;
            Navigator.pushNamedAndRemoveUntil(context, logInScreenRoute, (route) => false);
          }
        } else {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Invalid OTP'),
            backgroundColor: Colors.red,
          ));
        }
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Unexpected Error: ${e.toString()}'),
        backgroundColor: Colors.red,
      ));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  void dispose() {
    for (var c in _controllers) {
      c.dispose();
    }
    for (var f in _focusNodes) {
      f.dispose();
    }
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final masked = _email == null
        ? ''
        : _email!.replaceAll(RegExp(r'(?<=.).(?=.*@)'), '*');

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: AbsorbPointer(
          absorbing: _busy,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(Icons.arrow_back, size: 28),
                ),
                const SizedBox(height: 40),
                Center(
                  child: Image.asset(
                    'assets/Illustration/Illustration-2.png',
                    height: 180,
                  ),
                ),
                const SizedBox(height: 40),
                const Text(
                  'Verification code',
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta',
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  masked.isEmpty
                      ? 'Enter the code we sent'
                      : 'We have sent the code verification to $masked',
                  style: TextStyle(
                    fontFamily: 'Grandis Extended',
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 40),
                Form(
                  key: _formKey,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(6, (index) {
                      return SizedBox(
                        width: 50,
                        child: TextFormField(
                          controller: _controllers[index],
                          focusNode: _focusNodes[index],
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w500,
                          ),
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            counterText: '',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                            fillColor: const Color(0xFFF7F7F9),
                          ),
                          maxLength: 1,
                          validator: (value) {
                            if (value == null || value.isEmpty) return '';
                            return null;
                          },
                          onChanged: (value) => _onOtpChanged(value, index),
                        ),
                      );
                    }),
                  ),
                ),
                const Spacer(),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _secondsRemaining == 0 ? _resendCode : null,
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.black),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          _secondsRemaining == 0
                              ? 'Resend'
                              : 'Resend (${_secondsRemaining}s)',
                          style: const TextStyle(
                            color: Colors.black,
                            fontFamily: 'Plus Jakarta',
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _confirm,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF8D6CFF),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Confirm',
                          style: TextStyle(
                            color: Colors.white,
                            fontFamily: 'Plus Jakarta',
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                if (_busy) const LinearProgressIndicator(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
