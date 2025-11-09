import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:my_library/models/review_model.dart';

class ReviewService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Get all reviews for a product as a stream
  Stream<List<ReviewModel>> getReviewsForProduct(String productId) {
    return _db
        .collection('products')
        .doc(productId)
        .collection('reviews')
        .orderBy('time', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ReviewModel.fromFirestore(doc.data(), doc.id))
            .toList());
  }

  /// Add a new review to Firestore and update product stats in a transaction (safe)
  Future<void> addReview(String productId, ReviewModel review) async {
    final productRef = _db.collection('products').doc(productId);

    await _db.runTransaction((tx) async {
      // read product snapshot (may be null)
      final prodSnap = await tx.get(productRef);
      final Map<String, dynamic>? prodData =
          (prodSnap.data() as Map<String, dynamic>?);

      // safely parse existing counts/averages
      int oldCount = 0;
      double oldAvg = 0.0;

      if (prodData != null) {
        final dynamic rc = prodData['reviewsCount'];
        if (rc is int) {
          oldCount = rc;
        } else if (rc is String) {
          oldCount = int.tryParse(rc) ?? 0;
        }

        final dynamic rAvg = prodData['rating'];
        if (rAvg is num) {
          oldAvg = rAvg.toDouble();
        } else if (rAvg is String) {
          oldAvg = double.tryParse(rAvg) ?? 0.0;
        }
      }

      final int newCount = oldCount + 1;
      final double newAvg = (oldCount == 0)
          ? review.rating
          : (oldAvg * oldCount + review.rating) / newCount;

      // create a new review doc with auto id
      final reviewRef = productRef.collection('reviews').doc();

      // set the review doc
      tx.set(reviewRef, review.toMap());

      // merge stats into product document (safe, won't overwrite other fields)
      tx.set(productRef, {
        'reviewsCount': newCount,
        'rating': newAvg,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    });
  }

  /// Get distribution of 1-5 star reviews
  Stream<Map<int, int>> getReviewDistribution(String productId) {
    return _db
        .collection("products")
        .doc(productId)
        .collection("reviews")
        .snapshots()
        .map((snapshot) {
      Map<int, int> distribution = {1: 0, 2: 0, 3: 0, 4: 0, 5: 0};
      for (var doc in snapshot.docs) {
        final data = doc.data();
        final r = data["rating"] ?? 0;
        int rating = 0;
        if (r is num) rating = r.toInt();
        else rating = int.tryParse(r.toString()) ?? 0;
        if (distribution.containsKey(rating)) {
          distribution[rating] = distribution[rating]! + 1;
        }
      }
      return distribution;
    });
  }
}

extension ReviewStats on ReviewService {
  Stream<Map<String, dynamic>> getReviewStats(String productId) {
    return getReviewsForProduct(productId).map((reviews) {
      final count = reviews.length;
      final avg = count == 0
          ? 0.0
          : reviews.map((e) => e.rating).reduce((a, b) => a + b) / count;

      int countStar(int star) =>
          reviews.where((r) => r.rating.round() == star).length;

      return {
        "average": avg,
        "count": count,
        "distribution": {
          5: countStar(5),
          4: countStar(4),
          3: countStar(3),
          2: countStar(2),
          1: countStar(1),
        }
      };
    });
  }
}
