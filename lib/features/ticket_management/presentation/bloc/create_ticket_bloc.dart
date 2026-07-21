// lib/features/ticket_management/presentation/bloc/create_ticket_bloc.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:parkirin/features/ticket_management/domain/usecases/create_ticket_usecase.dart';
import 'package:parkirin/features/ticket_management/presentation/bloc/create_ticket_event.dart';
import 'package:parkirin/features/ticket_management/presentation/bloc/create_ticket_state.dart';

class CreateTicketBloc extends Bloc<CreateTicketEvent, CreateTicketState> {
  final CreateTicketUseCase _createTicketUseCase;

  CreateTicketBloc({
    required CreateTicketUseCase createTicketUseCase,
  })  : _createTicketUseCase = createTicketUseCase,
        super(CreateTicketInitial()) {
    on<ValidatePlateNumber>(_onValidatePlateNumber);
    on<CalculatePrice>(_onCalculatePrice);
    on<CreateNewTicket>(_onCreateNewTicket);
  }

  Future<void> _onValidatePlateNumber(
    ValidatePlateNumber event,
    Emitter<CreateTicketState> emit,
  ) async {
    emit(const CreateTicketLoading('Validating plate number...'));
    try {
      if (!_createTicketUseCase.isValidPlateNumber(event.plateNumber)) {
        emit(const PlateNumberInvalid(
            'Invalid plate number format. Example: BP 1234 JK'));
        return;
      }

      final vehicle = await _createTicketUseCase.findVehicleByPlateNumber(
        event.plateNumber,
      );

      if (vehicle == null) {
        emit(const PlateNumberInvalid(
          'Vehicle not found. Please check the plate number or ask driver to register.',
        ));
        return;
      }

      final estimatedPrice = _createTicketUseCase.calculatePrice(vehicle.type);

      emit(PlateNumberValidated(
        vehicle: vehicle,
        estimatedPrice: estimatedPrice,
      ));
    } catch (e) {
      debugPrint('Error validating plate number: $e');
      emit(CreateTicketError(e.toString()));
    }
  }

  Future<void> _onCalculatePrice(
    CalculatePrice event,
    Emitter<CreateTicketState> emit,
  ) async {
    try {
      final price = _createTicketUseCase.calculatePrice(event.vehicleType);
      emit(PriceCalculated(price));
    } catch (e) {
      emit(CreateTicketError(e.toString()));
    }
  }

  Future<void> _onCreateNewTicket(
    CreateNewTicket event,
    Emitter<CreateTicketState> emit,
  ) async {
    emit(const CreateTicketLoading('Creating parking ticket...'));
    try {
      final ticketId = await _createTicketUseCase(
        attendantId: event.attendantId,
        plateNumber: event.plateNumber,
        vehicleType: event.vehicleType,
        locationName: event.locationName,
        latitude: event.latitude,
        longitude: event.longitude,
        paymentType: event.paymentType,
      );

      emit(TicketCreated(ticketId));
    } catch (e) {
      emit(CreateTicketError(e.toString()));
    }
  }
}
