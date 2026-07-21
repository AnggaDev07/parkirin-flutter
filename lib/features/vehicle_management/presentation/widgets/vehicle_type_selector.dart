// lib/features/vehicle_management/presentation/widgets/vehicle_type_selector.dart

import 'package:flutter/material.dart';
import 'package:parkirin/localization/app_localizations.dart';

// lib/features/vehicle_management/presentation/widgets/vehicle_type_selector.dart

enum VehicleType {
  car('Car'),
  motorcycle('Motorcycle'),
  truck('Truck'),
  bus('Bus');

  final String defaultLabel;
  const VehicleType(this.defaultLabel);

  String getLocalizedLabel(AppLocalizations loc) {
    switch (this) {
      case VehicleType.car:
        return loc.car;
      case VehicleType.motorcycle:
        return loc.motorcycle;
      case VehicleType.truck:
        return loc.truck;
      case VehicleType.bus:
        return loc.bus;
    }
  }
}

class VehicleTypeSelector extends StatelessWidget {
  final VehicleType selectedType;
  final Function(VehicleType) onTypeSelected;

  const VehicleTypeSelector({
    super.key,
    required this.selectedType,
    required this.onTypeSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          loc.vehicleType,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 2.5,
          children: VehicleType.values.map((type) {
            final isSelected = type == selectedType;
            return _buildTypeCard(context, type, isSelected, loc);
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildTypeCard(
    BuildContext context,
    VehicleType type,
    bool isSelected,
    AppLocalizations loc,
  ) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: () => onTypeSelected(type),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.outline.withOpacity(0.5),
          ),
          color: isSelected
              ? theme.colorScheme.primary.withOpacity(0.1)
              : theme.colorScheme.surface,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _getVehicleIcon(type),
              color: isSelected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurface,
            ),
            const SizedBox(width: 8),
            Text(
              type.getLocalizedLabel(loc),
              style: theme.textTheme.bodyLarge?.copyWith(
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurface,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getVehicleIcon(VehicleType type) {
    switch (type) {
      case VehicleType.car:
        return Icons.directions_car;
      case VehicleType.motorcycle:
        return Icons.motorcycle;
      case VehicleType.truck:
        return Icons.local_shipping;
      case VehicleType.bus:
        return Icons.directions_bus;
    }
  }
}
