// lib/features/ticket_management/presentation/widgets/ticket_details_dialog.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:parkirin/features/ticket_management/domain/entities/ticket.dart';

class TicketDetailsDialog extends StatelessWidget {
  final Ticket ticket;

  const TicketDetailsDialog({
    super.key,
    required this.ticket,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currencyFormat = NumberFormat.currency(
      locale: 'id',
      symbol: 'Rp',
      decimalDigits: 0,
    );

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
                  'Ticket Details',
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

            // Ticket ID and Status
            _buildSection(
              'Ticket Information',
              [
                _buildInfoRow('Ticket ID', '#${ticket.id}'),
                _buildInfoRow(
                  'Status',
                  ticket.status.toString().split('.').last,
                  highlighted: true,
                  color: _getStatusColor(ticket.status, theme),
                ),
              ],
            ),

            // Vehicle Information
            _buildSection(
              'Vehicle Information',
              [
                _buildInfoRow('Plate Number', ticket.vehiclePlateNumber),
                _buildInfoRow('Vehicle Type', ticket.vehicleType),
              ],
            ),

            // Location Information
            _buildSection(
              'Location Information',
              [
                _buildInfoRow('Location', ticket.locationName),
                _buildInfoRow(
                  'Coordinates',
                  '${ticket.latitude.toStringAsFixed(6)}, ${ticket.longitude.toStringAsFixed(6)}',
                ),
              ],
            ),

            // Time Information
            _buildSection(
              'Time Information',
              [
                _buildInfoRow(
                  'Entry Time',
                  DateFormat('dd MMM yyyy, HH:mm').format(ticket.entryTime),
                ),
                if (ticket.exitTime != null)
                  _buildInfoRow(
                    'Exit Time',
                    DateFormat('dd MMM yyyy, HH:mm').format(ticket.exitTime!),
                  ),
                _buildInfoRow(
                  'Duration',
                  _formatDuration(ticket.getParkingDuration()),
                ),
              ],
            ),

            // Payment Information
            _buildSection(
              'Payment Information',
              [
                _buildInfoRow(
                  'Amount',
                  currencyFormat.format(ticket.amount),
                  highlighted: true,
                  color: theme.colorScheme.primary,
                ),
                _buildInfoRow(
                  'Payment Type',
                  ticket.paymentType.toString().split('.').last,
                ),
                _buildInfoRow(
                  'Payment Status',
                  ticket.paymentStatus.toString().split('.').last,
                  highlighted: true,
                  color: _getPaymentStatusColor(ticket.paymentStatus, theme),
                ),
              ],
            ),

            const SizedBox(height: 24),
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

  Color _getStatusColor(TicketStatus status, ThemeData theme) {
    switch (status) {
      case TicketStatus.pending:
        return Colors.orange;
      case TicketStatus.active:
        return theme.colorScheme.primary;
      case TicketStatus.completed:
        return Colors.green;
      case TicketStatus.cancelled:
        return Colors.red;
    }
  }

  Color _getPaymentStatusColor(PaymentStatus status, ThemeData theme) {
    switch (status) {
      case PaymentStatus.unpaid:
        return Colors.red;
      case PaymentStatus.pending:
        return Colors.orange;
      case PaymentStatus.paid:
        return Colors.green;
      case PaymentStatus.failed:
        return Colors.red;
    }
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    return '$hours h ${minutes.toString().padLeft(2, '0')} m';
  }
}
