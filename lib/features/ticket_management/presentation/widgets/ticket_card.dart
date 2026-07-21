// lib/features/ticket_management/presentation/widgets/ticket_card.dart

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:parkirin/features/ticket_management/domain/entities/ticket.dart';
import 'package:parkirin/features/ticket_management/presentation/bloc/edit_ticket_bloc.dart';
import 'package:parkirin/features/ticket_management/presentation/bloc/edit_ticket_event.dart';
import 'package:parkirin/features/ticket_management/presentation/widgets/edit_ticket_handler.dart';
import 'package:parkirin/features/ticket_management/presentation/widgets/ticket_details_dialog.dart';

class _EditButtonWithCountdown extends StatefulWidget {
  final Ticket ticket;
  final VoidCallback onPressed;

  const _EditButtonWithCountdown({
    required this.ticket,
    required this.onPressed,
  });

  @override
  State<_EditButtonWithCountdown> createState() =>
      _EditButtonWithCountdownState();
}

class _EditButtonWithCountdownState extends State<_EditButtonWithCountdown> {
  Timer? _timer;
  late Duration _timeLeft;

  @override
  void initState() {
    super.initState();
    _timeLeft = widget.ticket.remainingEditTime;
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _timeLeft = widget.ticket.remainingEditTime;
          if (_timeLeft <= Duration.zero) {
            _timer?.cancel();
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final minutes = _timeLeft.inMinutes;
    final seconds = _timeLeft.inSeconds % 60;

    if (_timeLeft <= Duration.zero) {
      return const SizedBox.shrink(); // Hide button if time expired
    }

    return TextButton.icon(
      icon: const Icon(Icons.edit, size: 16),
      label: Text(
        'Edit ($minutes:${seconds.toString().padLeft(2, '0')})',
        style: const TextStyle(fontSize: 12),
      ),
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        foregroundColor: theme.colorScheme.primary,
      ),
      onPressed: widget.onPressed,
    );
  }
}

class TicketCard extends StatelessWidget {
  final Ticket ticket;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;

  const TicketCard({
    super.key,
    required this.ticket,
    this.onTap,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currencyFormat = NumberFormat.currency(
      locale: 'id',
      symbol: 'Rp',
      decimalDigits: 0,
    );

    IconData getVehicleIcon(String vehicleType) {
      switch (vehicleType.toLowerCase()) {
        case 'motorcycle':
          return Icons.motorcycle;
        case 'truck':
          return Icons.local_shipping;
        case 'bus':
          return Icons.directions_bus;
        case 'car':
        default:
          return Icons.directions_car;
      }
    }

    // Get color based on status
    Color cardColor;
    switch (ticket.status) {
      case TicketStatus.pending:
        cardColor = theme.colorScheme.secondary.withOpacity(1);
        break;
      case TicketStatus.completed:
        cardColor = theme.colorScheme.primary;
        break;
      case TicketStatus.cancelled:
        cardColor = theme.colorScheme.error;
        break;
      default:
        cardColor = theme.colorScheme.primary;
    }

    return EditTicketHandler(
      ticket: ticket,
      onEditSuccess: onEdit,
      child: Card(
        elevation: 0,
        color: cardColor.withOpacity(0.1),
        margin: const EdgeInsets.only(bottom: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: theme.colorScheme.shadow.withOpacity(0.08),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: InkWell(
            onTap: onTap ?? () => _showTicketDetails(context),
            borderRadius: BorderRadius.circular(16),
            child: Column(
              children: [
                // Edit button section
                if (ticket.isEditable)
                  Container(
                    width: double.infinity,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: _buildEditButton(context),
                    ),
                  ),

                // Main ticket content
                Padding(
                  padding: EdgeInsets.only(
                    left: 16,
                    right: 16,
                    bottom: 16,
                    top: ticket.isEditable ? 4 : 16,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Plate Number and Status
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.surface
                                      .withOpacity(0.8),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  getVehicleIcon(ticket
                                      .vehicleType), // Use the helper method here
                                  color: cardColor,
                                  size: 18,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                ticket.vehiclePlateNumber,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          _buildStatusChip(theme, cardColor),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Time and Amount
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surface.withOpacity(0.8),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.access_time,
                                  size: 16,
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  DateFormat('dd MMM yyyy, HH:mm')
                                      .format(ticket.createdAt),
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            currencyFormat.format(ticket.amount),
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: cardColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Location and Payment Type
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color:
                                    theme.colorScheme.surface.withOpacity(0.8),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.location_on_outlined,
                                    size: 16,
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      ticket.locationName,
                                      style:
                                          theme.textTheme.bodySmall?.copyWith(
                                        color:
                                            theme.colorScheme.onSurfaceVariant,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surface.withOpacity(0.8),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  ticket.paymentType == PaymentType.cash
                                      ? Icons.money
                                      : Icons.credit_card,
                                  size: 16,
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  ticket.paymentType.toString().split('.').last,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(ThemeData theme, Color color) {
    String text;
    switch (ticket.status) {
      case TicketStatus.pending:
        text = 'Pending';
        break;
      case TicketStatus.active:
        text = 'Active';
        break;
      case TicketStatus.completed:
        text = 'Completed';
        break;
      case TicketStatus.cancelled:
        text = 'Cancelled';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withOpacity(0.8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Text(
        text,
        style: theme.textTheme.bodySmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildEditButton(BuildContext context) {
    Theme.of(context);

    return _EditButtonWithCountdown(
      ticket: ticket,
      onPressed: () {
        debugPrint('Edit button pressed for ticket: ${ticket.id}');
        context.read<EditTicketBloc>().add(ValidateEditTime(ticket.id));
      },
    );
  }

  void _showTicketDetails(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => TicketDetailsDialog(ticket: ticket),
    );
  }
}
