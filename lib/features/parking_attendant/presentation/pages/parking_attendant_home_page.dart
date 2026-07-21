import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:parkirin/di/dependency_injection.dart';
import 'package:parkirin/features/authentication/data/repositories/user_repository.dart';
import 'package:parkirin/features/authentication/domain/entities/parking_attendant_model.dart';
import 'package:parkirin/features/authentication/presentation/bloc/auth_bloc.dart';
import 'package:parkirin/features/parking_attendant/presentation/pages/parking_attendant_history_page.dart';
import 'package:parkirin/features/parking_attendant/presentation/pages/parking_attendant_profile_page.dart';
import 'package:parkirin/features/parking_attendant/presentation/pages/parking_attendant_settings_page.dart';
import 'package:parkirin/features/parking_attendant/presentation/widgets/parking_attendant_appbar.dart';
import 'package:parkirin/features/ticket_management/domain/entities/ticket.dart';
import 'package:parkirin/features/ticket_management/domain/repositories/i_parking_record_repository.dart';
import 'package:parkirin/features/ticket_management/domain/repositories/i_ticket_repository.dart';
import 'package:parkirin/features/ticket_management/presentation/bloc/ticket_bloc.dart';
import 'package:parkirin/features/ticket_management/presentation/pages/create_ticket_page.dart';
import 'package:parkirin/features/ticket_management/presentation/pages/record_parking_page.dart';
import 'package:parkirin/localization/app_localizations.dart';

class ActivityItem {
  final String id;
  final String plateNumber;
  final DateTime date;
  final double amount;
  final TicketStatus status; // Change from String to TicketStatus
  final String vehicleType;
  final PaymentType paymentType;

  const ActivityItem({
    required this.id,
    required this.plateNumber,
    required this.date,
    required this.amount,
    required this.status,
    required this.vehicleType,
    required this.paymentType,
  });

  factory ActivityItem.fromTicket(Ticket ticket) {
    return ActivityItem(
      id: ticket.id,
      plateNumber: ticket.vehiclePlateNumber,
      date: ticket.createdAt,
      amount: ticket.amount,
      status: ticket.status, // Pass the TicketStatus enum directly
      vehicleType: ticket.vehicleType,
      paymentType: ticket.paymentType,
    );
  }
}

class ParkingAttendantHomePage extends StatefulWidget {
  const ParkingAttendantHomePage({super.key});

  @override
  ParkingAttendantHomePageState createState() =>
      ParkingAttendantHomePageState();
}

class ParkingAttendantHomePageState extends State<ParkingAttendantHomePage> {
  ParkingAttendantModel? _attendantData;
  late final UserRepository _userRepository;
  StreamSubscription? _dataSubscription;
  int _selectedIndex = 0;
  List<ActivityItem> _activities = [];
  late final ITicketRepository _ticketRepository;

  // Add ticket stats
  int _totalTickets = 0;
  int _completedTickets = 0;
  int _pendingTickets = 0;

  @override
  void initState() {
    super.initState();
    _userRepository = getIt<UserRepository>();
    _ticketRepository = getIt<ITicketRepository>();
    _loadAttendantData();
  }

