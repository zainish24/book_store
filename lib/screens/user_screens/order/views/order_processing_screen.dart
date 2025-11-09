import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:my_library/constants.dart';
import '/models/order_model.dart';
import 'package:my_library/screens/admin_screens/orders/views/services/orders_repository.dart';
import 'package:my_library/components/order_process.dart';

class OrderProcessingScreen extends StatefulWidget {
  const OrderProcessingScreen({super.key});

  @override
  State<OrderProcessingScreen> createState() => _OrderProcessingScreenState();
}

class _OrderProcessingScreenState extends State<OrderProcessingScreen> {
  final repo = OrdersRepository.instance;
  final DateFormat dateFormat = DateFormat('yyyy-MM-dd');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteColor,
      appBar: AppBar(
        backgroundColor: whiteColor,
        elevation: 0,
        centerTitle: true,
        leading: const BackButton(color: blackColor),
        title: const Text(
          'Processing Orders',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            fontFamily: grandisExtendedFont,
            color: blackColor,
          ),
        ),
      ),
      body: StreamBuilder<List<OrderModel>>(
        stream: repo.ordersStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(color: primaryColor));
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          final processingOrders = (snapshot.data ?? [])
              .where((o) =>
                  o.status.toLowerCase() == "pending" ||
                  o.status.toLowerCase() == "processing")
              .toList();

          if (processingOrders.isEmpty) {
            return const Center(child: Text("No processing orders yet."));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(defaultPadding),
            itemCount: processingOrders.length,
            itemBuilder: (context, index) {
              final order = processingOrders[index];
              return _buildExpandableOrderCard(order);
            },
          );
        },
      ),
    );
  }

  /// 🔹 Expandable card with progress + details merged
  Widget _buildExpandableOrderCard(OrderModel order) {
    return ExpansionTile(
      tilePadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(defaultBorderRadious),
      ),
      backgroundColor: lightGreyColor,
      collapsedBackgroundColor: lightGreyColor,
      title: Text(
        "Order #${order.id}",
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          fontFamily: grandisExtendedFont,
          color: blackColor,
        ),
      ),
      subtitle: Text(
        "Placed on ${order.orderDate != null ? dateFormat.format(order.orderDate!) : '-'}",
        style: const TextStyle(fontSize: 12, color: blackColor60),
      ),
      childrenPadding: const EdgeInsets.all(16),
      children: [
        /// Progress bar
        OrderProgress(
          orderStatus: OrderProcessStatus.done,
          processingStatus: _mapStatus(order.status, "processing"),
          packedStatus: _mapStatus(order.status, "packed"),
          shippedStatus: _mapStatus(order.status, "shipped"),
          deliveredStatus: _mapStatus(order.status, "delivered"),
          isCanceled: order.status.toLowerCase() == "cancelled",
        ),
        const SizedBox(height: 16),

        /// 🔹 Order Details like Admin screen
        _card(
          title: "Customer Information",
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _infoRow(Icons.person, order.userName),
              _infoRow(Icons.email, order.userEmail ?? ''),
              _infoRow(Icons.phone, order.phone ?? 'N/A'),
              _infoRow(Icons.location_on, order.address ?? 'N/A'),
            ],
          ),
        ),
        const SizedBox(height: defaultPadding),

        _card(
          title: "Order Dates",
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (order.orderDate != null)
                _infoRow(Icons.calendar_today,
                    "Order: ${DateFormat.yMMMd().format(order.orderDate!)}"),
              if (order.deliveryDate != null)
                _infoRow(Icons.local_shipping,
                    "Delivered: ${DateFormat.yMMMd().format(order.deliveryDate!)}"),
            ],
          ),
        ),
        const SizedBox(height: defaultPadding),

        _card(
          title: "Ordered Products",
          child: Column(
            children: order.items
                .map((it) => ListTile(
                      leading: const Icon(Icons.shopping_bag),
                      title: Text(it.productName,
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(
                          "Price: \$${it.price.toStringAsFixed(2)} • Qty: ${it.quantity}"),
                      trailing: Text(
                        "\$${(it.price * it.quantity).toStringAsFixed(2)}",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ))
                .toList(),
          ),
        ),
        const SizedBox(height: defaultPadding),

        _card(
          title: "Totals",
          child: Column(
            children: [
              _totalRow("Subtotal", order.totalAmount),
              _totalRow("Tax (10%)", order.totalAmount * 0.10),
              const Divider(),
              _totalRow("Total", order.totalAmount * 1.10, bold: true),
            ],
          ),
        ),
        const SizedBox(height: defaultPadding),

        /// Cancel button only if pending/processing
        if (_canCancel(order.status))
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: errorColor,
              minimumSize: const Size(double.infinity, 44),
            ),
            onPressed: () => _confirmCancel(order),
            child: const Text(
              "Cancel Order",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: whiteColor,
              ),
            ),
          ),
      ],
    );
  }

  /// Reusable card widget
  Widget _card({required String title, required Widget child}) {
    return Card(
      color: whiteColor,
      elevation: 2,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(defaultBorderRadious)),
      child: Padding(
        padding: const EdgeInsets.all(defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: blackColor)),
            const Divider(),
            child,
          ],
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(children: [
        Icon(icon, size: 18, color: blackColor60),
        const SizedBox(width: 8),
        Expanded(child: Text(text, style: const TextStyle(color: blackColor))),
      ]),
    );
  }

  Widget _totalRow(String label, double amount, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(label,
            style: TextStyle(
                fontWeight: bold ? FontWeight.bold : FontWeight.normal)),
        Text("\$${amount.toStringAsFixed(2)}",
            style: TextStyle(
                fontWeight: bold ? FontWeight.bold : FontWeight.normal)),
      ]),
    );
  }

  /// Confirmation dialog for cancel
  void _confirmCancel(OrderModel order) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Cancel Order"),
        content: const Text("Are you sure you want to cancel this order?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("No"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: errorColor),
            onPressed: () async {
              Navigator.pop(ctx);
              await repo.updateOrderStatus(order.id, "cancelled");
              setState(() {});
            },
            child: const Text("Yes, Cancel"),
          ),
        ],
      ),
    );
  }

  /// Allow cancel if pending/processing
  bool _canCancel(String status) {
    final st = status.toLowerCase();
    return st == "pending" || st == "processing";
  }

  /// Map order.status → OrderProgress step
  OrderProcessStatus _mapStatus(String current, String step) {
    final st = current.toLowerCase();
    if (st == "cancelled" && step != "delivered") {
      return OrderProcessStatus.canceled;
    }
    if (st == step) return OrderProcessStatus.processing;

    const steps = ["pending", "processing", "packed", "shipped", "delivered"];
    final curIndex = steps.indexOf(st);
    final stepIndex = steps.indexOf(step);

    if (curIndex > stepIndex) return OrderProcessStatus.done;
    return OrderProcessStatus.notDoneYeat;
  }
}
