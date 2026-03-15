class Admin {
  final String id;
  final String name;
  final String email;
  final String structureId;
  final String structureName;

  Admin({
    required this.id,
    required this.name,
    required this.email,
    required this.structureId,
    required this.structureName,
  });

  // Convert from JSON
  factory Admin.fromJson(Map<String, dynamic> json) {
    return Admin(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      structureId: json['structureId'] ?? '',
      structureName: json['structureName'] ?? '',
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'structureId': structureId,
      'structureName': structureName,
    };
  }
}
