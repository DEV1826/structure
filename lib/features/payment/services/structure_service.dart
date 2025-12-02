import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart' show debugPrint;
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class StructureService {
  static const String _baseUrl = 'http://192.168.1.179:8080/api';
  static const String _authTokenKey = 'auth_token';

  final http.Client client;
  final SharedPreferences prefs;

  StructureService({required this.client, required this.prefs});

  // Récupérer le token d'authentification
  Future<String?> _getAuthToken() async {
    try {
      return prefs.getString(_authTokenKey);
    } catch (e) {
      debugPrint('Erreur lors de la récupération du token: $e');
      return null;
    }
  }

  // Méthode pour obtenir les en-têtes avec le token JWT
  Future<Map<String, String>> _getHeaders() async {
    final headers = <String, String>{
      'Content-Type': 'application/json; charset=utf-8',
      'Accept': 'application/json',
    };

    try {
      final token = await _getAuthToken();
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
    } catch (e) {
      debugPrint('Erreur lors de la récupération du token: $e');
    }

    return headers;
  }

  // Récupérer toutes les structures
  Future<List<Map<String, dynamic>>> getStructures() async {
    try {
      final url = Uri.parse('$_baseUrl/structures');
      final response = await client.get(url, headers: await _getHeaders());

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
        return data.map((item) => item as Map<String, dynamic>).toList();
      } else {
        debugPrint(
          'Erreur lors de la récupération des structures: ${response.statusCode}',
        );
        throw Exception('Échec du chargement des structures');
      }
    } catch (e) {
      debugPrint('Erreur lors de la récupération des structures: $e');
      rethrow;
    }
  }

  // Récupérer les services d'une structure
  Future<List<Map<String, dynamic>>> getServicesByStructureId(
    int structureId,
  ) async {
    try {
      final url = Uri.parse('$_baseUrl/structures/$structureId/services');
      final response = await client.get(url, headers: await _getHeaders());

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
        return data.map((item) => item as Map<String, dynamic>).toList();
      } else {
        debugPrint(
          'Erreur lors de la récupération des services: ${response.statusCode}',
        );
        throw Exception(
          'Échec du chargement des services pour la structure $structureId',
        );
      }
    } catch (e) {
      debugPrint('Erreur lors de la récupération des services: $e');
      rethrow;
    }
  }

  // Vérifier si une structure existe
  Future<bool> structureExists(int structureId) async {
    try {
      final url = Uri.parse('$_baseUrl/structures/$structureId');
      final response = await client.head(url, headers: await _getHeaders());
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Erreur lors de la vérification de la structure: $e');
      return false;
    }
  }

  // Vérifier si un service existe dans une structure
  Future<bool> serviceExists(int structureId, int serviceId) async {
    try {
      final url = Uri.parse(
        '$_baseUrl/structures/$structureId/services/$serviceId',
      );
      final response = await client.head(url, headers: await _getHeaders());
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Erreur lors de la vérification du service: $e');
      return false;
    }
  }
}
