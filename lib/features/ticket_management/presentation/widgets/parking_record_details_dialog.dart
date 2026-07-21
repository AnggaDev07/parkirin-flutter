// lib/features/ticket_management/presentation/widgets/parking_record_details_dialog.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:parkirin/features/ticket_management/domain/entities/parking_record.dart';

class ParkingRecordDetailsDialog extends StatelessWidget {
  final ParkingRecord record;

  const ParkingRecordDetailsDialog({
    super.key,
    required this.record,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currencyFormat = NumberFormat.currency(
      locale: 'id',
      symbol: 'Rp',
      decimalDigits: 0,
    );
    final dateFormat = DateFormat('dd MMM yyyy, HH:mm');

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Record Details',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Record ID
            _buildSection(
              'Record Information',
              [
                _buildInfoRow('Record ID', '#${record.id}'),
                _buildInfoRow(
                  'Status',
                  'Completed',
                  color: theme.colorScheme.primary,
                  highlighted: true,
                ),
              ],
            ),

            // Vehicle Information
            _buildSection(
              'Vehicle Information',
              [
                _buildInfoRow('Plate Number', record.vehiclePlateNumber),
                _buildInfoRow('Vehicle Type', record.vehicleType),
              ],
            ),

            // Location Information
            _buildSection(
              'Location Information',
              [
                _buildInfoRow('Location', record.locationName),
                _buildInfoRow(
                  'Coordinates',
                  '${record.latitude.toStringAsFixed(6)}, ${record.longitude.toStringAsFixed(6)}',
                ),
              ],
            ),

            // Time Information
            _buildSection(
              'Time Information',
              [
                _buildInfoRow(
                  'Entry Time',
                  dateFormat.format(record.entryTime),
                ),
                _buildInfoRow(
                  'Exit Time',
                  dateFormat.format(record.exitTime!),
                ),
                _buildInfoRow(
                  'Duration',
                  '${record.getParkingDuration().inHours}h ${record.getParkingDuration().inMinutes.remainder(60)}m',
                ),
              ],
            ),

            // Payment Information
            _buildSection(
              'Payment Information',
              [
                _buildInfoRow(
                  'Amount',
                  currencyFormat.format(record.amount),
                  highlighted: true,
                  color: theme.colorScheme.primary,
                ),
                _buildInfoRow('Payment Method', 'Cash'),
              ],
            ),

            const SizedBox(height: 24),

            // Action Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    // Implement print functionality
                    Navigator.pop(context);
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.print,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      const Text('Print'),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Close'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 8),
        ...children,
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildInfoRow(
    String label,
    String value, {
    bool highlighted = false,
    Color? color,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.grey,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: highlighted ? FontWeight.bold : null,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
