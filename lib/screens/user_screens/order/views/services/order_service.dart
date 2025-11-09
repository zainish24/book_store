// ===================== order_service.dart =====================
// Place in: lib/services/order_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class OrderService {
  OrderService._();
  static final instance = OrderService._();

  final _orders = FirebaseFirestore.instance.collection('orders');

  /// Map Firestore status -> UI buckets
  static const processingStatuses = ['Pending', 'Processing', 'Packed'];
  static const deliveredStatuses = ['Delivered'];
  static const returnedStatuses = ['Returned'];
  static const canceledStatuses = ['Canceled', 'Cancelled'];

  String? get currentUserId => FirebaseAuth.instance.currentUser?.uid;

  /// Stream all orders for current user
  Stream<QuerySnapshot<Map<String, dynamic>>> userOrdersStream() {
    final uid = currentUserId;
    if (uid == null) {
      // return an empty stream if not logged in
      return const Stream<QuerySnapshot<Map<String, dynamic>>>.empty();
    }
    return _orders
        .where('userId', isEqualTo: uid)
        .orderBy('orderDate', descending: true)
        .snapshots();
  }

  /// Count by bucket (client side; avoids multiple queries & keeps it reactive)
  Stream<Map<String, int>> userOrderCounts() {
    return userOrdersStream().map((snap) {
      final counts = <String, int>{
        'Processing': 0,
        'Delivered': 0,
        'Returned': 0,
        'Canceled': 0,
      };
      for (final d in snap.docs) {
        final s = (d.data()['status'] as String?)?.trim() ?? '';
        if (processingStatuses.contains(s)) counts['Processing'] = (counts['Processing'] ?? 0) + 1;
        else if (deliveredStatuses.contains(s)) counts['Delivered'] = (counts['Delivered'] ?? 0) + 1;
        else if (returnedStatuses.contains(s)) counts['Returned'] = (counts['Returned'] ?? 0) + 1;
        else if (canceledStatuses.contains(s)) counts['Canceled'] = (counts['Canceled'] ?? 0) + 1;
      }
      return counts;
    });
  }

  /// Latest order in a given status bucket (for detail screen without args)
  Stream<Map<String, dynamic>?> latestOrderInBucket(List<String> statuses) {
    final uid = currentUserId;
    if (uid == null) {
      return const Stream<Map<String, dynamic>?>.empty();
    }
    // We can't order + whereIn together efficiently on mobile; do client filter after single user query.
    return userOrdersStream().map((snap) {
      final docs = snap.docs
          .where((d) => statuses.contains((d.data()['status'] as String?)?.trim() ?? ''))
          .toList();
      if (docs.isEmpty) return null;
      return docs.first.data();
    });
  }

  /// Update order status (used by existing Cancel button UI)
  Future<void> updateStatusByOrderNumber(String orderNumber, String newStatus, {String? returnReason}) async {
    final q = await _orders.where('orderNumber', isEqualTo: orderNumber).limit(1).get();
    if (q.docs.isEmpty) return;
    await q.docs.first.reference.update({
      'status': newStatus,
      if (returnReason != null) 'returnReason': returnReason,
    });
  }
}

