import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:my_library/constants.dart';
import 'package:my_library/route/route_constants.dart';
import 'package:my_library/models/order_model.dart';
import 'package:my_library/components/order_process.dart'; // 👈 import your OrderProgress

class Processing extends StatefulWidget {
  final OrderModel order;

  const Processing({super.key, required this.order});

  @override
  State<Processing> createState() => _ProcessingState();
}

class _ProcessingState extends State<Processing> {
  String? selectedReason;

  final List<String> reasons = [
    "It's too costly.",
    "I found another product that fulfills my need.",
    "I don’t use it enough.",
    "Other",
  ];

  final dateFormat = DateFormat('yyyy-MM-dd');

  @override
  Widget build(BuildContext context) {
    final order = widget.order;

    return Scaffold(
      backgroundColor: whiteColor,
      appBar: AppBar(
        backgroundColor: whiteColor,
        elevation: 0,
        leading: const BackButton(color: blackColor),
        centerTitle: true,
        title: Text(
          "Order #${order.id}",
          style: const TextStyle(
            color: blackColor,
            fontWeight: FontWeight.w700,
            fontFamily: 'Plus Jakarta',
            fontSize: 18,
          ),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: Icon(Icons.info_outline, color: blackColor),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildOrderDetails(order),
          if (_canCancel(order.status)) _buildReasonSection(),
          if (_canCancel(order.status)) _buildCancelButton(),
        ],
      ),
    );
  }

  /// Only allow cancel if status = Pending or Processing
  bool _canCancel(String status) {
    final st = status.toLowerCase();
    return st == "pending" || st == "processing";
  }

  Widget _buildOrderDetails(OrderModel order) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      margin: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Order #${order.id}",
            style: const TextStyle(color: blackColor60, fontSize: 14),
          ),
          const SizedBox(height: 4),
          Text(
            "Placed on ${order.orderDate != null ? dateFormat.format(order.orderDate!) : '-'}",
            style: const TextStyle(color: blackColor, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),

          /// ✅ Use OrderProgress widget here
          OrderProgress(
            orderStatus: OrderProcessStatus.done, // Always first done
            processingStatus: _mapStatus(order.status, "processing"),
            packedStatus: _mapStatus(order.status, "packed"),
            shippedStatus: _mapStatus(order.status, "shipped"),
            deliveredStatus: _mapStatus(order.status, "delivered"),
            isCanceled: order.status.toLowerCase() == "canceled",
          ),
          const SizedBox(height: 16),

          /// Order items
          ...order.items.map((item) => _buildOrderItemTile(item)).toList(),
        ],
      ),
    );
  }

  /// Map order.status into progress steps
  OrderProcessStatus _mapStatus(String current, String step) {
    final st = current.toLowerCase();

    if (st == "canceled" && step != "delivered") return OrderProcessStatus.canceled;

    if (st == step) return OrderProcessStatus.processing;

    // If current step is beyond this step → mark as done
    const orderSteps = ["pending", "processing", "packed", "shipped", "delivered"];
    final currentIndex = orderSteps.indexOf(st);
    final stepIndex = orderSteps.indexOf(step);

    if (currentIndex > stepIndex) return OrderProcessStatus.done;
    return OrderProcessStatus.notDoneYeat;
  }

  Widget _buildOrderItemTile(OrderItem item) {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Row(
        children: [
          /// Placeholder product image
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: blackColor10,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.shopping_bag, color: blackColor40),
          ),
          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.productName,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: blackColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Qty: ${item.quantity}",
                  style: const TextStyle(fontSize: 12, color: blackColor40),
                ),
                const SizedBox(height: 4),
                Text(
                  "\$${item.price.toStringAsFixed(2)}",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: primaryColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReasonSection() {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "What is the biggest reason for your wish to cancel?",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: blackColor,
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.separated(
                itemCount: reasons.length,
                separatorBuilder: (_, __) => const Divider(height: 1, color: blackColor10),
                itemBuilder: (context, index) {
                  return RadioListTile<String>(
                    title: Text(reasons[index]),
                    activeColor: primaryColor,
                    value: reasons[index],
                    groupValue: selectedReason,
                    onChanged: (value) {
                      setState(() {
                        selectedReason = value;
                      });
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCancelButton() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: ElevatedButton(
          onPressed: selectedReason == null
              ? null
              : () {
                  Navigator.pushNamed(context, cancleOrderScreenRoute);
                },
          style: ElevatedButton.styleFrom(
            backgroundColor: selectedReason != null ? errorColor : blackColor10,
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text(
            "Cancel Order",
            style: TextStyle(
              color: whiteColor,
              fontWeight: FontWeight.w600,
              fontSize: 16,
              fontFamily: 'Plus Jakarta',
            ),
          ),
        ),
      ),
    );
  }
}