  Future<void> _loadTicketStats() async {
    if (_attendantData?.id == null) return;

    try {
      debugPrint('Loading stats for attendant: ${_attendantData!.id}');

      // Get ticket stats
      final allTickets = await _ticketRepository.getAttendantTickets(
        attendantId: _attendantData!.id,
      );
      debugPrint('All tickets count: ${allTickets.length}');

      final completedTickets = await _ticketRepository.getAttendantTickets(
        attendantId: _attendantData!.id,
        status: TicketStatus.completed,
      );
      debugPrint('Completed tickets count: ${completedTickets.length}');

      final pendingTickets = await _ticketRepository.getAttendantTickets(
        attendantId: _attendantData!.id,
        status: TicketStatus.pending,
      );
      debugPrint('Pending tickets count: ${pendingTickets.length}');

      // Get parking records
      final parkingRecordRepo = getIt<IParkingRecordRepository>();
      final parkingRecords = await parkingRecordRepo.getAttendantRecords(
        attendantId: _attendantData!.id,
      );
      final parkingRecordsCount = parkingRecords.length;
      debugPrint('Parking records retrieved count: $parkingRecordsCount');

      if (mounted) {
        setState(() {
          _totalTickets = allTickets.length;
          _completedTickets = completedTickets.length;
          _pendingTickets = pendingTickets.length;

          // Create new stats object with all values
          final newStats = ParkingAttendantStats(
            totalTicketsIssued: allTickets.length,
            totalTicketsPaid: completedTickets.length,
            pendingTickets: pendingTickets.length,
            totalRevenue: _attendantData?.stats.totalRevenue ?? 0,
            parkingRecordsCount: parkingRecordsCount, // Set the actual count
          );

          // Update the attendant data with new stats
          _attendantData = _attendantData?.copyWith(
            stats: newStats,
          );
        });

        debugPrint(
            'Stats updated with parkingRecordsCount: $parkingRecordsCount');
        debugPrint(
            'Verify updated stats: ${_attendantData?.stats.parkingRecordsCount}');
      }
    } catch (e, stackTrace) {
      debugPrint('Error loading ticket stats: $e');
      debugPrint('Stack trace: $stackTrace');
    }
  }

  Future<void> _loadRecentActivities() async {
    try {
      if (_attendantData?.id == null) {
        debugPrint('Cannot load activities: attendantId is null');
        return;
      }

      debugPrint(
          'Loading recent activities for attendant: ${_attendantData!.id}');
      final tickets = await _ticketRepository.getAttendantTickets(
        attendantId: _attendantData!.id,
        limit: 5,
      );

      if (mounted) {
        setState(() {
          _activities =
              tickets.map((ticket) => ActivityItem.fromTicket(ticket)).toList();
          debugPrint('Loaded ${_activities.length} recent activities');
        });
      }
    } catch (e) {
      debugPrint('Error loading recent activities: $e');
      if (mounted) {
        setState(() {
          _activities = [];
        });
        _showErrorSnackBar('Failed to load recent activities');
      }
    }
  }

  Future<void> _loadAttendantData() async {
    try {
      final authState = context.read<AuthBloc>().state;
      if (authState is AuthSuccess) {
        final nijp = authState.user.id;
        debugPrint('Loading attendant data for NIJP: $nijp');

        // Get initial data
        final attendant = await _userRepository.getParkingAttendant(nijp);
        if (mounted && attendant != null) {
          setState(() {
            _attendantData = attendant;
          });

          // Load both stats and activities
          await Future.wait([
            _loadTicketStats(),
            _loadRecentActivities(), // Add this
          ]);

          // Setup real-time updates
          _dataSubscription?.cancel();
          _dataSubscription =
              _userRepository.getParkingAttendantStream(attendant.id).listen(
            (updatedAttendant) {
              if (mounted && updatedAttendant != null) {
                setState(() {
                  _attendantData = updatedAttendant.copyWith(
                    stats: updatedAttendant.stats.copyWith(
                      parkingRecordsCount:
                          _attendantData?.stats.parkingRecordsCount ?? 0,
                    ),
                  );
                });
              }
            },
            onError: (error) {
              _showErrorSnackBar('Failed to load data: $error');
            },
          );
        }
      } else {
        Navigator.of(context).pushReplacementNamed('/login');
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('Error loading data: $e');
      }
    }
  }

  @override
  void dispose() {
    _dataSubscription?.cancel();
    super.dispose();
  }

