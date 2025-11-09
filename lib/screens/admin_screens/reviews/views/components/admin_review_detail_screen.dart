import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:my_library/constants.dart';
import 'package:my_library/components/custom_dialog.dart';

class AdminReviewDetailScreen extends StatefulWidget {
  final String productId;
  final String reviewId;
  const AdminReviewDetailScreen({
    super.key,
    required this.productId,
    required this.reviewId,
  });

  @override
  State<AdminReviewDetailScreen> createState() =>
      _AdminReviewDetailScreenState();
}

class _AdminReviewDetailScreenState extends State<AdminReviewDetailScreen> {
  final productsRef = FirebaseFirestore.instance.collection('products');
  bool _isLoading = false;

  Future<Map<String, dynamic>> _loadData() async {
    final productSnap = await productsRef.doc(widget.productId).get();
    final reviewSnap = await productsRef
        .doc(widget.productId)
        .collection('reviews')
        .doc(widget.reviewId)
        .get();

    final product = productSnap.data() ?? {};
    final review = reviewSnap.data() ?? {};

    return {'product': product, 'review': review};
  }

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

  Future<void> _setStatus(String status) async {
    setState(() => _isLoading = true);
    try {
      final ref = productsRef
          .doc(widget.productId)
          .collection('reviews')
          .doc(widget.reviewId);
      await ref.update({'status': status});
      await _recalculateProductStats();
      if (!mounted) return;
      CustomDialog.show(context, message: 'Review marked $status');
      Navigator.pop(context);
    } catch (e) {
      if (mounted) CustomDialog.show(context, message: 'Failed: $e', isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteReview() async {
    setState(() => _isLoading = true);
    try {
      final ref = productsRef
          .doc(widget.productId)
          .collection('reviews')
          .doc(widget.reviewId);
      await ref.delete();
      await _recalculateProductStats();
      if (!mounted) return;
      CustomDialog.show(context, message: 'Review deleted');
      Navigator.pop(context);
    } catch (e) {
      if (mounted) CustomDialog.show(context, message: 'Failed: $e', isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          backgroundColor: lightGreyColor,
          appBar: AppBar(
            backgroundColor: primaryColor,
            title: const Text('Review Details',
                style: TextStyle(fontFamily: grandisExtendedFont)),
          ),
          body: FutureBuilder<Map<String, dynamic>>(
            future: _loadData(),
            builder: (context, snap) {
              if (snap.connectionState == ConnectionState.waiting)
                return const Center(child: CircularProgressIndicator());
              final product = snap.data!['product'] as Map<String, dynamic>;
              final review = snap.data!['review'] as Map<String, dynamic>;

              final images = (product['images'] is List)
                  ? List.from(product['images'])
                  : <dynamic>[];
              final title = product['title'] ?? product['name'] ?? widget.productId;
              final price = (product['price'] ?? product['salePrice'] ?? '').toString();

              final userName = review['userName'] ?? 'Anonymous';
              final avatar = review['avatarUrl'] ?? '';
              final rating = (review['rating'] ?? 0).toDouble();
              final comment = review['comment'] ?? '';
              final status = review['status'] ?? 'Pending';

              return SingleChildScrollView(
                padding: const EdgeInsets.all(defaultPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(defaultPadding),
                        child: Row(
                          children: [
                            if (images.isNotEmpty)
                              Image.network(images.first.toString(),
                                  width: 84, height: 84, fit: BoxFit.cover)
                            else
                              Container(width: 84, height: 84, color: blackColor10),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(title,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16)),
                                  const SizedBox(height: 6),
                                  Text("Price: $price"),
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(defaultPadding),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 28,
                                  backgroundImage:
                                      avatar.isNotEmpty ? NetworkImage(avatar) : null,
                                  child: avatar.isEmpty
                                      ? const Icon(Icons.person)
                                      : null,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                    child: Text(userName,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold))),
                                RatingBarIndicator(
                                  rating: rating,
                                  itemBuilder: (context, _) =>
                                      const Icon(Icons.star, color: Colors.amber),
                                  itemSize: 18,
                                ),
                                const SizedBox(width: 8),
                                Text(rating.toString()),
                              ],
                            ),
                            const SizedBox(height: 12),
                            const Text('Comment:',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 6),
                            Text(comment),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                const Text('Status: ',
                                    style: TextStyle(fontWeight: FontWeight.bold)),
                                Text(status,
                                    style: TextStyle(
                                      color: status == 'Approved'
                                          ? successColor
                                          : status == 'Rejected'
                                              ? errorColor
                                              : primaryColor,
                                      fontWeight: FontWeight.bold,
                                    )),
                              ],
                            ),
                            const SizedBox(height: 12),
                            // Action buttons: Approve / Reject / Delete
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                TextButton(
                                  onPressed: status != 'Approved'
                                      ? () => _setStatus('Approved')
                                      : null,
                                  child: const Text('Approve'),
                                ),
                                TextButton(
                                  onPressed: status != 'Rejected'
                                      ? () => _setStatus('Rejected')
                                      : null,
                                  child: const Text('Reject',
                                      style: TextStyle(color: Colors.red)),
                                ),
                                TextButton(
                                  onPressed: () async {
                                    final ok = await showDialog<bool>(
                                      context: context,
                                      builder: (_) => AlertDialog(
                                        title: const Text('Delete review?'),
                                        content: const Text(
                                            'This will remove the review and recalculate product rating.'),
                                        actions: [
                                          TextButton(
                                              onPressed: () =>
                                                  Navigator.pop(context, false),
                                              child: const Text('Cancel')),
                                          TextButton(
                                              onPressed: () =>
                                                  Navigator.pop(context, true),
                                              child: const Text('Delete',
                                                  style: TextStyle(
                                                      color: Colors.red))),
                                        ],
                                      ),
                                    );
                                    if (ok == true) await _deleteReview();
                                  },
                                  child: const Text('Delete',
                                      style: TextStyle(color: Colors.red)),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
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
