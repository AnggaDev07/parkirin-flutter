// lib/features/ticket_management/presentation/widgets/ticket_status_badge.dart

import 'package:flutter/material.dart';
import 'package:parkirin/features/ticket_management/domain/entities/ticket.dart';

class TicketStatusBadge extends StatelessWidget {
  final TicketStatus status;
  final double? scale;

  const TicketStatusBadge({
    super.key,
    required this.status,
    this.scale = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Color getStatusColor() {
      switch (status) {
        case TicketStatus.active:
          return theme.colorScheme.primary;
        case TicketStatus.completed:
          return theme.colorScheme.tertiary;
        case TicketStatus.cancelled:
          return theme.colorScheme.error;
        case TicketStatus.pending:
          return theme.colorScheme.secondary;
      }
    }

    String getStatusText() {
      switch (status) {
        case TicketStatus.active:
          return 'Active';
        case TicketStatus.completed:
          return 'Completed';
        case TicketStatus.cancelled:
          return 'Cancelled';
        case TicketStatus.pending:
          return 'Pending';
      }
    }

    final color = getStatusColor();
    final baseSize = scale ?? 1.0;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 12 * baseSize,
        vertical: 6 * baseSize,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20 * baseSize),
        border: Border.all(
          color: color.withOpacity(0.2),
        ),
      ),
      child: Text(
        getStatusText(),
        style: theme.textTheme.bodySmall?.copyWith(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: (12 * baseSize),
        ),
      ),
    );
  }
}
