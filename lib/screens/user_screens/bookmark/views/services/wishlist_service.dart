import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:my_library/models/product_model.dart';

class WishlistService {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  /// Add product to wishlist
  Future<void> addToWishlist(ProductModel product) async {
    final user = _auth.currentUser;
    if (user == null) return;

    await _firestore
        .collection("users")
        .doc(user.uid)
        .collection("wishlist")
        .doc(product.id)
        .set(product.toMap());
  }

  /// Remove product from wishlist
  Future<void> removeFromWishlist(String productId) async {
    final user = _auth.currentUser;
    if (user == null) return;

    await _firestore
        .collection("users")
        .doc(user.uid)
        .collection("wishlist")
        .doc(productId)
        .delete();
  }

  /// Get wishlist stream
  Stream<List<ProductModel>> getWishlist() {
    final user = _auth.currentUser;
    if (user == null) return const Stream.empty();

    return _firestore
        .collection("users")
        .doc(user.uid)
        .collection("wishlist")
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => ProductModel.fromMap(doc.data(), id: doc.id))
          .toList();
    });
  }

  /// Check if product is in wishlist
  Stream<bool> isInWishlist(String productId) {
    final user = _auth.currentUser;
    if (user == null) return const Stream.empty();

    return _firestore
        .collection("users")
        .doc(user.uid)
        .collection("wishlist")
        .doc(productId)
        .snapshots()
        .map((doc) => doc.exists);
  }
}
