import 'package:cloud_firestore/cloud_firestore.dart';

class ProductModel {
  final String id;
  final List<String> images;
  final String authorName;
  final String title;
  final String? description;
  final double price;
  final double? priceAfterDiscount;
  final int? discountPercent;
  final List<String> categories;
  final List<String> specialCategories;
  final bool inStock;
  final double? rating;
  final int? reviewsCount;
  final Timestamp? createdAt;
  final Timestamp? updatedAt;

  ProductModel({
    required this.id,
    required this.images,
    required this.authorName,
    required this.title,
    this.description,
    required this.price,
    this.priceAfterDiscount,
    this.discountPercent,
    this.categories = const [],
    this.specialCategories = const [],
    this.inStock = true,
    this.rating,
    this.reviewsCount,
    this.createdAt,
    this.updatedAt,
  });

  /// ✅ Universal fromMap constructor (used for Wishlist & Firestore reads)
  factory ProductModel.fromMap(Map<String, dynamic> data, {String? id}) {
    List<String> _listOfStrings(dynamic v) {
      if (v == null) return [];
      if (v is List) {
        return v.map((e) => e?.toString() ?? '').where((s) => s.isNotEmpty).toList();
      }
      return [];
    }

    double _toDouble(dynamic v) {
      if (v == null) return 0.0;
      if (v is num) return v.toDouble();
      return double.tryParse(v.toString()) ?? 0.0;
    }

    int? _toInt(dynamic v) {
      if (v == null) return null;
      if (v is int) return v;
      return int.tryParse(v.toString());
    }

    return ProductModel(
      id: id ?? '',
      images: _listOfStrings(data['images']),
      authorName: data['authorName']?.toString() ?? '',
      title: data['title']?.toString() ?? '',
      description: data['description']?.toString(),
      price: _toDouble(data['price']),
      priceAfterDiscount: data['priceAfterDiscount'] != null
          ? _toDouble(data['priceAfterDiscount'])
          : null,
      discountPercent: _toInt(data['discountPercent']),
      categories: _listOfStrings(data['categories']),
      specialCategories: _listOfStrings(data['specialCategories']).isNotEmpty
          ? _listOfStrings(data['specialCategories'])
          : _listOfStrings(data['tags']),
      inStock: data['inStock'] is bool
          ? data['inStock'] as bool
          : (data['inStock']?.toString().toLowerCase() == 'true'),
      rating: data['rating'] != null ? _toDouble(data['rating']) : null,
      reviewsCount: _toInt(data['reviewsCount']),
      createdAt: data['createdAt'] is Timestamp ? data['createdAt'] as Timestamp : null,
      updatedAt: data['updatedAt'] is Timestamp ? data['updatedAt'] as Timestamp : null,
    );
  }

  /// Still keep `fromFirestore` if you want direct DocumentSnapshot support
  factory ProductModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return ProductModel.fromMap(data, id: doc.id);
  }

  Map<String, dynamic> toMap() {
    return {
      'images': images,
      'authorName': authorName,
      'title': title,
      'description': description,
      'price': price,
      'priceAfterDiscount': priceAfterDiscount,
      'discountPercent': discountPercent,
      'categories': categories,
      'specialCategories': specialCategories,
      'inStock': inStock,
      'rating': rating,
      'reviewsCount': reviewsCount,
      'createdAt': createdAt ?? FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }
}
