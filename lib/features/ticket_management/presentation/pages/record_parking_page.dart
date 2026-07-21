// lib/features/ticket_management/presentation/pages/record_parking_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:parkirin/core/widgets/loading_overlay.dart';
import 'package:parkirin/di/dependency_injection.dart';
import 'package:parkirin/features/ticket_management/domain/entities/parking_record.dart';
import 'package:parkirin/features/ticket_management/presentation/widgets/parking_time_selector.dart';
import 'package:parkirin/features/vehicle_management/presentation/widgets/vehicle_type_selector.dart';

import '../bloc/record_parking_bloc.dart';
import '../bloc/record_parking_event.dart';
import '../bloc/record_parking_state.dart';
import '../widgets/vehicle_input_form.dart';

class RecordParkingPage extends StatelessWidget {
  final String attendantId;
  final String locationName;

  const RecordParkingPage({
    super.key,
    required this.attendantId,
    required this.locationName,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<RecordParkingBloc>(),
      child: _RecordParkingContent(
        attendantId: attendantId,
        locationName: locationName,
      ),
    );
  }
}

class _RecordParkingContent extends StatefulWidget {
  final String attendantId;
  final String locationName;

  const _RecordParkingContent({
    required this.attendantId,
    required this.locationName,
  });

  @override
  State<_RecordParkingContent> createState() => _RecordParkingContentState();
}

class _RecordParkingContentState extends State<_RecordParkingContent> {
  final _formKey = GlobalKey<FormState>();
  final _plateController = TextEditingController();
  VehicleType _selectedVehicleType = VehicleType.car;
  Position? _currentPosition;
  bool _isLoading = false;
  double _estimatedPrice = 0;
  DateTime _entryTime = DateTime.now();
  DateTime _exitTime = DateTime.now();

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _updateEstimatedPrice();
  }

  @override
  void dispose() {
    _plateController.dispose();
    super.dispose();
  }

  void _updateEstimatedPrice() {
    final duration = _exitTime.difference(_entryTime);

    // Base prices
    double basePrice;
    switch (_selectedVehicleType) {
      case VehicleType.motorcycle:
        basePrice = 2000.0;
        break;
      case VehicleType.car:
        basePrice = 5000.0;
        break;
      case VehicleType.truck:
        basePrice = 10000.0;
        break;
      case VehicleType.bus:
        basePrice = 15000.0;
        break;
      default:
        basePrice = 5000.0;
    }

    // Calculate hours (round up to nearest hour)
    final hours = (duration.inMinutes / 60).ceil();

    setState(() {
      // First hour is base price, additional hours are half the base price
      _estimatedPrice =
          hours <= 1 ? basePrice : basePrice + (basePrice * 0.5 * (hours - 1));
    });
  }

  Future<void> _getCurrentLocation() async {
    setState(() => _isLoading = true);
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _showError('Location services are disabled');
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _showError('Location permission denied');
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _showError('Location permissions permanently denied');
        return;
      }

      _currentPosition = await Geolocator.getCurrentPosition();
      setState(() {});
    } catch (e) {
      _showError('Could not get location: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
    );
  }

  Future<void> _recordParking() async {
    if (!_formKey.currentState!.validate()) return;

    if (_currentPosition == null) {
      _showError('Waiting for location data. Please try again.');
      return;
    }

    if (_exitTime.isBefore(_entryTime)) {
      _showError('Exit time cannot be before entry time');
      return;
    }

    context.read<RecordParkingBloc>().add(
          CreateParkingRecord(
            attendantId: widget.attendantId,
            plateNumber: _plateController.text.trim(),
            vehicleType: _selectedVehicleType.name,
            locationName: widget.locationName,
            latitude: _currentPosition!.latitude,
            longitude: _currentPosition!.longitude,
            entryTime: _entryTime,
            exitTime: _exitTime,
          ),
        );
  }

  void _showSuccessDialog(String recordId, ParkingRecord record) {
    final theme = Theme.of(context);
    final currencyFormat = NumberFormat.currency(
      locale: 'id',
      symbol: 'Rp',
      decimalDigits: 0,
    );
    final dateFormat = DateFormat('dd MMM yyyy, HH:mm');

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        icon: Icon(
          Icons.check_circle_outline,
          color: theme.colorScheme.primary,
          size: 48,
        ),
        title: const Text('Parking Recorded Successfully'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInfoRow('Record ID', '#$recordId'),
              _buildInfoRow(
                'Entry Time',
                dateFormat.format(record.entryTime),
              ),
              _buildInfoRow(
                'Exit Time',
                dateFormat.format(record.exitTime!),
              ),
              const SizedBox(height: 16),
              _buildSectionTitle('Vehicle Information'),
              _buildInfoRow('Plate Number', record.vehiclePlateNumber),
              _buildInfoRow('Vehicle Type', record.vehicleType),
              const SizedBox(height: 16),
              _buildSectionTitle('Duration Information'),
              _buildInfoRow(
                'Total Duration',
                '${record.getParkingDuration().inHours}h ${record.getParkingDuration().inMinutes.remainder(60)}m',
              ),
              const SizedBox(height: 16),
              _buildSectionTitle('Payment Information'),
              _buildInfoRow('Amount', currencyFormat.format(record.amount)),
              _buildInfoRow('Payment Method', 'Cash'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _plateController.clear();
              setState(() {
                _selectedVehicleType = VehicleType.car;
              });
              _updateEstimatedPrice();
            },
            child: const Text('Record Another'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
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

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value),
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

    return BlocListener<RecordParkingBloc, RecordParkingState>(
      listener: (context, state) {
        setState(() => _isLoading = state is RecordParkingLoading);

        if (state is RecordParkingError) {
          _showError(state.error);
        } else if (state is RecordCreated) {
          _showSuccessDialog(state.recordId, state.record);
        }
      },
      child: Stack(
        children: [
          Scaffold(
            appBar: AppBar(
              title: const Text('Record Parking'),
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
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  ParkingTimeSelector(
                    entryTime: _entryTime,
                    exitTime: _exitTime,
                    onEntryTimeChanged: (time) {
                      setState(() {
                        _entryTime = time;
                        // Ensure exit time is not before entry time
                        if (_exitTime.isBefore(_entryTime)) {
                          _exitTime = _entryTime.add(const Duration(hours: 1));
                        }
                      });
                      _updateEstimatedPrice();
                    },
                    onExitTimeChanged: (time) {
                      setState(() {
                        _exitTime = time;
                      });
                      _updateEstimatedPrice();
                    },
                  ),
                  const SizedBox(height: 16),

                  // Vehicle Input Form
                  VehicleInputForm(
                    plateController: _plateController,
                    selectedVehicleType: _selectedVehicleType,
                    onVehicleTypeChanged: (type) {
                      setState(() {
                        _selectedVehicleType = type;
                      });
                      _updateEstimatedPrice();
                    },
                    plateValidationEnabled: false,
                  ),
                  const SizedBox(height: 24),

                  // Record Button
                  FilledButton(
                    onPressed: _isLoading ? null : _recordParking,
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.receipt_long),
                        const SizedBox(width: 8),
                        Text(
                          _isLoading ? 'Recording...' : 'Record Parking',
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
