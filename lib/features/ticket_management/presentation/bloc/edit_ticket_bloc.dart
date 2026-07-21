// lib/features/ticket_management/presentation/bloc/edit_ticket_bloc.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:parkirin/features/ticket_management/domain/repositories/i_ticket_repository.dart';
import 'package:parkirin/features/ticket_management/domain/usecases/edit_ticket_usecase.dart';
import 'package:parkirin/features/ticket_management/presentation/bloc/edit_ticket_event.dart';
import 'package:parkirin/features/ticket_management/presentation/bloc/edit_ticket_state.dart';
import 'package:parkirin/features/vehicle_management/domain/repositories/i_vehicle_repository.dart';

class EditTicketBloc extends Bloc<EditTicketEvent, EditTicketState> {
  final EditTicketUseCase _editTicketUseCase;
  final ITicketRepository _ticketRepository;
  final IVehicleRepository _vehicleRepository;

  EditTicketBloc({
    required EditTicketUseCase editTicketUseCase,
    required ITicketRepository ticketRepository,
    required IVehicleRepository vehicleRepository,
  })  : _editTicketUseCase = editTicketUseCase,
        _ticketRepository = ticketRepository,
        _vehicleRepository = vehicleRepository,
        super(EditTicketInitial()) {
    on<ValidateEditTime>(_onValidateEditTime);
    on<ValidatePlateNumber>(_onValidatePlateNumber);
    on<EditExistingTicket>(_onEditExistingTicket);
  }

  Future<void> _onValidateEditTime(
    ValidateEditTime event,
    Emitter<EditTicketState> emit,
  ) async {
    try {
      final ticket = await _ticketRepository.getTicketById(event.ticketId);
      if (ticket == null) {
        emit(const EditTicketError('Ticket not found'));
        return;
      }

      if (ticket.isEditable) {
        emit(EditTimeValid(
          remainingTime: ticket.remainingEditTime,
          ticket: ticket,
        ));
      } else {
        emit(EditTimeExpired(ticket.remainingEditTime));
      }
    } catch (e) {
      emit(EditTicketError(e.toString()));
    }
  }

  Future<void> _onValidatePlateNumber(
    ValidatePlateNumber event,
    Emitter<EditTicketState> emit,
  ) async {
    try {
      final vehicle = await _vehicleRepository.findVehicleByPlateNumber(
        event.plateNumber,
      );

      if (vehicle != null) {
        emit(PlateNumberValidated(vehicle: vehicle));
      } else {
        emit(const PlateNumberInvalid(
          'No registered vehicle found with this plate number',
        ));
      }
    } catch (e) {
      emit(EditTicketError(e.toString()));
    }
  }

  Future<void> _onEditExistingTicket(
    EditExistingTicket event,
    Emitter<EditTicketState> emit,
  ) async {
    try {
      await _editTicketUseCase(
        ticketId: event.ticketId,
        vehiclePlateNumber: event.vehiclePlateNumber,
        vehicleType: event.vehicleType,
        paymentType: event.paymentType,
      );

      final updatedTicket =
          await _ticketRepository.getTicketById(event.ticketId);
      if (updatedTicket == null) {
        emit(const EditTicketError('Failed to fetch updated ticket'));
        return;
      }

      emit(EditTicketSuccess(updatedTicket));
    } catch (e) {
      emit(EditTicketError(e.toString()));
    }
  }
}
