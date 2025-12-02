import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:structure_mobile/core/models/user_model.dart';
import 'package:structure_mobile/core/network/api_service.dart';

class AuthProvider extends ChangeNotifier {
  User? _user;
  String? _token;
  bool _isLoading = false;
  String? _error;

  // Getters
  User? get user => _user;
  String? get token => _token;
  bool get isAuthenticated => _user != null && _token != null;
  bool get isAdmin => _user?.role == UserRole.admin || isSuperAdmin;
  bool get isSuperAdmin => _user?.role == UserRole.superAdmin;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Initialisation
  Future<void> init(SharedPreferences prefs) async {
    _token = prefs.getString('jwt_token');
    if (_token != null) {
      await tryAutoLogin();
    }
  }

  // Méthodes d'authentification
  Future<void> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await ApiService.post('auth/login', {
        'email': email,
        'password': password,
      });

      if (response['success']) {
        final token = response['data']['token'];
        final userData = response['data']['user'] ?? response['data'];

        // Sauvegarder le token
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('jwt_token', token);

        // Mettre à jour l'utilisateur
        _user = User(
          id: userData['id'].toString(),
          email: userData['email'],
          firstName: userData['prenom'] ?? userData['firstName'] ?? '',
          lastName: userData['nom'] ?? userData['lastName'] ?? '',
          role: _parseUserRole(userData['role']),
          structureId: userData['structureId'],
        );
        _token = token;
      } else {
        throw Exception(response['error'] ?? 'Échec de la connexion');
      }
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> register(
    String email,
    String password,
    String firstName,
    String lastName,
  ) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await ApiService.post('auth/register', {
        'email': email,
        'password': password,
        'prenom': firstName,
        'nom': lastName,
      });

      if (response['success']) {
        final token = response['data']['token'];
        final userData = response['data']['user'] ?? response['data'];

        // Sauvegarder le token
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('jwt_token', token);

        // Mettre à jour l'utilisateur
        _user = User(
          id: userData['id'].toString(),
          email: userData['email'],
          firstName: userData['prenom'] ?? userData['firstName'] ?? '',
          lastName: userData['nom'] ?? userData['lastName'] ?? '',
          role: _parseUserRole(userData['role'] ?? 'client'),
          structureId: userData['structureId'],
        );
        _token = token;
      } else {
        throw Exception(response['error'] ?? 'Échec de l\'inscription');
      }
    } catch (e) {
      _error = 'Échec de l\'inscription. Veuillez réessayer.';
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    try {
      // Appeler l'API de déconnexion si nécessaire
      // await ApiService.post('auth/logout', {});

      // Supprimer le token
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('jwt_token');
    } catch (e) {
      // En cas d'erreur, on continue la déconnexion
    } finally {
      _user = null;
      _token = null;
      _error = null;
      notifyListeners();
    }
  }

  Future<bool> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');

    if (token != null) {
      try {
        final response = await ApiService.get('auth/me');

        if (response['success']) {
          final userData = response['data'];
          _user = User(
            id: userData['id'].toString(),
            email: userData['email'],
            firstName: userData['prenom'] ?? userData['firstName'] ?? '',
            lastName: userData['nom'] ?? userData['lastName'] ?? '',
            role: _parseUserRole(userData['role']),
            structureId: userData['structureId'],
          );
          _token = token;
          return true;
        }
      } catch (e) {
        // En cas d'erreur, on considère que le token n'est plus valide
        await prefs.remove('jwt_token');
      }
    }
    return false;
  }

  // Méthode utilitaire pour convertir le rôle du serveur en enum
  UserRole _parseUserRole(String role) {
    if (role == null) return UserRole.client;

    switch (role.toLowerCase()) {
      case 'super_admin':
      case 'superadmin':
        return UserRole.superAdmin;
      case 'admin':
        return UserRole.admin;
      case 'client':
      default:
        return UserRole.client;
    }
  }
}
