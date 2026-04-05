import 'package:intl/intl.dart';
import 'package:flutter/material.dart' show Icons;

class DashboardStats {
  final int totalStructures;
  final int activeStructures;
  final int pendingStructures;
  final int totalUsers;
  final int activeUsers;
  final int newUsersThisMonth;
  final int totalServices; // Nombre de services/produits (spécifique à l'admin)
  final int totalRevenue;
  final Map<String, int> monthlyRevenue;
  final Map<String, int> structureCategories;
  final List<Map<String, dynamic>> recentActivities;
  final List<Map<String, dynamic>> topStructures;

  DashboardStats({
    required this.totalStructures,
    required this.activeStructures,
    required this.pendingStructures,
    required this.totalUsers,
    required this.activeUsers,
    required this.newUsersThisMonth,
    required this.totalServices,
    required this.totalRevenue,
    required this.monthlyRevenue,
    required this.structureCategories,
    required this.recentActivities,
    required this.topStructures,
  });

  // Pourcentage de structures actives
  double get activeStructuresPercentage =>
      totalStructures > 0 ? (activeStructures / totalStructures) * 100 : 0;

  // Pourcentage d'utilisateurs actifs
  double get activeUsersPercentage =>
      totalUsers > 0 ? (activeUsers / totalUsers) * 100 : 0;

  // Revenu formaté
  String get formattedTotalRevenue {
    final formatter = NumberFormat.currency(
      symbol: 'FCFA',
      decimalDigits: 0,
      locale: 'fr_FR',
    );
    return formatter.format(totalRevenue);
  }

  // Données pour le graphique de revenus
  List<Map<String, dynamic>> get chartData {
    return monthlyRevenue.entries.map((entry) {
      return {
        'month': entry.key,
        'revenue': entry.value,
      };
    }).toList();
  }

  // Données pour le graphique des catégories
  List<Map<String, dynamic>> get categoryData {
    return structureCategories.entries.map((entry) {
      return {
        'category': entry.key,
        'count': entry.value,
      };
    }).toList();
  }

  // Créer une instance à partir de données JSON
  factory DashboardStats.fromJson(Map<String, dynamic> json) {
    return DashboardStats(
      totalStructures: json['totalStructures'] ?? 0,
      activeStructures: json['activeStructures'] ?? 0,
      pendingStructures: json['pendingStructures'] ?? 0,
      totalUsers: json['totalUsers'] ?? 0,
      activeUsers: json['activeUsers'] ?? 0,
      newUsersThisMonth: json['newUsersThisMonth'] ?? 0,
      totalServices: json['totalServices'] ?? 0,
      totalRevenue: json['totalRevenue'] ?? 0,
      monthlyRevenue: Map<String, int>.from(json['monthlyRevenue'] ?? {}),
      structureCategories: Map<String, int>.from(json['structureCategories'] ?? {}),
      recentActivities: List<Map<String, dynamic>>.from(json['recentActivities'] ?? []),
      topStructures: List<Map<String, dynamic>>.from(json['topStructures'] ?? []),
    );
  }

  // Données de démo pour le développement
  factory DashboardStats.demo() {
    final now = DateTime.now();
    final formatter = DateFormat('MMM');
    
    // Générer des données de revenus mensuels pour les 6 derniers mois
    final monthlyRevenue = <String, int>{};
    for (var i = 5; i >= 0; i--) {
      final date = DateTime(now.year, now.month - i, 1);
      monthlyRevenue[formatter.format(date)] = 1000000 + (i * 200000);
    }
    
    // Catégories de structures
    final structureCategories = {
      'Restauration': 42,
      'Hébergement': 28,
      'Santé': 15,
      'Éducation': 8,
      'Commerce': 32,
      'Services': 24,
      'Loisirs': 19,
      'Autre': 12,
    };
    
    // Activités récentes
    final recentActivities = [
      {
        'id': '1',
        'type': 'new_structure',
        'title': 'Nouvelle structure ajoutée',
        'description': 'Hôtel du Lac a été ajouté par admin',
        'time': 'Il y a 5 minutes',
        'icon': Icons.business,
      },
      {
        'id': '2',
        'type': 'user_registration',
        'title': 'Nouvel utilisateur',
        'description': 'John Doe s\'est inscrit',
        'time': 'Il y a 1 heure',
        'icon': Icons.person_add,
      },
      {
        'id': '3',
        'type': 'payment_received',
        'title': 'Paiement reçu',
        'description': '25 000 FCFA de Restaurant Le Délicieux',
        'time': 'Il y a 3 heures',
        'icon': Icons.payment,
      },
      {
        'id': '4',
        'type': 'structure_approved',
        'title': 'Structure approuvée',
        'description': 'Clinique du Cœur a été approuvée',
        'time': 'Hier',
        'icon': Icons.verified_user,
      },
    ];
    
    // Meilleures structures
    final topStructures = [
      {
        'id': '1',
        'name': 'Hôtel du Plateau',
        'category': 'Hébergement',
        'revenue': 1250000,
        'rating': 4.8,
        'status': 'active',
      },
      {
        'id': '2',
        'name': 'Restaurant Le Délicieux',
        'category': 'Restauration',
        'revenue': 980000,
        'rating': 4.6,
        'status': 'active',
      },
      {
        'id': '3',
        'name': 'Clinique du Cœur',
        'category': 'Santé',
        'revenue': 875000,
        'rating': 4.9,
        'status': 'active',
      },
    ];
    
    return DashboardStats(
      totalStructures: 180,
      activeStructures: 156,
      pendingStructures: 12,
      totalUsers: 1245,
      activeUsers: 987,
      newUsersThisMonth: 124,
      totalServices: 45,
      totalRevenue: 12500000,
      monthlyRevenue: monthlyRevenue,
      structureCategories: structureCategories,
      recentActivities: recentActivities,
      topStructures: topStructures,
    );
  }

  /// Instance vide (avant chargement)
  factory DashboardStats.empty() => DashboardStats(
        totalStructures: 0,
        activeStructures: 0,
        pendingStructures: 0,
        totalUsers: 0,
        activeUsers: 0,
        newUsersThisMonth: 0,
        totalServices: 0,
        totalRevenue: 0,
        monthlyRevenue: {},
        structureCategories: {},
        recentActivities: [],
        topStructures: [],
      );

  /// Construit depuis les données réelles de l'API
  factory DashboardStats.fromRealData({
    required int totalStructures,
    required int activeStructures,
    int totalUsers = 0,
    int activeUsers = 0,
    int newUsersThisMonth = 0,
    int totalServices = 0,
  }) => DashboardStats(
        totalStructures: totalStructures,
        activeStructures: activeStructures,
        pendingStructures: 0,
        totalUsers: totalUsers,
        activeUsers: activeUsers,
        newUsersThisMonth: newUsersThisMonth,
        totalServices: totalServices,
        totalRevenue: 0,
        monthlyRevenue: {},
        structureCategories: {},
        recentActivities: [],
        topStructures: [],
      );

}