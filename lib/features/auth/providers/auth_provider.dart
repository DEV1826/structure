import 'package:flutter/foundation.dart';

class User {
  final String id;
  final String email;
  final String? role;
  final String? structureId;

  User({required this.id, required this.email, this.role, this.structureId});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      role: json['role'],
      structureId: json['structureId'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'email': email,
    'role': role,
    'structureId': structureId,
  };
}

class AuthProvider extends ChangeNotifier {
  User? _user;
  bool _isLoading = false;
  String? _error;

  User? get user => _user;
  bool get isAuthenticated => _user != null;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAdmin => _user?.role == 'admin';
  bool get isSuperAdmin => _user?.role == 'superadmin';

  Future<void> login({
    required String email,
    required String password,
    bool isAdmin = false,
    bool isSuperAdmin = false,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // Simulation d'une requête API
      await Future.delayed(const Duration(seconds: 2));

      // En production, ceci viendrait d'une API
      _user = User(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        email: email,
        role: isSuperAdmin ? 'superadmin' : (isAdmin ? 'admin' : 'user'),
        structureId: isAdmin || isSuperAdmin ? 'structure_1' : null,
      );

      notifyListeners();
    } catch (e) {
      _error = 'Erreur lors de la connexion: ${e.toString()}';
      notifyListeners();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    _user = null;
    notifyListeners();
  }
}

authProvider() {}

login({
  required String email,
  required String password,
  bool? isAdmin,
  bool? isSuperAdmin,
}) {}
