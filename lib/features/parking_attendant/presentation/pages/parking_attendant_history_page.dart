import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:parkirin/di/dependency_injection.dart';
import 'package:parkirin/features/parking_attendant/presentation/widgets/parking_attendant_appbar.dart';
import 'package:parkirin/features/ticket_management/domain/entities/parking_record.dart';
import 'package:parkirin/features/ticket_management/domain/entities/ticket.dart';
import 'package:parkirin/features/ticket_management/presentation/bloc/edit_ticket_bloc.dart';
import 'package:parkirin/features/ticket_management/presentation/bloc/ticket_bloc.dart';
import 'package:parkirin/features/ticket_management/presentation/bloc/ticket_event.dart';
import 'package:parkirin/features/ticket_management/presentation/bloc/ticket_state.dart';
import 'package:parkirin/features/ticket_management/presentation/widgets/parking_record_card.dart';
import 'package:parkirin/features/ticket_management/presentation/widgets/parking_record_details_dialog.dart';
import 'package:parkirin/features/ticket_management/presentation/widgets/ticket_card.dart';
import 'package:parkirin/features/ticket_management/presentation/widgets/ticket_details_dialog.dart';

class AttendantTicketHistoryPage extends StatelessWidget {
  final String attendantId;

  const AttendantTicketHistoryPage({
    super.key,
    required this.attendantId,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<TicketBloc>(
          create: (context) => getIt<TicketBloc>(),
        ),
        BlocProvider<EditTicketBloc>(
          create: (context) => getIt<EditTicketBloc>(),
        ),
      ],
      child: _AttendantTicketHistoryContent(
        attendantId: attendantId,
      ),
    );
  }
}

class _AttendantTicketHistoryContent extends StatefulWidget {
  final String attendantId;

  const _AttendantTicketHistoryContent({
    required this.attendantId,
  });

  @override
  State<_AttendantTicketHistoryContent> createState() =>
      _AttendantTicketHistoryContentState();
}

