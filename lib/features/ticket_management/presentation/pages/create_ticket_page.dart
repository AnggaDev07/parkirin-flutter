// lib/features/ticket_management/presentation/pages/create_ticket_page.dart

// lib/features/ticket_management/presentation/pages/create_ticket_page.dart

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:parkirin/core/widgets/loading_overlay.dart';
import 'package:parkirin/di/dependency_injection.dart';
import 'package:parkirin/features/ticket_management/domain/entities/ticket.dart';
import 'package:parkirin/features/ticket_management/presentation/bloc/create_ticket_bloc.dart';
import 'package:parkirin/features/ticket_management/presentation/bloc/ticket_bloc.dart';
import 'package:parkirin/features/ticket_management/presentation/bloc/ticket_event.dart';
import 'package:parkirin/features/vehicle_management/presentation/widgets/vehicle_type_selector.dart';

import '../bloc/create_ticket_event.dart';
import '../bloc/create_ticket_state.dart';

const LocationSettings locationSettings = LocationSettings(
  accuracy: LocationAccuracy.high,
  distanceFilter: 0,
);

class CreateTicketPage extends StatelessWidget {
  final String attendantId;
  final String locationName;

  const CreateTicketPage({
    super.key,
    required this.attendantId,
    required this.locationName,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<CreateTicketBloc>(),
      child: _CreateTicketContent(
        attendantId: attendantId,
        locationName: locationName,
      ),
    );
  }
}

class _CreateTicketContent extends StatefulWidget {
  final String attendantId;
  final String locationName;

  const _CreateTicketContent({
    required this.attendantId,
    required this.locationName,
  });

  @override
  _CreateTicketContentState createState() => _CreateTicketContentState();
}

