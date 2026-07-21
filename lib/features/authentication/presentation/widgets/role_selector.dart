// lib/features/authentication/presentation/widgets/role_selector.dart

import 'package:flutter/material.dart';
import 'package:parkirin/core/enums/user_role.dart';

class RoleSelector extends StatelessWidget {
  final UserRole selectedRole;
  final VoidCallback onTap;

  const RoleSelector({
    super.key,
    required this.selectedRole,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: theme.colorScheme.primary,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              selectedRole == UserRole.driver ? 'Driver' : 'Parking Attendant',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.arrow_drop_down,
              color: theme.colorScheme.onPrimary,
            ),
          ],
        ),
      ),
    );
  }
}