  void _showErrorSnackBar(String message) {
    if (mounted) {
      final loc = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${loc.errorOccurred}: $message'),
          backgroundColor: Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
          action: SnackBarAction(
            label: loc.tryAgain,
            textColor: Theme.of(context).colorScheme.onError,
            onPressed: _loadAttendantData,
          ),
        ),
      );
    }
  }

  void _onBottomNavTapped(int index) {
    if (index == 2) {
      // Create Ticket
      _showCreateTicketOptions();
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  Widget _buildCurrentPage() {
    final theme = Theme.of(context);

    switch (_selectedIndex) {
      case 0: // Home
        return RefreshIndicator(
          onRefresh: _loadAttendantData,
          child: SingleChildScrollView(
            // Changed from CustomScrollView
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildGreeting(theme),
                    const SizedBox(height: 24),
                    _buildLocationCard(theme),
                    const SizedBox(height: 24),
                    _buildStatsGrid(theme),
                    const SizedBox(height: 24),
                    _buildRecentActivity(theme),
                  ],
                ),
              ),
            ),
          ),
        );

      case 1: // History
        return BlocProvider(
          create: (context) => getIt<TicketBloc>(),
          child: AttendantTicketHistoryPage(
            attendantId: _attendantData?.id ?? '',
          ),
        );

      case 2: // Create Ticket - This will be handled by _onBottomNavTapped
        return const SizedBox.shrink();

      case 3: // Profile
        return ParkingAttendantProfilePage(
          attendant: _attendantData,
        );

      case 4: // Settings
        return const ParkingAttendantSettingsPage();

      default:
        return const SizedBox.shrink();
    }
  }

  void _showCreateTicketOptions() {
    final theme = Theme.of(context);
    AppLocalizations.of(context);

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: theme.colorScheme.onSurface.withOpacity(0.2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Title
            Text(
              'Create Ticket',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),

            // Create Ticket Option (with app)
            ListTile(
              leading: CircleAvatar(
                backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                child: Icon(
                  Icons.receipt_long,
                  color: theme.colorScheme.primary,
                ),
              ),
              title: const Text('Create Ticket'),
              subtitle: const Text('Create ticket for app users'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CreateTicketPage(
                      attendantId: _attendantData?.id ?? '',
                      locationName: _attendantData?.locationName ?? '',
                    ),
                  ),
                ).then((created) {
                  if (created == true) {
                    _loadAttendantData();
                  }
                });
              },
            ),
            const SizedBox(height: 8),

            // Record Parking Option (without app)
            ListTile(
              leading: CircleAvatar(
                backgroundColor: theme.colorScheme.secondary.withOpacity(0.1),
                child: Icon(
                  Icons.local_parking,
                  color: theme.colorScheme.secondary,
                ),
              ),
              title: const Text('Record Parking'),
              subtitle: const Text('Record parking for non-app users'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RecordParkingPage(
                      attendantId: _attendantData?.id ?? '',
                      locationName: _attendantData?.locationName ?? '',
                    ),
                  ),
                ).then((_) {
                  _loadAttendantData();
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthInitial) {
          Navigator.of(context).pushReplacementNamed('/login');
        }
      },
      child: Scaffold(
        // Add AppBar here, only show on home page
        appBar: _selectedIndex == 0
            ? ParkingAttendantAppBar(
                title: 'Parkirin',
                showNotification: true,
                showLogout: true,
              )
            : null,
        body: _buildCurrentPage(),
        bottomNavigationBar: _buildBottomNavigationBar(theme),
      ),
    );
  }

  Widget _buildGreeting(ThemeData theme) {
    final greeting = _getTimeBasedGreeting();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          greeting,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          _attendantData?.name ?? 'Loading...',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  String _getTimeBasedGreeting() {
    final loc = AppLocalizations.of(context);
    final hour = DateTime.now().hour;
    if (hour < 12) return loc.goodMorning;
    if (hour < 17) return loc.goodAfternoon;
    if (hour < 20) return loc.goodEvening;
    return loc.goodNight;
  }

  Widget _buildLocationCard(ThemeData theme) {
    final loc = AppLocalizations.of(context);
    final locationItems = [
      {
        'label': loc.location,
        'value': _attendantData?.locationName ?? 'Loading...',
        'icon': Icons.location_on,
        'color': theme.colorScheme.onPrimary,
      },
      {
        'label': loc.district,
        'value': _attendantData?.district ?? 'Loading...',
        'icon': Icons.location_city,
        'color': theme.colorScheme.onPrimary,
      },
      {
        'label': loc.supervisor,
        'value': _attendantData?.supervisorName ?? 'Loading...',
        'icon': Icons.person,
        'color': theme.colorScheme.onPrimary,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          loc.locationDetails,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 16),
        ...locationItems.asMap().entries.map((entry) => Padding(
              padding: EdgeInsets.only(
                bottom: entry.key != locationItems.length - 1 ? 12 : 0,
              ),
              child: _buildLocationItem(theme, entry.value),
            )),
      ],
    );
  }

  Widget _buildLocationItem(ThemeData theme, Map<String, dynamic> item) {
    return Card(
      elevation: 4,
      color: theme.colorScheme.primary.withOpacity(1),
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
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment:
                CrossAxisAlignment.start, // Align to top for multiline text
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 2), // Adjust icon position
                child: Icon(
                  item['icon'] as IconData,
                  color: item['color'] as Color,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item['label'].toString(),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item['value'].toString(),
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: item['color'] as Color,
                        height: 1.3, // Add line height for better readability
                      ),
                      maxLines: 2, // Allow up to 2 lines
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsGrid(ThemeData theme) {
    final loc = AppLocalizations.of(context);

    final parkingRecordsCount = _attendantData?.stats.parkingRecordsCount ?? 0;
    debugPrint(
        'Building stats grid with parking records count: $parkingRecordsCount');
    debugPrint(
        'Current attendant data: ${_attendantData?.toMap()}'); // Add toMap() method if not exists

    final items = [
      {
        'label': loc.totalTickets,
        'value': '$_totalTickets',
        'icon': Icons.confirmation_number,
        'color': theme.colorScheme.secondary,
      },
      {
        'label': loc.paidTickets,
        'value': '$_completedTickets',
        'icon': Icons.check_circle,
        'color': theme.colorScheme.primary,
      },
      {
        'label': loc.pendingTickets,
        'value': '$_pendingTickets',
        'icon': Icons.pending,
        'color': theme.colorScheme.error,
      },
      {
        'label': 'Parking Records',
        'value': parkingRecordsCount.toString(),
        'icon': Icons.local_parking,
        'color': theme.colorScheme.tertiary,
      },
    ];

    // Additional debug log for the actual value being displayed
    debugPrint('Parking records value to be displayed: ${items[3]['value']}');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          loc.statsOverview,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, constraints) {
            // Determine cross axis count and aspect ratio based on screen width
            int crossAxisCount = constraints.maxWidth > 768 ? 4 : 2;
            double childAspectRatio = constraints.maxWidth > 768 ? 1.5 : 1.0;

            return GridView.count(
              padding: EdgeInsets.zero,
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: childAspectRatio,
              children:
                  items.map((item) => _buildStatCard(theme, item)).toList(),
            );
          },
        ),
      ],
    );
  }

  Widget _buildStatCard(ThemeData theme, Map<String, dynamic> item) {
    return Card(
      elevation: 0,
      color: (item['color'] as Color).withOpacity(0.1),
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
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(
                item['icon'] as IconData,
                color: item['color'] as Color,
                size: 24,
              ),
              const Spacer(),
              Text(
                item['value'].toString(),
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: item['color'] as Color,
                ),
              ),
              Text(
                item['label'].toString(),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentActivity(ThemeData theme) {
    final loc = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              loc.recentActivity,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            TextButton(
              onPressed: _activities.isNotEmpty
                  ? () {
                      // Update the selected index to navigate to History (index 1)
                      setState(() {
                        _selectedIndex = 1;
                      });
                    }
                  : null,
              child: Text(
                loc.viewAll,
                style: TextStyle(
                  color: _activities.isNotEmpty
                      ? theme.colorScheme.primary
                      : theme.colorScheme.primary.withOpacity(0.5),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (_activities.isEmpty)
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.receipt_long_outlined,
                  size: 48,
                  color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
                ),
                const SizedBox(height: 8),
                Text(
                  'No recent activities',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    _loadRecentActivities();
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.refresh,
                          size: 16, color: theme.colorScheme.primary),
                      const SizedBox(width: 4),
                      Text('Refresh',
                          style: TextStyle(color: theme.colorScheme.primary)),
                    ],
                  ),
                ),
              ],
            ),
          )
        else
          ..._activities.map((activity) => _buildActivityItem(activity, theme)),
      ],
    );
  }

  Widget _buildActivityItem(ActivityItem activity, ThemeData theme) {
    final dateFormat = DateFormat('HH:mm • d MMM yyyy');
    final formattedDate = dateFormat.format(activity.date);
    final currencyFormat = NumberFormat.currency(
      locale: 'id',
      symbol: 'Rp',
      decimalDigits: 0,
    );

    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceContainerHighest,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: getStatusColor(activity.status, theme).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                _getVehicleTypeIcon(activity.vehicleType),
                color: getStatusColor(activity.status, theme),
                size: 22,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    activity.plateNumber,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    formattedDate,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  currencyFormat.format(activity.amount),
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 6),
                _buildStatusBadge(
                    activity.status, theme), // Pass TicketStatus enum directly
              ],
            ),
          ],
        ),
      ),
    );
  }

  IconData _getVehicleTypeIcon(String vehicleType) {
    switch (vehicleType.toLowerCase()) {
      case 'car':
        return Icons.directions_car;
      case 'motorcycle':
        return Icons.two_wheeler;
      case 'truck':
        return Icons.local_shipping;
      default:
        return Icons.local_parking;
    }
  }

  Color getStatusColor(TicketStatus status, ThemeData theme) {
    switch (status) {
      case TicketStatus.completed:
        return theme.colorScheme.tertiary;
      case TicketStatus.pending:
        return theme.colorScheme.error;
      case TicketStatus.active:
        return theme.colorScheme.primary;
      case TicketStatus.cancelled:
        return theme.colorScheme.error;
    }
  }

  Widget _buildStatusBadge(TicketStatus status, ThemeData theme) {
    String getStatusText() {
      switch (status) {
        case TicketStatus.pending:
          return 'PENDING';
        case TicketStatus.active:
          return 'ACTIVE';
        case TicketStatus.completed:
          return 'COMPLETED';
        case TicketStatus.cancelled:
          return 'CANCELLED';
      }
    }

    Color getStatusColor(TicketStatus status, ThemeData theme) {
      switch (status) {
        case TicketStatus.completed:
          return theme.colorScheme.tertiary;
        case TicketStatus.pending:
          return theme.colorScheme.error;
        case TicketStatus.active:
          return theme.colorScheme.primary;
        case TicketStatus.cancelled:
          return theme.colorScheme.error;
      }
    }

    final color = getStatusColor(status, theme);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Text(
        getStatusText(),
        style: theme.textTheme.bodySmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildBottomNavigationBar(ThemeData theme) {
    final loc = AppLocalizations.of(context);
    return NavigationBar(
      selectedIndex:
          _selectedIndex, // Use _selectedIndex instead of _selectedNavIndex
      backgroundColor: theme.colorScheme.surface,
      elevation: 0,
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      onDestinationSelected: _onBottomNavTapped,
      destinations: [
        NavigationDestination(
          icon: const Icon(Icons.home_outlined),
          selectedIcon: const Icon(Icons.home),
          label: loc.navHome,
        ),
        NavigationDestination(
          icon: const Icon(Icons.history_outlined),
          selectedIcon: const Icon(Icons.history),
          label: loc.navHistory,
        ),
        NavigationDestination(
          icon: const Icon(Icons.add_circle_outline),
          selectedIcon: const Icon(Icons.add_circle),
          label: loc.createTicket,
        ),
        NavigationDestination(
          icon: const Icon(Icons.person_outline),
          selectedIcon: const Icon(Icons.person),
          label: loc.navProfile,
        ),
        NavigationDestination(
          icon: const Icon(Icons.settings_outlined),
          selectedIcon: const Icon(Icons.settings),
          label: loc.navSettings,
        ),
      ],
    );
  }
}
