// file: lib/data/models/vehicle.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class Vehicle {
  final String id; // Add this line to define the id property
  String category;
  String make;
  String model;
  int year;
  String licensePlate;
  int mileage;
  double rentPerDay;
  double advanceAmount;
  String description;
  bool isAvailable;
  bool requiresLicense;
  String address;
  String addressId;
  String? ownerId;

  Vehicle({
    required this.id, // Add this to the constructor
    required this.category,
    required this.make,
    required this.model,
    required this.year,
    required this.licensePlate,
    required this.mileage,
    required this.rentPerDay,
    required this.advanceAmount,
    required this.description,
    required this.isAvailable,
    required this.requiresLicense,
    required this.address,
    required this.addressId,
    this.ownerId,
  });

  /// Converts a Vehicle object into a Map for Firestore storage.
  Map<String, dynamic> toMap() {
    return {
      'category': category,
      'make': make,
      'model': model,
      'year': year,
      'licensePlate': licensePlate,
      'mileage': mileage,
      'rentPerDay': rentPerDay,
      'advanceAmount': advanceAmount,
      'description': description,
      'isAvailable': isAvailable,
      'requiresLicense': requiresLicense,
      'address': address,
      'addressId': addressId,
      'ownerId': ownerId,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  /// Creates a Vehicle object from a Firestore document snapshot.
  factory Vehicle.fromMap(Map<String, dynamic> map, {required String id}) {
    return Vehicle(
      id: id, // Pass the id from the document to the new property
      category: map['category'] ?? '',
      make: map['make'] ?? '',
      model: map['model'] ?? '',
      year: map['year'] ?? 0,
      licensePlate: map['licensePlate'] ?? '',
      mileage: map['mileage'] ?? 0,
      rentPerDay: (map['rentPerDay'] ?? 0.0).toDouble(),
      advanceAmount: (map['advanceAmount'] ?? 0.0).toDouble(),
      description: map['description'] ?? '',
      isAvailable: map['isAvailable'] ?? true,
      requiresLicense: map['requiresLicense'] ?? false,
      address: map['address'] ?? '',
      addressId: map['addressId'] ?? '',
      ownerId: map['ownerId'],
    );
  }
}