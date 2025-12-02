import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart' show debugPrint;
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../models/payment_data.dart';
import 'structure_service.dart';

class PaymentService {
  static const String _initPaymentEndpoint = '/api/paiements/initier';
  static const String _verifyPaymentEndpoint = '/api/paiements/verifier';
  static const String _lastOrderIdKey = 'last_order_id';
  static const String _authTokenKey = 'auth_token';

  final http.Client client;
  final SharedPreferences prefs;
  final StructureService structureService;

  PaymentService({
    required this.client,
    required this.prefs,
    required this.structureService,
  });

  // Configuration de l'URL de base
  static String get _baseUrl {
    // Pour le test, on force l'IP locale
    const String serverIp =
        '192.168.1.179'; // Remplacez par votre IP locale si nécessaire
    const String serverPort = '8080';
    final String baseUrl = 'http://$serverIp:$serverPort';

    debugPrint('Configuration de l\'URL de base: $baseUrl');

    // Pour le débogage sur émulateur Android
    if (Platform.isAndroid) {
      debugPrint('Appareil Android détecté - Connexion directe au serveur');
    }

    return baseUrl;
  }

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

  // Initialisation d'un paiement
  Future<PaymentData> initiatePayment({
    required double amount,
    required String serviceId,
    required String structureId,
    required String customerName,
    required String customerPhone,
    String? customerEmail,
    String? serviceName,
    String? structureName,
  }) async {
    try {
      // Validation des entrées
      if (customerName.trim().isEmpty) {
        throw Exception('Le nom complet est requis');
      }

      final nameParts = customerName
          .trim()
          .split(' ')
          .where((part) => part.isNotEmpty)
          .toList();
      if (nameParts.length < 2) {
        throw Exception('Veuillez entrer un prénom et un nom');
      }

      final phoneNumber = customerPhone.replaceAll(RegExp(r'\D'), '');
      if (phoneNumber.isEmpty || phoneNumber.length < 8) {
        throw Exception('Numéro de téléphone invalide');
      }

      final email = customerEmail?.trim() ?? '';
      if (email.isNotEmpty &&
          !RegExp(
            r'^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[\w-]{2,4}\$',
          ).hasMatch(email)) {
        throw Exception('Adresse email invalide');
      }

      // Conversion des IDs en entiers
      final numericServiceId = int.tryParse(
        serviceId.replaceAll(RegExp(r'\D'), ''),
      );
      final numericStructureId = int.tryParse(
        structureId.replaceAll(RegExp(r'\D'), ''),
      );

      if (numericServiceId == null) {
        throw Exception('ID de service invalide');
      }
      if (numericStructureId == null) {
        throw Exception('ID de structure invalide');
      }

      // Vérification de l'existence de la structure et du service
      final structureExists = await structureService.structureExists(
        numericStructureId,
      );
      if (!structureExists) {
        throw Exception('La structure spécifiée n\'existe pas');
      }

      final serviceExists = await structureService.serviceExists(
        numericStructureId,
        numericServiceId,
      );
      if (!serviceExists) {
        throw Exception(
          'Le service spécifié n\'existe pas pour cette structure',
        );
      }

      final url = Uri.parse('${_baseUrl}$_initPaymentEndpoint');

      debugPrint('Préparation de la requête de paiement...');
      debugPrint('URL: $url');
      debugPrint(
        'Service ID: $numericServiceId, Structure ID: $numericStructureId',
      );

      final customerData = {
        'firstName': nameParts.first,
        'lastName': nameParts.skip(1).join(' '),
        'phoneNumber': phoneNumber,
        'email': email.isNotEmpty ? email : 'client@structuremobile.com',
        'language': 'fr',
      };

      final requestBody = {
        'customer': customerData,
        'amount': amount.toInt(),
        'serviceId': numericServiceId,
        'structureId': numericStructureId,
        'serviceName': serviceName,
        'structureName': structureName,
        'currency': 'XAF',
        'reason': 'Paiement pour ${serviceName ?? 'service'}',
      };

      debugPrint('En-têtes de la requête: ${await _getHeaders()}');
      debugPrint('Corps de la requête: ${jsonEncode(requestBody)}');

      final response = await client
          .post(
            url,
            headers: await _getHeaders(),
            body: jsonEncode(requestBody),
          )
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              throw TimeoutException('La connexion a expiré après 30 secondes');
            },
          );

