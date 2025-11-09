// lib/models/cart_model.dart
import 'dart:convert';

class CartItem {
  final String productId;
  final String title;
  final String image;
  final double price; // original price
  final double discountedPrice; // used for subtotal calculations
  int qty;
  final int? selectedColorIndex;
  final int? selectedSizeIndex;

  CartItem({
    required this.productId,
    required this.title,
    required this.image,
    required this.price,
    required this.discountedPrice,
    this.qty = 1,
    this.selectedColorIndex,
    this.selectedSizeIndex,
  });

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'title': title,
      'image': image,
      'price': price,
      'discountedPrice': discountedPrice,
      'qty': qty,
      'selectedColorIndex': selectedColorIndex,
      'selectedSizeIndex': selectedSizeIndex,
    };
  }

  factory CartItem.fromMap(Map<String, dynamic> map) {
    // safe numeric parsing
    double _toDouble(dynamic v) {
      if (v == null) return 0.0;
      if (v is num) return v.toDouble();
      return double.tryParse(v.toString()) ?? 0.0;
    }

    int? _toInt(dynamic v) {
      if (v == null) return null;
      if (v is int) return v;
      if (v is num) return v.toInt();
      return int.tryParse(v.toString());
    }

    final qtyVal = map['qty'];
    final qty = qtyVal == null
        ? 1
        : (qtyVal is num ? qtyVal.toInt() : int.tryParse(qtyVal.toString()) ?? 1);

    return CartItem(
      productId: map['productId']?.toString() ?? '',
      title: map['title']?.toString() ?? '',
      image: map['image']?.toString() ?? '',
      price: _toDouble(map['price']),
      discountedPrice: _toDouble(map['discountedPrice']),
      qty: qty,
      selectedColorIndex: _toInt(map['selectedColorIndex']),
      selectedSizeIndex: _toInt(map['selectedSizeIndex']),
    );
  }

  String toJson() => json.encode(toMap());
  factory CartItem.fromJson(String source) =>
      CartItem.fromMap(json.decode(source) as Map<String, dynamic>);
}
