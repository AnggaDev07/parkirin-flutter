// lib/features/authentication/presentation/widgets/role_selection_bottom_sheet.dart

import 'package:flutter/material.dart';
import 'package:parkirin/core/enums/user_role.dart';
import 'package:parkirin/localization/app_localizations.dart';

class RoleSelectionBottomSheet extends StatelessWidget {
  final Function(UserRole) onRoleSelected;

  const RoleSelectionBottomSheet({super.key, required this.onRoleSelected});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar at the top
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: theme.colorScheme.onSurface.withOpacity(0.2),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Text(
              loc.selectRole,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
          _buildRoleListTile(
            context: context,
            role: UserRole.driver,
            title: loc.driverRole,
            subtitle: loc.driverDescription,
            icon: Icons.drive_eta,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(height: 8),
          _buildRoleListTile(
            context: context,
            role: UserRole.parkingAttendant,
            title: loc.attendantRole,
            subtitle: loc.attendantDescription,
            icon: Icons.local_parking,
            color: theme.colorScheme.secondary,
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildRoleListTile({
    required BuildContext context,
    required UserRole role,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.2),
          child: Icon(
            icon,
            color: color,
          ),
        ),
        title: Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            subtitle,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        onTap: () {
          onRoleSelected(role);
          Navigator.pop(context);
        },
      ),
    );
  }
}
