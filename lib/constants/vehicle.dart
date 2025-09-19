// file: lib/data/models/vehicle.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class Vehicle {
  final String id;
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
  DateTime? createdAt; // Added for tracking creation time
  DateTime? updatedAt; // Added for tracking updates
  double? averageRating; // Added for user ratings
  int? ratingCount; // Added for the total count of ratings
  String? locationLink; // Added for a direct link to the map location

  Vehicle({
    required this.id,
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
    this.createdAt,
    this.updatedAt,
    this.averageRating,
    this.ratingCount,
    this.locationLink,
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
      'updatedAt': FieldValue.serverTimestamp(),
      'averageRating': averageRating,
      'ratingCount': ratingCount,
      'locationLink': locationLink,
    };
  }

  /// Creates a Vehicle object from a Firestore document snapshot.
  factory Vehicle.fromMap(Map<String, dynamic> map, {required String id}) {
    return Vehicle(
      id: id,
      category: map['category'] as String? ?? '',
      make: map['make'] as String? ?? '',
      model: map['model'] as String? ?? '',
      year: map['year'] as int? ?? 0,
      licensePlate: map['licensePlate'] as String? ?? '',
      mileage: map['mileage'] as int? ?? 0,
      rentPerDay: (map['rentPerDay'] as num?)?.toDouble() ?? 0.0,
      advanceAmount: (map['advanceAmount'] as num?)?.toDouble() ?? 0.0,
      description: map['description'] as String? ?? '',
      isAvailable: map['isAvailable'] as bool? ?? true,
      requiresLicense: map['requiresLicense'] as bool? ?? false,
      address: map['address'] as String? ?? '',
      addressId: map['addressId'] as String? ?? '',
      ownerId: map['ownerId'] as String?,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate(),
      averageRating: (map['averageRating'] as num?)?.toDouble(),
      ratingCount: map['ratingCount'] as int?,
      locationLink: map['locationLink'] as String?,
    );
  }
}