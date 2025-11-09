import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:my_library/models/product_model.dart';
import 'package:my_library/models/review_model.dart';

class ProductService {
  final CollectionReference<Map<String, dynamic>> rawRef =
      FirebaseFirestore.instance.collection('products');

  // typed ref with converter
  CollectionReference<ProductModel> get _ref =>
      rawRef.withConverter<ProductModel>(
        fromFirestore: (snap, _) => ProductModel.fromFirestore(snap),
        toFirestore: (p, _) => p.toMap(),
      );

  // 🔍 SEARCH METHOD
  Future<List<ProductModel>> searchProducts(String query, {int limit = 30}) async {
    final q = query.trim().toLowerCase();
    if (q.length < 2) return [];

    final prefixStart = q;
    final prefixEnd = '$q\uf8ff';

    QuerySnapshot<ProductModel> snap = await _ref
        .where('name_lower', isGreaterThanOrEqualTo: prefixStart)
        .where('name_lower', isLessThanOrEqualTo: prefixEnd)
        .limit(limit)
        .get();

    // fallback → keyword search
    if (snap.docs.isEmpty) {
      final snap2 = await _ref.where('keywords', arrayContains: q).limit(limit).get();
      snap = snap2;
    }

    return snap.docs.map((d) => d.data()).toList();
  }

  // POPULAR PRODUCTS
  Future<List<ProductModel>> fetchPopularProducts({int limit = 10}) async {
    final snap = await _ref.orderBy('popularity', descending: true).limit(limit).get();
    return snap.docs.map((d) => d.data()).toList();
  }

  Stream<List<ProductModel>> getProductsBySpecialCategory(String specialCategory,
      {int limit = 20}) {
    final slug = specialCategory.replaceAll(RegExp(r'\s+'), '');
    return _ref
        .where('specialCategories', arrayContains: slug)
        .limit(limit)
        .snapshots()
        .map((snap) => snap.docs.map((d) => d.data()).toList());
  }

  Stream<List<ProductModel>> getProductsByCategory(String category,
      {int limit = 20}) {
    final slug = category.replaceAll(RegExp(r'\s+'), '');
    return _ref
        .where('categories', arrayContains: slug)
        .limit(limit)
        .snapshots()
        .map((snap) => snap.docs.map((d) => d.data()).toList());
  }

  Stream<ProductModel?> getProductById(String id) {
    return _ref.doc(id).snapshots().map((snap) => snap.data());
  }

  Future<ProductModel?> fetchProductOnce(String id) async {
    final snap = await _ref.doc(id).get();
    return snap.data();
  }

  Stream<List<ProductModel>> getRelatedProducts({
    required String productId,
    required List<String> categories,
    int limit = 5,
  }) {
    if (categories.isNotEmpty) {
      return _ref
          .where('categories',
              arrayContains: categories.first.replaceAll(RegExp(r'\s+'), ''))
          .limit(limit + 1)
          .snapshots()
          .map((snap) {
        final list = snap.docs
            .map((d) => d.data())
            .where((p) => p.id != productId)
            .toList();
        if (list.length > limit) return list.sublist(0, limit);
        return list;
      });
    } else {
      return _ref.limit(limit + 1).snapshots().map((snap) => snap.docs
          .map((d) => d.data())
          .where((p) => p.id != productId)
          .toList());
    }
  }

  // REVIEW METHODS
  Stream<List<ReviewModel>> getProductReviews(String productId) {
    return FirebaseFirestore.instance
        .collection("products")
        .doc(productId)
        .collection("reviews")
        .orderBy("time", descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) => ReviewModel.fromFirestore(doc.data(), doc.id))
            .toList());
  }

  Stream<Map<int, int>> getReviewDistribution(String productId) {
    return getProductReviews(productId).map((reviews) {
      final distribution = {1: 0, 2: 0, 3: 0, 4: 0, 5: 0};
      for (var r in reviews) {
        final rating = r.rating.round();
        distribution[rating] = (distribution[rating] ?? 0) + 1;
      }
      return distribution;
    });
  }

  Future<void> addProduct(ProductModel p) async => await rawRef.add(p.toMap());
  Future<void> updateProduct(ProductModel p) async =>
      await rawRef.doc(p.id).update(p.toMap());
  Future<void> deleteProduct(String id) async => await rawRef.doc(id).delete();
}
