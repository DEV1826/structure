import 'package:flutter/foundation.dart';
import 'package:structure_mobile/core/network/api_service.dart';

class User {
  final String id;
  final String email;
  final String? role;
  final String? structureId;
  final String? token;
  final String? firstName;
  final String? lastName;

  User({
    required this.id,
    required this.email,
    this.role,
    this.structureId,
    this.token,
    this.firstName,
    this.lastName,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    // Le backend peut envoyer structureId comme un int ou null
    final sId = json['structureId']?.toString();
    
    return User(
      id: json['id']?.toString() ?? '',
      email: json['email'] ?? '',
      role: json['role']?.toString().toLowerCase(), // On normalise en minuscule
      structureId: sId,
      token: json['token'],
      firstName: json['firstName'],
      lastName: json['lastName'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'email': email,
    'role': role,
    'structureId': structureId,
    'token': token,
    'firstName': firstName,
    'lastName': lastName,
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

      final response = await ApiService.post('auth/login', {
        'username': email, // Le backend utilise email comme username par défaut
        'password': password,
      });

      if (response['success'] == true) {
        final data = response['data'];
        if (data != null) {
          _user = User.fromJson(data);
          
          // Sauvegarder le token si présent
          if (_user?.token != null) {
             await ApiService.setToken(_user!.token!);
          }
        }
      } else {
        _error = response['error'] ?? 'Identifiants incorrects';
      }

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
    await ApiService.clearToken();
    notifyListeners();
  }
}
