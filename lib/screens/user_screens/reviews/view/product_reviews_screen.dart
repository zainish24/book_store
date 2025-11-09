import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:intl/intl.dart';
import 'package:my_library/models/review_model.dart';
import 'package:my_library/screens/user_screens/reviews/view/services/review_service.dart';
import 'package:my_library/route/route_constants.dart';
import 'package:my_library/screens/user_screens/reviews/view/components/review_summary_card.dart';

class ProductReviewsScreen extends StatelessWidget {
  final String productId;
  final String productName;

  const ProductReviewsScreen({
    super.key,
    required this.productId,
    required this.productName,
  });

  @override
  Widget build(BuildContext context) {
    final reviewService = ReviewService();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "$productName Reviews",
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// ⭐ Review Summary (live)
            StreamBuilder<List<ReviewModel>>(
              stream: reviewService.getReviewsForProduct(productId),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final reviews = snapshot.data!;
                if (reviews.isEmpty) {
                  return const Text("No reviews yet.");
                }

                final totalReviews = reviews.length;
                final avgRating = reviews
                        .map((e) => e.rating)
                        .fold(0.0, (a, b) => a + b) /
                    totalReviews;

                int countStar(int star) =>
                    reviews.where((r) => r.rating.round() == star).length;

                return ReviewSummaryCard(
                  avgRating: avgRating,
                  totalReviews: totalReviews,
                  numOfFiveStar: countStar(5),
                  numOfFourStar: countStar(4),
                  numOfThreeStar: countStar(3),
                  numOfTwoStar: countStar(2),
                  numOfOneStar: countStar(1),
                );
              },
            ),

            const SizedBox(height: 24),
            _buildAddReviewButton(context),
            const SizedBox(height: 24),

            const Text(
              "User reviews",
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF333333),
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),

            /// 👇 Reviews List from Firestore
            Expanded(
              child: StreamBuilder<List<ReviewModel>>(
                // If you want users to see only approved reviews, change service to return only status == 'Approved'
                stream: reviewService.getReviewsForProduct(productId),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final reviews = snapshot.data!;
                  if (reviews.isEmpty) {
                    return const Center(child: Text("No reviews yet."));
                  }

                  return ListView.builder(
                    itemCount: reviews.length,
                    itemBuilder: (_, index) {
                      final review = reviews[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 20,
                                  backgroundColor: Colors.grey,
                                  backgroundImage: review.avatarUrl.isNotEmpty
                                      ? NetworkImage(review.avatarUrl)
                                      : null,
                                  child: review.avatarUrl.isEmpty
                                      ? const Icon(Icons.person,
                                          color: Colors.white)
                                      : null,
                                ),
                                const SizedBox(width: 10),
                                Flexible(
                                  child: Text(
                                    review.userName,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF333333),
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  DateFormat.yMMMd().format(review.time),
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF999999),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            RatingBarIndicator(
                              rating: review.rating,
                              itemBuilder: (context, _) =>
                                  const Icon(Icons.star, color: Colors.amber),
                              itemSize: 20.0,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              review.comment,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Color(0xFF333333),
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddReviewButton(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.pushNamed(
          context,
          addReviewsScreenRoute,
          arguments: {
            'productId': productId,
            'productName': productName,
          },
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Row(
          children: [
            Icon(Icons.chat_bubble_outline, color: Colors.black),
            SizedBox(width: 8),
            Text(
              "Add Review",
              style: TextStyle(fontSize: 16, color: Color(0xFF333333)),
            ),
            Spacer(),
            Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
