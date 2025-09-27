// lib/constants/vehicle_data_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class Vehicle {
  final String id;
  final String ownerId;
  final String make;
  final String model;
  final String category;
  final double rentPerDay;
  final double advanceAmount;
  final String licensePlate;
  final String mileage;
  final String description;
  final bool isAvailable;
  final Map<String, dynamic>? addressData;
  final String? locationLink;
  final double? averageRating;
  final int? ratingCount;

  const Vehicle({
    required this.id,
    required this.ownerId,
    required this.make,
    required this.model,
    required this.category,
    required this.rentPerDay,
    required this.advanceAmount,
    required this.licensePlate,
    required this.mileage,
    required this.description,
    required this.isAvailable,
    this.addressData,
    this.locationLink,
    this.averageRating,
    this.ratingCount,
  });

  factory Vehicle.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    final addressMap = data['address'] as Map<String, dynamic>? ?? {};

    return Vehicle(
      id: doc.id,
      ownerId: data['ownerId'] ?? '',
      make: data['make'] ?? 'N/A',
      model: data['model'] ?? 'N/A',
      category: data['category'] ?? 'Other',
      rentPerDay: (data['rentPerDay'] as num?)?.toDouble() ?? 0.0,
      advanceAmount: (data['advanceAmount'] as num?)?.toDouble() ?? 0.0,
      licensePlate: data['licensePlate'] ?? 'N/A',
      mileage: data['mileage'] ?? 'N/A',
      description: data['description'] ?? 'No description provided.',
      isAvailable: data['isAvailable'] ?? false,
      addressData: addressMap,
      locationLink: addressMap['location'],
      averageRating: (data['averageRating'] as num?)?.toDouble(),
      ratingCount: (data['ratingCount'] as int?) ?? 0,
    );
  }
}