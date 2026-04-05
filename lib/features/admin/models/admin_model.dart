class Admin {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String structureId;
  final String structureName;

  Admin({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.structureId,
    required this.structureName,
  });

  String get name => '$firstName $lastName'.trim();

  // Convert from JSON
  factory Admin.fromJson(Map<String, dynamic> json) {
    return Admin(
      id: json['id']?.toString() ?? '',
      firstName: json['firstName']?.toString() ?? json['prenom']?.toString() ?? '',
      lastName: json['lastName']?.toString() ?? json['nom']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      structureId: json['structureId']?.toString() ?? '',
      structureName: json['structureName']?.toString() ??
          json['structure']?['name']?.toString() ?? '',
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'structureId': structureId,
      'structureName': structureName,
    };
  }
}