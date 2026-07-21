// lib/features/ticket_management/presentation/pages/ticket_detail_page.dart

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:parkirin/di/dependency_injection.dart';
import 'package:parkirin/features/authentication/domain/entities/user_model.dart';
import 'package:parkirin/features/payment/data/services/midtrans_service.dart';
import 'package:parkirin/features/payment/data/services/payment_status_checker.dart';
import 'package:parkirin/features/payment/domain/entities/payment.dart';
import 'package:parkirin/features/payment/domain/repositories/i_payment_repository.dart';
import 'package:parkirin/features/payment/presentation/bloc/payment_bloc.dart';
import 'package:parkirin/features/payment/presentation/bloc/payment_event.dart';
import 'package:parkirin/features/payment/presentation/bloc/payment_state.dart';
import 'package:parkirin/features/ticket_management/domain/entities/ticket.dart';
import 'package:parkirin/features/ticket_management/presentation/bloc/ticket_bloc.dart';
import 'package:parkirin/features/ticket_management/presentation/bloc/ticket_event.dart';
import 'package:parkirin/features/ticket_management/presentation/bloc/ticket_state.dart';
import 'package:parkirin/features/ticket_management/presentation/widgets/ticket_info_row.dart';
import 'package:url_launcher/url_launcher.dart';

class SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;

  const SectionHeader({
    required this.title,
    required this.icon,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(
          icon,
          color: theme.colorScheme.primary,
          size: 20,
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

///*********************************************
/// Main Page Widget
///*********************************************

class TicketDetailPage extends StatefulWidget {
  final String ticketId;
  final UserModel currentUser;

  const TicketDetailPage({
    super.key,
    required this.ticketId,
    required this.currentUser,
  });

  @override
  State<TicketDetailPage> createState() => _TicketDetailPageState();
}

class _TicketDetailPageState extends State<TicketDetailPage> {
  UserModel get _currentUser => widget.currentUser;
  Timer? _timer;
  bool _isLoadingDialogShowing = false;
  final PaymentStatusChecker _paymentStatusChecker;

  _TicketDetailPageState()
      : _paymentStatusChecker = PaymentStatusChecker(
          paymentRepository: getIt<IPaymentRepository>(),
          midtransService: getIt<MidtransService>(),
        );

  @override
  void initState() {
    super.initState();
    final currentState = context.read<TicketBloc>().state;
    if (currentState is! TicketsLoaded ||
        !currentState.tickets.any((t) => t.id == widget.ticketId)) {
      context.read<TicketBloc>().add(LoadTicketDetail(widget.ticketId));
    }
  }

  void _initiatePayment(BuildContext context, dynamic ticket) {
    context.read<PaymentBloc>().add(
          CreatePayment(
            ticketId: ticket.id,
            userId: _currentUser.id,
            amount: ticket.amount,
            itemName: 'Parking Ticket - ${ticket.vehiclePlateNumber}',
          ),
        );
  }

  void _showPaymentPage(BuildContext context, Payment payment) async {
    if (payment.paymentUrl == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Payment URL not available')),
      );
      return;
    }

    final uri = Uri.parse(payment.paymentUrl!);
    if (await canLaunchUrl(uri)) {
      // Cancel any existing timer first
      _stopPaymentStatusCheck();

      // Start checking payment status before launching URL
      _paymentStatusChecker.startChecking(
        paymentId: payment.id,
        ticketId: payment.ticketId,
        onStatusUpdate: (status) {
          if (!context.mounted) return;

          if (status == PaymentStatus.paid) {
            context.read<PaymentBloc>().add(
                  ProcessPaymentCompletion(
                    paymentId: payment.id,
                    ticketId: payment.ticketId,
                    status: status,
                  ),
                );
          }
        },
        onComplete: () {
          _stopPaymentStatusCheck();
        },
      );

      // Launch the URL
      await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not launch payment page')),
        );
      }
    }
  }

// Add this method to stop the timer
  void _stopPaymentStatusCheck() {
    _timer?.cancel();
    _timer = null;
  }

  Future<void> _openMaps(double lat, double lng) async {
    final uri =
        Uri.parse('https://www.google.com/maps/search/?api=1&query=$lat,$lng');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    return '${hours}h ${minutes}m';
  }

  Widget _buildAmountCard(
    BuildContext context,
    dynamic ticket,
    NumberFormat currencyFormat,
    ThemeData theme,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.onSecondary,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Amount Due',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.8),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  ticket.status.toString().split('.').last.toUpperCase(),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            currencyFormat.format(ticket.amount),
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context, dynamic ticket, ThemeData theme) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        color: theme.colorScheme.onSecondary,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Vehicle Information Section
          const SectionHeader(
            title: 'Vehicle Information',
            icon: Icons.directions_car_filled,
          ),
          const SizedBox(height: 12),
          TicketInfoRow(
            icon: Icons.directions_car,
            label: 'License Plate',
            value: ticket.vehiclePlateNumber,
          ),
          TicketInfoRow(
            icon: Icons.category,
            label: 'Vehicle Type',
            value: ticket.vehicleType,
          ),

          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Divider(),
          ),

          // Location Information Section
          const SectionHeader(
            title: 'Location',
            icon: Icons.location_on,
          ),
          const SizedBox(height: 12),
          Text(
            ticket.locationName,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          TextButton.icon(
            onPressed: () => _openMaps(
              ticket.latitude,
              ticket.longitude,
            ),
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              alignment: Alignment.centerLeft,
            ),
            icon: Icon(
              Icons.directions,
              size: 18,
              color: theme.colorScheme.primary,
            ),
            label: Text(
              'Get Directions',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.primary,
              ),
            ),
          ),

          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Divider(),
          ),

          // Time Information Section
          const SectionHeader(
            title: 'Time Information',
            icon: Icons.access_time,
          ),
          const SizedBox(height: 12),
          TicketInfoRow(
            icon: Icons.access_time,
            label: 'Entry Time',
            value: DateFormat('dd MMM yyyy, HH:mm').format(ticket.entryTime),
          ),
          if (ticket.exitTime != null)
            TicketInfoRow(
              icon: Icons.exit_to_app,
              label: 'Exit Time',
              value: DateFormat('dd MMM yyyy, HH:mm').format(ticket.exitTime!),
            ),
          TicketInfoRow(
            icon: Icons.timer,
            label: 'Duration',
            value: _formatDuration(ticket.getParkingDuration()),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentCard(
    BuildContext context,
    dynamic ticket,
    NumberFormat currencyFormat,
    ThemeData theme,
  ) {
    return BlocListener<PaymentBloc, PaymentState>(
      listener: (context, state) {
        if (state is PaymentLoading) {
          // Show loading indicator
          if (!_isLoadingDialogShowing) {
            _isLoadingDialogShowing = true;
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) => Center(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const CircularProgressIndicator(),
                        const SizedBox(height: 16),
                        Text(
                          state.message,
                          style: theme.textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }
        } else {
          // Hide loading dialog if it's showing
          if (_isLoadingDialogShowing) {
            Navigator.of(context).pop();
            _isLoadingDialogShowing = false;
          }

          if (state is PaymentError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.error),
                backgroundColor: theme.colorScheme.error,
              ),
            );
          } else if (state is PaymentCreated) {
            _showPaymentPage(context, state.payment);
          } else if (state is PaymentCompleted ||
              state is RedemptionCompleted) {
            // Stop checking payment status
            _stopPaymentStatusCheck();

            // Refresh ticket details
            context.read<TicketBloc>().add(LoadTicketDetail(widget.ticketId));

            // Show success message
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Payment completed successfully'),
                backgroundColor: Colors.green,
              ),
            );
          }
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          boxShadow: [
            BoxShadow(
              color: theme.shadowColor.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 36),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Pay Now Button
              FilledButton.icon(
                onPressed: ticket.status == TicketStatus.pending
                    ? () => _initiatePayment(context, ticket)
                    : null,
                style: FilledButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.payment),
                label: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Pay Now',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.onPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      currencyFormat.format(ticket.amount),
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.onPrimary,
                      ),
                    ),
                  ],
                ),
              ),

              // Free Parking Option
              if (_currentUser.freeParkingChances > 0 &&
                  ticket.status == TicketStatus.pending) ...[
                const SizedBox(height: 12),
                SizedBox(
                  height: 48,
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () {
                      // Implement redeem logic
                      _redeemFreeParkingChance(context, ticket);
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: theme.colorScheme.secondary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Icon on the left
                        const Align(
                          alignment: Alignment.centerLeft,
                          child: Icon(Icons.local_parking_rounded),
                        ),
                        // Centered text with left margin
                        Padding(
                          padding: const EdgeInsets.only(left: 24),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Use Free Parking',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  color: theme.colorScheme.onSecondary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                '${_currentUser.freeParkingChances} available',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],

              // Payment Methods Info
              const SizedBox(height: 12),
              if (ticket.status == TicketStatus.pending)
                Text(
                  'Pay securely using our payment gateway or redeem your free parking ticket.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                )
              else
                Row(
                  children: [
                    Icon(
                      ticket.status == TicketStatus.completed
                          ? Icons.check_circle_outline
                          : Icons.info_outline,
                      size: 18,
                      color: ticket.status == TicketStatus.completed
                          ? Colors.green
                          : theme.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        ticket.status == TicketStatus.completed
                            ? 'Payment completed'
                            : 'Ticket ${ticket.status.toString().split('.').last}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: ticket.status == TicketStatus.completed
                              ? Colors.green
                              : theme.colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentMethodIcon(
      String iconPath, String label, ThemeData theme) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(
          iconPath,
          width: 32,
          height: 32,
          color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant.withOpacity(0.7),
          ),
        ),
      ],
    );
  }

  void _redeemFreeParkingChance(BuildContext context, Ticket ticket) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Redeem Free Parking'),
        content: Text(
          'Are you sure you want to use 1 free parking chance for this ticket?\n\n'
          'You currently have ${_currentUser.freeParkingChances} chances remaining.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<PaymentBloc>().add(
                    RedeemFreeParking(
                      userId: _currentUser.id,
                      ticketId: ticket.id,
                    ),
                  );
            },
            child: const Text('Redeem'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _stopPaymentStatusCheck();
    _paymentStatusChecker.dispose();
    super.dispose();
  }

  ///*********************************************
  /// Build Method
  ///*********************************************

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currencyFormat = NumberFormat.currency(
      locale: 'id',
      symbol: 'Rp',
      decimalDigits: 0,
    );

    return BlocBuilder<TicketBloc, TicketState>(
      builder: (context, state) {
        ///*********************************************
        /// Loading State
        ///*********************************************
        if (state is TicketLoading) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Ticket Details'),
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
            ),
            body: const Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        ///*********************************************
        /// Error State
        ///*********************************************
        if (state is TicketError) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Ticket Details'),
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
            ),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 48,
                    color: theme.colorScheme.error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading ticket details',
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () {
                      context
                          .read<TicketBloc>()
                          .add(LoadTicketDetail(widget.ticketId));
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }

        ///*********************************************
        /// Success State
        ///*********************************************
        if (state is TicketsLoaded) {
          try {
            final ticket = state.tickets.firstWhere(
              (t) => t.id == widget.ticketId,
            );

            return Scaffold(
              appBar: AppBar(
                title: const Text('Ticket Details'),
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
                actions: [
                  IconButton(
                    icon: const Icon(Icons.share),
                    onPressed: () {
                      // Implement share functionality
                    },
                  ),
                ],
              ),
              body: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ///*********************************************
                          /// Header Section
                          ///*********************************************
                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  theme.colorScheme.primary,
                                  theme.colorScheme.primary,
                                ],
                              ),
                              borderRadius: const BorderRadius.vertical(
                                bottom: Radius.circular(32),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Ticket ID',
                                          style: theme.textTheme.bodySmall
                                              ?.copyWith(
                                            color: theme.colorScheme.onPrimary
                                                .withOpacity(0.8),
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          ticket.id,
                                          style: theme.textTheme.titleMedium
                                              ?.copyWith(
                                            color: theme.colorScheme.onPrimary,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16, vertical: 8),
                                      decoration: BoxDecoration(
                                        color: theme.colorScheme.onPrimary
                                            .withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.timer,
                                            size: 18,
                                            color: theme.colorScheme.onPrimary,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            _formatDuration(
                                                ticket.getParkingDuration()),
                                            style: theme.textTheme.bodyMedium
                                                ?.copyWith(
                                              color:
                                                  theme.colorScheme.onPrimary,
                                              fontWeight: FontWeight.bold,
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

                          ///*********************************************
                          /// Amount Card
                          ///*********************************************
                          _buildAmountCard(
                              context, ticket, currencyFormat, theme),

                          ///*********************************************
                          /// Combined Info Card
                          ///*********************************************
                          _buildInfoCard(context, ticket, theme),

                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),

                  ///*********************************************
                  /// Payment Card at Bottom
                  ///*********************************************
                  _buildPaymentCard(context, ticket, currencyFormat, theme),
                ],
              ),
            );
          } catch (e) {
            ///*********************************************
            /// Error Fallback
            ///*********************************************
            return Scaffold(
              appBar: AppBar(
                title: const Text('Ticket Details'),
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
              ),
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 48,
                      color: theme.colorScheme.error,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Ticket not found',
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Go Back'),
                    ),
                  ],
                ),
              ),
            );
          }
        }

        ///*********************************************
        /// Default Loading State
        ///*********************************************
        return Scaffold(
          appBar: AppBar(
            title: const Text('Ticket Details'),
            backgroundColor: theme.colorScheme.primary,
            foregroundColor: theme.colorScheme.onPrimary,
          ),
          body: const Center(
            child: CircularProgressIndicator(),
          ),
        );
      },
    );
  }
}