      debugPrint(
        'Réponse du serveur (${response.statusCode}): ${response.body}',
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData =
            jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
        return PaymentData.fromJson(responseData);
      } else {
        final errorMessage =
            'Erreur serveur: ${response.statusCode}\n${response.body}';
        debugPrint(errorMessage);
        throw HttpException(errorMessage, uri: url);
      }
    } on SocketException catch (e) {
      final error = 'Erreur de connexion au serveur: ${e.message}';
      debugPrint(error);
      throw Exception('Vérifiez votre connexion internet et réessayez');
    } on FormatException catch (e) {
      final error = 'Erreur de format de la réponse: $e';
      debugPrint(error);
      throw Exception('Erreur lors du traitement de la réponse du serveur');
    } on TimeoutException {
      const error = 'La connexion a expiré';
      debugPrint(error);
      throw Exception(
        'Le serveur met trop de temps à répondre. Veuillez réessayer plus tard.',
      );
    } on HttpException catch (e) {
      debugPrint('Erreur HTTP: ${e.message}');
      rethrow;
    } catch (e) {
      debugPrint('Erreur inattendue: $e');
      rethrow;
    }
  }

  // Vérifier le statut d'un paiement
  Future<PaymentData> verifyPayment(String orderId) async {
    try {
      final url = Uri.parse('${_baseUrl}$_verifyPaymentEndpoint/$orderId');
      debugPrint('Vérification du paiement: $url');

      final response = await client
          .get(url, headers: await _getHeaders())
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              throw TimeoutException(
                'La vérification du paiement a expiré après 30 secondes',
              );
            },
          );

      debugPrint(
        'Réponse de vérification (${response.statusCode}): ${response.body}',
      );

      if (response.statusCode == 200) {
        final responseData =
            jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
        return PaymentData.fromJson(responseData);
      } else {
        throw HttpException(
          'Erreur lors de la vérification du paiement: ${response.statusCode}\n${response.body}',
          uri: url,
        );
      }
    } catch (e) {
      debugPrint('Erreur lors de la vérification du paiement: $e');
      rethrow;
    }
  }

  // Lancer l'URL de paiement dans le navigateur
  Future<bool> launchPaymentUrl(String paymentUrl) async {
    try {
      if (await canLaunchUrlString(paymentUrl)) {
        await launchUrlString(paymentUrl, mode: LaunchMode.externalApplication);
        return true;
      } else {
        throw 'Impossible d\'ouvrir l\'URL de paiement';
      }
    } catch (e) {
      debugPrint('Erreur lors du lancement de l\'URL de paiement: $e');
      rethrow;
    }
  }

  // Tester la connexion au serveur
  Future<bool> testConnection() async {
    try {
      final url = Uri.parse('$_baseUrl/api/health');
      debugPrint('Test de connexion au serveur: $url');

      final response = await client
          .get(url, headers: await _getHeaders())
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              throw TimeoutException('La connexion a expiré après 10 secondes');
            },
          );

      debugPrint(
        'Réponse du serveur (${response.statusCode}): ${response.body}',
      );
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Erreur de test de connexion: $e');
      return false;
    }
  }

  // Récupérer le dernier ID de commande
  String? getLastOrderId() {
    try {
      return prefs.getString(_lastOrderIdKey);
    } catch (e) {
      debugPrint(
        'Erreur lors de la récupération du dernier ID de commande: $e',
      );
      return null;
    }
  }

  // Sauvegarder l'ID de commande
  Future<void> _saveLastOrderId(String orderId) async {
    try {
      await prefs.setString(_lastOrderIdKey, orderId);
      debugPrint('ID de commande sauvegardé: $orderId');
    } catch (e) {
      debugPrint('Erreur lors de la sauvegarde de l\'ID de commande: $e');
    }
  }
}
