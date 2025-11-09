import 'package:flutter/material.dart';
import '/constants.dart';
import 'package:intl/intl.dart';
import '/models/order_model.dart';
import 'package:my_library/screens/admin_screens/orders/views/services/orders_repository.dart';
import 'package:my_library/components/order_process.dart';

class DeliveredOrdersScreen extends StatefulWidget {
  const DeliveredOrdersScreen({super.key});

  @override
  State<DeliveredOrdersScreen> createState() => _DeliveredOrdersScreenState();
}

class _DeliveredOrdersScreenState extends State<DeliveredOrdersScreen> {
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
          'Delivered Orders',
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
            return const Center(child: CircularProgressIndicator(color: primaryColor));
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          final deliveredOrders = (snapshot.data ?? [])
              .where((o) => o.status.toLowerCase() == "delivered")
              .toList();

          if (deliveredOrders.isEmpty) {
            return _buildEmptyState(
              "No delivered orders yet.",
              "assets/Illustration/Success_lightTheme.png",
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(defaultPadding),
            itemCount: deliveredOrders.length,
            itemBuilder: (context, index) {
              final order = deliveredOrders[index];
              return _buildExpandableOrderCard(order);
            },
          );
        },
      ),
    );
  }

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
        "Delivered on ${order.deliveryDate != null ? dateFormat.format(order.deliveryDate!) : '-'}",
        style: const TextStyle(fontSize: 12, color: blackColor60),
      ),
      childrenPadding: const EdgeInsets.all(16),
      children: [
        const OrderProgress(
          orderStatus: OrderProcessStatus.done,
          processingStatus: OrderProcessStatus.done,
          packedStatus: OrderProcessStatus.done,
          shippedStatus: OrderProcessStatus.done,
          deliveredStatus: OrderProcessStatus.done,
          isCanceled: false,
        ),
        const SizedBox(height: 16),
        _orderDetailsCard(order),
      ],
    );
  }

  Widget _orderDetailsCard(OrderModel order) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _card(
          title: "Customer Information",
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _infoRow(Icons.person, order.userName),
              _infoRow(Icons.email, order.userEmail),
              _infoRow(Icons.phone, order.phone ?? 'N/A'),
              _infoRow(Icons.location_on, order.address ?? 'N/A'),
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
                      subtitle:
                          Text("Price: \$${it.price.toStringAsFixed(2)} • Qty: ${it.quantity}"),
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
              _totalRow("Tax (10%)", (order.totalAmount) * 0.10),
              const Divider(),
              _totalRow("Total", (order.totalAmount) * 1.10, bold: true),
            ],
          ),
        ),
      ],
    );
  }

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
                    fontSize: 16, fontWeight: FontWeight.bold, color: blackColor)),
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
            style: TextStyle(fontWeight: bold ? FontWeight.bold : FontWeight.normal)),
        Text("\$${amount.toStringAsFixed(2)}",
            style: TextStyle(fontWeight: bold ? FontWeight.bold : FontWeight.normal)),
      ]),
    );
  }

  Widget _buildEmptyState(String message, String assetPath) {
    return Center(
      child: TweenAnimationBuilder<Offset>(
        tween: Tween(begin: const Offset(0, 1), end: Offset.zero),
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeOutBack,
        builder: (context, offset, child) {
          return Transform.translate(offset: offset, child: child);
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(assetPath, height: 200),
            const SizedBox(height: 20),
            Text(
              message,
              style: const TextStyle(fontSize: 16, fontFamily: grandisExtendedFont, color: blackColor60),
            ),
          ],
        ),
      ),
    );
  }
}
