class User {
  final String id;
  final String name;
  final String email;
  final String? phoneNumber;
  final String? avatarUrl;
  final String role; // 'admin', 'structure_owner', 'user'
  final String status; // 'active', 'inactive', 'suspended'
  final DateTime createdAt;
  final DateTime updatedAt;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.phoneNumber,
    this.avatarUrl,
    required this.role,
    this.status = 'active',
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  // Créer un utilisateur de démonstration
  factory User.demo() {
    return User(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: 'Utilisateur de démonstration',
      email: 'demo@example.com',
      role: 'user',
      status: 'active',
    );
  }

  // Convertir un objet User en Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phoneNumber': phoneNumber,
      'avatarUrl': avatarUrl,
      'role': role,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  // Créer un objet User à partir d'un Map
  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      phoneNumber: map['phoneNumber'],
      avatarUrl: map['avatarUrl'],
      role: map['role'] ?? 'user',
      status: map['status'] ?? 'active',
      createdAt: map['createdAt'] != null ? DateTime.parse(map['createdAt']) : DateTime.now(),
      updatedAt: map['updatedAt'] != null ? DateTime.parse(map['updatedAt']) : DateTime.now(),
    );
  }

  // Créer une copie de l'utilisateur avec des valeurs mises à jour
  User copyWith({
    String? id,
    String? name,
    String? email,
    String? phoneNumber,
    String? avatarUrl,
    String? role,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      role: role ?? this.role,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is User && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