class _CreateTicketContentState extends State<_CreateTicketContent> {
  final _formKey = GlobalKey<FormState>();
  final _plateController = TextEditingController();
  VehicleType _selectedVehicleType = VehicleType.car;
  PaymentType _selectedPaymentType = PaymentType.cash;
  Position? _currentPosition;
  bool _isLoading = false;
  double _estimatedPrice = 0;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _plateController.addListener(() {
      if (_plateController.text.length >= 3) {
        context
            .read<CreateTicketBloc>()
            .add(ValidatePlateNumber(_plateController.text));
      }
    });
    _updateEstimatedPrice();
  }

  void _updateEstimatedPrice() {
    // Base prices for different vehicle types
    final basePrices = {
      VehicleType.motorcycle: 2000.0,
      VehicleType.car: 5000.0,
      VehicleType.truck: 10000.0,
      VehicleType.bus: 15000.0,
    };
    setState(() {
      _estimatedPrice = basePrices[_selectedVehicleType] ?? 5000.0;
    });
  }

  Future<void> _getCurrentLocation() async {
    setState(() => _isLoading = true);
    debugPrint('Starting location request...');

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      debugPrint('Location service enabled: $serviceEnabled');

      if (!serviceEnabled) {
        _showError(
          'Location services are disabled. Please enable location services in your device settings.',
          showRetry: true,
        );
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      debugPrint('Initial permission status: $permission');

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        debugPrint('Permission after request: $permission');

        if (permission == LocationPermission.denied) {
          _showError(
            'Location permission denied. Please grant location permission to create tickets.',
            showRetry: true,
          );
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _showError(
          'Location permission permanently denied. Please enable it in app settings.',
          showOpenSettings: true,
        );
        return;
      }

      debugPrint('Requesting location...');

      // Define optimized location settings
      const locationSettings = LocationSettings(
        accuracy: LocationAccuracy.reduced,
        distanceFilter: 0,
        timeLimit: Duration(seconds: 5),
      );

      _currentPosition = await Geolocator.getCurrentPosition(
        locationSettings: locationSettings,
      ).timeout(
        const Duration(seconds: 5),
        onTimeout: () async {
          debugPrint('Timed out, trying with lower accuracy...');

          // Fall back to lower accuracy settings
          const fallbackSettings = LocationSettings(
            accuracy: LocationAccuracy.low,
            distanceFilter: 0,
            timeLimit: Duration(seconds: 5),
          );

          return await Geolocator.getCurrentPosition(
            locationSettings: fallbackSettings,
          );
        },
      );

      if (_currentPosition != null) {
        debugPrint(
            'Successfully got location: ${_currentPosition!.latitude}, ${_currentPosition!.longitude}');
        setState(() {});
      } else {
        throw Exception('Could not get location');
      }
    } catch (e, stackTrace) {
      debugPrint('Location error: $e');
      debugPrint('Stack trace: $stackTrace');

      if (!mounted) return;

      _showError(
        'Could not get location. Please try again or move to an area with better GPS signal.',
        showRetry: true,
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
    _plateController.dispose();
  }

  void _showError(String message,
      {bool showRetry = false, bool showOpenSettings = false}) {
    if (!mounted) return;

    final theme = Theme.of(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: theme.colorScheme.error,
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: showOpenSettings
              ? 'Settings'
              : showRetry
                  ? 'Retry'
                  : 'OK',
          textColor: theme.colorScheme.onError,
          onPressed: () {
            if (showOpenSettings) {
              Geolocator.openAppSettings();
            } else if (showRetry) {
              _getCurrentLocation();
            }
          },
        ),
        duration: const Duration(seconds: 10),
      ),
    );
  }

  bool _validatePlateNumber(String value) {
    final regex = RegExp(r'^[A-Z]{1,2}\s?\d{1,4}\s?[A-Z]{1,3}$');
    return regex.hasMatch(value.toUpperCase());
  }

  Future<void> _createTicket() async {
    if (!_formKey.currentState!.validate()) return;

    if (_currentPosition == null) {
      _showError('Waiting for location data. Please try again.');
      return;
    }

    final state = context.read<CreateTicketBloc>().state;
    if (state is! PlateNumberValidated) {
      _showError('Please enter a valid plate number');
      return;
    }

    try {
      context.read<CreateTicketBloc>().add(
            CreateNewTicket(
              attendantId: widget.attendantId,
              plateNumber: _plateController.text.trim(),
              vehicleType: _selectedVehicleType.name,
              locationName: widget.locationName,
              latitude: _currentPosition!.latitude,
              longitude: _currentPosition!.longitude,
              paymentType: _selectedPaymentType,
            ),
          );
    } catch (e) {
      _showError('Failed to create ticket. Please try again.');
    }
  }

  void _showSuccessDialog(String ticketId) {
    final currencyFormat = NumberFormat.currency(
      locale: 'id',
      symbol: 'Rp',
      decimalDigits: 0,
    );

    final now = DateTime.now();
    final dateFormat = DateFormat('dd MMM yyyy, HH:mm');

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        icon: Icon(
          Icons.check_circle_outline,
          color: Theme.of(context).colorScheme.primary,
          size: 48,
        ),
        title: const Text('Ticket Created Successfully'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInfoRow('Ticket ID', ticketId),
              const SizedBox(height: 16),
              _buildInfoRow(
                'Created On',
                dateFormat.format(now),
              ),
              const SizedBox(height: 16),
              _buildSectionTitle('Attendant Information'),
              _buildInfoRow('ID', widget.attendantId),
              const SizedBox(height: 16),
              _buildSectionTitle('Vehicle Information'),
              _buildInfoRow(
                  'Plate Number', _plateController.text.toUpperCase()),
              _buildInfoRow('Vehicle Type', _selectedVehicleType.name),
              const SizedBox(height: 16),
              _buildSectionTitle('Location Information'),
              _buildInfoRow('Location', widget.locationName),
              _buildInfoRow(
                'Coordinates',
                '${_currentPosition!.latitude.toStringAsFixed(6)}, ${_currentPosition!.longitude.toStringAsFixed(6)}',
              ),
              const SizedBox(height: 16),
              _buildSectionTitle('Payment Information'),
              _buildInfoRow('Amount', currencyFormat.format(_estimatedPrice)),
              _buildInfoRow('Payment Method', _selectedPaymentType.name),
              if (_selectedPaymentType == PaymentType.cashless)
                _buildInfoRow('Points Earned', '+40 points',
                    isHighlighted: true),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              _plateController.clear();
              setState(() {
                _selectedVehicleType = VehicleType.car;
                _selectedPaymentType = PaymentType.cash;
              });
            },
            child: const Text('Create Another'),
          ),
          FilledButton(
            onPressed: () {
              // Refresh ticket list before navigating back
              context.read<TicketBloc>().add(
                    LoadAttendantTickets(
                      attendantId: widget.attendantId,
                      status: TicketStatus.pending,
                    ),
                  );

              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Close page
            },
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.grey,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    String label,
    String value, {
    bool isHighlighted = false,
    IconData? icon,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: 16,
              color: Colors.grey,
            ),
            const SizedBox(width: 8),
          ],
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontWeight: isHighlighted ? FontWeight.bold : null,
                    color: isHighlighted ? Colors.green : null,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currencyFormat = NumberFormat.currency(
      locale: 'id',
      symbol: 'Rp',
      decimalDigits: 0,
    );

    return BlocListener<CreateTicketBloc, CreateTicketState>(
      listener: (context, state) {
        setState(() => _isLoading = state is CreateTicketLoading);

        if (state is CreateTicketError) {
          _showError(state.error);
        } else if (state is TicketCreated) {
          _showSuccessDialog(state.ticketId);
        } else if (state is PlateNumberValidated) {
          _updateEstimatedPrice();
        }
      },
      child: Stack(
        children: [
          Scaffold(
            appBar: AppBar(
              title: const Text('Create Ticket'),
            ),
            body: Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Price Display
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'Parking Fee',
                          style: TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          currencyFormat.format(_estimatedPrice),
                          style: theme.textTheme.headlineMedium?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Location Card
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.location_on,
                                  color: theme.colorScheme.onSurface),
                              const SizedBox(width: 8),
                              const Text(
                                'Location',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Text(widget.locationName),
                          if (_currentPosition != null) ...[
                            const SizedBox(height: 8),
                            Text(
                              'GPS: ${_currentPosition!.latitude.toStringAsFixed(6)}, ${_currentPosition!.longitude.toStringAsFixed(6)}',
                              style: theme.textTheme.bodySmall,
                            ),
                          ],
                          if (_currentPosition == null) ...[
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Getting location...',
                                  style: theme.textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Vehicle Details
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.directions_car,
                                  color: theme.colorScheme.onSurface),
                              const SizedBox(width: 8),
                              const Text(
                                'Vehicle Details',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _plateController,
                            textCapitalization: TextCapitalization.characters,
                            decoration: InputDecoration(
                              labelText: 'License Plate',
                              hintText: 'e.g., B 1234 ABC',
                              border: const OutlineInputBorder(),
                              suffixIcon: _plateController.text.isNotEmpty
                                  ? BlocBuilder<CreateTicketBloc,
                                      CreateTicketState>(
                                      builder: (context, state) {
                                        if (state is PlateNumberValidated) {
                                          return const Icon(Icons.check_circle,
                                              color: Colors.green);
                                        } else if (state
                                            is PlateNumberInvalid) {
                                          return const Icon(Icons.error,
                                              color: Colors.red);
                                        }
                                        return const SizedBox.shrink();
                                      },
                                    )
                                  : null,
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter license plate';
                              }
                              if (!_validatePlateNumber(value)) {
                                return 'Invalid plate number format';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          DropdownButtonFormField<VehicleType>(
                            value: _selectedVehicleType,
                            decoration: const InputDecoration(
                              labelText: 'Vehicle Type',
                              border: OutlineInputBorder(),
                            ),
                            items: VehicleType.values.map((type) {
                              return DropdownMenuItem(
                                value: type,
                                child: Text(type.name.toUpperCase()),
                              );
                            }).toList(),
                            onChanged: (value) {
                              if (value != null) {
                                setState(() {
                                  _selectedVehicleType = value;
                                });
                                _updateEstimatedPrice();
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Payment Details
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.payment,
                                  color: theme.colorScheme.onSurface),
                              const SizedBox(width: 8),
                              const Text(
                                'Payment Details',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: _PaymentOption(
                                  icon: Icons.money,
                                  label: 'Cash',
                                  isSelected:
                                      _selectedPaymentType == PaymentType.cash,
                                  onTap: () {
                                    setState(() {
                                      _selectedPaymentType = PaymentType.cash;
                                    });
                                  },
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _PaymentOption(
                                  icon: Icons.credit_card,
                                  label: 'Cashless',
                                  isSelected: _selectedPaymentType ==
                                      PaymentType.cashless,
                                  onTap: () {
                                    setState(() {
                                      _selectedPaymentType =
                                          PaymentType.cashless;
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Create Button
                  FilledButton(
                    onPressed: _isLoading ? null : _createTicket,
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.receipt_long),
                        const SizedBox(width: 8),
                        Text(
                          _isLoading ? 'Creating Ticket...' : 'Create Ticket',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_isLoading) const LoadingOverlay(message: 'Processing...'),
        ],
      ),
    );
  }
}

class _PaymentOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _PaymentOption({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(
            vertical: 16,
            horizontal: 12,
          ),
          decoration: BoxDecoration(
            border: Border.all(
              color: isSelected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.outline,
              width: isSelected ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(12),
            color:
                isSelected ? theme.colorScheme.primary.withOpacity(0.1) : null,
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  color: isSelected
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurfaceVariant,
                  fontWeight: isSelected ? FontWeight.bold : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
