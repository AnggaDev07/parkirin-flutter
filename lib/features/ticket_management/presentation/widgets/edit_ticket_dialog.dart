import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:parkirin/features/ticket_management/domain/entities/ticket.dart';
import 'package:parkirin/features/ticket_management/presentation/bloc/edit_ticket_bloc.dart';
import 'package:parkirin/features/ticket_management/presentation/bloc/edit_ticket_event.dart';
import 'package:parkirin/features/ticket_management/presentation/bloc/edit_ticket_state.dart';

class EditTicketDialog extends StatefulWidget {
  final Ticket ticket;
  final Duration remainingTime;

  const EditTicketDialog({
    super.key,
    required this.ticket,
    required this.remainingTime,
  });

  @override
  State<EditTicketDialog> createState() => _EditTicketDialogState();
}

class _EditTicketDialogState extends State<EditTicketDialog> {
  late TextEditingController _plateController;
  late PaymentType _selectedPaymentType;
  late String _selectedVehicleType;
  Timer? _timer;
  Duration _timeLeft = Duration.zero;
  bool _isValidatingPlate = false;

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _plateController =
        TextEditingController(text: widget.ticket.vehiclePlateNumber);
    _selectedPaymentType = widget.ticket.paymentType;
    _selectedVehicleType = widget.ticket.vehicleType;
    _timeLeft = widget.remainingTime;

    _plateController.addListener(() {
      if (_plateController.text.length >= 3) {
        context.read<EditTicketBloc>().add(
              ValidatePlateNumber(_plateController.text),
            );
      }
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_timeLeft > Duration.zero) {
          _timeLeft -= const Duration(seconds: 1);
        } else {
          _timer?.cancel();
          Navigator.of(context).pop();
        }
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _plateController.dispose();
    super.dispose();
  }

  bool _validatePlateNumber(String value) {
    final regex = RegExp(r'^[A-Z]{1,2}\s?\d{1,4}\s?[A-Z]{1,3}$');
    return regex.hasMatch(value.toUpperCase());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocListener<EditTicketBloc, EditTicketState>(
      listener: (context, state) {
        setState(() => _isValidatingPlate = state is EditTicketLoading);

        if (state is PlateNumberInvalid) {
          _formKey.currentState?.validate();
        }

        if (state is EditTicketSuccess || state is EditTicketError) {
          Navigator.of(context, rootNavigator: true).pop();
        }
      },
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.85,
          ),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Handle bar
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        margin: const EdgeInsets.only(bottom: 20),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.onSurface.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Edit Ticket',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.error.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.timer,
                                size: 16,
                                color: theme.colorScheme.error,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${_timeLeft.inMinutes}:${(_timeLeft.inSeconds % 60).toString().padLeft(2, '0')}',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.error,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    BlocBuilder<EditTicketBloc, EditTicketState>(
                      builder: (context, state) {
                        return TextFormField(
                          controller: _plateController,
                          textCapitalization: TextCapitalization.characters,
                          decoration: InputDecoration(
                            labelText: 'License Plate',
                            border: const OutlineInputBorder(),
                            suffixIcon: _isValidatingPlate
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2),
                                    ),
                                  )
                                : state is PlateNumberValidated
                                    ? const Icon(Icons.check_circle,
                                        color: Colors.green)
                                    : state is PlateNumberInvalid
                                        ? const Icon(Icons.error,
                                            color: Colors.red)
                                        : null,
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter license plate';
                            }
                            if (!_validatePlateNumber(value)) {
                              return 'Invalid plate number format';
                            }
                            if (state is PlateNumberInvalid) {
                              return state.error;
                            }
                            return null;
                          },
                        );
                      },
                    ),
                    const SizedBox(height: 16),

                    DropdownButtonFormField<String>(
                      value: _selectedVehicleType,
                      decoration: const InputDecoration(
                        labelText: 'Vehicle Type',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'car', child: Text('CAR')),
                        DropdownMenuItem(
                            value: 'motorcycle', child: Text('MOTORCYCLE')),
                        DropdownMenuItem(value: 'truck', child: Text('TRUCK')),
                        DropdownMenuItem(value: 'bus', child: Text('BUS')),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _selectedVehicleType = value);
                        }
                      },
                    ),
                    const SizedBox(height: 16),

                    DropdownButtonFormField<PaymentType>(
                      value: _selectedPaymentType,
                      decoration: const InputDecoration(
                        labelText: 'Payment Type',
                        border: OutlineInputBorder(),
                      ),
                      items: PaymentType.values.map((type) {
                        return DropdownMenuItem(
                          value: type,
                          child: Text(type.name.toUpperCase()),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _selectedPaymentType = value);
                        }
                      },
                    ),
                    const SizedBox(height: 24),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: const Text('Cancel'),
                        ),
                        const SizedBox(width: 8),
                        BlocBuilder<EditTicketBloc, EditTicketState>(
                          builder: (context, state) {
                            return FilledButton(
                              onPressed: _timeLeft > Duration.zero &&
                                      state is! EditTicketLoading &&
                                      (_plateController.text ==
                                              widget
                                                  .ticket.vehiclePlateNumber ||
                                          state is PlateNumberValidated)
                                  ? () {
                                      if (_formKey.currentState!.validate()) {
                                        Navigator.pop(context);
                                        context.read<EditTicketBloc>().add(
                                              EditExistingTicket(
                                                ticketId: widget.ticket.id,
                                                vehiclePlateNumber:
                                                    _plateController.text,
                                                vehicleType:
                                                    _selectedVehicleType,
                                                paymentType:
                                                    _selectedPaymentType,
                                              ),
                                            );
                                      }
                                    }
                                  : null,
                              child: state is EditTicketLoading
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                                Colors.white),
                                      ),
                                    )
                                  : const Text('Save Changes'),
                            );
                          },
                        ),
                      ],
                    ),
                    // Add extra bottom padding for keyboard
                    SizedBox(
                        height: MediaQuery.of(context).viewInsets.bottom > 0
                            ? 20
                            : 0),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
