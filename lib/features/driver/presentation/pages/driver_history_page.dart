// lib/features/ticket_management/presentation/pages/ticket_list_page.dart

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:parkirin/features/authentication/domain/entities/user_model.dart';
import 'package:parkirin/features/driver/widgets/driver_appbar.dart';
import 'package:parkirin/features/ticket_management/domain/entities/ticket.dart';
import 'package:parkirin/features/ticket_management/presentation/bloc/ticket_bloc.dart';
import 'package:parkirin/features/ticket_management/presentation/bloc/ticket_event.dart';
import 'package:parkirin/features/ticket_management/presentation/bloc/ticket_state.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'driver_ticket_detail_page.dart';

class TicketListPage extends StatefulWidget {
  final String userId;
  final UserModel currentUser;

  const TicketListPage({
    super.key,
    required this.userId,
    required this.currentUser,
  });

  @override
  State<TicketListPage> createState() => _TicketListPageState();
}

class _TicketListPageState extends State<TicketListPage>
    with SingleTickerProviderStateMixin {
  final _refreshController = RefreshController(initialRefresh: false);
  DateTime? _selectedStartDate;
  DateTime? _selectedEndDate;
  final _searchController = TextEditingController();
  late TabController _tabController;
  int _currentPage = 0;
  static const int itemsPerPage = 2;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        // Reset pagination when switching tabs
        setState(() {
          _currentPage = 0; // Reset to first page when switching tabs
        });
        _loadTicketsWithFilter();
      }
    });
    _loadTickets();
  }

  void setPage(int page, int totalItems) {
    // Calculate max possible pages based on total items
    final totalPages = (totalItems / itemsPerPage).ceil();
    setState(() {
      // Ensure page is between 0 and max pages
      _currentPage = max(0, min(page, max(0, totalPages - 1)));
    });
  }

  @override
  void dispose() {
    _refreshController.dispose();
    _searchController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _loadTickets() {
    context.read<TicketBloc>().add(LoadUserTickets(widget.userId));
  }

  void _loadTicketsWithFilter() {
    final status = _getCurrentStatus();
    if (_selectedStartDate != null && _selectedEndDate != null) {
      context.read<TicketBloc>().add(
            LoadTicketsByDateRange(
              userId: widget.userId,
              startDate: _selectedStartDate!,
              endDate: _selectedEndDate!,
            ),
          );
    } else {
      context.read<TicketBloc>().add(
            SearchTickets(
              userId: widget.userId,
              status: status,
            ),
          );
    }
  }

  TicketStatus? _getCurrentStatus() {
    switch (_tabController.index) {
      case 0:
        return TicketStatus.pending;
      case 1:
        return TicketStatus.completed;
      case 2:
        return null; // All tickets
      default:
        return null;
    }
  }

  Future<void> _onRefresh() async {
    _loadTickets();
    _refreshController.refreshCompleted();
  }

  Widget _buildTicketCard(Ticket ticket) {
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
    Color getStatusColor() {
      switch (ticket.status) {
        case TicketStatus.pending:
          return theme.colorScheme.secondary;
        case TicketStatus.active:
          return theme.colorScheme.primary;
        case TicketStatus.completed:
          return theme.colorScheme.primary;
        case TicketStatus.cancelled:
          return theme.colorScheme.error;
      }
    }

    final cardColor = getStatusColor();

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Card(
        elevation: 0,
        color: cardColor.withOpacity(0.1),
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
                  currentUser: widget.currentUser, // Use widget.currentUser
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
                      // Plate Number with Icon
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surface.withOpacity(0.8),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              getVehicleIcon(
                                  ticket.vehicleType), // Update this line
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
                          ticket.status.toString().split('.').last,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: cardColor,
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
                          color: cardColor,
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: DriverAppBar(
        title: ("History"),
        showLogout: true,
        showNotification: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(120),
          child: Column(
            children: [
              TabBar(
                controller: _tabController,
                isScrollable: true,
                labelColor: theme.colorScheme.onPrimary,
                unselectedLabelColor: theme.colorScheme.onSurfaceVariant,
                indicator: BoxDecoration(
                  borderRadius: BorderRadius.circular(50),
                  color: theme.colorScheme.primary,
                ),
                dividerColor: Colors.transparent,
                padding: EdgeInsets.zero, // Remove default padding
                tabAlignment: TabAlignment.center, // Center align the tabs
                tabs: [
                  _buildTab('Pending', Icons.pending_actions),
                  _buildTab('Completed', Icons.check_circle),
                  _buildTab('All', Icons.list_alt),
                ],
              ),
              Container(
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  border: Border(
                    bottom: BorderSide(
                      color: theme.colorScheme.outline.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    if (_selectedStartDate != null && _selectedEndDate != null)
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
                      onPressed: () async {
                        final picked = await showDateRangePicker(
                          context: context,
                          firstDate: DateTime(2020),
                          lastDate: DateTime.now(),
                          initialDateRange: _selectedStartDate != null &&
                                  _selectedEndDate != null
                              ? DateTimeRange(
                                  start: _selectedStartDate!,
                                  end: _selectedEndDate!,
                                )
                              : null,
                        );
                        if (picked != null) {
                          setState(() {
                            _selectedStartDate = picked.start;
                            _selectedEndDate = picked.end;
                          });
                          _loadTicketsWithFilter();
                        }
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.restart_alt),
                      onPressed: () {
                        setState(() {
                          _selectedStartDate = null;
                          _selectedEndDate = null;
                        });
                        _loadTicketsWithFilter();
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      body: BlocConsumer<TicketBloc, TicketState>(
        listener: (context, state) {
          if (state is TicketError) {
            _refreshController.refreshFailed();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: theme.colorScheme.error,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is TicketLoading && state is! TicketsLoaded) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is TicketsLoaded && state.tickets.isEmpty) {
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
                  const Text('No tickets found'),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton(
                        onPressed: _loadTickets,
                        child: const Text('Refresh'),
                      ),
                      const SizedBox(width: 8),
                      // Only show this button in debug mode
                    ],
                  ),
                ],
              ),
            );
          }

          if (state is TicketsLoaded) {
            // Filter tickets based on current tab
            final filteredTickets = _filterTicketsByCurrentTab(state.tickets);
            final totalPages = (filteredTickets.length / itemsPerPage).ceil();

            return SmartRefresher(
              controller: _refreshController,
              onRefresh: _onRefresh,
              child: Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      // Calculate itemCount based on filtered tickets
                      itemCount: max(
                          0,
                          min(
                              itemsPerPage,
                              filteredTickets.length -
                                  (_currentPage * itemsPerPage))),
                      itemBuilder: (context, index) {
                        final itemIndex = (_currentPage * itemsPerPage) + index;
                        if (itemIndex >= filteredTickets.length) {
                          return const SizedBox.shrink();
                        }

                        final ticket = filteredTickets[itemIndex];
                        return _buildTicketCard(ticket);
                      },
                    ),
                  ),

                  // Pagination
                  if (totalPages > 1)
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
                                ? () => setPage(
                                    _currentPage - 1, filteredTickets.length)
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
                                ? () => setPage(
                                    _currentPage + 1, filteredTickets.length)
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

  List<Ticket> _filterTicketsByCurrentTab(List<Ticket> tickets) {
    final status = _getCurrentStatus();
    if (status == null) {
      return tickets; // Return all tickets if status is null (All tab)
    }
    return tickets.where((ticket) => ticket.status == status).toList();
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
}
