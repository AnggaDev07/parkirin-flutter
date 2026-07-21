// lib/features/vehicle_management/presentation/pages/add_vehicle_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:parkirin/localization/app_localizations.dart';

import '../bloc/vehicle_bloc.dart';
import '../bloc/vehicle_event.dart';
import '../bloc/vehicle_state.dart';
import '../widgets/photo_picker.dart';
import '../widgets/plate_number_input.dart';
import '../widgets/vehicle_type_selector.dart';

class AddVehiclePage extends StatefulWidget {
  final String userId;

  const AddVehiclePage({
    super.key,
    required this.userId,
  });

  @override
  State<AddVehiclePage> createState() => _AddVehiclePageState();
}

class _AddVehiclePageState extends State<AddVehiclePage> {
  final _plateController = TextEditingController();
  VehicleType _selectedType = VehicleType.car;
  String? _photoPath;
  String? _plateError;
  String? _photoError;
  bool _isProcessing = false;

  AppLocalizations get loc => AppLocalizations.of(context);

  @override
  void dispose() {
    _plateController.dispose();
    super.dispose();
  }

  void _validateForm() {
    setState(() {
      // Validate photo
      _photoError = _photoPath == null ? loc.photoRequired : null;

      // Validate plate number
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

  void _handleSubmit() {
    _validateForm();

    if (_photoError != null || _plateError != null) {
      return;
    }

    if (!mounted) return;

    setState(() => _isProcessing = true);

    context.read<VehicleBloc>().add(
          AddVehicleEvent(
            userId: widget.userId,
            plateNumber: _plateController.text,
            type: _selectedType.name,
            photoPath: _photoPath!,
          ),
        );
  }

  Future<void> _showSuccessAndNavigateBack(BuildContext parentContext) async {
    // Store theme and loc before async operation
    final theme = Theme.of(parentContext);
    final loc = AppLocalizations.of(parentContext);

    if (!parentContext.mounted) return;

    await showDialog(
      context: parentContext,
      barrierDismissible: false,
      builder: (dialogContext) {
        return Dialog(
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
                  loc.vehicleAdded,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  loc.vehicleAddedDesc,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(loc.backToVehicles),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (!parentContext.mounted) return;
    Navigator.pop(parentContext, true);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context);

    return BlocConsumer<VehicleBloc, VehicleState>(
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
            title: Text(loc.addVehicle),
            centerTitle: false,
            surfaceTintColor: Colors.transparent,
          ),
          body: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (_isProcessing)
                        LinearProgressIndicator(
                          backgroundColor:
                              theme.colorScheme.primary.withOpacity(0.1),
                        ),
                      const SizedBox(height: 20),
                      Text(
                        loc.vehicleDetails,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 24),
                      PhotoPicker(
                        currentPhotoPath: _photoPath,
                        onPhotoSelected: (path) {
                          setState(() {
                            _photoPath = path;
                            _photoError = null;
                          });
                        },
                      ),
                      if (_photoError != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            _photoError!,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.error,
                            ),
                          ),
                        ),
                      const SizedBox(height: 24),
                      // Vehicle Type Section
                      const SizedBox(height: 16),
                      VehicleTypeSelector(
                        selectedType: _selectedType,
                        onTypeSelected: (type) {
                          setState(() => _selectedType = type);
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
                        },
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ],
          ),
          bottomNavigationBar: Container(
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
                _isProcessing ? loc.processing : loc.saveVehicle,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.onPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
