// lib/features/ticket_management/presentation/bloc/record_parking_state.dart

import 'package:equatable/equatable.dart';
import 'package:parkirin/features/ticket_management/domain/entities/parking_record.dart';

abstract class RecordParkingState extends Equatable {
  const RecordParkingState();

  @override
  List<Object?> get props => [];
}

class RecordParkingInitial extends RecordParkingState {}

class RecordParkingLoading extends RecordParkingState {
  final String message;

  const RecordParkingLoading(this.message);

  @override
  List<Object> get props => [message];
}

class PriceCalculated extends RecordParkingState {
  final double amount;

  const PriceCalculated(this.amount);

  @override
  List<Object> get props => [amount];
}

class RecordCreated extends RecordParkingState {
  final String recordId;
  final ParkingRecord record;

  const RecordCreated({
    required this.recordId,
    required this.record,
  });

  @override
  List<Object> get props => [recordId, record];
}

class RecordParkingError extends RecordParkingState {
  final String error;

  const RecordParkingError(this.error);

  @override
  List<Object> get props => [error];
}
