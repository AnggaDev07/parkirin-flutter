// lib/features/authentication/data/repositories/user_repository.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:parkirin/core/utils/password_utils.dart';

import '../../domain/entities/parking_attendant_model.dart';
import '../../domain/entities/user_model.dart';

class UserRepository {
  final CollectionReference _usersCollection;
  final CollectionReference _parkingAttendantsCollection;

  UserRepository({FirebaseFirestore? firestore})
      : _usersCollection =
            (firestore ?? FirebaseFirestore.instance).collection('users'),
        _parkingAttendantsCollection = (firestore ?? FirebaseFirestore.instance)
            .collection('parking_attendants');

  Future<void> createUser(UserModel user) async {
    try {
      await _usersCollection.doc(user.id).set(user.toMap());
    } catch (e) {
      throw Exception('Failed to create user: $e');
    }
  }

  Future<UserModel?> getUser(String userId) async {
    try {
      final doc = await _usersCollection.doc(userId).get();
      if (doc.exists) {
        return UserModel.fromMap(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get user: $e');
    }
  }

  Future<void> updateUser(String userId, Map<String, dynamic> data) async {
    try {
      await _usersCollection.doc(userId).update({
        ...data,
        'updatedAt': Timestamp.now(),
      });
    } catch (e) {
      throw Exception('Failed to update user: $e');
    }
  }

  Stream<UserModel?> getUserStream(String userId) {
    debugPrint('[UserRepository] Setting up stream for user: $userId');

    // Add a flag to track if we're currently processing a points update
    bool isProcessingPoints = false;

    return _usersCollection
        .doc(userId)
        .snapshots()
        .map((doc) {
          if (!doc.exists) return null;

          try {
            final data = doc.data() as Map<String, dynamic>;
            final points = data['points'] as int? ?? 0;
            const maxPoints = 2000;

            // If points exceed 2000 and we're not already processing
            if (points >= maxPoints && !isProcessingPoints) {
              debugPrint(
                  '[UserRepository] Processing large points update: $points');
              isProcessingPoints = true; // Set flag to true

              final newFreeParkingChances = points ~/ maxPoints;
              final remainingPoints = points % maxPoints;

              debugPrint(
                  '[UserRepository] Calculated: chances=$newFreeParkingChances, remaining=$remainingPoints');

              final now = Timestamp.now();

              // Create a WriteBatch to ensure atomic updates
              final batch = FirebaseFirestore.instance.batch();

              batch.update(doc.reference, {
                'points': remainingPoints,
                'freeParkingChances':
                    FieldValue.increment(newFreeParkingChances),
                'updatedAt': now,
                'lastPointsUpdate': points,
                'shouldShowCelebration': true,
              });

              // Commit the batch
              batch.commit().then((_) {
                isProcessingPoints = false; // Reset flag after update
              });

              // Return current state
              return UserModel.fromMap({
                ...data,
                'points': remainingPoints,
                'freeParkingChances':
                    (data['freeParkingChances'] as int? ?? 0) +
                        newFreeParkingChances,
                'updatedAt': now,
                'createdAt': data['createdAt'] ?? now,
                'shouldShowCelebration': true,
                'lastPointsUpdate': points,
              });
            }

            return UserModel.fromMap(data);
          } catch (e, stackTrace) {
            debugPrint('[UserRepository] Error processing user data: $e');
            debugPrint(stackTrace.toString());
            return null;
          }
        })
        .where((user) => user != null)
        .distinct(); // Add distinct() operator
  }

  Future<void> clearCelebrationFlag(String userId) async {
    try {
      await _usersCollection.doc(userId).update({
        'shouldShowCelebration': false,
      });
    } catch (e) {
      debugPrint('[UserRepository] Error clearing celebration flag: $e');
    }
  }

  Future<void> updateUserPoints(String userId, int additionalPoints) async {
    try {
      final userRef = _usersCollection.doc(userId);

      // Get current user data
      final userDoc = await userRef.get();
      if (!userDoc.exists) throw Exception('User not found');

      final userData = userDoc.data() as Map<String, dynamic>;
      final currentPoints = userData['points'] as int? ?? 0;
      final currentParkingChances = userData['freeParkingChances'] as int? ?? 0;

      final newTotalPoints = currentPoints + additionalPoints;
      const maxPoints = 2000;

      // Calculate new values
      final newFreeParkingChances = newTotalPoints ~/ maxPoints;
      final remainingPoints = newTotalPoints % maxPoints;

      debugPrint('Current points: $currentPoints');
      debugPrint('Additional points: $additionalPoints');
      debugPrint('New total points: $newTotalPoints');
      debugPrint('New free parking chances: $newFreeParkingChances');
      debugPrint('Remaining points: $remainingPoints');

      // Update user document
      await userRef.update({
        'points': remainingPoints,
        'freeParkingChances': currentParkingChances + newFreeParkingChances,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Error updating user points: $e');
      throw Exception('Failed to update user points: $e');
    }
  }

  Future<void> useFreeParkingChance(String userId) async {
    try {
      final userRef = _usersCollection.doc(userId);

      // Get current user data
      final userDoc = await userRef.get();
      if (!userDoc.exists) throw Exception('User not found');

      final userData = userDoc.data() as Map<String, dynamic>;
      final currentParkingChances = userData['freeParkingChances'] as int? ?? 0;

      if (currentParkingChances <= 0) {
        throw Exception('No free parking chances available');
      }

      // Update user document
      await userRef.update({
        'freeParkingChances': FieldValue.increment(-1),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Error using free parking chance: $e');
      throw Exception('Failed to use free parking chance: $e');
    }
  }

  Future<ParkingAttendantModel?> getParkingAttendant(String nijp) async {
    try {
      final querySnapshot = await _parkingAttendantsCollection
          .where('nijp', isEqualTo: nijp)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) return null;

      final doc = querySnapshot.docs.first;
      return ParkingAttendantModel.fromMap({
        ...doc.data() as Map<String, dynamic>,
        'id': doc.id, // Include the document ID
        'nijp': nijp, // Ensure NIJP is included
      });
    } catch (e) {
      throw Exception('Failed to get parking attendant: $e');
    }
  }

  Future<void> updateParkingAttendantPassword(
      String id, String newPassword) async {
    try {
      await _parkingAttendantsCollection.doc(id).update({
        'password':
            PasswordUtils.hashPassword(newPassword), // Use PasswordUtils class
        'updatedAt': Timestamp.now(),
      });
    } catch (e) {
      throw Exception('Failed to update password: $e');
    }
  }

  Future<void> updateParkingAttendantStats(
      String id, Map<String, dynamic> updates) async {
    try {
      await _parkingAttendantsCollection.doc(id).update({
        'stats': updates,
        'updatedAt': Timestamp.now(),
      });
    } catch (e) {
      throw Exception('Failed to update parking attendant stats: $e');
    }
  }

  Stream<ParkingAttendantModel?> getParkingAttendantStream(String id) {
    if (id.isEmpty) {
      return Stream.value(null);
    }

    return _parkingAttendantsCollection.doc(id).snapshots().map((doc) {
      if (!doc.exists) return null;
      return ParkingAttendantModel.fromMap({
        ...doc.data() as Map<String, dynamic>,
        'id': doc.id,
      });
    });
  }
}
