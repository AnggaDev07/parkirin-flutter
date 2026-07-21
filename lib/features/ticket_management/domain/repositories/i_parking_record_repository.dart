// lib/features/ticket_management/domain/repositories/i_parking_record_repository.dart

import '../entities/parking_record.dart';

abstract class IParkingRecordRepository {
  // Create a new parking record
  Future<String> createParkingRecord({
    required String attendantId,
    required String vehiclePlateNumber,
    required String vehicleType,
    required String locationName,
    required double latitude,
    required double longitude,
    required double amount,
    required DateTime entryTime, // Added
    required DateTime exitTime,
  });

  // Get records by attendant
  Future<List<ParkingRecord>> getAttendantRecords({
    required String attendantId,
    ParkingRecordStatus? status,
    DateTime? startDate,
    DateTime? endDate,
    bool excludeCompleted = false,
    int? limit,
  });

  // Get a specific record
  Future<ParkingRecord?> getParkingRecord(String id);

  // Update record status (e.g., when vehicle leaves)
  Future<void> updateRecordStatus({
    required String id,
    required ParkingRecordStatus status,
    DateTime? exitTime,
  });

  // Search records
  Future<List<ParkingRecord>> searchRecords({
    required String attendantId,
    String? plateNumber,
    DateTime? date,
    ParkingRecordStatus? status,
  });

  // Get real-time updates for a specific record
  Stream<ParkingRecord> getParkingRecordStream(String id);

  // Get real-time updates for attendant's records
  Stream<List<ParkingRecord>> getAttendantRecordsStream(String attendantId);
}
