import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:my_library/constants.dart';
import 'package:my_library/models/user_model.dart';

class UserCard extends StatelessWidget {
  final UserModel user;
  final VoidCallback onView;
  final VoidCallback? onEdit; // Admin only
  final VoidCallback? onDelete; // Admin only (Logout)

  const UserCard({
    super.key,
    required this.user,
    required this.onView,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
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
        onTap: onView,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              // Circle Avatar
              CircleAvatar(
                radius: 28,
                backgroundColor: primaryColor.withOpacity(0.12),
                child: user.image != null
                    ? ClipOval(
                        child: Image.network(
                          user.image!,
                          width: 56,
                          height: 56,
                          fit: BoxFit.cover,
                        ),
                      )
                    : const Icon(Iconsax.user, color: primaryColor, size: 28),
              ),

              const SizedBox(width: 16),
              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: blackColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user.email,
                      style: const TextStyle(color: blackColor60),
                    ),
                  ],
                ),
              ),
              // Action buttons
              if (onEdit != null || onDelete != null)
                Row(
                  children: [
                    if (onEdit != null)
                      IconButton(
                        tooltip: 'Edit',
                        icon: const Icon(Iconsax.edit,
                            size: 20, color: primaryColor),
                        onPressed: onEdit,
                      ),
                    if (onDelete != null)
                      IconButton(
                        tooltip: 'Logout',
                        icon: const Icon(Icons.logout,
                            size: 20, color: Colors.red),
                        onPressed: onDelete,
                      ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
