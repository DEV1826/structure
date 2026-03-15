import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:structure_mobile/core/models/user_model.dart';
import 'package:structure_mobile/core/network/api_service.dart';

class AuthProvider extends ChangeNotifier {
  User? _user;
  String? _token;
  bool _isLoading = false;
  String? _error;

  User? get user => _user;
  String? get token => _token;
  bool get isAuthenticated => _user != null && _token != null;
  bool get isAdmin => _user?.role == UserRole.admin || isSuperAdmin;
  bool get isSuperAdmin => _user?.role == UserRole.superAdmin;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> init(SharedPreferences prefs) async {
    _token = prefs.getString('jwt_token');
    if (_token != null) {
      await tryAutoLogin();
    }
  }

  Future<void> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await ApiService.post('auth/login', {
        'identifier': email,
        'password': password,
      });

      if (response['success'] == true) {
        // Le backend retourne directement l'objet à la racine de 'data'
        // { token, id, email, firstName, lastName, role, structureId, ... }
        final data = response['data'] as Map<String, dynamic>;
        final token = data['token'] as String?;

        if (token == null) throw Exception('Token manquant dans la réponse');

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('jwt_token', token);

        _user = User(
          id: data['id']?.toString() ?? '',
          email: data['email'] ?? '',
          firstName: data['firstName'] ?? data['prenom'] ?? '',
          lastName: data['lastName'] ?? data['nom'] ?? '',
          role: _parseUserRole(data['role']?.toString()),
          structureId: data['structureId']?.toString(),
        );
        _token = token;

        debugPrint('Login OK — email: ${_user?.email} | rôle: ${_user?.role}');
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
        'firstName': firstName,
        'lastName': lastName,
      });

      if (response['success'] == true) {
        final data = response['data'] as Map<String, dynamic>;
        final token = data['token'] as String?;

        if (token == null) throw Exception('Token manquant dans la réponse');

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('jwt_token', token);

        _user = User(
          id: data['id']?.toString() ?? '',
          email: data['email'] ?? '',
          firstName: data['firstName'] ?? data['prenom'] ?? '',
          lastName: data['lastName'] ?? data['nom'] ?? '',
          role: _parseUserRole(data['role']?.toString() ?? 'USER'),
          structureId: data['structureId']?.toString(),
        );
        _token = token;
      } else {
        throw Exception(response['error'] ?? "Échec de l'inscription");
      }
    } catch (e) {
      _error = "Échec de l'inscription. Veuillez réessayer.";
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('jwt_token');
    } catch (_) {
    } finally {
      _user = null;
      _token = null;
      _error = null;
      notifyListeners();
    }
  }

  /// Auto-login au démarrage : on décode le JWT stocké localement
  /// sans appeler /auth/me (route absente du backend).
  Future<bool> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');
    if (token == null) return false;

    try {
      // Décoder le payload JWT (base64) sans appel réseau
      final parts = token.split('.');
      if (parts.length != 3) throw Exception('JWT malformé');

      // Padding base64
      String payload = parts[1];
      payload += '=' * ((4 - payload.length % 4) % 4);
      final decoded = String.fromCharCodes(
        base64Url.decode(payload),
      );
      final Map<String, dynamic> claims =
          Map<String, dynamic>.from(jsonDecode(decoded) as Map);

      // Vérifier l'expiration
      final exp = claims['exp'] as int?;
      if (exp != null &&
          DateTime.fromMillisecondsSinceEpoch(exp * 1000)
              .isBefore(DateTime.now())) {
        await prefs.remove('jwt_token');
        return false;
      }

      // Reconstruire l'utilisateur depuis les claims JWT
      // Le backend met le rôle dans le claim "role" sous forme de liste d'authorities
      String? roleStr;
      final roleClaim = claims['role'];
      if (roleClaim is List && roleClaim.isNotEmpty) {
        // Format: [{"authority":"SUPER_ADMIN"}, {"authority":"ROLE_SUPER_ADMIN"}]
        final first = roleClaim.first;
        if (first is Map) {
          roleStr = first['authority']?.toString();
        } else {
          roleStr = first?.toString();
        }
      } else if (roleClaim is String) {
        roleStr = roleClaim;
      }

      _user = User(
        id: claims['sub'] ?? '',
        email: claims['sub'] ?? '',
        firstName: claims['firstName'] ?? '',
        lastName: claims['lastName'] ?? '',
        role: _parseUserRole(roleStr),
        structureId: claims['structureId']?.toString(),
      );
      _token = token;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Auto-login échoué: $e');
      await prefs.remove('jwt_token');
      return false;
    }
  }

  /// Convertit le rôle backend (SUPER_ADMIN, ADMIN, USER) en enum Flutter.
  /// Gère majuscules, minuscules et variantes avec/sans underscore.
  UserRole _parseUserRole(String? role) {
    if (role == null) return UserRole.client;
    switch (role.toUpperCase()) {
      case 'SUPER_ADMIN':
      case 'SUPERADMIN':
        return UserRole.superAdmin;
      case 'ADMIN':
        return UserRole.admin;
      case 'USER':
      case 'CLIENT':
      default:
        return UserRole.client;
    }
  }
}
