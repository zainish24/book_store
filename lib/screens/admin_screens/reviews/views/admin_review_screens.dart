import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:my_library/constants.dart';
import 'package:my_library/components/custom_dialog.dart';

// update these imports to match your project structure
import 'package:my_library/screens/admin_screens/reviews/views/components/admin_review_detail_screen.dart';
import 'package:my_library/screens/admin_screens/reviews/views/components/admin_review_list_screen.dart';

class AdminReviewScreen extends StatefulWidget {
  const AdminReviewScreen({super.key});

  @override
  State<AdminReviewScreen> createState() => _AdminReviewScreenState();
}

class _AdminReviewScreenState extends State<AdminReviewScreen> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: lightGreyColor,
        appBar: AppBar(
          title: const Text(
            "Manage Product Reviews",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: Color.fromARGB(255, 0, 0, 0),
            ),
          ),
          backgroundColor: whiteColor,
          elevation: 0,
          centerTitle: true,
        ),
        body: TabBarView(
          children: [
            // Products tab -> only products with reviews
            const AdminReviewListScreen(),

            // All Reviews tab -> show all reviews across products
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collectionGroup('reviews')
                  .orderBy('time', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting)
                  return const Center(child: CircularProgressIndicator());
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty)
                  return const Center(child: Text('No reviews found.'));

                final docs = snapshot.data!.docs;

                return ListView.separated(
                  padding: const EdgeInsets.all(defaultPadding),
                  itemCount: docs.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final doc = docs[index];
                    final data = doc.data() as Map<String, dynamic>? ?? {};
                    final reviewId = doc.id;
                    final productDocRef = doc.reference.parent.parent;
                    final productId = productDocRef?.id ?? '';

                    final userName = data['userName'] ?? 'Anonymous';
                    final comment = data['comment'] ?? '';
                    final rating = (data['rating'] ?? 0).toDouble();
                    final status = data['status'] ?? 'Pending';

                    return Card(
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(defaultPadding),
                        title: Text(userName,
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 6),
                            Text(comment,
                                maxLines: 2, overflow: TextOverflow.ellipsis),
                            const SizedBox(height: 6),
                            Row(children: [
                              RatingBarIndicator(
                                  rating: rating,
                                  itemBuilder: (context, _) => const Icon(
                                      Icons.star,
                                      color: Colors.amber),
                                  itemSize: 14),
                              const SizedBox(width: 8),
                              Text('Status: $status'),
                            ])
                          ],
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.open_in_new),
                          onPressed: () {
                            if (productId.isEmpty) {
                              CustomDialog.show(context, message: "Product not found for this review", isError: true);
                              return;
                            }
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => AdminReviewDetailScreen(
                                      productId: productId,
                                      reviewId: reviewId)),
                            );
                          },
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
