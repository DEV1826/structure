import 'package:equatable/equatable.dart';

class ServiceModel extends Equatable {
  final String id;
  final String name;
  final String? description;
  final double? price;
  final String? priceUnit;
  final String? structureId;
  final String? category;
  final Duration? duration;
  final bool isAvailable;

  const ServiceModel({
    required this.id,
    required this.name,
    this.description,
    this.price,
    this.priceUnit = 'FCFA',
    this.structureId,
    this.category,
    this.duration,
    this.isAvailable = true,
  });

  factory ServiceModel.fromMap(Map<String, dynamic> map) {
    return ServiceModel(
      id: map['id']?.toString() ?? '',
      name: map['name']?.toString() ?? 'Sans nom',
      description: map['description']?.toString(),
      price: map['price'] != null ? (map['price'] as num).toDouble() : null,
      priceUnit: map['priceUnit']?.toString() ?? 'FCFA',
      structureId: map['structureId']?.toString(),
      category: map['category']?.toString(),
      duration: map['duration'] != null
          ? Duration(minutes: int.tryParse(map['duration'].toString()) ?? 0)
          : null,
      isAvailable: map['isAvailable'] is bool 
          ? map['isAvailable'] as bool 
          : true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      if (description != null) 'description': description,
      if (price != null) 'price': price,
      'priceUnit': priceUnit,
      if (structureId != null) 'structureId': structureId,
      if (category != null) 'category': category,
      if (duration != null) 'duration': duration!.inMinutes,
      'isAvailable': isAvailable,
    }..removeWhere((key, value) => value == null);
  }

  ServiceModel copyWith({
    String? id,
    String? name,
    double? price,
    String? description,
    String? priceUnit,
    String? structureId,
    String? category,
    Duration? duration,
    bool? isAvailable,
  }) {
    return ServiceModel(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      description: description ?? this.description,
      priceUnit: priceUnit ?? this.priceUnit,
      structureId: structureId ?? this.structureId,
      category: category ?? this.category,
      duration: duration ?? this.duration,
      isAvailable: isAvailable ?? this.isAvailable,
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    description,
    price,
    priceUnit,
    structureId,
    category,
    duration,
    isAvailable,
  ];

  @override
  String toString() => 'ServiceModel(id: $id, name: $name, price: $price, isAvailable: $isAvailable)';
}
