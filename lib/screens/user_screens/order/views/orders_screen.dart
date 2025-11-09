import 'package:flutter/material.dart';
import 'package:my_library/route/route_constants.dart';
import '/constants.dart';
import '/models/order_model.dart';
import 'package:my_library/screens/admin_screens/orders/views/services/orders_repository.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = OrdersRepository.instance;

    return Scaffold(
      backgroundColor: whiteColor,
      appBar: AppBar(
        backgroundColor: whiteColor,
        elevation: 0,
        centerTitle: true,
        leading: const BackButton(color: blackColor),
        title: const Text(
          'Orders',
          style: TextStyle(
            fontFamily: grandisExtendedFont,
            fontWeight: FontWeight.w600,
            fontSize: 18,
            color: blackColor,
          ),
        ),
      ),
      body: SafeArea(
        child: StreamBuilder<List<OrderModel>>(
          stream: repo.ordersStream(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text("Error: ${snapshot.error}"));
            }

            final orders = snapshot.data ?? [];

            // 🔹 Grouped orders
            final processingOrders = orders
                .where((o) =>
                    o.status.toLowerCase() == "pending" ||
                    o.status.toLowerCase() == "processing")
                .toList();
            final processingCount = processingOrders.length;

            final deliveredCount =
                orders.where((o) => o.status.toLowerCase() == "delivered").length;

            

            final cancelledCount =
                orders.where((o) => o.status.toLowerCase() == "cancelled").length;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 🔍 Search Bar
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: defaultPadding),
                  child: Container(
                    height: 48,
                    decoration: BoxDecoration(
                      borderRadius:
                          BorderRadius.circular(defaultBorderRadious),
                      color: lightGreyColor,
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: const Row(
                      children: [
                        Icon(Icons.search, color: greyColor, size: 20),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Find an order...',
                            style: TextStyle(
                              fontSize: 14,
                              color: greyColor,
                              fontFamily: grandisExtendedFont,
                            ),
                          ),
                        ),
                        Icon(Icons.tune, color: greyColor, size: 20),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // 📝 Orders History Title
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: defaultPadding),
                  child: Text(
                    'Orders history',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      fontFamily: grandisExtendedFont,
                      color: blackColor,
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // 📋 Orders Categories
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(
                        horizontal: defaultPadding),
                    children: [
                      buildStatusTile(
                        icon: Icons.inventory_2_outlined,
                        title: 'Processing',
                        count: processingCount,
                        color: const Color(0xFF22C3DD),
                        onTap: () {
                          Navigator.pushNamed(
                              context, orderProcessingScreenRoute);
                        },
                      ),
                      buildStatusTile(
                        icon: Icons.local_shipping_outlined,
                        title: 'Delivered',
                        count: deliveredCount,
                        color: const Color(0xFF22C3DD),
                        onTap: () {
                          Navigator.pushNamed(
                              context, deliveredOrdersScreenRoute);
                        },
                      ),
                      
                      buildStatusTile(
                        icon: Icons.cancel_outlined,
                        title: 'Canceled',
                        count: cancelledCount,
                        color: errorColor,
                        onTap: () {
                          Navigator.pushNamed(
                              context, cancleOrderScreenRoute);
                        },
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget buildStatusTile({
    required IconData icon,
    required String title,
    required int count,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Column(
      children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          onTap: onTap,
          leading: Icon(icon, size: 28, color: blackColor),
          title: Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              fontFamily: grandisExtendedFont,
              color: blackColor,
            ),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Text(
                  '$count',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    fontFamily: grandisExtendedFont,
                    color: color,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.chevron_right, color: greyColor),
            ],
          ),
        ),
        const Divider(height: 1, color: Color(0xFFEAEAEA)),
      ],
    );
  }
}
