import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:structure_mobile/features/payment/models/payment_data.dart';
import 'package:structure_mobile/features/user/models/structure_model.dart';
import 'package:structure_mobile/features/user/models/service_model.dart';
import 'package:structure_mobile/features/user/screens/home_screen.dart';
import 'package:structure_mobile/features/user/screens/payment_screen.dart';
import 'package:structure_mobile/features/user/screens/payment_success_screen.dart';
import 'package:structure_mobile/features/user/screens/services_selection_screen.dart';
import 'package:structure_mobile/features/user/screens/structure_detail_screen.dart';

class UserRouter {
  // Route paths
  static const String home = '/home';
  static const String structureDetail = '/structure/:id';
  static const String servicesSelection = '/services-selection';
  static const String payment = '/payment';
  static const String paymentSuccess = '/payment/success';

  // Get all user routes for the main router
  static List<RouteBase> get routes => [
    GoRoute(
      path: home,
      name: 'home',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: structureDetail,
      name: 'structure-detail',
      builder: (context, state) {
        final structureId = state.pathParameters['id']!;
        return StructureDetailScreen(structureId: structureId);
      },
    ),
    GoRoute(
      path: servicesSelection,
      name: 'services-selection',
      builder: (context, state) {
        final args = state.extra as Map<String, dynamic>?;
        if (args == null ||
            args['structure'] == null ||
            args['services'] == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Erreur')),
            body: const Center(child: Text('Données manquantes')),
          );
        }
        return ServicesSelectionScreen(
          structure: args['structure'] as StructureModel,
          services: (args['services'] as List<dynamic>).cast<ServiceModel>(),
        );
      },
    ),
    GoRoute(
      path: payment,
      name: 'payment',
      pageBuilder: (context, state) {
        final args = state.extra as Map<String, dynamic>?;
        if (args == null ||
            args['structure'] == null ||
            args['selectedServices'] == null) {
          return MaterialPage(
            key: state.pageKey,
            child: const Scaffold(
              body: Center(child: Text('Données de paiement manquantes')),
            ),
          );
        }

        // Convertir la structure en StructureModel si nécessaire
        final structure = args['structure'] is StructureModel
            ? args['structure'] as StructureModel
            : StructureModel.fromJson(
                Map<String, dynamic>.from(args['structure']),
              );

        // Convertir les services sélectionnés
        final selectedServices = (args['selectedServices'] as List<dynamic>)
            .map((e) => Map<String, dynamic>.from(e))
            .toList();

        return MaterialPage(
          key: state.pageKey,
          child: PaymentScreen(
            structure: structure,
            selectedServices: selectedServices,
            totalAmount: (args['totalAmount'] as num).toDouble(),
          ),
        );
      },
    ),
    GoRoute(
      path: paymentSuccess,
      name: 'payment-success',
      pageBuilder: (context, state) {
        final paymentData = state.extra as PaymentData;
        return MaterialPage(
          key: state.pageKey,
          child: PaymentSuccessScreen(paymentData: paymentData),
        );
      },
    ),
  ];

  // Navigation methods
  static void goToHome(BuildContext context) => context.go(home);

  static void goToStructureDetail(BuildContext context, String structureId) =>
      context.go(structureDetail.replaceAll(':id', structureId));

  static void goToPaymentScreen(
    BuildContext context, {
    required StructureModel structure,
    required List<Map<String, dynamic>> selectedServices,
    required double totalAmount,
  }) {
    // Préparer les données pour la navigation
    final navigationData = {
      'structure': structure,
      'selectedServices': selectedServices,
      'totalAmount': totalAmount,
    };

    // Naviguer vers l'écran de paiement
    context.push(payment, extra: navigationData);
  }

  static void goToPaymentSuccess(
    BuildContext context, {
    required PaymentData paymentData,
  }) {
    context.pushReplacement(paymentSuccess, extra: paymentData);
  }
}
