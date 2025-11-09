import 'package:flutter/material.dart';
import 'package:my_library/constants.dart';
import 'package:my_library/models/order_model.dart';
import 'services/orders_repository.dart';
import 'order_detail_screen.dart';

class AdminAllOrdersTabScreen extends StatefulWidget {
  const AdminAllOrdersTabScreen({super.key});

  @override
  State<AdminAllOrdersTabScreen> createState() => _AdminAllOrdersTabScreenState();
}

class _AdminAllOrdersTabScreenState extends State<AdminAllOrdersTabScreen> {
  final ordersRepo = OrdersRepository.instance;
  String selectedFilter = 'All';
  final filters = ['All', 'Pending', 'Approved', 'Delivered', 'Cancelled'];

  List<OrderModel> _filtered(List<OrderModel> all) {
    if (selectedFilter == 'All') return all;
    return all
        .where((o) => o.status.toLowerCase() == selectedFilter.toLowerCase())
        .toList();
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
      case 'delivered':
      case 'return approved':
        return successColor;
      case 'cancelled':
      case 'return rejected':
        return errorColor;
      case 'return requested':
      case 'pending':
        return warningColor;
      default:
        return greyColor;
    }
  }

  Widget _buildOrderTile(OrderModel order) {
    final hasReturn = (order.returnStatus ?? '').isNotEmpty;

    return Container(
      decoration: BoxDecoration(
        color: whiteColor,
        borderRadius: BorderRadius.circular(defaultBorderRadious),
        boxShadow: [
          BoxShadow(
            color: blackColor20.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 6),
          )
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(defaultBorderRadious),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => AdminOrderDetailScreen(orderId: order.id),
            ),
          );
        },
        child: Row(
          children: [
            // 🔹 Circle with default person icon
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: const Icon(Icons.person, size: 40, color: primaryColor),
            ),
            const SizedBox(width: 16),
            // Info Column
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 14.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order.userName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: blackColor,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "Total: \$${order.totalAmount.toStringAsFixed(2)}",
                      style: const TextStyle(
                        fontSize: 14,
                        color: blackColor80,
                      ),
                    ),
                    if (hasReturn)
                      Padding(
                        padding: const EdgeInsets.only(top: 6.0),
                        child: Text(
                          "Return: ${order.returnStatus} • ${order.returnReason ?? ''}",
                          style: const TextStyle(
                            color: warningColor,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            // Status Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _statusColor(order.status),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                order.status,
                style: const TextStyle(
                  color: whiteColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 10),
            const Icon(Icons.arrow_forward_ios_rounded, color: primaryColor, size: 22),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightGreyColor,
      appBar: AppBar(
        title: const Text(
          'Manage Orders',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: blackColor,
          ),
        ),
        backgroundColor: whiteColor,
        centerTitle: true,
        elevation: 0,
      ),
      body: CustomScrollView(
        slivers: [
          // 🔹 Filter Buttons
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(defaultPadding),
              child: Row(
                children: filters.map((f) {
                  final isSelected = f == selectedFilter;
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            selectedFilter = f;
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isSelected ? primaryColor : whiteColor,
                          foregroundColor: isSelected ? whiteColor : blackColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(defaultBorderRadious),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          elevation: 4,
                        ),
                        child: Text(f, style: const TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          // 🔹 Orders List
          StreamBuilder<List<OrderModel>>(
            stream: ordersRepo.ordersStream(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                );
              }
              if (snapshot.hasError) {
                return SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Center(
                      child: Text(
                        'Error: ${snapshot.error}',
                        style: const TextStyle(color: errorColor),
                      ),
                    ),
                  ),
                );
              }

              final orders = _filtered(snapshot.data ?? []);
              if (orders.isEmpty) {
                return const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(
                      child: Text(
                        "No orders found",
                        style: TextStyle(
                          color: blackColor60,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                );
              }

              return SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: defaultPadding, vertical: 8),
                      child: _buildOrderTile(orders[index]),
                    );
                  },
                  childCount: orders.length,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