class _AttendantTicketHistoryContentState
    extends State<_AttendantTicketHistoryContent>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late TextEditingController _searchController;
  DateTime? _selectedStartDate;
  DateTime? _selectedEndDate;
  int _currentPage = 0;
  Timer? _refreshTimer;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        _loadTickets();
      }
    });
    _searchController = TextEditingController();
    _loadTickets();
    _startAutoRefresh();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Reload tickets when returning to this page
    _loadTickets();
  }

  void _startAutoRefresh() {
    // Cancel any existing timer
    _refreshTimer?.cancel();

    // Set up periodic refresh every 30 seconds
    _refreshTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (mounted) {
        _loadTickets();
      }
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _showRecordDetails(BuildContext context, ParkingRecord record) {
    showDialog(
      context: context,
      builder: (context) => ParkingRecordDetailsDialog(record: record),
    );
  }

  void _showTicketDetails(BuildContext context, Ticket ticket) {
    showDialog(
      context: context,
      builder: (context) => TicketDetailsDialog(ticket: ticket),
    );
  }

  Future<void> _loadTickets() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _currentPage = 0;
    });

    try {
      if (_tabController.index == 4) {
        // Records tab
        context.read<TicketBloc>().add(
              LoadParkingRecords(
                attendantId: widget.attendantId,
                startDate: _selectedStartDate,
                endDate: _selectedEndDate,
              ),
            );
      } else {
        // Regular tickets
        final status = _getCurrentStatus();
        final paymentType = _getCurrentPaymentType();

        context.read<TicketBloc>().add(
              LoadAttendantTickets(
                attendantId: widget.attendantId,
                status: status,
                paymentType: paymentType,
                startDate: _selectedStartDate,
                endDate: _selectedEndDate,
                excludeCompleted:
                    _tabController.index == 1 || _tabController.index == 2,
              ),
            );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  TicketStatus? _getCurrentStatus() {
    switch (_tabController.index) {
      case 0: // Pending tab
        return TicketStatus.pending;
      case 1: // Cash tab
        return null;
      case 2: // Cashless tab
        return null;
      case 3: // Completed tab
        return TicketStatus.completed;
      default:
        return TicketStatus.pending;
    }
  }

  PaymentType? _getCurrentPaymentType() {
    switch (_tabController.index) {
      case 1: // Cash tab
        return PaymentType.cash;
      case 2: // Cashless tab
        return PaymentType.cashless;
      default:
        return null;
    }
  }

  Future<void> _showDateRangePicker() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: _selectedStartDate != null && _selectedEndDate != null
          ? DateTimeRange(
              start: _selectedStartDate!,
              end: _selectedEndDate!,
            )
          : null,
    );

    if (picked != null && mounted) {
      setState(() {
        _selectedStartDate = picked.start;
        _selectedEndDate = picked.end;
      });
      _loadTickets();
    }
  }

  void _clearFilters() {
    setState(() {
      _selectedStartDate = null;
      _selectedEndDate = null;
      _searchController.clear();
    });
    _loadTickets();
  }

  TabBar get _customTabBar {
    final theme = Theme.of(context);

    return TabBar(
      controller: _tabController,
      onTap: (index) => _loadTickets(),
      isScrollable: true,
      labelColor: theme.colorScheme.onPrimary,
      unselectedLabelColor: theme.colorScheme.onSurfaceVariant,
      indicator: BoxDecoration(
        borderRadius: BorderRadius.circular(50),
        color: theme.colorScheme.primary.withOpacity(1),
      ),
      overlayColor: WidgetStateProperty.resolveWith<Color>((states) {
        return Colors.transparent;
      }),
      tabAlignment: TabAlignment.center,
      labelStyle: const TextStyle(
        fontWeight: FontWeight.w600,
      ),
      unselectedLabelStyle: const TextStyle(
        fontWeight: FontWeight.w500,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      indicatorSize: TabBarIndicatorSize.tab,
      dividerColor: Colors.transparent,
      tabs: [
        _buildTab('Pending', Icons.pending_actions),
        _buildTab('Cash', Icons.payments),
        _buildTab('Cashless', Icons.credit_card),
        _buildTab('Completed', Icons.check_circle),
        _buildTab('Records', Icons.receipt_long),
      ],
    );
  }

  Widget _buildTab(String label, IconData icon) {
    return Tab(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18),
            const SizedBox(width: 8),
            Text(label),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocListener<TicketBloc, TicketState>(
      listener: (context, state) {
        if (state is TicketError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: theme.colorScheme.error,
            ),
          );
        }
      },
      child: Scaffold(
        appBar: ParkingAttendantAppBar(
          title: 'Tickets',
          showLogout: true,
          showNotification: true,
        ),
        body: RefreshIndicator(
          onRefresh: _loadTickets,
          child: SafeArea(
            child: Column(
              children: [
                // Tab Bar Section
                Container(
                  color: theme.colorScheme.surface,
                  child: _customTabBar,
                ),

                // Filter Section
                Container(
                  color: theme.colorScheme.surface,
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          if (_selectedStartDate != null &&
                              _selectedEndDate != null)
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(left: 16),
                                child: Text(
                                  '${DateFormat('dd MMM yyyy').format(_selectedStartDate!)} - '
                                  '${DateFormat('dd MMM yyyy').format(_selectedEndDate!)}',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            )
                          else
                            const Spacer(),
                          IconButton(
                            icon: const Icon(Icons.date_range),
                            onPressed: _showDateRangePicker,
                          ),
                          IconButton(
                            icon: const Icon(Icons.restart_alt),
                            onPressed: _clearFilters,
                          ),
                        ],
                      ),
                      Divider(
                        height: 1,
                        thickness: 1,
                        color: theme.colorScheme.outlineVariant,
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),

                // Main Content Section
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: BlocBuilder<TicketBloc, TicketState>(
                      builder: (context, state) {
                        if (state is TicketLoading || _isLoading) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }

                        if (state is TicketError) {
                          return Center(child: Text(state.message));
                        }

                        final items = state is TicketsLoaded
                            ? state.tickets
                            : state is ParkingRecordsLoaded
                                ? state.records
                                : [];

                        if (items.isEmpty) {
                          return Center(
                            child: Text(
                              _tabController.index == 4
                                  ? 'No parking records found'
                                  : 'No tickets found',
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          );
                        }

                        final int totalPages = (items.length / 2).ceil();

                        return CustomScrollView(
                          slivers: [
                            SliverFillRemaining(
                              hasScrollBody: false,
                              child: Column(
                                children: [
                                  Expanded(
                                    child: Column(
                                      children: List.generate(
                                        min(2,
                                            items.length - (_currentPage * 2)),
                                        (index) {
                                          final itemIndex =
                                              (_currentPage * 2) + index;
                                          if (itemIndex >= items.length) {
                                            return const SizedBox.shrink();
                                          }

                                          final item = items[itemIndex];
                                          if (item is Ticket) {
                                            return Padding(
                                              padding: const EdgeInsets.only(
                                                  bottom: 8),
                                              child: TicketCard(
                                                ticket: item,
                                                onTap: () => _showTicketDetails(
                                                    context, item),
                                                onEdit: _loadTickets,
                                              ),
                                            );
                                          } else if (item is ParkingRecord) {
                                            return Padding(
                                              padding: const EdgeInsets.only(
                                                  bottom: 8),
                                              child: ParkingRecordCard(
                                                record: item,
                                                onTap: () => _showRecordDetails(
                                                    context, item),
                                              ),
                                            );
                                          }
                                          return const SizedBox.shrink();
                                        },
                                      ),
                                    ),
                                  ),

                                  // Pagination Controls
                                  if (totalPages > 1)
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 16),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 8,
                                        ),
                                        decoration: BoxDecoration(
                                          color: theme.colorScheme.surface,
                                          borderRadius:
                                              BorderRadius.circular(20),
                                          boxShadow: [
                                            BoxShadow(
                                              color: theme.shadowColor
                                                  .withOpacity(0.1),
                                              blurRadius: 8,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            IconButton.filled(
                                              icon: const Icon(
                                                  Icons.chevron_left),
                                              onPressed: _currentPage > 0
                                                  ? () => setState(
                                                      () => _currentPage--)
                                                  : null,
                                              style: IconButton.styleFrom(
                                                backgroundColor: _currentPage >
                                                        0
                                                    ? theme.colorScheme.primary
                                                    : theme.colorScheme
                                                        .surfaceContainerHighest,
                                                foregroundColor:
                                                    _currentPage > 0
                                                        ? theme.colorScheme
                                                            .onPrimary
                                                        : theme.colorScheme
                                                            .onSurfaceVariant,
                                                padding:
                                                    const EdgeInsets.all(12),
                                              ),
                                            ),
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 24),
                                              child: Text(
                                                '${_currentPage + 1} / $totalPages',
                                                style: theme
                                                    .textTheme.titleMedium
                                                    ?.copyWith(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                            IconButton.filled(
                                              icon: const Icon(
                                                  Icons.chevron_right),
                                              onPressed:
                                                  _currentPage < totalPages - 1
                                                      ? () => setState(
                                                          () => _currentPage++)
                                                      : null,
                                              style: IconButton.styleFrom(
                                                backgroundColor: _currentPage <
                                                        totalPages - 1
                                                    ? theme.colorScheme.primary
                                                    : theme.colorScheme
                                                        .surfaceContainerHighest,
                                                foregroundColor: _currentPage <
                                                        totalPages - 1
                                                    ? theme
                                                        .colorScheme.onPrimary
                                                    : theme.colorScheme
                                                        .onSurfaceVariant,
                                                padding:
                                                    const EdgeInsets.all(12),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
