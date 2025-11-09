import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:my_library/constants.dart';
import 'package:my_library/components/custom_dialog.dart';
import 'package:my_library/screens/admin_screens/reviews/views/components/admin_review_detail_screen.dart';

class AdminProductReviewsScreen extends StatefulWidget {
  final String productId;
  final String productName;
  const AdminProductReviewsScreen({
    super.key,
    required this.productId,
    required this.productName,
  });

  @override
  State<AdminProductReviewsScreen> createState() =>
      _AdminProductReviewsScreenState();
}

class _AdminProductReviewsScreenState extends State<AdminProductReviewsScreen> {
  final productsRef = FirebaseFirestore.instance.collection('products');
  bool _isLoading = false;

  Future<void> _recalculateProductStats() async {
    final reviewsSnap =
        await productsRef.doc(widget.productId).collection('reviews').get();
    final ratings = reviewsSnap.docs.map((d) {
      final r = d.data();
      final dynamic rr = r['rating'] ?? 0;
      if (rr is num) return rr.toDouble();
      return double.tryParse(rr.toString()) ?? 0.0;
    }).toList();

    final count = ratings.length;
    final avg = count == 0 ? 0.0 : ratings.reduce((a, b) => a + b) / count;

    await productsRef.doc(widget.productId).set({
      'reviewsCount': count,
      'rating': avg,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> _updateStatus(String reviewId, String newStatus) async {
    setState(() => _isLoading = true);
    try {
      final ref =
          productsRef.doc(widget.productId).collection('reviews').doc(reviewId);
      await ref.update({'status': newStatus});
      await _recalculateProductStats();
      if (mounted) {
        CustomDialog.show(context, message: "Status set to $newStatus");
      }
    } catch (e) {
      if (mounted) CustomDialog.show(context, message: "Failed: $e", isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteReview(String reviewId) async {
    setState(() => _isLoading = true);
    try {
      final ref =
          productsRef.doc(widget.productId).collection('reviews').doc(reviewId);
      await ref.delete();
      await _recalculateProductStats();
      if (mounted) CustomDialog.show(context, message: "Review deleted");
    } catch (e) {
      if (mounted) CustomDialog.show(context, message: "Failed: $e", isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final productDocRef = productsRef.doc(widget.productId);

    return Stack(
      children: [
        Scaffold(
          backgroundColor: lightGreyColor,
          appBar: AppBar(
            backgroundColor: primaryColor,
            title: Text(widget.productName,
                style: const TextStyle(fontFamily: grandisExtendedFont)),
            centerTitle: true,
          ),
          body: Padding(
            padding: const EdgeInsets.all(defaultPadding),
            child: Column(
              children: [
                FutureBuilder<DocumentSnapshot>(
                  future: productDocRef.get(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return const SizedBox();
                    final data =
                        snapshot.data!.data() as Map<String, dynamic>? ?? {};
                    final price =
                        (data['price'] ?? data['salePrice'] ?? 0).toString();
                    final avg =
                        data['rating'] != null ? (data['rating'] as num).toDouble() : 0.0;
                    final count = data['reviewsCount'] ?? 0;
                    final images = (data['images'] is List)
                        ? List.from(data['images'])
                        : <dynamic>[];

                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(defaultPadding),
                        child: Row(
                          children: [
                            if (images.isNotEmpty)
                              Image.network(
                                images.first.toString(),
                                width: 72,
                                height: 72,
                                fit: BoxFit.cover,
                              )
                            else
                              Container(width: 72, height: 72, color: blackColor10),
                            const SizedBox(width: defaultPadding),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(data['title'] ?? widget.productName,
                                      style:
                                          const TextStyle(fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 8),
                                  Row(children: [
                                    RatingBarIndicator(
                                      rating: avg,
                                      itemBuilder: (context, _) => const Icon(
                                          Icons.star, color: Colors.amber),
                                      itemSize: 16,
                                    ),
                                    const SizedBox(width: 8),
                                    Text("$avg • $count reviews"),
                                  ]),
                                  const SizedBox(height: 8),
                                  Text("Price: $price",
                                      style: const TextStyle(fontWeight: FontWeight.w500)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: productsRef
                        .doc(widget.productId)
                        .collection('reviews')
                        .orderBy('time', descending: true)
                        .snapshots(),
                    builder: (context, snap) {
                      if (!snap.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      final docs = snap.data!.docs;
                      if (docs.isEmpty) return const Center(child: Text("No reviews."));

                      return ListView.separated(
                        itemCount: docs.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final r = docs[index].data() as Map<String, dynamic>;
                          final reviewId = docs[index].id;
                          final userName = r['userName'] ?? 'Anonymous';
                          final comment = r['comment'] ?? '';
                          final rating = (r['rating'] ?? 0).toDouble();
                          final status = r['status'] ?? 'Pending';
                          final avatar = r['avatarUrl'] ?? '';

                          return Card(
                            child: ListTile(
                              contentPadding: const EdgeInsets.all(defaultPadding),
                              leading: CircleAvatar(
                                radius: 28,
                                backgroundImage:
                                    avatar.isNotEmpty ? NetworkImage(avatar) : null,
                                child: avatar.isEmpty ? const Icon(Icons.person) : null,
                              ),
                              title: Text(userName,
                                  style: const TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 6),
                                  RatingBarIndicator(
                                    rating: rating,
                                    itemBuilder: (context, _) =>
                                        const Icon(Icons.star, color: Colors.amber),
                                    itemSize: 14,
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    comment,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 6),
                                  Text("Status: $status",
                                      style:
                                          const TextStyle(fontWeight: FontWeight.w600)),
                                ],
                              ),
                              isThreeLine: true,
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.open_in_new),
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => AdminReviewDetailScreen(
                                            productId: widget.productId,
                                            reviewId: reviewId,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                  PopupMenuButton<String>(
                                    onSelected: (value) {
                                      if (value == 'Approve' || value == 'Reject') {
                                        _updateStatus(reviewId, value);
                                      } else if (value == 'Delete') {
                                        _deleteReview(reviewId);
                                      }
                                    },
                                    itemBuilder: (context) => [
                                      const PopupMenuItem(
                                          value: 'Approve', child: Text('Approve')),
                                      const PopupMenuItem(
                                          value: 'Reject', child: Text('Reject')),
                                      const PopupMenuItem(
                                          value: 'Delete', child: Text('Delete')),
                                    ],
                                  ),
                                ],
                              ),
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
        ),
        if (_isLoading)
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(
                child: CircularProgressIndicator(color: primaryColor),
              ),
            ),
          ),
      ],
    );
  }
}
