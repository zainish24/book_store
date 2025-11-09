// lib/screens/admin/admin_update_order_status_screen.dart
import 'package:flutter/material.dart';
import 'package:my_library/constants.dart';
import 'services/orders_repository.dart';
import 'package:my_library/components/custom_dialog.dart'; // 👈 use CustomDialog

class AdminUpdateOrderStatusScreen extends StatefulWidget {
  final String orderId;
  final String initialStatus;

  const AdminUpdateOrderStatusScreen({
    super.key,
    required this.orderId,
    required this.initialStatus,
  });

  @override
  State<AdminUpdateOrderStatusScreen> createState() =>
      _AdminUpdateOrderStatusScreenState();
}

class _AdminUpdateOrderStatusScreenState
    extends State<AdminUpdateOrderStatusScreen> {
  late String _selectedStatus;
  final repo = OrdersRepository.instance;
  bool _isUpdating = false;

  final List<String> _statuses = [
    "Pending",
    "Approved",
    "Delivered",
    "Cancelled",
  ];

  @override
  void initState() {
    super.initState();
    _selectedStatus = _statuses.contains(widget.initialStatus)
        ? widget.initialStatus
        : "Pending";
  }

  Future<void> _updateStatus() async {
    setState(() => _isUpdating = true);
    try {
      await repo.updateOrderStatus(widget.orderId, _selectedStatus);
      if (mounted) {
        await CustomDialog.show(context, message: "Order status updated successfully");
        Navigator.pop(context, _selectedStatus); // Return updated status here
      }
    } catch (e) {
      if (mounted) {
        await CustomDialog.show(context,
            message: "Failed to update status: $e", isError: false);
      }
    } finally {
      if (mounted) setState(() => _isUpdating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            title: const Text("Update Order Status"),
            backgroundColor: primaryColor,
          ),
          body: Padding(
            padding: const EdgeInsets.all(defaultPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Select Status:",
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: _selectedStatus,
                  isExpanded: true,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(defaultBorderRadious),
                    ),
                  ),
                  items: _statuses
                      .map((status) =>
                          DropdownMenuItem(value: status, child: Text(status)))
                      .toList(),
                  onChanged: _isUpdating
                      ? null
                      : (value) {
                          if (value != null) {
                            setState(() => _selectedStatus = value);
                          }
                        },
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(defaultBorderRadious),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: _isUpdating ? null : _updateStatus,
                    child: const Text("Update Order Status",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (_isUpdating)
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(
                child: CircularProgressIndicator(color: primaryColor),
              ),
            ),
          ),
      ],
    );
  }
}
