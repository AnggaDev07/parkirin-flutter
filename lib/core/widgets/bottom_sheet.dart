import 'package:flutter/material.dart';
import 'package:parkirin/core/enums/user_role.dart';

class RoleSelectionBottomSheet extends StatelessWidget {
  final Function(UserRole) onRoleSelected;

  const RoleSelectionBottomSheet({super.key, required this.onRoleSelected});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Padding(
            padding: EdgeInsets.only(bottom: 16),
            child: Text(
              'Select your role',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ListTile(
            leading: const CircleAvatar(
              backgroundColor: Colors.blue,
              child: Icon(
                Icons.drive_eta,
                color: Colors.white,
              ),
            ),
            title: const Text(
              'Driver',
              style: TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: const Text(
              'Find and book parking spots easily for your vehicle',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
            onTap: () {
              onRoleSelected(UserRole.driver);
              Navigator.pop(context);
            },
          ),
          const SizedBox(height: 8),
          ListTile(
            leading: const CircleAvatar(
              backgroundColor: Colors.green,
              child: Icon(
                Icons.local_parking,
                color: Colors.white,
              ),
            ),
            title: const Text(
              'Parking Attendant',
              style: TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: const Text(
              'Manage parking areas and handle vehicle check-ins/outs',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
            onTap: () {
              onRoleSelected(UserRole.parkingAttendant);
              Navigator.pop(context);
            },
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
