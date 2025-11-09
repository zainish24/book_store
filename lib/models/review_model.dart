import 'package:cloud_firestore/cloud_firestore.dart';

class ReviewModel {
  final String id;
  final String userId;
  final String userName;
  final String comment;
  final double rating;
  final DateTime time;
  final String avatarUrl;
  final String status; // Pending | Approved | Rejected

  ReviewModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.comment,
    required this.rating,
    required this.time,
    this.avatarUrl = "",
    this.status = "Pending",
  });

  Map<String, dynamic> toMap() {
    return {
      "userId": userId,
      "userName": userName,
      "comment": comment,
      "rating": rating,
      "time": Timestamp.fromDate(time),
      "avatarUrl": avatarUrl,
      "status": status,
    };
  }

  factory ReviewModel.fromFirestore(Map<String, dynamic> data, String docId) {
    return ReviewModel(
      id: docId,
      userId: data["userId"]?.toString() ?? "",
      userName: data["userName"] ?? "Anonymous",
      comment: data["comment"] ?? "",
      rating: (data["rating"] ?? 0).toDouble(),
      time: (data["time"] as Timestamp?)?.toDate() ?? DateTime.now(),
      avatarUrl: data["avatarUrl"] ?? "",
      status: data["status"] ?? "Pending",
    );
  }
}
