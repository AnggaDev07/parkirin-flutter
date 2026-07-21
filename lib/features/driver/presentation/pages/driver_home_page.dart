import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:parkirin/di/dependency_injection.dart';
import 'package:parkirin/features/authentication/data/repositories/user_repository.dart';
import 'package:parkirin/features/authentication/domain/entities/user_model.dart';
import 'package:parkirin/features/authentication/presentation/bloc/auth_bloc.dart';
import 'package:parkirin/features/driver/presentation/bloc/latest_pending_bills_bloc.dart';
import 'package:parkirin/features/driver/presentation/bloc/latest_pending_bills_event.dart';
import 'package:parkirin/features/driver/presentation/bloc/latest_pending_bills_state.dart';
import 'package:parkirin/features/driver/presentation/bloc/pending_tickets_count_bloc.dart';
import 'package:parkirin/features/driver/presentation/bloc/pending_tickets_count_event.dart';
import 'package:parkirin/features/driver/presentation/bloc/pending_tickets_count_state.dart';
import 'package:parkirin/features/driver/presentation/pages/driver_bills_page.dart';
import 'package:parkirin/features/driver/presentation/pages/driver_history_page.dart';
import 'package:parkirin/features/driver/presentation/pages/driver_profile_page.dart';
import 'package:parkirin/features/driver/presentation/pages/driver_settings_page.dart';
import 'package:parkirin/features/driver/widgets/driver_appbar.dart';
import 'package:parkirin/features/driver/widgets/points_celebration_overlay.dart';
import 'package:parkirin/features/ticket_management/domain/entities/ticket.dart';
import 'package:parkirin/features/vehicle_management/presentation/bloc/vehicle_bloc.dart';
import 'package:parkirin/features/vehicle_management/presentation/pages/vehicle_list_page.dart';
import 'package:parkirin/localization/app_localizations.dart';

class DriverHomePage extends StatefulWidget {
  const DriverHomePage({super.key});

  @override
  DriverHomePageState createState() => DriverHomePageState();
}

