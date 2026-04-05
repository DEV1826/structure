import 'package:flutter/material.dart';
import 'package:structure_mobile/core/network/api_service.dart';
import 'package:structure_mobile/features/admin/models/admin_model.dart';
import 'package:structure_mobile/features/admin/models/dashboard_stats.dart';
import 'package:structure_mobile/features/admin/models/service_product_model.dart';
import 'package:structure_mobile/features/admin/models/payment_model.dart';

class DashboardProvider extends ChangeNotifier {
  DashboardStats _stats = DashboardStats.empty();
  bool _isLoading = false;
  bool _isDemoMode = false; // Nouvel indicateur pour les données fictives
  String? _error;
  String _activeTab = 'overview';
  String? _selectedStructureId; // ID de la structure sélectionnée par le Super Admin

  // Structures chargées depuis l'API
  List<Map<String, dynamic>> _structures = [];
  // Administrateurs chargés depuis l'API
  List<Admin> _admins = [];
  // Services/Produits - liste vide au démarrage, chargée depuis l'API ou fictifs en fallback
  List<ServiceProduct> _services = [];
  // Paiements/Transactions
  List<Payment> _payments = [];

  DashboardStats get stats => _stats;
  bool get isLoading => _isLoading;
  bool get isDemoMode => _isDemoMode;
  String? get error => _error;
  String get activeTab => _activeTab;
  List<Map<String, dynamic>> get structures => _structures;
  List<Admin> get admins => _admins;
  List<ServiceProduct> get services => _services;
  List<Payment> get payments => _payments;
  String? get selectedStructureId => _selectedStructureId;

  void setActiveTab(String tabId) {
    _activeTab = tabId;
    notifyListeners();
  }

  // ─── Structures ────────────────────────────────────────────────

