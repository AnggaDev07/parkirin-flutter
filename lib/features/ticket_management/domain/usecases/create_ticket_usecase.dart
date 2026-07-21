// lib/features/ticket_management/domain/usecases/create_ticket_usecase.dart

import 'package:parkirin/features/ticket_management/domain/entities/ticket.dart';
import 'package:parkirin/features/ticket_management/domain/repositories/i_ticket_repository.dart';
import 'package:parkirin/features/vehicle_management/domain/entities/vehicle.dart';
import 'package:parkirin/features/vehicle_management/domain/repositories/i_vehicle_repository.dart';

class CreateTicketUseCase {
  final ITicketRepository _ticketRepository;
  final IVehicleRepository _vehicleRepository;

  CreateTicketUseCase(this._ticketRepository, this._vehicleRepository);

  Future<String> call({
    required String attendantId,
    required String plateNumber,
    required String vehicleType,
    required String locationName,
    required double latitude,
    required double longitude,
    required PaymentType paymentType,
  }) async {
    // Validate plate number format
    if (!isValidPlateNumber(plateNumber)) {
      throw Exception('Invalid plate number format');
    }

    // Find vehicle owner by plate number
    final vehicle =
        await _vehicleRepository.findVehicleByPlateNumber(plateNumber);
    if (vehicle == null) {
      throw Exception('No registered vehicle found with this plate number');
    }

    // Calculate price based on vehicle type
    final price = calculatePrice(vehicleType);

    // Create the ticket
    return await _ticketRepository.createParkingTicket(
      userId: vehicle.userId,
      attendantId: attendantId,
      vehiclePlateNumber: plateNumber.toUpperCase(),
      vehicleType: vehicleType,
      locationName: locationName,
      latitude: latitude,
      longitude: longitude,
      amount: price,
      paymentType: paymentType,
    );
  }

  bool isValidPlateNumber(String plateNumber) {
    // Normalize the plate number first
    final normalized = _normalizePlateNumber(plateNumber);

    // Indonesian license plate format without spaces: AA1234BB or AB1234CD
    final regex = RegExp(r'^[A-Z]{1,2}\d{1,4}[A-Z]{1,3}$');
    return regex.hasMatch(normalized);
  }

  Future<Vehicle?> findVehicleByPlateNumber(String plateNumber) async {
    return await _vehicleRepository.findVehicleByPlateNumber(plateNumber);
  }

  String _normalizePlateNumber(String plateNumber) {
    // Remove quotes, spaces, and convert to uppercase
    return plateNumber
        .replaceAll('"', '')
        .replaceAll("'", '')
        .replaceAll(' ', '')
        .toUpperCase();
  }

  double calculatePrice(String vehicleType) {
    // Basic pricing logic - we can make this more sophisticated later
    switch (vehicleType.toLowerCase()) {
      case 'motorcycle':
        return 2000.0;
      case 'car':
        return 5000.0;
      case 'truck':
        return 10000.0;
      case 'bus':
        return 15000.0;
      default:
        return 5000.0;
    }
  }
}
