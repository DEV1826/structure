import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart' show debugPrint;
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../models/payment_data.dart';

class PaymentService {
  static const String _initPaymentEndpoint = '/api/paiements/initier';
  static const String _verifyPaymentEndpoint = '/api/paiements/verifier';
  static const String _lastOrderIdKey = 'last_order_id';
  static const String _authTokenKey = 'auth_token';

  final http.Client client;
  final SharedPreferences prefs;

  PaymentService({required this.client, required this.prefs});

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
      final url = Uri.parse('${_baseUrl}$_initPaymentEndpoint');

      // Validation des entrées
      if (customerName.isEmpty) {
        throw Exception('Le nom du client est requis');
      }
      if (customerPhone.isEmpty) {
        throw Exception('Le numéro de téléphone est requis');
      }

      // Logs de débogage
      debugPrint('Tentative de connexion à: $url');
      debugPrint('Adresse IP de base: $_baseUrl');
      debugPrint('Endpoint: $_initPaymentEndpoint');
      debugPrint('URL complète: $url');

      // Test de connexion réseau
      try {
        final result = await InternetAddress.lookup(Uri.parse(_baseUrl).host);
        if (result.isEmpty || result[0].rawAddress.isEmpty) {
          debugPrint('Impossible de résoudre l\'hôte');
        } else {
          debugPrint('Hôte résolu avec succès: ${result[0].address}');
        }
      } on SocketException catch (e) {
        debugPrint('Erreur de résolution DNS: ${e.message}');
      }

      // Préparation des données client
      final customerData = {
        'firstName': customerName.split(' ').first,
        'lastName': customerName.split(' ').skip(1).join(' '),
        'phoneNumber': customerPhone.replaceAll(RegExp(r'\D'), ''),
        'email': customerEmail ?? 'client@structuremobile.com',
        'language': 'fr',
      };

      // Construction du corps de la requête
      final requestBody = {
        'customer': customerData,
        'amount': amount,
        'serviceId': serviceId,
        'structureId': structureId,
        'serviceName': serviceName ?? 'Service',
        'structureName': structureName ?? 'Structure',
        'currency': 'XAF',
        'reason': 'Paiement pour ${serviceName ?? 'service'}',
      };

      debugPrint('Envoi de la requête de paiement à: $url');
      debugPrint('Données de la requête: ${jsonEncode(requestBody)}');

      // Envoi de la requête
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

      // Traitement de la réponse
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
      final error = 'Erreur de connexion: ${e.message}';
      debugPrint(error);
      throw Exception(error);
    } on FormatException catch (e) {
      final error = 'Erreur de format de la réponse: $e';
      debugPrint(error);
      throw Exception(error);
    } on TimeoutException {
      final error = 'La connexion a expiré';
      debugPrint(error);
      throw Exception(error);
    } catch (e) {
      debugPrint('Erreur lors de l\'initialisation du paiement: $e');
      rethrow;
    }
  }

  // Vérifier le statut d'un paiement
  Future<PaymentData> verifyPayment(String orderId) async {
    try {
      final url = Uri.parse('${_baseUrl}$_verifyPaymentEndpoint/$orderId');
      debugPrint(' Vérification du paiement: $url');

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
        ' Réponse de vérification (${response.statusCode}): ${response.body}',
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
      debugPrint(' Erreur lors de la vérification du paiement: $e');
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
      debugPrint(' Erreur lors du lancement de l\'URL de paiement: $e');
      rethrow;
    }
  }

  // Sauvegarder le dernier orderId
  // TODO: Implémenter l'utilisation de _saveLastOrderId
  // pour suivre les paiements en cours
  Future<void> _saveLastOrderId(String orderId) async {
    await prefs.setString(_lastOrderIdKey, orderId);
  }

  // Récupérer le dernier orderId
  Future<String?> getLastOrderId() async {
    return prefs.getString(_lastOrderIdKey);
  }

  // Vérifier les paiements en attente
  Future<void> checkPendingPayment() async {
    final lastOrderId = await getLastOrderId();
    if (lastOrderId != null) {
      try {
        final paymentData = await verifyPayment(lastOrderId);
        if (paymentData.status == 'PENDING') {
          // Le paiement est toujours en attente
          debugPrint('Paiement en attente: $lastOrderId');
        }
      } catch (e) {
        debugPrint('Erreur lors de la vérification du paiement en attente: $e');
      }
    }
  }

  // Tester la connexion au serveur
  Future<bool> testConnection() async {
    try {
      final url = Uri.parse('${_baseUrl}/api/health');
      debugPrint(' Test de connexion à: $url');

      final response = await client
          .get(url)
          .timeout(
            const Duration(seconds: 5),
            onTimeout: () => throw TimeoutException(
              'La connexion a expiré après 5 secondes',
            ),
          );

      debugPrint(
        ' Réponse du serveur (${response.statusCode}): ${response.body}',
      );
      return response.statusCode == 200;
    } catch (e) {
      debugPrint(' Erreur de connexion: $e');
      return false;
    }
  }
}