class DriverHomePageState extends State<DriverHomePage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  int _selectedIndex = 0;
  UserModel? _currentUser;
  late final UserRepository _userRepository;

  StreamSubscription? _userSubscription;

  @override
  void initState() {
    super.initState();
    _userRepository = getIt<UserRepository>();
    _setupUserStream();
    _loadUserData();

    final currentUser = firebase_auth.FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      // Use the new PendingTicketsCountBloc instead
      context.read<PendingTicketsCountBloc>().add(
            LoadPendingTicketsCount(currentUser.uid),
          );

      context.read<LatestPendingBillsBloc>().add(
            LoadLatestPendingBills(currentUser.uid),
          );
    }
  }

  void _setupUserStream() {
    final currentUser = firebase_auth.FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      debugPrint('[DriverHome] Setting up user stream');
      _userSubscription = _userRepository.getUserStream(currentUser.uid).listen(
        (userData) async {
          if (mounted && userData != null) {
            debugPrint(
                '[DriverHome] Received update - Points: ${userData.points}, Should Show: ${userData.shouldShowCelebration}');

            setState(() {
              _currentUser = userData;
            });

            // Check if we should show celebration
            if (userData.shouldShowCelebration) {
              debugPrint(
                  '[DriverHome] Showing celebration for large points update');
              _showCelebrationOverlay();
              // Clear the flag after showing celebration
              await _userRepository.clearCelebrationFlag(userData.id);
            }
          }
        },
        onError: (error, stackTrace) {
          debugPrint('[DriverHome] Stream error: $error');
          debugPrint(stackTrace.toString());
        },
      );
    }
  }

  void _onBottomNavTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  Future<void> _loadUserData() async {
    try {
      final currentUser = firebase_auth.FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        final userData = await _userRepository.getUser(currentUser.uid);
        if (mounted) {
          setState(() {
            _currentUser = userData;
          });
        }
      }
    } catch (e) {
      debugPrint('Error loading user data: $e');
    }
  }

  void _showCelebrationOverlay() {
    // Check if there's already a dialog showing
    if (ModalRoute.of(context)?.isCurrent ?? false) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => PointsCelebrationOverlay(
          freeParkingChances: _currentUser?.freeParkingChances ?? 0,
          onDismiss: () {
            Navigator.of(context).pop();
          },
        ),
      );
    } else {
      debugPrint(
          'Prevented duplicate celebration overlay - route is not current');
    }
  }

  String _formatName(String? fullName) {
    if (fullName == null || fullName.isEmpty) return 'User';

    // Split the name into parts
    final nameParts = fullName.split(' ');

    // If name is short enough, return as is
    if (fullName.length <= 15) return fullName;

    // If there's only one word but it's too long
    if (nameParts.length == 1) {
      return '${nameParts[0].substring(0, 12)}...';
    }

    // If there are multiple parts
    if (nameParts.length >= 3) {
      // Return first name + middle initial + last name
      return '${nameParts[0]} ${nameParts[1][0]}. ${nameParts.last}';
    } else if (nameParts.length == 2) {
      // Return first name + last name
      return '${nameParts[0]} ${nameParts[1]}';
    }

    return fullName;
  }

  String _getGreetingName() {
    if (_currentUser == null) return 'User';

    // If user has a name, format it
    if (_currentUser!.name != null && _currentUser!.name!.isNotEmpty) {
      return _formatName(_currentUser!.name);
    }

    // If no name but has phone number, format and use phone
    if (_currentUser!.phoneNumber.isNotEmpty) {
      // Format phone number to be more readable
      // Assuming Indonesian format: +62xxx-xxxx-xxxx
      String phone = _currentUser!.phoneNumber;
      if (phone.startsWith('+62')) {
        phone = '0${phone.substring(3)}';
      }
      return phone;
    }

    return _currentUser!.email ?? 'User';
  }

  @override
  void dispose() {
    _userSubscription?.cancel();
    _pageController.dispose();
    super.dispose();
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
        backgroundColor: theme.colorScheme.surface,
        appBar: _selectedIndex == 0
            ? DriverAppBar(
                title: 'Parkirin',
                showNotification: true,
                showLogout: true,
              )
            : null,
        body: IndexedStack(
          index: _selectedIndex,
          children: [
            // Home Page Content
            RefreshIndicator(
              color: theme.colorScheme.primary,
              backgroundColor: theme.colorScheme.surface,
              onRefresh: _loadUserData,
              child: SingleChildScrollView(
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: _currentUser == null
                        ? const Center(child: CircularProgressIndicator())
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildGreeting(theme),
                              const SizedBox(height: 24),
                              _buildPointCard(theme),
                              const SizedBox(height: 48),
                              _buildInfoCard(theme),
                              const SizedBox(height: 48),
                              _buildLatestTicketsSection(theme),
                            ],
                          ),
                  ),
                ),
              ),
            ),
            // History Page
            if (_currentUser != null)
              TicketListPage(
                userId: _currentUser!.id,
                currentUser: _currentUser!,
              )
            else
              const Center(child: CircularProgressIndicator()),
            // Bills Page
            if (_currentUser != null)
              DriverBillsPage(
                userId: _currentUser!.id,
                currentUser: _currentUser!,
              )
            else
              const Center(child: CircularProgressIndicator()),
            // Profile Page
            if (_currentUser != null)
              DriverProfilePage(driver: _currentUser)
            else
              const Center(child: CircularProgressIndicator()),
            // Settings Page
            const DriverSettingsPage(),
          ],
        ),
        bottomNavigationBar: _buildBottomNavigationBar(theme),
      ),
    );
  }

  Widget _buildGreeting(ThemeData theme) {
    final loc = AppLocalizations.of(context);
    final greeting = _getTimeBasedGreeting(loc);
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
          _getGreetingName(),
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  String _getTimeBasedGreeting(AppLocalizations loc) {
    final hour = DateTime.now().hour;
    if (hour < 12) return loc.goodMorning;
    if (hour < 17) return loc.goodAfternoon;
    if (hour < 20) return loc.goodEvening;
    return loc.goodNight;
  }

  Widget _buildPointCard(ThemeData theme) {
    final loc = AppLocalizations.of(context);
    final currentPoints = _currentUser?.points ?? 0;
    final freeParkingChances = _currentUser?.freeParkingChances ?? 0;
    const targetPoints = 2000;
    final progress = (currentPoints / targetPoints).clamp(0.0, 1.0);

    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.colorScheme.primary,
              theme.colorScheme.primary.withOpacity(0.8),
            ],
            stops: const [0.3, 1.0],
          ),
          boxShadow: [
            // Outer shadow
            BoxShadow(
              color: theme.colorScheme.primary.withOpacity(0.3),
              blurRadius: 5,
              offset: const Offset(0, 4),
            ),
            // Inner glow
            BoxShadow(
              color: theme.colorScheme.primary.withOpacity(0.2),
              blurRadius: 20,
              spreadRadius: -5,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.stars_rounded,
                      color: theme.colorScheme.onPrimary.withOpacity(0.9),
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      loc.parkirinPoints,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.onPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  onPressed: () => _showPointsInfoDialog(context, theme, loc),
                  icon: Icon(
                    Icons.info_outline,
                    color: theme.colorScheme.onPrimary.withOpacity(0.9),
                    size: 20,
                  ),
                  style: IconButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(24, 24),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Points Display
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  currentPoints.toString(),
                  style: theme.textTheme.headlineLarge?.copyWith(
                    color: theme.colorScheme.onPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 4),
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    '/ $targetPoints pts',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.onPrimary.withOpacity(0.7),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            Text(
              loc.remainingPoints.replaceFirst(
                  '%d', (targetPoints - currentPoints).toString()),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onPrimary.withOpacity(0.9),
              ),
            ),

            // Add Free Parking Chances here
            if (freeParkingChances > 0) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: theme.colorScheme.onPrimary.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.local_parking_rounded,
                      color: theme.colorScheme.onPrimary,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Free Parking: $freeParkingChances',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 20),
            // Progress Bar Container with Glass Effect
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.onPrimary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: theme.colorScheme.onPrimary.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 12,
                      backgroundColor:
                          theme.colorScheme.onPrimary.withOpacity(0.2),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        theme.colorScheme.onPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        loc.pointsProgress.replaceFirst(
                            '%d', (progress * 100).toInt().toString()),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onPrimary.withOpacity(0.9),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        loc.pointsTarget
                            .replaceFirst('%d', targetPoints.toString()),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onPrimary.withOpacity(0.9),
                          fontWeight: FontWeight.w500,
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
    );
  }

