// lib/features/ticket_management/domain/usecases/record_parking_usecase.dart

import '../repositories/i_parking_record_repository.dart';

class RecordParkingUseCase {
  final IParkingRecordRepository _repository;

  RecordParkingUseCase(this._repository);

  Future<String> call({
    required String attendantId,
    required String plateNumber,
    required String vehicleType,
    required String locationName,
    required double latitude,
    required double longitude,
    required DateTime entryTime,
    required DateTime exitTime,
  }) async {
    // Calculate price based on vehicle type and duration
    final duration = exitTime.difference(entryTime);
    final price = _calculatePrice(vehicleType, duration);

    return await _repository.createParkingRecord(
      attendantId: attendantId,
      vehiclePlateNumber: plateNumber,
      vehicleType: vehicleType,
      locationName: locationName,
      latitude: latitude,
      longitude: longitude,
      amount: price,
      entryTime: entryTime, // Added
      exitTime: exitTime, // Added
    );
  }

  double _calculatePrice(String vehicleType, Duration duration) {
    // Base prices
    double basePrice;
    switch (vehicleType.toLowerCase()) {
      case 'motorcycle':
        basePrice = 2000.0;
        break;
      case 'car':
        basePrice = 5000.0;
        break;
      case 'truck':
        basePrice = 10000.0;
        break;
      case 'bus':
        basePrice = 15000.0;
        break;
      default:
        basePrice = 5000.0;
    }

    // Calculate hours (round up to nearest hour)
    final hours = (duration.inMinutes / 60).ceil();

    // First hour is base price, additional hours are half the base price
    if (hours <= 1) {
      return basePrice;
    } else {
      return basePrice + (basePrice * 0.5 * (hours - 1));
    }
  }
}
