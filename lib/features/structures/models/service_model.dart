class Service {
  final String id;
  final String name;
  final String? description;
  final double? price;
  final String? priceUnit; // Ex: 'FCFA', '€', etc.
  final Duration? duration;
  final bool isAvailable;

  Service({
    required this.id,
    required this.name,
    this.description,
    this.price,
    this.priceUnit = 'FCFA',
    this.duration,
    this.isAvailable = true,
  });

  // Créer un service de démonstration
  factory Service.demo() {
    return Service(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: 'Service de démonstration',
      description: 'Description du service de démonstration',
      price: 5000.0,
      priceUnit: 'FCFA',
      duration: const Duration(minutes: 30),
      isAvailable: true,
    );
  }

  // Convertir un objet Service en Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'priceUnit': priceUnit,
      'durationInMinutes': duration?.inMinutes,
      'isAvailable': isAvailable,
    };
  }

  // Créer un objet Service à partir d'un Map
  factory Service.fromMap(Map<String, dynamic> map) {
    return Service(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      description: map['description'],
      price: map['price']?.toDouble(),
      priceUnit: map['priceUnit'] ?? 'FCFA',
      duration: map['durationInMinutes'] != null
          ? Duration(minutes: map['durationInMinutes'] as int)
          : null,
      isAvailable: map['isAvailable'] ?? true,
    );
  }

  // Copier avec modifications
  Service copyWith({
    String? id,
    String? name,
    String? description,
    double? price,
    String? priceUnit,
    Duration? duration,
    bool? isAvailable,
  }) {
    return Service(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      priceUnit: priceUnit ?? this.priceUnit,
      duration: duration ?? this.duration,
      isAvailable: isAvailable ?? this.isAvailable,
    );
  }
}
