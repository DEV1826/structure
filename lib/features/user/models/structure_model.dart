import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

class OpeningHours {
  final Map<String, String>
  hours; // Map of day to hours (e.g., 'monday': '09:00 - 18:00')

  const OpeningHours({required this.hours});

  factory OpeningHours.fromMap(Map<String, dynamic> map) {
    return OpeningHours(hours: Map<String, String>.from(map['hours'] ?? {}));
  }

  Map<String, dynamic> toMap() {
    return {'hours': hours};
  }
}

class StructureModel extends Equatable {
  // Factory constructor pour créer une instance à partir d'un JSON
  factory StructureModel.fromJson(Map<String, dynamic> json) {
    return StructureModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      address: json['address'] as String?,
      city: json['city'] as String?,
      country: json['country'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
      email: json['email'] as String?,
      website: json['website'] as String?,
      imageUrl: json['imageUrl'] as String?,
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
      serviceIds: json['serviceIds'] != null
          ? List<String>.from(json['serviceIds'] as List)
          : null,
      isActive: json['isActive'] as bool? ?? true,
      isOpen: json['isOpen'] as bool? ?? false,
      categories: json['categories'] != null
          ? List<String>.from(json['categories'] as List)
          : const [],
      distance: json['distance']?.toDouble(),
      openingHours: json['openingHours'] != null
          ? OpeningHours.fromMap(
              Map<String, dynamic>.from(json['openingHours'] as Map),
            )
          : null,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      reviewCount: (json['reviewCount'] as num?)?.toInt() ?? 0,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }

  final String id;
  final String name;
  final String? description;
  final String? address;
  final String? city;
  final String? country;
  final String? phoneNumber;
  final String? email;
  final String? website;
  final String? imageUrl;
  final double? latitude;
  final double? longitude;
  final List<String>? serviceIds;
  final bool isActive;
  final bool isOpen;
  final List<String> categories;
  final double? distance; // in kilometers
  final OpeningHours? openingHours;
  final double rating;
  final int reviewCount;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const StructureModel({
    required this.id,
    required this.name,
    this.description,
    this.address,
    this.city,
    this.country,
    this.phoneNumber,
    this.email,
    this.website,
    this.imageUrl,
    this.latitude,
    this.longitude,
    this.serviceIds,
    this.isActive = true,
    this.isOpen = false,
    this.categories = const [],
    this.distance,
    this.openingHours,
    this.rating = 0.0,
    this.reviewCount = 0,
    this.createdAt,
    this.updatedAt,
  });

  factory StructureModel.fromMap(Map<String, dynamic> map) {
    return StructureModel(
      id: map['id'] as String,
      name: map['name'] as String,
      description: map['description'] as String?,
      address: map['address'] as String?,
      city: map['city'] as String?,
      country: map['country'] as String?,
      phoneNumber: map['phoneNumber'] as String?,
      email: map['email'] as String?,
      website: map['website'] as String?,
      imageUrl: map['imageUrl'] as String?,
      latitude: map['latitude']?.toDouble(),
      longitude: map['longitude']?.toDouble(),
      serviceIds: map['serviceIds'] != null
          ? List<String>.from(map['serviceIds'] as List)
          : null,
      isActive: map['isActive'] as bool? ?? true,
      isOpen: map['isOpen'] as bool? ?? false,
      categories: map['categories'] != null
          ? List<String>.from(map['categories'] as List)
          : [],
      distance: map['distance']?.toDouble(),
      openingHours: map['openingHours'] != null
          ? OpeningHours.fromMap(Map<String, dynamic>.from(map['openingHours']))
          : null,
      rating: (map['rating'] as num?)?.toDouble() ?? 0.0,
      reviewCount: (map['reviewCount'] as int?) ?? 0,
      createdAt: map['createdAt']?.toDate(),
      updatedAt: map['updatedAt']?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      if (description != null) 'description': description,
      if (address != null) 'address': address,
      if (city != null) 'city': city,
      if (country != null) 'country': country,
      if (phoneNumber != null) 'phoneNumber': phoneNumber,
      if (email != null) 'email': email,
      if (website != null) 'website': website,
      if (imageUrl != null) 'imageUrl': imageUrl,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (serviceIds != null) 'serviceIds': serviceIds,
      'isActive': isActive,
      'isOpen': isOpen,
      'categories': categories,
      if (distance != null) 'distance': distance,
      if (openingHours != null) 'openingHours': openingHours!.toMap(),
      'rating': rating,
      'reviewCount': reviewCount,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  StructureModel copyWith({
    String? id,
    String? name,
    String? description,
    String? address,
    String? city,
    String? country,
    String? phoneNumber,
    String? email,
    String? website,
    String? imageUrl,
    double? latitude,
    double? longitude,
    List<String>? serviceIds,
    bool? isActive,
    bool? isOpen,
    List<String>? categories,
    double? distance,
    OpeningHours? openingHours,
    double? rating,
    int? reviewCount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return StructureModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      address: address ?? this.address,
      city: city ?? this.city,
      country: country ?? this.country,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: email ?? this.email,
      website: website ?? this.website,
      imageUrl: imageUrl ?? this.imageUrl,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      serviceIds: serviceIds ?? this.serviceIds,
      isActive: isActive ?? this.isActive,
      isOpen: isOpen ?? this.isOpen,
      categories: categories ?? this.categories,
      distance: distance ?? this.distance,
      openingHours: openingHours ?? this.openingHours,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    description,
    address,
    city,
    country,
    phoneNumber,
    email,
    website,
    imageUrl,
    latitude,
    longitude,
    serviceIds,
    isActive,
    isOpen,
    categories,
    distance,
    openingHours,
    rating,
    reviewCount,
    createdAt,
    updatedAt,
  ];

  @override
  String toString() =>
      'StructureModel(id: $id, name: $name, isActive: $isActive)';
}
