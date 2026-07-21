// lib/features/driver/presentation/pages/driver_bills_page.dart

import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:parkirin/features/authentication/domain/entities/user_model.dart';
import 'package:parkirin/features/driver/presentation/bloc/pending_bills_bloc.dart';
import 'package:parkirin/features/driver/presentation/bloc/pending_bills_event.dart';
import 'package:parkirin/features/driver/presentation/bloc/pending_bills_state.dart';
import 'package:parkirin/features/driver/presentation/pages/driver_ticket_detail_page.dart';
import 'package:parkirin/features/driver/widgets/driver_appbar.dart';
import 'package:parkirin/features/ticket_management/domain/entities/ticket.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class DriverBillsPage extends StatefulWidget {
  final String userId;
  final UserModel currentUser;

  const DriverBillsPage({
    super.key,
    required this.userId,
    required this.currentUser,
  });

  @override
  State<DriverBillsPage> createState() => _DriverBillsPageState();
}

class _DriverBillsPageState extends State<DriverBillsPage> {
  final _refreshController = RefreshController(initialRefresh: false);
  Timer? _refreshTimer;
  int _currentPage = 0;
  static const int itemsPerPage = 3;

  @override
  void initState() {
    super.initState();
    _loadPendingBills();

    // Set up automatic refresh every 30 seconds
    _refreshTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted) {
        context
            .read<PendingBillsBloc>()
            .add(RefreshPendingBills(widget.userId));
      }
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _refreshController.dispose();
    super.dispose();
  }

  void _loadPendingBills() {
    context.read<PendingBillsBloc>().add(LoadPendingBills(widget.userId));
  }

  Future<void> _onRefresh() async {
    // Call refresh event
    context.read<PendingBillsBloc>().add(RefreshPendingBills(widget.userId));

    // Add a timeout to ensure refresh indicator doesn't stay forever
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      _refreshController.refreshCompleted();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currencyFormat = NumberFormat.currency(
      locale: 'id',
      symbol: 'Rp',
      decimalDigits: 0,
    );

    return Scaffold(
      appBar: DriverAppBar(
        title: "Pending Bills",
        showLogout: true,
        showNotification: true,
      ),
      body: BlocConsumer<PendingBillsBloc, PendingBillsState>(
        listener: (context, state) {
          if (state is PendingBillsError) {
            _refreshController.refreshFailed();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: theme.colorScheme.error,
              ),
            );
          } else if (state is PendingBillsLoaded) {
            _refreshController.refreshCompleted();
          }
        },
        builder: (context, state) {
          if (state is PendingBillsLoading && state is! PendingBillsLoaded) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is PendingBillsLoaded) {
            if (state.tickets.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.receipt_long_outlined,
                      size: 64,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No pending bills',
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: _onRefresh,
                      child: const Text('Refresh'),
                    ),
                  ],
                ),
              );
            }

            final totalPages = (state.tickets.length / itemsPerPage).ceil();
            return SmartRefresher(
              controller: _refreshController,
              onRefresh: _onRefresh,
              child: Column(
                children: [
                  Expanded(
                    child: Container(
                      color: theme.scaffoldBackgroundColor,
                      child: ListView.builder(
                        // Disable scrolling on ListView
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true, // Add this
                        padding: const EdgeInsets.all(16),
                        itemCount: min(
                            itemsPerPage,
                            state.tickets.length -
                                (_currentPage * itemsPerPage)),
                        itemBuilder: (context, index) {
                          final itemIndex =
                              (_currentPage * itemsPerPage) + index;
                          if (itemIndex >= state.tickets.length) {
                            return const SizedBox.shrink();
                          }

                          final ticket = state.tickets[itemIndex];
                          return _buildTicketCard(
                              theme, ticket, currencyFormat);
                        },
                      ),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 16),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: theme.shadowColor.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton.filled(
                          icon: const Icon(Icons.chevron_left),
                          onPressed: _currentPage > 0
                              ? () => setState(() => _currentPage--)
                              : null,
                          style: IconButton.styleFrom(
                            backgroundColor: _currentPage > 0
                                ? theme.colorScheme.primary
                                : theme.colorScheme.surfaceContainerHighest,
                            foregroundColor: _currentPage > 0
                                ? theme.colorScheme.onPrimary
                                : theme.colorScheme.onSurfaceVariant,
                            padding: const EdgeInsets.all(12),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Text(
                            '${_currentPage + 1} / $totalPages',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        IconButton.filled(
                          icon: const Icon(Icons.chevron_right),
                          onPressed: _currentPage < totalPages - 1
                              ? () => setState(() => _currentPage++)
                              : null,
                          style: IconButton.styleFrom(
                            backgroundColor: _currentPage < totalPages - 1
                                ? theme.colorScheme.primary
                                : theme.colorScheme.surfaceContainerHighest,
                            foregroundColor: _currentPage < totalPages - 1
                                ? theme.colorScheme.onPrimary
                                : theme.colorScheme.onSurfaceVariant,
                            padding: const EdgeInsets.all(12),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }

          return const Center(child: Text('Something went wrong'));
        },
      ),
    );
  }

  // Rest of the _buildTicketCard method remains unchanged
  Widget _buildTicketCard(
      ThemeData theme, Ticket ticket, NumberFormat currencyFormat) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Card(
        elevation: 0,
        color: theme.colorScheme.secondary.withOpacity(0.085),
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
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => TicketDetailPage(
                  ticketId: ticket.id,
                  currentUser: widget.currentUser,
                ),
              ),
            ),
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surface.withOpacity(0.8),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.directions_car,
                              color: theme.colorScheme.secondary,
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
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surface.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'Pending',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.secondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
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
                          color: theme.colorScheme.secondary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surface.withOpacity(0.8),
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
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
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
          ),
        ),
      ),
    );
  }
}