// Updated info dialog with localization
  void _showPointsInfoDialog(
      BuildContext context, ThemeData theme, AppLocalizations loc) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.stars_rounded,
                        color: theme.colorScheme.primary,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            loc.pointsSystem,
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            loc.howItWorks,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _buildInfoSection(
                  theme,
                  icon: Icons.add_circle_outline,
                  title: loc.earningPoints,
                  content: loc.earningPointsDesc,
                ),
                const SizedBox(height: 16),
                _buildInfoSection(
                  theme,
                  icon: Icons.redeem,
                  title: loc.usingPoints,
                  content: loc.usingPointsDesc,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () => Navigator.pop(context),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(loc.gotIt),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoSection(
    ThemeData theme, {
    required IconData icon,
    required String title,
    required String content,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 20,
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                content,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard(ThemeData theme) {
    final loc = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Title
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 16),
          child: Row(
            children: [
              Icon(
                Icons.analytics_outlined,
                size: 20,
                color: theme.colorScheme.secondary,
              ),
              const SizedBox(width: 8),
              Text(
                loc.overview,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        // Metric Cards Row
        Row(
          children: [
            // Vehicles Card
            Expanded(
              child: _buildMetricCard(
                theme: theme,
                icon: Icons.directions_car,
                value: (_currentUser?.vehicles.length ?? 0).toString(),
                label: loc.registeredVehicles,
                buttonLabel: loc.manageVehicles,
                onButtonPressed: () {
                  if (_currentUser != null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MultiBlocProvider(
                          providers: [
                            BlocProvider(
                              create: (context) => getIt<VehicleBloc>(),
                            ),
                          ],
                          child: VehicleListPage(userId: _currentUser!.id),
                        ),
                      ),
                    );
                  }
                },
              ),
            ),
            const SizedBox(width: 16),
            // Bills Card
            Expanded(
              child: BlocBuilder<PendingTicketsCountBloc,
                  PendingTicketsCountState>(
                builder: (context, state) {
                  String countText = '0';
                  if (state is PendingTicketsCountLoaded) {
                    countText = state.count.toString();
                  }

                  return _buildMetricCard(
                    theme: theme,
                    icon: Icons.receipt_long,
                    value: countText,
                    label: loc.totalBills,
                    buttonLabel: loc.viewBills,
                    onButtonPressed: () {
                      if (_currentUser != null) {
                        setState(() => _selectedIndex = 2);
                      }
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMetricCard({
    required ThemeData theme,
    required IconData icon,
    required String value,
    required String label,
    required String buttonLabel,
    required VoidCallback onButtonPressed,
  }) {
    return Card(
      elevation: 0,
      color: theme.colorScheme.primary.withOpacity(0.1),
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.shadow.withOpacity(0.06),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  icon,
                  size: 28,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 16),
              Column(
                children: [
                  Text(
                    value,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    label,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      height: 1.2,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: FilledButton.tonal(
                  onPressed: onButtonPressed,
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 12,
                    ),
                    backgroundColor: theme.colorScheme.surface.withOpacity(0.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return SizedBox(
                        width: constraints.maxWidth,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Flexible(
                              child: Text(
                                buttonLabel,
                                style: theme.textTheme.labelLarge?.copyWith(
                                  color: theme.colorScheme.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              Icons.arrow_forward_rounded,
                              size: 18,
                              color: theme.colorScheme.primary,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLatestTicketsSection(ThemeData theme) {
    final loc = AppLocalizations.of(context);
    // Get screen size
    final screenSize = MediaQuery.of(context).size;
    // Calculate dynamic height based on screen size
    final containerHeight = screenSize.width > 768 ? 360.0 : 280.0;
    // Calculate dynamic aspect ratio
    final childAspectRatio = screenSize.width > 768 ? 2.5 : 1.5;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header (keep existing header code)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.receipt_outlined,
                    size: 20,
                    color: theme.colorScheme.secondary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    loc.latestBills,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              TextButton.icon(
                onPressed: () {
                  setState(() => _selectedIndex = 2); // Change to bills tab
                },
                label: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(loc.viewAll),
                    const SizedBox(width: 4),
                    const Icon(Icons.arrow_forward_rounded, size: 18),
                  ],
                ),
                style: TextButton.styleFrom(
                  foregroundColor: theme.colorScheme.primary,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Bills Grid with Pagination
        SizedBox(
          height: containerHeight,
          child: BlocBuilder<LatestPendingBillsBloc, LatestPendingBillsState>(
            builder: (context, state) {
              if (state is LatestPendingBillsLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (state is LatestPendingBillsLoaded) {
                if (state.tickets.isEmpty) {
                  return Center(
                    child: Text(
                      'No pending bills',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  );
                }

                return PageView.builder(
                  controller: _pageController,
                  onPageChanged: (int page) {
                    setState(() => _currentPage = page);
                  },
                  itemCount: (state.tickets.length / 4).ceil(),
                  itemBuilder: (context, pageIndex) {
                    return GridView.count(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: childAspectRatio,
                      children: List.generate(4, (index) {
                        final ticketIndex = pageIndex * 4 + index;
                        if (ticketIndex < state.tickets.length) {
                          return _buildTicketCard(
                              state.tickets[ticketIndex], theme);
                        }
                        return const SizedBox.shrink();
                      }),
                    );
                  },
                );
              }
              if (state is LatestPendingBillsError) {
                return Center(
                  child: Text(
                    'Error: ${state.message}',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.error,
                    ),
                  ),
                );
              }

              return const SizedBox.shrink();
            },
          ),
        ),

        // Pagination Indicator
        BlocBuilder<LatestPendingBillsBloc, LatestPendingBillsState>(
          builder: (context, state) {
            if (state is LatestPendingBillsLoaded && state.tickets.isNotEmpty) {
              final pageCount = (state.tickets.length / 4).ceil();

              return Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      pageCount,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width: _currentPage == index ? 24 : 8,
                        height: 8,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          color: _currentPage == index
                              ? theme.colorScheme.primary
                              : theme.colorScheme.primary.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ],
    );
  }

  Widget _buildTicketCard(Ticket ticket, ThemeData theme) {
    final currencyFormat = NumberFormat.currency(
      locale: 'id',
      symbol: 'Rp',
      decimalDigits: 0,
    );

    return Card(
      elevation: 0,
      color: theme.colorScheme.primary.withOpacity(0.05),
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.shadow.withOpacity(0.06),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              setState(() => _selectedIndex = 2); // Navigate to bills tab
            },
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.directions_car,
                          size: 16,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          ticket.vehiclePlateNumber,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Text(
                    currencyFormat.format(ticket.amount),
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat('dd-MM-yyyy').format(ticket.createdAt),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

// Update the logout dialog to match the new design

  Widget _buildBottomNavigationBar(ThemeData theme) {
    final loc = AppLocalizations.of(context);
    return NavigationBar(
      selectedIndex: _selectedIndex, // Update this line
      onDestinationSelected: _onBottomNavTapped,
      backgroundColor: theme.colorScheme.surface,
      elevation: 0,
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      destinations: [
        _buildNavDestination(Icons.home_outlined, Icons.home, loc.navHome, 0),
        _buildNavDestination(
            Icons.history_outlined, Icons.history, loc.navHistory, 1),
        _buildNavDestination(
            Icons.receipt_outlined, Icons.receipt, loc.navBills, 2),
        _buildNavDestination(
            Icons.person_outline, Icons.person, loc.navProfile, 3),
        _buildNavDestination(
            Icons.settings_outlined, Icons.settings, loc.navSettings, 4),
      ],
    );
  }

  NavigationDestination _buildNavDestination(
    IconData outlinedIcon,
    IconData filledIcon,
    String label,
    int index,
  ) {
    return NavigationDestination(
      icon: Icon(outlinedIcon),
      selectedIcon: Icon(filledIcon),
      label: label,
    );
  }
}
