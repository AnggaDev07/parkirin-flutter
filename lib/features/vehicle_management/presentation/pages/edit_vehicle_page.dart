// lib/features/vehicle_management/presentation/pages/edit_vehicle_page.dart

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:parkirin/localization/app_localizations.dart';

import '../../domain/entities/vehicle.dart';
import '../bloc/vehicle_bloc.dart';
import '../bloc/vehicle_event.dart';
import '../bloc/vehicle_state.dart';
import '../widgets/photo_picker.dart';
import '../widgets/plate_number_input.dart';
import '../widgets/vehicle_type_selector.dart';

class EditVehiclePage extends StatefulWidget {
  final Vehicle vehicle;

  const EditVehiclePage({
    super.key,
    required this.vehicle,
  });

  @override
  State<EditVehiclePage> createState() => _EditVehiclePageState();
}

class _EditVehiclePageState extends State<EditVehiclePage> {
  final _plateController = TextEditingController();
  late VehicleType _selectedType;
  String? _photoPath;
  String? _plateError;
  bool _isProcessing = false;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _plateController.text = widget.vehicle.plateNumber;
    _selectedType = VehicleType.values.firstWhere(
      (type) => type.defaultLabel == widget.vehicle.type,
      orElse: () => VehicleType.car,
    );

    _plateController.addListener(_checkChanges);
  }

  @override
  void dispose() {
    _plateController.dispose();
    super.dispose();
  }

  void _checkChanges() {
    final hasPlateChanges = _plateController.text != widget.vehicle.plateNumber;
    final hasTypeChanges = _selectedType.defaultLabel != widget.vehicle.type;
    final hasPhotoChanges = _photoPath != null;

    setState(() {
      _hasChanges = hasPlateChanges || hasTypeChanges || hasPhotoChanges;
    });
  }

  void _validateForm() {
    setState(() {
      if (_plateController.text.isEmpty) {
        _plateError = 'Please enter a plate number';
      } else {
        _validatePlateNumber(_plateController.text);
      }
    });
  }

  void _validatePlateNumber(String value) {
    final regex = RegExp(r'^[A-Z]{1,2}\s?\d{1,4}\s?[A-Z]{1,3}$');
    setState(() {
      _plateError =
          regex.hasMatch(value) ? null : 'Invalid format. Example: BP 1234 JK';
    });
  }

  Future<bool> _confirmDiscard(BuildContext context) async {
    if (!_hasChanges) return true;
    if (!context.mounted) return false;

    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context);

    // Return the result directly from showDialog
    return await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (dialogContext) => AlertDialog(
            title: Text(loc.unsavedChanges),
            content: Text(loc.unsavedChangesDesc),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(false),
                child: Text(
                  loc.keep,
                  style: TextStyle(color: theme.colorScheme.primary),
                ),
              ),
              FilledButton(
                onPressed: () => Navigator.of(dialogContext).pop(true),
                style: FilledButton.styleFrom(
                  backgroundColor: theme.colorScheme.error,
                  foregroundColor: theme.colorScheme.onError,
                ),
                child: Text(loc.discard),
              ),
            ],
          ),
        ) ??
        false;
  }

  void _handleSubmit() {
    _validateForm();

    if (_plateError != null) return;

    setState(() => _isProcessing = true);

    context.read<VehicleBloc>().add(
          EditVehicleEvent(
            id: widget.vehicle.id,
            plateNumber: _plateController.text != widget.vehicle.plateNumber
                ? _plateController.text
                : null,
            type: _selectedType.defaultLabel != widget.vehicle.type
                ? _selectedType.defaultLabel
                : null,
            photoPath: _photoPath,
          ),
        );
  }

  Future<void> _showSuccessAndNavigateBack(BuildContext context) async {
    if (!context.mounted) return;

    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context);

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check_circle_outline_rounded,
                  size: 48,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                loc.vehicleUpdated,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                loc.vehicleUpdatedDesc,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: () {
                  // First pop the dialog
                  Navigator.of(dialogContext).pop();
                  // Use a micro-task to ensure the first pop is complete
                  Future.microtask(() {
                    if (context.mounted) {
                      Navigator.of(context).pop(true);
                    }
                  });
                },
                style: FilledButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('OK'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;

        if (!_hasChanges) {
          if (context.mounted) {
            Navigator.of(context).pop();
          }
          return;
        }

        final navigationContext = context;
        final shouldPop = await _confirmDiscard(navigationContext);
        if (shouldPop && navigationContext.mounted) {
          Navigator.of(navigationContext).pop();
        }
      },
      child: BlocConsumer<VehicleBloc, VehicleState>(
        listener: (listenerContext, state) {
          if (state is VehicleError) {
            if (!listenerContext.mounted) return;

            setState(() => _isProcessing = false);
            ScaffoldMessenger.of(listenerContext).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: theme.colorScheme.error,
                behavior: SnackBarBehavior.floating,
              ),
            );
          } else if (state is VehiclesLoaded) {
            _showSuccessAndNavigateBack(listenerContext);
          }
        },
        builder: (builderContext, state) {
          return Scaffold(
            appBar: AppBar(
              title: Text(loc.editVehicle),
              centerTitle: false,
            ),
            body: CustomScrollView(
              slivers: [
                if (_isProcessing)
                  SliverToBoxAdapter(
                    child: LinearProgressIndicator(
                      backgroundColor:
                          theme.colorScheme.primary.withOpacity(0.1),
                    ),
                  ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          loc.lastUpdated.replaceFirst(
                            '%s',
                            DateFormat('dd MMM yyyy, HH:mm')
                                .format(widget.vehicle.updatedAt),
                          ),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 24),
                        PhotoPicker(
                          currentPhotoPath: _photoPath,
                          currentPhotoUrl: widget.vehicle.photoUrl,
                          onPhotoSelected: (path) {
                            setState(() {
                              _photoPath = path;
                            });
                            _checkChanges();
                          },
                        ),
                        const SizedBox(height: 24),
                        VehicleTypeSelector(
                          selectedType: _selectedType,
                          onTypeSelected: (type) {
                            setState(() => _selectedType = type);
                            _checkChanges();
                          },
                        ),
                        const SizedBox(height: 24),
                        PlateNumberInput(
                          controller: _plateController,
                          errorText: _plateError,
                          onChanged: (value) {
                            if (_plateError != null) {
                              _validatePlateNumber(value);
                            }
                            _checkChanges();
                          },
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            bottomNavigationBar: _hasChanges
                ? Container(
                    padding: EdgeInsets.only(
                      left: 20,
                      right: 20,
                      bottom: MediaQuery.of(builderContext).padding.bottom + 16,
                      top: 16,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      border: Border(
                        top: BorderSide(
                          color: theme.colorScheme.outline.withOpacity(0.1),
                        ),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: theme.shadowColor.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, -5),
                        ),
                      ],
                    ),
                    child: FilledButton(
                      onPressed: _isProcessing ? null : _handleSubmit,
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        _isProcessing ? loc.updatingVehicle : loc.saveChanges,
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: theme.colorScheme.onPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  )
                : null,
          );
        },
      ),
    );
  }
}

extension BuildContextExtension on BuildContext {
  void pop([Object? result]) => Navigator.of(this).pop(result);
}
