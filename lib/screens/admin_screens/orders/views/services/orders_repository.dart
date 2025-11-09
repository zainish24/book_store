// lib/services/orders_repository.dartmy_library
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:my_library/models/order_model.dart';

class OrdersRepository {
  OrdersRepository._();
  static final OrdersRepository instance = OrdersRepository._();

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  CollectionReference get _ordersRef => _db.collection('client_orders');

  /// Stream of all orders ordered by orderDate desc
  Stream<List<OrderModel>> ordersStream() {
    return _ordersRef.orderBy('orderDate', descending: true).snapshots().asyncMap(
      (snap) async {
        // Do not fetch items here (to save reads); list view shows top-level fields.
        return snap.docs.map((d) => OrderModel.fromFirestore(d)).toList();
      },
    );
  }

  /// Fetch items for a specific order (from subcollection `order_items`)
  Future<List<OrderItem>> fetchOrderItems(String orderId) async {
    final itemsSnap = await _ordersRef.doc(orderId).collection('order_items').get();
    return itemsSnap.docs
        .map((d) => OrderItem.fromMap(d.data()))
        .toList();
  }

  /// Get full order (with items)
  Future<OrderModel?> getOrderById(String orderId) async {
    final doc = await _ordersRef.doc(orderId).get();
    if (!doc.exists) return null;
    final items = await fetchOrderItems(orderId);
    return OrderModel.fromFirestore(doc, items: items);
  }

  /// Update order status (and set deliveryDate when delivered)
  Future<void> updateOrderStatus(String orderId, String status) {
    final data = {
      'status': status,
      if (status.toLowerCase() == 'delivered') 'deliveryDate': FieldValue.serverTimestamp(),
    };
    return _ordersRef.doc(orderId).update(data);
  }

  /// Set return decision (Approved / Rejected)
  Future<void> setReturnDecision(String orderId, String decision) {
    final d = decision.toLowerCase().trim();
    final isApproved = (d == 'approved' || d == 'return approved');
    return _ordersRef.doc(orderId).update({
      'status': isApproved ? 'Return Approved' : 'Return Rejected',
      'returnStatus': isApproved ? 'Approved' : 'Rejected',
    });
  }
}
