// lib/features/ticket_management/presentation/bloc/record_parking_bloc.dart

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:parkirin/features/ticket_management/domain/usecases/record_parking_usecase.dart';
import 'package:parkirin/features/ticket_management/presentation/bloc/record_parking_event.dart';
import 'package:parkirin/features/ticket_management/presentation/bloc/record_parking_state.dart';

import '../../domain/repositories/i_parking_record_repository.dart';

class RecordParkingBloc extends Bloc<RecordParkingEvent, RecordParkingState> {
  final RecordParkingUseCase _recordParkingUseCase;
  final IParkingRecordRepository _repository;

  RecordParkingBloc({
    required RecordParkingUseCase recordParkingUseCase,
    required IParkingRecordRepository repository,
  })  : _recordParkingUseCase = recordParkingUseCase,
        _repository = repository,
        super(RecordParkingInitial()) {
    on<CalculatePrice>(_onCalculatePrice);
    on<CreateParkingRecord>(_onCreateParkingRecord);
  }

  void _onCalculatePrice(
    CalculatePrice event,
    Emitter<RecordParkingState> emit,
  ) {
    try {
      // Using the same price calculation logic from use case
      double price = 5000.0; // Default price
      switch (event.vehicleType.toLowerCase()) {
        case 'motorcycle':
          price = 2000.0;
          break;
        case 'car':
          price = 5000.0;
          break;
        case 'truck':
          price = 10000.0;
          break;
        case 'bus':
          price = 15000.0;
          break;
      }
      emit(PriceCalculated(price));
    } catch (e) {
      emit(RecordParkingError(e.toString()));
    }
  }

  Future<void> _onCreateParkingRecord(
    CreateParkingRecord event,
    Emitter<RecordParkingState> emit,
  ) async {
    try {
      emit(const RecordParkingLoading('Creating parking record...'));

      final recordId = await _recordParkingUseCase(
        attendantId: event.attendantId,
        plateNumber: event.plateNumber,
        vehicleType: event.vehicleType,
        locationName: event.locationName,
        latitude: event.latitude,
        longitude: event.longitude,
        entryTime: event.entryTime,
        exitTime: event.exitTime,
      );

      // Get the created record
      final record = await _repository.getParkingRecord(recordId);
      if (record == null) {
        throw Exception('Failed to retrieve created record');
      }

      debugPrint('Created parking record with ID: $recordId');
      emit(RecordCreated(recordId: recordId, record: record));
    } catch (e) {
      debugPrint('Error creating parking record: $e');
      emit(RecordParkingError(e.toString()));
    }
  }
}
