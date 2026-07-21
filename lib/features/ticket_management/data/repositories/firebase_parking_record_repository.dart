// lib/features/ticket_management/data/repositories/firebase_parking_record_repository.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:parkirin/features/ticket_management/domain/entities/parking_record.dart';
import 'package:parkirin/features/ticket_management/domain/repositories/i_parking_record_repository.dart';

class FirebaseParkingRecordRepository implements IParkingRecordRepository {
  final FirebaseFirestore _firestore;
  late final CollectionReference _recordsCollection;

  FirebaseParkingRecordRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance {
    _recordsCollection = _firestore.collection('parking_records');
  }

  @override
  Future<String> createParkingRecord({
    required String attendantId,
    required String vehiclePlateNumber,
    required String vehicleType,
    required String locationName,
    required double latitude,
    required double longitude,
    required double amount,
    required DateTime entryTime,
    required DateTime exitTime,
  }) async {
    try {
      final docRef = _recordsCollection.doc();
      final now = DateTime.now();

      await docRef.set({
        'id': docRef.id,
        'attendantId': attendantId,
        'vehiclePlateNumber': vehiclePlateNumber.toUpperCase(),
        'vehicleType': vehicleType,
        'locationName': locationName,
        'latitude': latitude,
        'longitude': longitude,
        'entryTime': Timestamp.fromDate(entryTime), // Use provided entry time
        'exitTime': Timestamp.fromDate(exitTime),
        'amount': amount,
        'status': ParkingRecordStatus.completed
            .toString(), // Mark as completed immediately
        'createdAt': Timestamp.fromDate(now),
        'updatedAt': Timestamp.fromDate(now),
      });

      return docRef.id;
    } catch (e) {
      debugPrint('Error creating parking record: $e');
      throw Exception('Failed to create parking record: $e');
    }
  }

  @override
  Future<List<ParkingRecord>> getAttendantRecords({
    required String attendantId,
    ParkingRecordStatus? status,
    DateTime? startDate,
    DateTime? endDate,
    bool excludeCompleted = false,
    int? limit,
  }) async {
    try {
      Query query =
          _recordsCollection.where('attendantId', isEqualTo: attendantId);

      // Apply status filter if provided
      if (status != null) {
        query = query.where('status', isEqualTo: status.toString());
      }

      // Exclude completed records if requested
      if (excludeCompleted) {
        query = query.where('status',
            isNotEqualTo: ParkingRecordStatus.completed.toString());
      }

      // Apply date range filters
      if (startDate != null) {
        query = query.where('createdAt',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startDate));
      }

      if (endDate != null) {
        query = query.where('createdAt',
            isLessThanOrEqualTo:
                Timestamp.fromDate(endDate.add(const Duration(days: 1))));
      }

      // Add ordering
      query = query.orderBy('createdAt', descending: true);

      // Add limit if specified
      if (limit != null) {
        query = query.limit(limit);
      }

      final querySnapshot = await query.get();
      return querySnapshot.docs
          .map((doc) => _documentToParkingRecord(doc))
          .toList();
    } catch (e) {
      debugPrint('Error getting attendant records: $e');
      throw Exception('Failed to get attendant records: $e');
    }
  }

  @override
  Future<ParkingRecord?> getParkingRecord(String id) async {
    try {
      final docSnapshot = await _recordsCollection.doc(id).get();
      if (!docSnapshot.exists) return null;
      return _documentToParkingRecord(docSnapshot);
    } catch (e) {
      debugPrint('Error getting parking record: $e');
      throw Exception('Failed to get parking record: $e');
    }
  }

  @override
  Future<void> updateRecordStatus({
    required String id,
    required ParkingRecordStatus status,
    DateTime? exitTime,
  }) async {
    try {
      final updates = {
        'status': status.toString(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (exitTime != null) {
        updates['exitTime'] = Timestamp.fromDate(exitTime);
      }

      await _recordsCollection.doc(id).update(updates);
    } catch (e) {
      debugPrint('Error updating record status: $e');
      throw Exception('Failed to update record status: $e');
    }
  }

  @override
  Future<List<ParkingRecord>> searchRecords({
    required String attendantId,
    String? plateNumber,
    DateTime? date,
    ParkingRecordStatus? status,
  }) async {
    try {
      Query query =
          _recordsCollection.where('attendantId', isEqualTo: attendantId);

      if (plateNumber != null) {
        query = query.where('vehiclePlateNumber',
            isEqualTo: plateNumber.toUpperCase());
      }

      if (status != null) {
        query = query.where('status', isEqualTo: status.toString());
      }

      if (date != null) {
        final startOfDay = DateTime(date.year, date.month, date.day);
        final endOfDay = startOfDay.add(const Duration(days: 1));

        query = query
            .where('createdAt',
                isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
            .where('createdAt', isLessThan: Timestamp.fromDate(endOfDay));
      }

      final querySnapshot =
          await query.orderBy('createdAt', descending: true).get();
      return querySnapshot.docs
          .map((doc) => _documentToParkingRecord(doc))
          .toList();
    } catch (e) {
      debugPrint('Error searching records: $e');
      throw Exception('Failed to search records: $e');
    }
  }

  @override
  Stream<ParkingRecord> getParkingRecordStream(String id) {
    return _recordsCollection.doc(id).snapshots().map((doc) {
      if (!doc.exists) {
        throw Exception('Parking record not found');
      }
      return _documentToParkingRecord(doc);
    });
  }

  @override
  Stream<List<ParkingRecord>> getAttendantRecordsStream(String attendantId) {
    return _recordsCollection
        .where('attendantId', isEqualTo: attendantId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => _documentToParkingRecord(doc)).toList());
  }

  // Helper method to convert Firestore document to ParkingRecord entity
  ParkingRecord _documentToParkingRecord(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ParkingRecord(
      id: doc.id,
      attendantId: data['attendantId'],
      vehiclePlateNumber: data['vehiclePlateNumber'],
      vehicleType: data['vehicleType'],
      locationName: data['locationName'],
      latitude: data['latitude'],
      longitude: data['longitude'],
      entryTime: (data['entryTime'] as Timestamp).toDate(),
      exitTime: data['exitTime'] != null
          ? (data['exitTime'] as Timestamp).toDate()
          : null,
      amount: data['amount'],
      status: ParkingRecordStatus.values.firstWhere(
        (e) => e.toString() == data['status'],
      ),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }
}
