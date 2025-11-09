// lib/screens/admin/components/order_card.dart
import 'package:flutter/material.dart';
import 'package:my_library/models/order_model.dart';

class OrderCard extends StatelessWidget {
  final OrderModel order;
  final VoidCallback onView;
  final VoidCallback onUpdateStatus;

  const OrderCard({
    super.key,
    required this.order,
    required this.onView,
    required this.onUpdateStatus,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        title: Text('Order ID: ${order.id}'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('User: ${order.userName}'),
            Text('Total Amount: \$${order.totalAmount.toStringAsFixed(2)}'),
            Text('Status: ${order.status}'),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.visibility, color: Colors.blue),
              onPressed: onView,
            ),
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.green),
              onPressed: onUpdateStatus,
            ),
          ],
        ),
      ),
    );
  }
}
