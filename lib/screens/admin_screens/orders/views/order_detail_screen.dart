// lib/screens/admin/admin_order_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:my_library/constants.dart';
import 'package:my_library/models/order_model.dart';
import 'package:my_library/screens/admin_screens/orders/views/update_order_status_screen.dart';
import 'services/orders_repository.dart';
import 'package:my_library/components/custom_dialog.dart'; // 👈 use custom dialog

class AdminOrderDetailScreen extends StatefulWidget {
  final String orderId;
  const AdminOrderDetailScreen({super.key, required this.orderId});

  @override
  State<AdminOrderDetailScreen> createState() => _AdminOrderDetailScreenState();
}

class _AdminOrderDetailScreenState extends State<AdminOrderDetailScreen> {
  final repo = OrdersRepository.instance;
  OrderModel? order;
  List<OrderItem> items = [];
  bool loading = true;
  bool actionInProgress = false;
  String? selectedStatus;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => loading = true);
    try {
      final fetched = await repo.getOrderById(widget.orderId);
      if (!mounted) return;
      setState(() {
        order = fetched;
        items = fetched?.items ?? [];
        selectedStatus = order?.status;
      });
    } catch (e) {
      if (mounted) {
        CustomDialog.show(context,
            message: "Failed to load order: $e", isError: true);
      }
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }


  Future<void> _decideReturn(String decision) async {
    setState(() => actionInProgress = true);
    try {
      await repo.setReturnDecision(widget.orderId, decision);
      if (mounted) {
        CustomDialog.show(context, message: "Return $decision");
        await _load();
      }
    } catch (e) {
      if (mounted) {
        CustomDialog.show(context,
            message: "Failed to set return: $e", isError: true);
      }
    } finally {
      if (mounted) setState(() => actionInProgress = false);
    }
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

  @override
  Widget build(BuildContext context) {
    final o = order;

    return Stack(
      children: [
        Scaffold(
          backgroundColor: lightGreyColor,
          appBar: AppBar(
            title: Text("Order #${o?.id ?? widget.orderId}"),
            backgroundColor: primaryColor,
            centerTitle: true,
            actions: [
              if (o != null)
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 8),
                  child: Chip(
                    label: Text(o.status,
                        style: const TextStyle(color: whiteColor)),
                    backgroundColor: _statusColor(o.status),
                  ),
                ),
            ],
          ),
          body: loading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(defaultPadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _card(
                        title: "Customer Information",
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _infoRow(Icons.person, o?.userName ?? ''),
                            _infoRow(Icons.email, o?.userEmail ?? ''),
                            _infoRow(Icons.phone, o?.phone ?? 'N/A'),
                            _infoRow(Icons.location_on, o?.address ?? 'N/A'),
                          ],
                        ),
                      ),
                      const SizedBox(height: defaultPadding),
                      _card(
                        title: "Order Dates",
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (o?.orderDate != null)
                              _infoRow(
                                  Icons.calendar_today,
                                  "Order: ${DateFormat.yMMMd().format(o!.orderDate as DateTime)}"),
                            if (o?.deliveryDate != null)
                              _infoRow(
                                  Icons.local_shipping,
                                  "Delivered: ${DateFormat.yMMMd().format(o!.deliveryDate!)}"),
                          ],
                        ),
                      ),
                      const SizedBox(height: defaultPadding),
                      _card(
                        title: "Ordered Products",
                        child: Column(
                          children: items
                              .map((it) => ListTile(
                                    leading: const Icon(Icons.shopping_bag),
                                    title: Text(it.productName,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold)),
                                    subtitle: Text(
                                        "Price: \$${it.price.toStringAsFixed(2)} • Qty: ${it.quantity}"),
                                    trailing: Text(
                                      "\$${(it.price * it.quantity).toStringAsFixed(2)}",
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold),
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
                            _totalRow("Subtotal", o?.totalAmount ?? 0),
                            _totalRow("Tax (10%)", (o?.totalAmount ?? 0) * 0.10),
                            const Divider(),
                            _totalRow("Total", (o?.totalAmount ?? 0) * 1.10,
                                bold: true),
                          ],
                        ),
                      ),
                      const SizedBox(height: defaultPadding),
                      // Return Flow
                      if ((o?.returnStatus ?? '').isNotEmpty ||
                          (o?.status.toLowerCase() ?? '')
                              .contains('return'))
                        _card(
                          title: "Return",
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                  "Status: ${o?.returnStatus ?? o?.status ?? ''}"),
                              if (o?.returnReason != null)
                                Text("Reason: ${o!.returnReason}"),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: actionInProgress
                                          ? null
                                          : () => _decideReturn('Approved'),
                                      style: ElevatedButton.styleFrom(
                                          backgroundColor: successColor),
                                      child: const Text("Approve"),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: actionInProgress
                                          ? null
                                          : () => _decideReturn('Rejected'),
                                      style: ElevatedButton.styleFrom(
                                          backgroundColor: errorColor),
                                      child: const Text("Reject"),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      // Normal Flow – Update Status
                      if (o != null &&
                          !(o.returnStatus ?? '').toLowerCase().contains(
                              "requested"))
                        Padding(
                          padding: const EdgeInsets.only(top: 24),
                          child: SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryColor,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(defaultBorderRadious),
                                ),
                              ),
                              onPressed: actionInProgress
                                  ? null
                                  : () async {
                                      final updatedStatus = await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              AdminUpdateOrderStatusScreen(
                                            orderId: o.id,
                                            initialStatus: o.status,
                                          ),
                                        ),
                                      );

                                      if (updatedStatus != null && mounted) {
                                        setState(() {
                                          selectedStatus = updatedStatus;
                                          order = order?.copyWith(
                                              status: updatedStatus);
                                        });
                                        await _load();
                                      }
                                    },
                              child: const Text(
                                "Update Order Status",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontFamily: grandisExtendedFont,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
        ),
        if (actionInProgress)
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(
                  child: CircularProgressIndicator(
                color: primaryColor,
              )),
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
}
