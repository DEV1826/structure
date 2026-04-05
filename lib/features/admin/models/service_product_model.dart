class ServiceProduct {
  final String id;
  final String name;
  final String description;
  final double price;
  final String structureId;
  final String category;
  final int duration;
  final bool active;

  ServiceProduct({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.structureId,
    this.category = 'Général',
    this.duration = 0,
    this.active = true,
  });

  factory ServiceProduct.fromJson(Map<String, dynamic> json) {
    return ServiceProduct(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: (json['price'] ?? 0.0).toDouble(),
      structureId: json['structureId']?.toString() ?? '',
      category: json['category'] ?? 'Général',
      duration: json['duration'] ?? 0,
      active: json['active'] ?? true,
    );
  }

  // Payload conforme au ServiceDto backend — structureId est dans l'URL, pas dans le body
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'price': price,
      'category': category,
      'duration': duration,
      'active': active,
    };
  }
}