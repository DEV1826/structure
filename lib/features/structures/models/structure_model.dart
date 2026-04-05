import 'package:structure_mobile/features/structures/models/service_model.dart';

class Structure {
  final String id;
  final String name;
  final String description;
  final String address;
  final String? imageUrl;
  final double rating;
  final int reviewCount;
  final List<Service> services;
  final String category;
  final double? latitude;
  final double? longitude;
  final String? phoneNumber;
  final String? email;
  final String? website;
  final List<String>? galleryImages;
  final bool isFavorite;
  final String status; // 'active', 'pending', 'suspended'
  final String? adminId; // ID de l'administrateur de la structure
  final String? adminName; // Nom de l'administrateur de la structure
  final DateTime createdAt;
  final DateTime updatedAt;

  Structure({
    required this.id,
    required this.name,
    required this.description,
    required this.address,
    this.imageUrl,
    this.rating = 0.0,
    this.reviewCount = 0,
    List<Service>? services,
    required this.category,
    this.latitude,
    this.longitude,
    this.phoneNumber,
    this.email,
    this.website,
    this.galleryImages,
    this.isFavorite = false,
    this.status = 'active',
    this.adminId,
    this.adminName,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : services = services ?? [],
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  // Créer une structure de démonstration
  factory Structure.demo() {
    return Structure(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: 'Structure de démonstration',
      description: 'Description de la structure de démonstration',
      address: '123 Rue de la Démonstration',
      category: 'Autre',
      status: 'active',
      services: [
        Service.demo(),
      ],
    );
  }

  // Convertir un objet Structure en Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'address': address,
      'imageUrl': imageUrl,
      'rating': rating,
      'reviewCount': reviewCount,
      'services': services.map((service) => service.toMap()).toList(),
      'category': category,
      'latitude': latitude,
      'longitude': longitude,
      'phoneNumber': phoneNumber,
      'email': email,
      'website': website,
      'galleryImages': galleryImages,
      'isFavorite': isFavorite,
      'status': status,
      'adminId': adminId,
      'adminName': adminName,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  // Créer un objet Structure à partir d'un Map
  factory Structure.fromMap(Map<String, dynamic> map) {
    return Structure(
      id: (map['id'] ?? '').toString(),
      name: map['name'] ?? 'Sans nom',
      description: map['description'] ?? '',
      address: map['address'] ?? '',
      imageUrl: map['imageUrl'],
      rating: (map['rating'] ?? 0.0).toDouble(),
      reviewCount: (map['reviewCount'] ?? 0).toInt(),
      services: List<Service>.from(
          map['services']?.map((x) => Service.fromMap(x)) ?? []),
      category: map['category'] ?? 'Autre',
      latitude: (map['latitude'] ?? 0.0).toDouble(),
      longitude: (map['longitude'] ?? 0.0).toDouble(),
      phoneNumber: map['phoneNumber'] ?? map['phone'], // Supporte 'phone' ou 'phoneNumber'
      email: map['email'],
      website: map['website'],
      galleryImages: map['galleryImages'] != null ? List<String>.from(map['galleryImages']) : [],
      isFavorite: map['isFavorite'] ?? false,
      status: map['status'] ?? ((map['active'] == true) ? 'active' : 'suspended'),
      adminId: map['adminId'],
      adminName: map['adminName'],
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt']) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: map['updatedAt'] != null
          ? DateTime.tryParse(map['updatedAt']) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  String? get location => null;

  get openingHours => null;

  get distance => null;

  get categories => null;

  // Copier avec modifications
  Structure copyWith({
    String? id,
    String? name,
    String? description,
    String? address,
    String? imageUrl,
    double? rating,
    int? reviewCount,
    List<Service>? services,
    String? category,
    double? latitude,
    double? longitude,
    String? phoneNumber,
    String? email,
    String? website,
    List<String>? galleryImages,
    bool? isFavorite,
    String? status,
    String? adminId,
    String? adminName,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Structure(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      address: address ?? this.address,
      imageUrl: imageUrl ?? this.imageUrl,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      services: services ?? this.services,
      category: category ?? this.category,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: email ?? this.email,
      website: website ?? this.website,
      galleryImages: galleryImages ?? this.galleryImages,
      isFavorite: isFavorite ?? this.isFavorite,
      status: status ?? this.status,
      adminId: adminId ?? this.adminId,
      adminName: adminName ?? this.adminName,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
