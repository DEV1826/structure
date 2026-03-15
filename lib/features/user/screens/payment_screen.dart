import 'dart:async';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../payment/models/payment_data.dart';
import '../../payment/screens/payment_success_screen.dart';
import '../../payment/services/payment_service.dart';
import '../../payment/services/structure_service.dart';
import '../models/structure_model.dart';

class PaymentScreen extends StatefulWidget {
  final StructureModel structure;
  final List<Map<String, dynamic>> selectedServices;
  final double totalAmount;

  const PaymentScreen({
    super.key, // Corrigé: utilisation de super.key
    required this.structure,
    required this.selectedServices,
    required this.totalAmount,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  late final PaymentService _paymentService;
  late final StructureService _structureService;
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();

  bool _isLoading = false;
  String? _errorMessage;
  StreamSubscription<PaymentData>? _paymentSubscription;

  void _handleError(String message) {
    if (!mounted) return;

    // Traduction des messages d'erreur courants
    String friendlyMessage = message;

    if (message.contains('Erreur de connexion') ||
        message.contains('timeout')) {
      friendlyMessage =
          'Impossible de se connecter au serveur. Vérifiez votre connexion Internet et réessayez.';
    } else if (message.contains('400') || message.contains('invalide')) {
      friendlyMessage =
          'Les informations fournies sont incorrectes. Veuillez vérifier vos saisies.';
    } else if (message.contains('404')) {
      friendlyMessage =
          'La ressource demandée est introuvable. Veuillez réessayer plus tard.';
    } else if (message.contains('500')) {
      friendlyMessage =
          'Une erreur est survenue sur le serveur. Notre équipe a été notifiée.';
    } else if (message.contains('paiement a échoué')) {
      friendlyMessage =
          'Le paiement n\'a pas pu être traité. Veuillez réessayer ou utiliser un autre moyen de paiement.';
    } else if (message.contains('expiré')) {
      friendlyMessage =
          'Le délai de paiement a expiré. Veuillez recommencer le processus.';
    }

    setState(() {
      _isLoading = false;
      _errorMessage = friendlyMessage;
    });

    // Afficher un snackbar en plus du message d'erreur
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(friendlyMessage),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 5),
        action: SnackBarAction(
          label: 'OK',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  void _handleSuccess(PaymentData paymentData) {
    if (!mounted) return;

    setState(() {
      _isLoading = false;
      _errorMessage = null; // Effacer les erreurs précédentes
    });

    // Afficher un message de succès
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Paiement initié avec succès !'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );

    // Navigation vers l'écran de succès après un court délai
    Future.delayed(const Duration(milliseconds: 500), () {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => PaymentSuccessScreen(paymentData: paymentData),
        ),
      );
    });
  }

  void _checkPaymentStatus(String orderId) {
    _paymentSubscription?.cancel();

    _paymentSubscription =
        Stream.periodic(
              const Duration(seconds: 5),
              (_) => _paymentService.verifyPayment(orderId),
            )
            .asyncMap((future) => future)
            .listen(
              (paymentData) {
                if (paymentData.status == 'SUCCESS') {
                  _handleSuccess(paymentData);
                } else if (paymentData.status == 'FAILED') {
                  _handleError('Le paiement a échoué');
                }
              },
              onError: (error) {
                _handleError(
                  'Erreur lors de la vérification du paiement: $error',
                );
              },
              cancelOnError: true,
            );

    // Arrêter le polling après 30 minutes
    Future.delayed(const Duration(minutes: 30), () {
      if (mounted) {
        _paymentSubscription?.cancel();
        _handleError('Le paiement a expiré');
      }
    });
  }

  Future<void> _processPayment() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final paymentData = await _paymentService.initiatePayment(
        amount: widget.totalAmount,
        serviceId: widget.structure.id,
        structureId: widget.structure.id,
        customerName: _nameController.text,
        customerPhone: _phoneController.text,
        customerEmail: _emailController.text,
      );

      if (paymentData.paymentLink.isNotEmpty) {
        final launched = await _paymentService.launchPaymentUrl(
          paymentData.paymentLink,
        );

        if (launched) {
          if (paymentData.orderId.isNotEmpty) {
            _checkPaymentStatus(paymentData.orderId);
          } else {
            throw Exception(
              'ID de commande manquant dans la réponse du serveur',
            );
          }
        } else {
          throw Exception('Impossible d\'ouvrir la page de paiement');
        }
      } else {
        throw Exception('Lien de paiement non fourni par le serveur');
      }
    } catch (e) {
      _handleError('Erreur lors du traitement du paiement: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _initializeServices();
  }

  Future<void> _initializeServices() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final httpClient = http.Client();
      _structureService = StructureService(client: httpClient, prefs: prefs);
      _paymentService = PaymentService(
        client: httpClient,
        prefs: prefs,
        structureService: _structureService,
      );
      _checkPendingPayments();
      _testConnection();
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Erreur d\'initialisation: ${e.toString()}';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _testConnection() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final isConnected = await _paymentService.testConnection();
      if (!mounted) return;

      if (isConnected) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Connecté au serveur avec succès')),
        );
      } else {
        setState(() {
          _errorMessage = 'Impossible de se connecter au serveur';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Erreur de connexion: $e';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _checkPendingPayments() async {
    try {
      final lastOrderId = await _paymentService.getLastOrderId();
      if (lastOrderId != null && mounted) {
        debugPrint('Vérification du paiement en attente: $lastOrderId');
        // Vous pouvez ajouter ici une logique pour vérifier l'état du dernier paiement
      }
    } catch (e) {
      debugPrint('Erreur lors de la vérification des paiements en attente: $e');
    }
  }

  @override
  void dispose() {
    _paymentSubscription?.cancel();
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Paiement')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Informations de la structure et des services
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.structure.name,
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 8),
                            ...widget.selectedServices.map(
                              (service) => Padding(
                                padding: const EdgeInsets.only(bottom: 8.0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(service['name'] ?? ''),
                                    Text(
                                      '${service['price']} FCFA',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const Divider(),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Total à payer',
                                  style: Theme.of(
                                    context,
                                  ).textTheme.titleMedium,
                                ),
                                Text(
                                  '${widget.totalAmount} FCFA',
                                  style: Theme.of(
                                    context,
                                  ).textTheme.titleMedium,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Informations personnelles
                    Text(
                      'Vos informations',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 16),

                    // Champ Nom complet
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Nom complet',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.person),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer votre nom complet';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Champ Téléphone
                    TextFormField(
                      controller: _phoneController,
                      decoration: const InputDecoration(
                        labelText: 'Téléphone',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.phone),
                        hintText: '6XXXXXXXX',
                      ),
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer votre numéro de téléphone';
                        }
                        if (!RegExp(r'^6[0-9]{8}$').hasMatch(value)) {
                          return 'Numéro de téléphone invalide';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Champ Email (optionnel)
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        labelText: 'Email (facultatif)',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.email),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value != null && value.isNotEmpty) {
                          if (!RegExp(
                            r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                          ).hasMatch(value)) {
                            return 'Email invalide';
                          }
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),

                    // Bouton de test de connexion
                    const SizedBox(height: 16),
                    OutlinedButton.icon(
                      onPressed: _isLoading ? null : _testConnection,
                      icon: const Icon(Icons.wifi_find),
                      label: const Text('Tester la connexion'),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                      ),
                    ),

                    // Affichage des messages d'erreur
                    if (_errorMessage != null) ...[
                      const SizedBox(height: 16),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.red.shade200),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.error_outline, color: Colors.red),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                _errorMessage!,
                                style: TextStyle(color: Colors.red.shade800),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.close,
                                size: 20,
                                color: Colors.red,
                              ),
                              onPressed: () {
                                setState(() {
                                  _errorMessage = null;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    ],

                    // Bouton de paiement
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        onPressed: _isLoading ? null : _processPayment,
                        icon: const Icon(Icons.payment, size: 20),
                        label: _isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : Text(
                                'Payer ${widget.totalAmount} FCFA',
                                style: const TextStyle(fontSize: 16),
                              ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 2,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
