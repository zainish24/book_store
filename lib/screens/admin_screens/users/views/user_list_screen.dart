import 'package:flutter/material.dart';
import 'package:my_library/constants.dart';
import 'package:my_library/models/user_model.dart';
import 'package:my_library/route/route_constants.dart';
import 'services/user_service.dart';
import 'components/user_card.dart';
import 'package:my_library/components/custom_dialog.dart';
import 'package:my_library/screens/admin_screens/admin/views/components/offers_carousel.dart';

class AdminUserListScreen extends StatefulWidget {
  const AdminUserListScreen({super.key});

  @override
  State<AdminUserListScreen> createState() => _AdminUserListScreenState();
}

class _AdminUserListScreenState extends State<AdminUserListScreen> {
  final UserService _svc = UserService();
  String? currentUserRole;
  bool showAdmins = true; // initially show Admins

  @override
  void initState() {
    super.initState();
    _loadRole();
  }

  Future<void> _loadRole() async {
    final r = await _svc.getCurrentUserRole();
    setState(() => currentUserRole = r);
  }

  void _toggleView(bool showAdminsSelected) {
    setState(() {
      showAdmins = showAdminsSelected;
    });
  }

  @override
  Widget build(BuildContext context) {
    final canAddAdmin = currentUserRole == 'Admin' && showAdmins;

    return Scaffold(
      backgroundColor: lightGreyColor,
      appBar: AppBar(
        backgroundColor: whiteColor,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Manage Users",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: blackColor,
          ),
        ),
      ),
      floatingActionButton: canAddAdmin
          ? FloatingActionButton.extended(
              backgroundColor: primaryColor,
              onPressed: () => Navigator.pushNamed(
                context,
                adminUserAddScreenRoute,
              ),
              icon: const Icon(Icons.add, color: whiteColor),
              label: const Text(
                "Add Admin",
                style: TextStyle(color: whiteColor, fontWeight: FontWeight.bold),
              ),
            )
          : null,
      body: CustomScrollView(
        slivers: [
          // 🔹 Carousel at top
          const SliverToBoxAdapter(
            child: SizedBox(
              height: 200,
              child: OffersCarousel(),
            ),
          ),

          // 🔹 Buttons for Admins & Customers
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(defaultPadding),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _toggleView(true),
                      child: const Text("Admins"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            showAdmins ? primaryColor : whiteColor,
                        foregroundColor:
                            showAdmins ? whiteColor : blackColor,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(defaultBorderRadious),
                        ),
                        elevation: 4,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _toggleView(false),
                      child: const Text("Customers"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            !showAdmins ? primaryColor : whiteColor,
                        foregroundColor:
                            !showAdmins ? whiteColor : blackColor,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(defaultBorderRadious),
                        ),
                        elevation: 4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 🔹 User list
          StreamBuilder<List<UserModel>>(
            stream: showAdmins ? _svc.streamAdmins() : _svc.streamCustomers(),
            builder: (context, snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return const SliverToBoxAdapter(
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              final users = snap.data ?? [];
              if (users.isEmpty) {
                return const SliverToBoxAdapter(
                  child: Center(child: Text('No users found')),
                );
              }

              return SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, i) {
                    final u = users[i];
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: defaultPadding, vertical: 8),
                      child: UserCard(
                        user: u,
                        onView: () => Navigator.pushNamed(
                          context,
                          adminUserDetailScreenRoute,
                          arguments: {'user': u, 'isCurrentAdminView': showAdmins},
                        ),
                        onEdit: (showAdmins && currentUserRole == 'Admin')
                            ? () => Navigator.pushNamed(
                                  context,
                                  adminUserEditScreenRoute,
                                  arguments: u,
                                )
                            : null,
                        onDelete: showAdmins
                            ? () async {
                                await _svc.logoutUser(u.id);
                                CustomDialog.show(context, message: "Logged out", isError: true);
                              }
                            : null,
                      ),
                    );
                  },
                  childCount: users.length,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
