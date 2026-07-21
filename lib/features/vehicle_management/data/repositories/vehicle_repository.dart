// lib/features/vehicle_management/data/repositories/vehicle_repository.dart

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:parkirin/features/authentication/domain/entities/user_model.dart';
import 'package:path/path.dart' as path;

import '../../domain/entities/vehicle.dart';
import '../../domain/repositories/i_vehicle_repository.dart';

class VehicleRepository implements IVehicleRepository {
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;
  final CollectionReference _vehiclesCollection;
  final CollectionReference _usersCollection;

  VehicleRepository({
    FirebaseFirestore? firestore,
    FirebaseStorage? storage,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _storage = storage ?? FirebaseStorage.instance,
        _vehiclesCollection =
            (firestore ?? FirebaseFirestore.instance).collection('vehicles'),
        _usersCollection =
            (firestore ?? FirebaseFirestore.instance).collection('users');

  @override
  Future<String> addVehicle({
    required String userId,
    required String plateNumber,
    required String type,
    String? photoUrl,
  }) async {
    try {
      // Start a batch write
      final batch = _firestore.batch();

      // Create vehicle document reference
      final vehicleRef = _vehiclesCollection.doc();

      // Prepare vehicle data
      final vehicleData = {
        'id': vehicleRef.id,
        'userId': userId,
        'plateNumber': plateNumber.toUpperCase(),
        'type': type,
        'photoUrl': photoUrl,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      // Add vehicle document
      batch.set(vehicleRef, vehicleData);

      // Prepare vehicle info for user's array
      final vehicleInfo = {
        'plateNumber': plateNumber.toUpperCase(),
        'type': type,
        'photoUrl': photoUrl,
      };

      // Update user's vehicles array
      batch.update(_usersCollection.doc(userId), {
        'vehicles': FieldValue.arrayUnion([vehicleInfo]),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Commit the batch
      await batch.commit();

      return vehicleRef.id;
    } catch (e) {
      throw Exception('Failed to add vehicle: $e');
    }
  }

  @override
  Future<List<Vehicle>> getUserVehicles(String userId) async {
    try {
      final querySnapshot = await _vehiclesCollection
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs.map((doc) => _documentToVehicle(doc)).toList();
    } catch (e) {
      throw Exception('Failed to get user vehicles: $e');
    }
  }

  @override
  Future<Vehicle?> getVehicle(String id) async {
    try {
      final docSnapshot = await _vehiclesCollection.doc(id).get();
      if (!docSnapshot.exists) return null;
      return _documentToVehicle(docSnapshot);
    } catch (e) {
      throw Exception('Failed to get vehicle: $e');
    }
  }

  @override
  Future<void> updateVehicle({
    required String id,
    String? plateNumber,
    String? type,
    String? photoUrl,
  }) async {
    try {
      // Get the current vehicle data
      final vehicleDoc = await _vehiclesCollection.doc(id).get();
      if (!vehicleDoc.exists) {
        throw Exception('Vehicle not found');
      }

      final vehicleData = vehicleDoc.data() as Map<String, dynamic>;
      final userId = vehicleData['userId'] as String;
      final oldPlateNumber = vehicleData['plateNumber'] as String;
      final oldType = vehicleData['type'] as String;
      final oldPhotoUrl = vehicleData['photoUrl'] as String?;

      // Start a batch write
      final batch = _firestore.batch();

      // Prepare vehicle updates
      final updates = <String, dynamic>{
        'updatedAt': FieldValue.serverTimestamp(),
      };
      if (plateNumber != null) {
        updates['plateNumber'] = plateNumber.toUpperCase();
      }
      if (type != null) updates['type'] = type;
      if (photoUrl != null) updates['photoUrl'] = photoUrl;

      // Update vehicle document
      batch.update(_vehiclesCollection.doc(id), updates);

      // Remove old vehicle info from user's array
      batch.update(_usersCollection.doc(userId), {
        'vehicles': FieldValue.arrayRemove([
          {
            'plateNumber': oldPlateNumber,
            'type': oldType,
            'photoUrl': oldPhotoUrl,
          }
        ]),
      });

      // Add updated vehicle info to user's array
      batch.update(_usersCollection.doc(userId), {
        'vehicles': FieldValue.arrayUnion([
          {
            'plateNumber': plateNumber ?? oldPlateNumber,
            'type': type ?? oldType,
            'photoUrl': photoUrl ?? oldPhotoUrl,
          }
        ]),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Commit the batch
      await batch.commit();
    } catch (e) {
      throw Exception('Failed to update vehicle: $e');
    }
  }

  @override
  Future<void> deleteVehicle(String id) async {
    try {
      // Get the vehicle first to get user ID and plate number
      final vehicleDoc = await _vehiclesCollection.doc(id).get();
      if (!vehicleDoc.exists) {
        throw Exception('Vehicle not found');
      }

      final vehicleData = vehicleDoc.data() as Map<String, dynamic>;
      final userId = vehicleData['userId'] as String;
      final plateNumber = vehicleData['plateNumber'] as String;
      final type = vehicleData['type'] as String;
      final photoUrl = vehicleData['photoUrl'] as String?;

      // Start a batch write
      final batch = _firestore.batch();

      // Delete vehicle document
      batch.delete(_vehiclesCollection.doc(id));

      // Remove vehicle info from user's array
      batch.update(_usersCollection.doc(userId), {
        'vehicles': FieldValue.arrayRemove([
          {
            'plateNumber': plateNumber,
            'type': type,
            'photoUrl': photoUrl,
          }
        ]),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // If there's a photo, delete it from storage
      if (photoUrl != null) {
        await _storage.refFromURL(photoUrl).delete();
      }

      // Commit the batch
      await batch.commit();
    } catch (e) {
      throw Exception('Failed to delete vehicle: $e');
    }
  }

  @override
  Future<bool> isPlateNumberExists(String plateNumber) async {
    try {
      final querySnapshot = await _vehiclesCollection
          .where('plateNumber', isEqualTo: plateNumber.toUpperCase())
          .limit(1)
          .get();

      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      throw Exception('Failed to check plate number: $e');
    }
  }

  @override
  Future<Vehicle?> findVehicleByPlateNumber(String plateNumber) async {
    try {
      // Normalize input plate number
      final normalizedInputPlate = plateNumber
          .replaceAll('"', '')
          .replaceAll("'", '')
          .replaceAll(' ', '')
          .toUpperCase();

      final querySnapshot = await _usersCollection.get();

      for (var doc in querySnapshot.docs) {
        final userData = doc.data() as Map<String, dynamic>;
        final vehicles = (userData['vehicles'] as List<dynamic>?)
                ?.map((v) {
                  try {
                    return VehicleInfo.fromMap(v as Map<String, dynamic>);
                  } catch (e) {
                    debugPrint('Error parsing vehicle: $e');
                    return null;
                  }
                })
                .whereType<VehicleInfo>()
                .toList() ??
            [];

        // Find matching vehicle
        for (var vehicle in vehicles) {
          if ((vehicle.plateNumber)
                  .replaceAll('"', '')
                  .replaceAll("'", '')
                  .replaceAll(' ', '')
                  .toUpperCase() ==
              normalizedInputPlate) {
            return Vehicle(
              id: '${doc.id}_${vehicle.plateNumber}',
              userId: doc.id,
              plateNumber: vehicle.plateNumber,
              type: vehicle.type,
              photoUrl: vehicle.photoUrl,
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
            );
          }
        }
      }

      return null;
    } catch (e) {
      debugPrint('Error finding vehicle by plate number: $e');
      return null;
    }
  }

  @override
  Future<String> uploadVehiclePhoto({
    required String userId,
    required String vehicleId,
    required String filePath,
  }) async {
    try {
      final file = File(filePath);
      final extension = path.extension(filePath);
      final storageRef =
          _storage.ref().child('vehicles/$userId/$vehicleId/photo$extension');

      final uploadTask = await storageRef.putFile(
        file,
        SettableMetadata(
          contentType: 'image/${extension.substring(1)}',
        ),
      );

      final downloadUrl = await uploadTask.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      throw Exception('Failed to upload vehicle photo: $e');
    }
  }

  Vehicle _documentToVehicle(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    debugPrint('Converting document to vehicle: ${doc.id}');
    debugPrint('Photo URL from data: ${data['photoUrl']}');
    return Vehicle(
      id: doc.id,
      userId: data['userId'],
      plateNumber: data['plateNumber'],
      type: data['type'],
      photoUrl: data['photoUrl'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }
}