  Future<void> loadStructures({
    String? status,
    String? searchQuery,
    String? sortBy,
    String? structureId,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await ApiService.get('structures');

      if (response['success'] == true) {
        final data = response['data'];
        List<dynamic> list;
        if (data is List) {
          list = data;
        } else if (data is Map && data.containsKey('content')) {
          list = data['content'] as List;
        } else {
          list = [];
        }

        _structures = list.map<Map<String, dynamic>>((e) {
          final m = Map<String, dynamic>.from(e as Map);
          // normalise l'état : le backend n'a pas de "status", on déduit depuis "active"
          m['status'] = (m['active'] == true) ? 'active' : 'suspended';
          return m;
        }).toList();

        // Si le backend ne retourne rien, on injecte les structures fictives du dashboard
        if (_structures.isEmpty) {
          _structures = _getFictiveStructures();
        }

        // Filtre par structureId (admin limité)
        if (structureId != null && structureId.isNotEmpty) {
          _structures =
              _structures.where((s) => s['id'].toString() == structureId).toList();
        }

        // Filtre statut
        if (status != null && status != 'all') {
          _structures =
              _structures.where((s) => s['status'] == status).toList();
        }

        // Recherche
        if (searchQuery != null && searchQuery.isNotEmpty) {
          final q = searchQuery.toLowerCase();
          _structures = _structures
              .where((s) =>
          (s['name'] ?? '').toString().toLowerCase().contains(q) ||
              (s['description'] ?? '').toString().toLowerCase().contains(q))
              .toList();
        }

        // Tri (on trie sur le nom car le backend ne renvoie pas de date de création)
        if (sortBy == 'name_asc') {
          _structures.sort((a, b) =>
              (a['name'] ?? '').toString().compareTo((b['name'] ?? '').toString()));
        } else if (sortBy == 'name_desc') {
          _structures.sort((a, b) =>
              (b['name'] ?? '').toString().compareTo((a['name'] ?? '').toString()));
        }
      } else {
        _error = response['error'] ?? 'Impossible de charger les structures';
        _isDemoMode = true; // Si l'API échoue, on passe en mode démo
      }

      // Auto-sélection de la première structure si rien n'est sélectionné (pour Super Admin)
      if (_selectedStructureId == null && _structures.isNotEmpty) {
        _selectedStructureId = _structures.first['id'].toString();
        debugPrint('Auto-sélection de la structure : $_selectedStructureId');
      }
    } catch (e) {
      // En cas d'erreur réseau, on utilise les structures fictives
      _structures = _getFictiveStructures();
      _isDemoMode = true;
      debugPrint('loadStructures error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ─── Services ──────────────────────────────────────────────────

  Future<void> loadPayments(String? structureId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final endpoint = (structureId != null && structureId.isNotEmpty)
          ? 'transactions/structure/$structureId'
          : 'transactions';
      final response = await ApiService.get(endpoint);

      if (response['success'] == true) {
        final data = response['data'];
        final list = data is List ? data : [];
        final realPayments = list.map<Payment>((json) => Payment.fromJson(json as Map<String, dynamic>)).toList();
        _payments = [...realPayments.reversed, ..._getFictivePayments()];
      } else {
        _error = response['error'] ?? 'Erreur lors du chargement des paiements';
      }
    } catch (e) {
      _error = 'Erreur réseau lors du chargement des paiements';
      debugPrint('loadPayments error: $e');
      if (_payments.isEmpty) {
        _payments = _getFictivePayments();
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadServices(String structureId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final response = await ApiService.get('structures/$structureId/services');
      List<ServiceProduct> realServices = [];

      if (response['success'] == true) {
        final data = response['data'];
        final list = data is List ? data : [];
        realServices = list.map<ServiceProduct>((json) => ServiceProduct.fromJson(json as Map<String, dynamic>)).toList();
        debugPrint('Services réels chargés : ${realServices.length}');
      } else {
        _error = response['error'] ?? 'Erreur lors du chargement des services';
        debugPrint('Erreur API Services: $_error');
      }

      // Fictifs uniquement si le backend ne retourne rien
      if (realServices.isEmpty) {
        _services = _getFictiveServices();
      } else {
        _services = realServices;
      }
    } catch (e) {
      _error = 'Erreur réseau lors du chargement des services';
      debugPrint('loadServices error: $e');
      _services = _getFictiveServices();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createService(ServiceProduct service) async {
    if (_isDemoMode) {
      _error = 'Action impossible en Mode Démo. Veuillez vérifier votre connexion au serveur.';
      notifyListeners();
      return false;
    }

    // Vérifier que structureId est un entier valide (venant du backend)
    final structureIdInt = int.tryParse(service.structureId);
    if (structureIdInt == null) {
      _error = 'Cette structure est fictive (ID: "${service.structureId}"). Créez une vraie structure d\'abord.';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      // Payload conforme au ServiceDto — structureId est dans l'URL, pas dans le body
      final payload = {
        'name': service.name,
        'description': service.description,
        'price': service.price,
        'category': service.category,
        'duration': service.duration,
        'active': service.active,
      };
      debugPrint('Envoi service → structures/$structureIdInt/services : $payload');

      final response = await ApiService.post(
        'structures/$structureIdInt/services',
        payload,
      );

      if (response['success'] == true) {
        await loadServices(service.structureId);
        // Rafraîchir le compteur dans le header
        await loadDashboardData(isAdmin: true, structureId: service.structureId);
        return true;
      } else {
        _error = response['error'] ?? 'Erreur lors de la création du service';
        debugPrint('Échec création service: $_error');
        return false;
      }
    } catch (e) {
      _error = 'Erreur réseau lors de la création du service';
      debugPrint('createService error: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ─── Structures fictives (fallback si backend vide/indisponible) ──
  List<ServiceProduct> _getFictiveServices() {
    return [
      ServiceProduct(
        id: 'SP001',
        name: 'Consultation Générale',
        description: 'Consultation médicale avec un médecin généraliste.',
        price: 5000.0,
        structureId: 'S001',
      ),
      ServiceProduct(
        id: 'SP002',
        name: 'Analyse Sanguine',
        description: 'Examen sanguin complet pour bilan annuel.',
        price: 15000.0,
        structureId: 'S001',
      ),
    ];
  }

  List<Payment> _getFictivePayments() {
    final now = DateTime.now();
    return [
      Payment(
        id: 'PAY001',
        clientName: 'Jean Dupont',
        serviceName: 'Consultation Générale',
        amount: 5000,
        date: now.subtract(const Duration(days: 2)),
        paymentMethod: 'Mobile Money',
      ),
      Payment(
        id: 'PAY002',
        clientName: 'Marie Martin',
        serviceName: 'Analyse Sanguine',
        amount: 15000,
        date: now.subtract(const Duration(days: 5)),
        paymentMethod: 'Carte Bancaire',
      ),
    ];
  }

  List<Map<String, dynamic>> _getFictiveStructures() {
    return [
      {'id': 'S001', 'name': 'Hôpital Central', 'status': 'active', 'active': true, 'address': 'Yaoundé Centre'},
      {'id': 'S002', 'name': 'École Primaire', 'status': 'active', 'active': true, 'address': 'Yaoundé'},
      {'id': 'S003', 'name': 'Hôtel du Plateau', 'status': 'active', 'active': true, 'address': 'Plateau'},
      {'id': 'S004', 'name': 'Restaurant Le Délicieux', 'status': 'active', 'active': true, 'address': 'Centre Ville'},
      {'id': 'S005', 'name': 'Clinique du Cœur', 'status': 'active', 'active': true, 'address': 'Bastos'},
    ];
  }

  Future<Map<String, dynamic>> createStructure(
      Map<String, dynamic> data) async {
    try {
      // S'assurer que les clés correspondent au DTO backend
      final payload = {
        'name': data['name'],
        'email': data['email'],
        'description': data['description'],
        'address': data['address'],
        'phone': data['phone'],
        'imageUrl': data['imageUrl'],
        'adminId': data['adminId'], // Ajout de l'ID de l'admin
      };
      
      final response = await ApiService.post('superadmin/structures', payload);
      if (response['success'] == true) {
        await loadStructures(); // rafraîchit la liste
        return {'success': true};
      } else {
        return {
          'success': false,
          'error': response['error'] ?? 'Erreur lors de la création'
        };
      }
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  Future<Map<String, dynamic>> updateStructure(
      String id, Map<String, dynamic> data) async {
    try {
      final response = await ApiService.put('structures/$id', data);
      if (response['success'] == true) {
        await loadStructures();
        return {'success': true};
      } else {
        return {
          'success': false,
          'error': response['error'] ?? 'Erreur lors de la mise à jour'
        };
      }
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  Future<Map<String, dynamic>> deleteStructure(String id) async {
    try {
      final response = await ApiService.delete('structures/$id');
      if (response['success'] == true) {
        await loadStructures();
        return {'success': true};
      } else {
        return {
          'success': false,
          'error': response['error'] ?? 'Erreur lors de la suppression'
        };
      }
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  // ─── Dashboard stats ────────────────────────────────────────────

  Future<void> loadDashboardData({bool isAdmin = false, String? structureId}) async {
    if (_isLoading) return;
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Charge les structures
      final structResponse = await ApiService.get('structures');
      int totalStructs = 0;
      int activeStructs = 0;

      if (structResponse['success'] == true) {
        final data = structResponse['data'];
        List<dynamic> list = data is List
            ? data
            : (data is Map && data.containsKey('content'))
            ? data['content'] as List
            : [];
        totalStructs = list.length;
        activeStructs = list.where((s) => s['active'] == true).length;
        _isDemoMode = false;
      } else {
        _isDemoMode = true;
        _error = structResponse['error'] ?? 'Impossible de joindre le serveur';
      }

      // Charge les utilisateurs
      final userResponse = await ApiService.get('users');
      int totalUsers = 0;
      int activeUsers = 0;
      int newUsers = 0;

      if (userResponse['success'] == true) {
        final data = userResponse['data'];
        List<dynamic> list = data is List
            ? data
            : (data is Map && data.containsKey('content'))
            ? data['content'] as List
            : [];
        totalUsers = list.length;
        activeUsers = list.where((u) => u['active'] == true).length;

        // Simuler le calcul des nouveaux utilisateurs (créés ce mois-ci)
        final now = DateTime.now();
        newUsers = list.where((u) {
          if (u['createdAt'] == null) return false;
          final createdAt = DateTime.tryParse(u['createdAt']);
          return createdAt != null && createdAt.month == now.month && createdAt.year == now.year;
        }).length;
      }

      // Charge les services pour l'admin
      int totalServices = 0;
      if (isAdmin && structureId != null) {
        final servicesResponse = await ApiService.get('structures/$structureId/services');
        if (servicesResponse['success'] == true) {
          final sData = servicesResponse['data'];
          List<dynamic> sList = sData is List ? sData : [];
          totalServices = sList.length;
        } else {
          totalServices = 0;
        }
      }

      _stats = DashboardStats.fromRealData(
        totalStructures: totalStructs,
        activeStructures: activeStructs,
        totalUsers: totalUsers,
        activeUsers: activeUsers,
        newUsersThisMonth: newUsers,
        totalServices: totalServices,
      );
      _isDemoMode = false;
    } catch (e) {
      _error = 'Impossible de charger le tableau de bord.';
      _stats = DashboardStats.empty();
      _isDemoMode = true;
      debugPrint('loadDashboardData error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setSelectedStructureId(String? id) {
    if (id != _selectedStructureId) {
      _selectedStructureId = id;
      notifyListeners();
    }
  }

  // ─── Structures ────────────────────────────────────────────────

  // ─── Administrateurs ────────────────────────────────────────────

  Future<Map<String, dynamic>> createAdminForStructure(String structureId, Map<String, dynamic> data) async {
    if (_isDemoMode) {
      _error = 'Action impossible en Mode Démo.';
      notifyListeners();
      return {'success': false, 'error': _error};
    }

    try {
      final response = await ApiService.post('superadmin/structures/$structureId/admin', data);
      if (response['success'] == true) {
        await loadAdmins();
        return {'success': true};
      } else {
        return {'success': false, 'error': response['error'] ?? 'Erreur lors de la création de l\'admin'};
      }
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  Future<void> loadAdmins({String? searchQuery}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Le backend pourrait avoir un endpoint dédié ou on filtre les utilisateurs par rôle
      final response = await ApiService.get('users', queryParameters: {'role': 'ADMIN'});

      if (response['success'] == true) {
        final data = response['data'];
        List<dynamic> list = data is List
            ? data
            : (data is Map && data.containsKey('content'))
            ? data['content'] as List
            : [];

        _admins = list.map((e) => Admin.fromJson(Map<String, dynamic>.from(e as Map))).toList();
        
        debugPrint('Admins chargés : ${_admins.length}');
        
        if (searchQuery != null && searchQuery.isNotEmpty) {
          final q = searchQuery.toLowerCase();
          _admins = _admins.where((a) =>
          a.name.toLowerCase().contains(q) ||
              a.email.toLowerCase().contains(q) ||
              a.structureName.toLowerCase().contains(q)
          ).toList();
        }
      } else {
        _error = response['error'] ?? 'Impossible de charger les administrateurs';
      }
    } catch (e) {
      _error = 'Erreur réseau lors du chargement des administrateurs';
      debugPrint('loadAdmins error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshData() => loadDashboardData();

  // ─── Actions (approve / reject / suspend) ──────────────────────

  Future<Map<String, dynamic>> createUser(Map<String, dynamic> data) async {
    try {
      final response = await ApiService.post('users', data);
      if (response['success'] == true) {
        await loadUsers(); // Rafraîchit la liste des utilisateurs
        await loadAdmins(); // Rafraîchit aussi les admins au cas où
        return {'success': true};
      } else {
        return {'success': false, 'error': response['error'] ?? 'Erreur lors de la création'};
      }
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  Future<Map<String, dynamic>> updateUser(String userId, Map<String, dynamic> data) async {
    try {
      final response = await ApiService.put('users/$userId', data);
      if (response['success'] == true) {
        await loadUsers();
        await loadAdmins();
        return {'success': true};
      } else {
        return {'success': false, 'error': response['error'] ?? 'Erreur lors de la mise à jour'};
      }
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  Future<Map<String, dynamic>> deleteUser(String userId) async {
    try {
      final response = await ApiService.delete('users/$userId');
      if (response['success'] == true) {
        await loadUsers();
        await loadAdmins();
        return {'success': true};
      } else {
        return {'success': false, 'error': response['error'] ?? 'Erreur lors de la suppression'};
      }
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  Future<Map<String, dynamic>> suspendUser(String userId, {bool active = false}) async {
    try {
      final response = await ApiService.put('users/$userId', {'active': active});
      if (response['success'] == true) {
        await loadUsers();
        return {'success': true};
      } else {
        return {'success': false, 'error': response['error'] ?? 'Erreur lors de l\'opération'};
      }
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  Future<Map<String, dynamic>> approveUser(String userId) async {
    return suspendUser(userId, active: true);
  }

  Future<Map<String, dynamic>> rejectUser(String userId, String reason) async {
    // Pour l'instant on supprime l'utilisateur refusé, ou on pourrait appeler un endpoint dédié
    return deleteUser(userId);
  }

  // Plage de dates pour les rapports
  DateTimeRange _selectedDateRange = DateTimeRange(
    start: DateTime.now().subtract(const Duration(days: 30)),
    end: DateTime.now(),
  );
  DateTimeRange get selectedDateRange => _selectedDateRange;

  Future<void> updateDateRange(DateTimeRange newRange) async {
    _selectedDateRange = newRange;
    await loadDashboardData();
  }

  // Utilisateurs (données locales pour l'instant)
  List<Map<String, dynamic>> _users = [];
  List<Map<String, dynamic>> get users => _users;

  Future<void> loadUsers({
    String? status,
    String? role,
    String? searchQuery,
    String? sortBy,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final response = await ApiService.get('users');
      if (response['success'] == true) {
        final data = response['data'];
        final list = data is List ? data : (data is Map && data.containsKey('content') ? data['content'] as List : []);
        _users = list.map<Map<String, dynamic>>((e) => Map<String, dynamic>.from(e as Map)).toList();
        if (status != null && status != 'all') {
          _users = _users.where((u) => (u['active'] == true ? 'active' : 'inactive') == status).toList();
        }
        if (role != null && role != 'all') {
          _users = _users.where((u) => u['role'] == role).toList();
        }
        if (searchQuery != null && searchQuery.isNotEmpty) {
          final q = searchQuery.toLowerCase();
          _users = _users.where((u) =>
          (u['email'] ?? '').toString().toLowerCase().contains(q) ||
              (u['firstName'] ?? '').toString().toLowerCase().contains(q) ||
              (u['lastName'] ?? '').toString().toLowerCase().contains(q)
          ).toList();
        }
      } else {
        _error = response['error'] ?? 'Erreur chargement utilisateurs';
      }
    } catch (e) {
      _error = 'Erreur réseau : $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

}