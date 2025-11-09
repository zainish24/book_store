import 'package:flutter/material.dart';

class ReviewSummaryCard extends StatelessWidget {
  final double avgRating;
  final int totalReviews;
  final int numOfFiveStar;
  final int numOfFourStar;
  final int numOfThreeStar;
  final int numOfTwoStar;
  final int numOfOneStar;

  const ReviewSummaryCard({
    super.key,
    required this.avgRating,
    required this.totalReviews,
    required this.numOfFiveStar,
    required this.numOfFourStar,
    required this.numOfThreeStar,
    required this.numOfTwoStar,
    required this.numOfOneStar,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          // ⭐ Average Rating
          Text(
            avgRating.toStringAsFixed(1),
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 48,
                ),
          ),
          const SizedBox(height: 4),

          // ⭐ Stars Row
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              5,
              (index) => Icon(
                Icons.star,
                size: 20,
                color: index < avgRating.round()
                    ? Colors.amber
                    : Colors.grey.withOpacity(0.3),
              ),
            ),
          ),
          const SizedBox(height: 4),

          // 📝 Total Reviews
          Text(
            "$totalReviews Reviews",
            style: const TextStyle(fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(height: 16),

          // 📊 Rating Distribution
          Column(
            children: [
              _buildStarRow(5, numOfFiveStar, totalReviews),
              _buildStarRow(4, numOfFourStar, totalReviews),
              _buildStarRow(3, numOfThreeStar, totalReviews),
              _buildStarRow(2, numOfTwoStar, totalReviews),
              _buildStarRow(1, numOfOneStar, totalReviews),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStarRow(int star, int count, int total) {
    final ratio = total == 0 ? 0.0 : count / total;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 24,
            child: Text(
              "$star",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 4),
          const Icon(Icons.star, size: 16, color: Colors.amber),
          const SizedBox(width: 8),

          // 📊 Progress Bar
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: ratio,
                color: Colors.amber,
                backgroundColor: Colors.grey.withOpacity(0.2),
                minHeight: 8,
              ),
            ),
          ),
          const SizedBox(width: 8),

          // 📌 Count
          Text("$count"),
        ],
      ),
    );
  }
}
