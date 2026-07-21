// lib/features/ticket_management/data/repositories/firebase_ticket_repository.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:parkirin/features/ticket_management/domain/entities/ticket.dart';
import 'package:parkirin/features/ticket_management/domain/repositories/i_ticket_repository.dart';

class FirebaseTicketRepository implements ITicketRepository {
  final FirebaseFirestore _firestore;
  late final CollectionReference _ticketsCollection;

  FirebaseTicketRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance {
    _ticketsCollection = _firestore.collection('tickets');
  }

  @override
  Future<int> getUserTicketsCount(String userId) async {
    try {
      final querySnapshot = await _ticketsCollection
          .where('userId', isEqualTo: userId)
          .count()
          .get();

      return querySnapshot.count ?? 0;
    } catch (e) {
      debugPrint('Error getting user tickets count: $e');
      throw Exception('Failed to get tickets count: $e');
    }
  }

  @override
  Future<List<Ticket>> getAttendantTickets({
    required String attendantId,
    TicketStatus? status,
    PaymentType? paymentType,
    DateTime? startDate,
    DateTime? endDate,
    bool excludeCompleted = false,
    int? limit,
  }) async {
    try {
      Query query =
          _ticketsCollection.where('attendantId', isEqualTo: attendantId);

      // Apply status filter if provided
      if (status != null) {
        // Convert enum to string without the enum type prefix
        final statusStr = 'TicketStatus.${status.name}';
        debugPrint('Adding status filter: $statusStr');
        query = query.where('status', isEqualTo: statusStr);
      }

      // Add payment type filter with explicit enum value string
      if (paymentType != null) {
        final paymentTypeStr = 'PaymentType.${paymentType.name}';
        debugPrint('Adding payment type filter: $paymentTypeStr');
        query = query.where('paymentType', isEqualTo: paymentTypeStr);
      }

      // Exclude completed tickets if requested
      if (excludeCompleted) {
        query = query.where('status', isNotEqualTo: 'TicketStatus.completed');
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

      debugPrint('Executing query...');
      final querySnapshot = await query.get();
      debugPrint('Got ${querySnapshot.docs.length} documents');

      return querySnapshot.docs.map((doc) => _documentToTicket(doc)).toList();
    } catch (e) {
      debugPrint('Error getting attendant tickets: $e');
      throw Exception('Failed to get attendant tickets: $e');
    }
  }

  @override
  Future<void> editTicket({
    required String ticketId,
    String? vehiclePlateNumber,
    String? vehicleType,
    double? amount,
    PaymentType? paymentType,
  }) async {
    try {
      final ticket = await getTicketById(ticketId);
      if (ticket == null) {
        throw Exception('Ticket not found');
      }

      if (!ticket.isEditable) {
        final remaining = ticket.remainingEditTime;
        throw Exception(
          'Ticket cannot be edited. Time window expired ${-remaining.inMinutes} minutes ago.',
        );
      }

      final updates = <String, dynamic>{
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (vehiclePlateNumber != null) {
        updates['vehiclePlateNumber'] = vehiclePlateNumber.toUpperCase();
      }
      if (vehicleType != null) {
        updates['vehicleType'] = vehicleType;
      }
      if (amount != null) {
        updates['amount'] = amount;
      }
      if (paymentType != null) {
        updates['paymentType'] = paymentType.toString();

        // Update status and payment status based on payment type
        if (paymentType == PaymentType.cash) {
          updates['status'] = TicketStatus.completed.toString();
          updates['paymentStatus'] = PaymentStatus.paid.toString();
          updates['exitTime'] = Timestamp.fromDate(DateTime.now());
        } else if (ticket.status == TicketStatus.completed) {
          // If changing from cash to cashless, reset to pending
          updates['status'] = TicketStatus.pending.toString();
          updates['paymentStatus'] = PaymentStatus.unpaid.toString();
          updates['exitTime'] = null;
        }
      }

      await _ticketsCollection.doc(ticketId).update(updates);
    } catch (e) {
      throw Exception('Failed to edit ticket: $e');
    }
  }

  @override
  Future<int> getUserTicketsCountByStatus(
      String userId, TicketStatus status) async {
    try {
      final querySnapshot = await _ticketsCollection
          .where('userId', isEqualTo: userId)
          .where('status', isEqualTo: status.toString())
          .count()
          .get();

      return querySnapshot.count ?? 0;
    } catch (e) {
      debugPrint('Error getting user tickets count by status: $e');
      throw Exception('Failed to get tickets count: $e');
    }
  }

  @override
  Future<List<Ticket>> getUserTickets(String userId) async {
    try {
      final querySnapshot = await _ticketsCollection
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs.map((doc) => _documentToTicket(doc)).toList();
    } catch (e) {
      throw Exception('Failed to get user tickets: $e');
    }
  }

  @override
  Future<Ticket?> getTicketById(String ticketId) async {
    try {
      final docSnapshot = await _ticketsCollection.doc(ticketId).get();
      if (!docSnapshot.exists) return null;
      return _documentToTicket(docSnapshot);
    } catch (e) {
      throw Exception('Failed to get ticket: $e');
    }
  }

  @override
  Future<List<Ticket>> getActiveUserTickets(String userId) async {
    try {
      final querySnapshot = await _ticketsCollection
          .where('userId', isEqualTo: userId)
          .where('status', isEqualTo: TicketStatus.active.toString())
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs.map((doc) => _documentToTicket(doc)).toList();
    } catch (e) {
      throw Exception('Failed to get active tickets: $e');
    }
  }

  @override
  Future<List<Ticket>> getUserTicketsByDateRange({
    required String userId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final querySnapshot = await _ticketsCollection
          .where('userId', isEqualTo: userId)
          .where('createdAt',
              isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .where('createdAt',
              isLessThanOrEqualTo: Timestamp.fromDate(
                  endDate.add(const Duration(days: 1)))) // Add this adjustment
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs.map((doc) => _documentToTicket(doc)).toList();
    } catch (e) {
      throw Exception('Failed to get tickets by date range: $e');
    }
  }

  @override
  Stream<Ticket> getTicketStream(String ticketId) {
    return _ticketsCollection.doc(ticketId).snapshots().map((doc) {
      if (!doc.exists) {
        throw Exception('Ticket not found');
      }
      return _documentToTicket(doc);
    });
  }

  @override
  Stream<List<Ticket>> getUserTicketsStream(String userId) {
    return _ticketsCollection
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => _documentToTicket(doc)).toList());
  }

  @override
  Future<void> updatePaymentStatus({
    required String ticketId,
    required PaymentStatus status,
    required PaymentType type,
  }) async {
    try {
      await _ticketsCollection.doc(ticketId).update({
        'paymentStatus': status.toString(),
        'paymentType': type.toString(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to update payment status: $e');
    }
  }

  @override
  Future<void> updateTicketStatus({
    required String ticketId,
    required TicketStatus status,
  }) async {
    try {
      await _ticketsCollection.doc(ticketId).update({
        'status': status.toString(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to update ticket status: $e');
    }
  }

  @override
  Future<String> createParkingTicket({
    required String userId,
    required String attendantId,
    required String vehiclePlateNumber,
    required String vehicleType,
    required String locationName,
    required double latitude,
    required double longitude,
    required double amount,
    required PaymentType paymentType,
  }) async {
    try {
      final docRef = _ticketsCollection.doc();
      final now = DateTime.now();

      // Set status based on payment type
      final initialStatus = paymentType == PaymentType.cash
          ? TicketStatus.completed
          : TicketStatus.pending;

      // Set payment status based on payment type
      final initialPaymentStatus = paymentType == PaymentType.cash
          ? PaymentStatus.paid
          : PaymentStatus.unpaid;

      await docRef.set({
        'id': docRef.id,
        'userId': userId,
        'attendantId': attendantId,
        'vehiclePlateNumber': vehiclePlateNumber,
        'vehicleType': vehicleType,
        'locationName': locationName,
        'latitude': latitude,
        'longitude': longitude,
        'entryTime': Timestamp.fromDate(now),
        'exitTime':
            paymentType == PaymentType.cash ? Timestamp.fromDate(now) : null,
        'amount': amount,
        'status': initialStatus.toString(),
        'paymentStatus': initialPaymentStatus.toString(),
        'paymentType': paymentType.toString(),
        'createdAt': Timestamp.fromDate(now),
        'updatedAt': Timestamp.fromDate(now),
      });

      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create parking ticket: $e');
    }
  }

  @override
  Future<List<Ticket>> searchTickets({
    required String userId,
    String? plateNumber,
    DateTime? date,
    TicketStatus? status,
    PaymentStatus? paymentStatus,
  }) async {
    try {
      Query query = _ticketsCollection.where('userId', isEqualTo: userId);

      if (plateNumber != null) {
        query = query.where('vehiclePlateNumber',
            isEqualTo: plateNumber.toUpperCase());
      }

      if (status != null) {
        query = query.where('status', isEqualTo: status.toString());
      }

      if (paymentStatus != null) {
        query =
            query.where('paymentStatus', isEqualTo: paymentStatus.toString());
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

      return querySnapshot.docs.map((doc) => _documentToTicket(doc)).toList();
    } catch (e) {
      throw Exception('Failed to search tickets: $e');
    }
  }

  // Helper method to convert Firestore document to Ticket entity
  Ticket _documentToTicket(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Ticket(
      id: doc.id,
      userId: data['userId'],
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
      status: TicketStatus.values.firstWhere(
        (e) => e.toString() == data['status'],
      ),
      paymentStatus: PaymentStatus.values.firstWhere(
        (e) => e.toString() == data['paymentStatus'],
      ),
      paymentType: PaymentType.values.firstWhere(
        (e) => e.toString() == data['paymentType'],
      ),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  // Helper method to populate test data
  Future<void> populateTestData(String userId, String attendantId) async {
    try {
      final batch = _firestore.batch();
      final now = DateTime.now();

      // Sample locations
      final locations = [
        {'name': 'Mall Central Park', 'lat': -6.1774, 'lng': 106.7907},
        {'name': 'Plaza Senayan', 'lat': -6.2255, 'lng': 106.7997},
        {'name': 'Grand Indonesia', 'lat': -6.1947, 'lng': 106.8197},
      ];

      // Sample vehicle types
      final vehicleTypes = ['Car', 'Motorcycle', 'SUV'];

      // Create 10 test tickets
      for (var i = 0; i < 10; i++) {
        final docRef = _ticketsCollection.doc();
        final location = locations[i % locations.length];
        final vehicleType = vehicleTypes[i % vehicleTypes.length];

        // Create tickets with varying dates (some recent, some older)
        final ticketDate = now.subtract(Duration(days: i * 2));
        final exitTime =
            i < 5 ? ticketDate.add(const Duration(hours: 3)) : null;

        final ticketData = {
          'id': docRef.id,
          'userId': userId,
          'attendantId': attendantId,
          'vehiclePlateNumber': 'B ${1234 + i} XYZ',
          'vehicleType': vehicleType,
          'locationName': location['name'],
          'latitude': location['lat'],
          'longitude': location['lng'],
          'entryTime': Timestamp.fromDate(ticketDate),
          'exitTime': exitTime != null ? Timestamp.fromDate(exitTime) : null,
          'amount': 5000.0 + (i * 1000),
          'status': i < 3
              ? TicketStatus.active.toString()
              : i < 6
                  ? TicketStatus.completed.toString()
                  : TicketStatus.pending.toString(),
          'paymentStatus': i < 6
              ? PaymentStatus.paid.toString()
              : PaymentStatus.unpaid.toString(),
          'paymentType': i % 2 == 0
              ? PaymentType.cash.toString()
              : PaymentType.cashless.toString(),
          'createdAt': Timestamp.fromDate(ticketDate),
          'updatedAt': Timestamp.fromDate(ticketDate),
        };

        batch.set(docRef, ticketData);
      }

      await batch.commit();
    } catch (e) {
      debugPrint('Error populating test data: $e');
      throw Exception('Failed to populate test data: $e');
    }
  }
}
