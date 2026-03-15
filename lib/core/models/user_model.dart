enum UserRole { client, admin, superAdmin }

class User {
  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final UserRole role;
  final String? profileImageUrl;
  final String? phoneNumber;
  final String? structureId; // Référence à la structure gérée par l'administrateur

  User({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.role,
    this.profileImageUrl,
    this.phoneNumber,
    this.structureId,
  });

  // Méthode pour convertir un utilisateur en Map (utile pour le stockage local)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'role': role.index,
      'profileImageUrl': profileImageUrl,
      'phoneNumber': phoneNumber,
      'structureId': structureId,
    };
  }

  // Méthode pour créer un utilisateur à partir d'un Map
  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] ?? '',
      email: map['email'] ?? '',
      firstName: map['firstName'] ?? '',
      lastName: map['lastName'] ?? '',
      role: UserRole.values[map['role'] ?? 0],
      profileImageUrl: map['profileImageUrl'],
      phoneNumber: map['phoneNumber'],
      structureId: map['structureId'],
    );
  }

  // Copier avec modifications
  User copyWith({
    String? id,
    String? email,
    String? firstName,
    String? lastName,
    UserRole? role,
    String? profileImageUrl,
    String? phoneNumber,
    String? structureId,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      role: role ?? this.role,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      structureId: structureId ?? this.structureId,
    );
  }
}
