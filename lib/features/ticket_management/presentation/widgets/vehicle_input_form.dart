// lib/features/ticket_management/presentation/widgets/vehicle_input_form.dart

import 'package:flutter/material.dart';
import 'package:parkirin/features/vehicle_management/presentation/widgets/vehicle_type_selector.dart';

class VehicleInputForm extends StatelessWidget {
  final TextEditingController plateController;
  final VehicleType selectedVehicleType;
  final Function(VehicleType) onVehicleTypeChanged;
  final bool plateValidationEnabled;
  final String? Function(String?)? plateValidator;

  const VehicleInputForm({
    super.key,
    required this.plateController,
    required this.selectedVehicleType,
    required this.onVehicleTypeChanged,
    this.plateValidationEnabled = true,
    this.plateValidator,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.directions_car, color: theme.colorScheme.onSurface),
                const SizedBox(width: 8),
                Text(
                  'Vehicle Details',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: plateController,
              textCapitalization: TextCapitalization.characters,
              decoration: const InputDecoration(
                labelText: 'License Plate',
                hintText: 'e.g., B 1234 ABC',
                border: OutlineInputBorder(),
              ),
              validator: plateValidationEnabled
                  ? (plateValidator ?? _defaultPlateValidator)
                  : null,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<VehicleType>(
              value: selectedVehicleType,
              decoration: const InputDecoration(
                labelText: 'Vehicle Type',
                border: OutlineInputBorder(),
              ),
              items: VehicleType.values.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(type.name.toUpperCase()),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  onVehicleTypeChanged(value);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  String? _defaultPlateValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter license plate';
    }

    // Basic Indonesian plate number format validation
    final regex = RegExp(r'^[A-Z]{1,2}\s?\d{1,4}\s?[A-Z]{1,3}$');
    if (!regex.hasMatch(value.toUpperCase())) {
      return 'Invalid plate number format';
    }
    return null;
  }
}
