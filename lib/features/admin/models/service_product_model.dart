class ServiceProduct {
  final String id;
  final String name;
  final String description;
  final double price;
  final String structureId; // L'ID de la structure qui offre ce service/produit

  ServiceProduct({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.structureId,
  });

  // Convert from JSON
  factory ServiceProduct.fromJson(Map<String, dynamic> json) {
    return ServiceProduct(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: (json['price'] ?? 0.0).toDouble(),
      structureId: json['structureId'] ?? '',
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'structureId': structureId,
    };
  }
}
