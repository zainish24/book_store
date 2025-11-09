import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:my_library/constants.dart';
import 'package:my_library/models/user_model.dart';
import 'services/user_service.dart';
import 'package:my_library/route/route_constants.dart';
import 'package:my_library/components/custom_dialog.dart';

class AdminUserDetailScreen extends StatelessWidget {
  const AdminUserDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map;
    final user = args['user'] as UserModel;
    final isCurrentAdminView = args['isCurrentAdminView'] as bool;
    final dateFmt = DateFormat('dd MMM yyyy');

    return Scaffold(
      backgroundColor: lightGreyColor,
      appBar: AppBar(
        backgroundColor: primaryColor,
        foregroundColor: whiteColor,
        title: const Text(
          "User Details",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontFamily: grandisExtendedFont,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(defaultPadding),
        child: Column(
          children: [
            Card(
              color: whiteColor,
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(defaultBorderRadious),
              ),
              child: Padding(
                padding: const EdgeInsets.all(defaultPadding),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 38,
                      backgroundColor: primaryColor.withOpacity(0.12),
                      backgroundImage:
                          user.image != null ? NetworkImage(user.image!) : null,
                      child: user.image == null
                          ? const Icon(Iconsax.user, size: 36, color: primaryColor)
                          : null,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user.name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              fontFamily: grandisExtendedFont,
                            ),
                          ),
                          const SizedBox(height: 4),
                          _RoleBadge(role: user.role),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(
                                user.isActive ? Icons.check_circle : Icons.cancel,
                                size: 16,
                                color: user.isActive ? Colors.green : Colors.red,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                user.isActive ? 'Active' : 'Inactive',
                                style: TextStyle(
                                  color: user.isActive ? Colors.green : Colors.red,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
            const SizedBox(height: defaultPadding),
            _InfoTile(icon: Iconsax.sms, title: 'Email', value: user.email),
            _InfoTile(icon: Iconsax.call, title: 'Phone', value: user.phone ?? '-'),
            _InfoTile(icon: Iconsax.location, title: 'Address', value: user.address ?? '-'),
            _InfoTile(icon: Iconsax.global, title: 'Country', value: user.country ?? '-'),
            _InfoTile(icon: Iconsax.calendar, title: 'Joined', value: dateFmt.format(user.createdAt)),
            const SizedBox(height: defaultPadding),
            if (isCurrentAdminView)
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pushNamed(
                          context,
                          adminUserEditScreenRoute,
                          arguments: user,
                        );
                      },
                      icon: const Icon(Iconsax.edit),
                      label: const Text('Edit'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: whiteColor,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(defaultBorderRadious),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        await UserService().logoutUser(user.id);
                        Navigator.pop(context);
                        CustomDialog.show(context, message: "logged out", isError: true);
                      },
                      icon: const Icon(Icons.logout),
                      label: const Text('Logout'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: whiteColor,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(defaultBorderRadious),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _RoleBadge extends StatelessWidget {
  final String role;
  const _RoleBadge({required this.role});

  @override
  Widget build(BuildContext context) {
    final Color bg = primaryColor.withOpacity(0.10);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        role,
        style: const TextStyle(
          color: primaryColor,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _InfoTile({required this.icon, required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: whiteColor,
      elevation: 1.5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(defaultBorderRadious),
      ),
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(icon, color: primaryColor),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
        subtitle: Text(value),
      ),
    );
  }
}
