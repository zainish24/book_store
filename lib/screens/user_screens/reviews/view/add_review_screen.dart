import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:my_library/models/review_model.dart';
import 'package:my_library/route/route_constants.dart';
import 'package:my_library/screens/user_screens/reviews/view/services/review_service.dart';
import 'package:my_library/constants.dart';
import 'package:my_library/components/custom_dialog.dart';

class AddReviewScreen extends StatefulWidget {
  final String productId;
  const AddReviewScreen({super.key, required this.productId});

  @override
  State<AddReviewScreen> createState() => _AddReviewScreenState();
}

class _AddReviewScreenState extends State<AddReviewScreen> {
  double rating = 0;
  bool recommend = false;
  final titleController = TextEditingController();
  final commentController = TextEditingController();

  final reviewService = ReviewService();

  String _userId = "";
  String _userName = "Anonymous";
  String _avatarUrl = "";
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _loadCurrentUserInfo();
  }

  Future<void> _loadCurrentUserInfo() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    _userId = user.uid;

    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(_userId).get();
      if (doc.exists) {
        final data = doc.data()!;
        setState(() {
          _userName = (data['name']?.toString() ?? user.displayName ?? "Anonymous");
          _avatarUrl = data['imageUrl']?.toString() ?? user.photoURL ?? "";
        });
      } else {
        setState(() {
          _userName = user.displayName ?? "Anonymous";
          _avatarUrl = user.photoURL ?? "";
        });
      }
    } catch (e, st) {
      debugPrint('Error loading user profile: $e\n$st');
    }
  }

  @override
  void dispose() {
    titleController.dispose();
    commentController.dispose();
    super.dispose();
  }

  Future<void> _submitReview() async {
    if (_isSubmitting) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      CustomDialog.show(context, message: "Please sign in to submit a review.", isError: true);
      return;
    }

    if (rating == 0 || commentController.text.trim().isEmpty) {
      CustomDialog.show(context, message: "Please add rating & comment", isError: true);
      return;
    }

    setState(() => _isSubmitting = true);

    final review = ReviewModel(
      id: "",
      userId: _userId.isNotEmpty ? _userId : user.uid,
      userName: _userName,
      time: DateTime.now(),
      comment: commentController.text.trim(),
      rating: rating,
      avatarUrl: _avatarUrl,
      status: "Pending",
    );

    try {
      await reviewService.addReview(widget.productId, review);

      if (!mounted) return;

      // ✅ Show success dialog
      CustomDialog.show(context, message: "Review submitted successfully", isError: false);

      // Wait 1 second so dialog is visible
      await Future.delayed(const Duration(seconds: 1));

      if (!mounted) return;

      // ✅ Navigate to reviews screen
      Navigator.pushReplacementNamed(
        context,
        productReviewsScreenRoute, // <-- make sure this route exists
        arguments: widget.productId,
      );
    } catch (e, st) {
      debugPrint('Error submitting review: $e\n$st');
      if (mounted) {
        CustomDialog.show(context, message: "Error submitting review: $e", isError: true);
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteColor,
      appBar: AppBar(
        backgroundColor: whiteColor,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Add Review",
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
        child: ListView(
          children: [
            const SizedBox(height: 16),
            const Center(
              child: Text(
                "Your overall rating of this product",
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
            ),
            const SizedBox(height: 12),
            Center(
              child: RatingBar.builder(
                initialRating: rating,
                minRating: 1,
                direction: Axis.horizontal,
                allowHalfRating: false,
                unratedColor: Colors.grey[300],
                itemCount: 5,
                itemPadding: const EdgeInsets.symmetric(horizontal: 6.0),
                itemBuilder: (context, _) => const Icon(
                  Icons.star,
                  color: Colors.amber,
                ),
                onRatingUpdate: (value) {
                  setState(() {
                    rating = value;
                  });
                },
              ),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: titleController,
              maxLength: 100,
              decoration: InputDecoration(
                hintText: "Summarize review",
                filled: true,
                fillColor: const Color(0xFFF9F9F9),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
                counterText: "",
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: commentController,
              maxLength: 3000,
              maxLines: 6,
              decoration: InputDecoration(
                hintText: "What should my_librarypers know?",
                filled: true,
                fillColor: const Color(0xFFF9F9F9),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
                counterText: "",
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                const Expanded(
                  child: Text(
                    "Would you recommend this product?",
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.black),
                  ),
                ),
                Switch(
                  value: recommend,
                  activeColor: primaryColor,
                  onChanged: (value) {
                    setState(() {
                      recommend = value;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submitReview,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Text(
                        "Submit Review",
                        style: TextStyle(fontSize: 16),
                      ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
