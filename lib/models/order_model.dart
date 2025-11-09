// lib/models/order_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class OrderItem {
  final String productId;
  final String productName;
  final double price;
  final int quantity;

  OrderItem({
    required this.productId,
    required this.productName,
    required this.price,
    required this.quantity,
  });

  factory OrderItem.fromMap(Map<String, dynamic> m) {
    double p = 0;
    final rawPrice = m['price'];
    if (rawPrice is int) p = rawPrice.toDouble();
    else if (rawPrice is double) p = rawPrice;
    else if (rawPrice is String) p = double.tryParse(rawPrice) ?? 0;

    return OrderItem(
      productId: m['productId'] ?? m['product_id'] ?? '',
      productName: m['productName'] ?? m['product_name'] ?? '',
      price: p,
      quantity: (m['quantity'] is int) ? m['quantity'] : int.tryParse('${m['quantity']}') ?? 0,
    );
  }

  Map<String, dynamic> toMap() => {
        'productId': productId,
        'productName': productName,
        'price': price,
        'quantity': quantity,
      };
}

class OrderModel {
  final String id;
  final String userId;
  final String userName;
  final String userEmail;
  final List<OrderItem> items;
  final double totalAmount;
  final String status;
  final DateTime? orderDate;
  final DateTime? deliveryDate;
  final String? address;
  final String? phone;
  final String? returnStatus;
  final String? returnReason;

  OrderModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userEmail,
    required this.items,
    required this.totalAmount,
    required this.status,
    required this.orderDate,
    this.deliveryDate,
    this.address,
    this.phone,
    this.returnStatus,
    this.returnReason,
  });

  factory OrderModel.fromFirestore(DocumentSnapshot doc, {List<OrderItem>? items}) {
    final data = doc.data() as Map<String, dynamic>? ?? {};

    double _toDouble(dynamic v) {
      if (v == null) return 0;
      if (v is double) return v;
      if (v is int) return v.toDouble();
      if (v is String) return double.tryParse(v) ?? 0;
      return 0;
    }

    DateTime? _toDate(dynamic v) {
      if (v == null) return null;
      if (v is Timestamp) return v.toDate();
      if (v is DateTime) return v;
      try {
        return DateTime.parse(v.toString());
      } catch (_) {
        return null;
      }
    }

    final usrName = data['userName'] ?? data['fullName'] ?? data['name'] ?? '';
    final usrEmail = data['userEmail'] ?? data['email'] ?? '';
    final total = _toDouble(data['totalAmount'] ?? data['total'] ?? data['amount']);
    final status = (data['status'] ?? 'Pending').toString();

    return OrderModel(
      id: doc.id,
      userId: data['userId'] ?? data['clientId'] ?? '',
      userName: usrName,
      userEmail: usrEmail,
      items: items ?? [],
      totalAmount: total,
      status: status,
      orderDate: _toDate(data['orderDate']),
      deliveryDate: _toDate(data['deliveryDate']),
      address: data['address'] ?? '',
      phone: data['phone'] ?? '',
      returnStatus: data['returnStatus']?.toString(),
      returnReason: data['returnReason']?.toString(),
    );
  }

  Map<String, dynamic> toMap() => {
        'userId': userId,
        'userName': userName,
        'userEmail': userEmail,
        'totalAmount': totalAmount,
        'status': status,
        'orderDate': orderDate,
        'deliveryDate': deliveryDate,
        'address': address,
        'phone': phone,
        'returnStatus': returnStatus,
        'returnReason': returnReason,
      };

  OrderModel copyWith({
    String? status,
    String? returnStatus,
    String? returnReason,
    DateTime? deliveryDate,
    List<OrderItem>? items,
  }) {
    return OrderModel(
      id: id,
      userId: userId,
      userName: userName,
      userEmail: userEmail,
      items: items ?? this.items,
      totalAmount: totalAmount,
      status: status ?? this.status,
      orderDate: orderDate,
      deliveryDate: deliveryDate ?? this.deliveryDate,
      address: address,
      phone: phone,
      returnStatus: returnStatus ?? this.returnStatus,
      returnReason: returnReason ?? this.returnReason,
    );
  }
}
