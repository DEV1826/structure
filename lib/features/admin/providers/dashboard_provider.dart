import 'package:flutter/material.dart';
import 'package:structure_mobile/core/network/api_service.dart';
import 'package:structure_mobile/features/admin/models/dashboard_stats.dart';

class DashboardProvider extends ChangeNotifier {
  DashboardStats _stats = DashboardStats.empty();
  bool _isLoading = false;
  String? _error;
  String _activeTab = 'overview';

  // Structures chargées depuis l'API
  List<Map<String, dynamic>> _structures = [];

  DashboardStats get stats => _stats;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get activeTab => _activeTab;
  List<Map<String, dynamic>> get structures => _structures;

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
      }
    } catch (e) {
      _error = 'Erreur réseau : $e';
      debugPrint('loadStructures error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>> createStructure(
      Map<String, dynamic> data) async {
    try {
      final response = await ApiService.post('structures', data);
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

  Future<void> loadDashboardData() async {
    if (_isLoading) return;
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Charge les structures pour avoir des stats réelles
      final response = await ApiService.get('structures');
      if (response['success'] == true) {
        final data = response['data'];
        List<dynamic> list = data is List
            ? data
            : (data is Map && data.containsKey('content'))
                ? data['content'] as List
                : [];

        final allStructures = list.map((e) => Map<String, dynamic>.from(e as Map)).toList();
        final active = allStructures.where((s) => s['active'] == true).length;

        _stats = DashboardStats.fromRealData(
          totalStructures: allStructures.length,
          activeStructures: active,
        );
      } else {
        _stats = DashboardStats.empty();
      }
    } catch (e) {
      _error = 'Impossible de charger le tableau de bord.';
      _stats = DashboardStats.empty();
      debugPrint('loadDashboardData error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshData() => loadDashboardData();

  // ─── Actions (approve / reject / suspend) ──────────────────────

  Future<void> approveStructure(String structureId) async {
    await updateStructure(structureId, {'active': true});
  }

  Future<void> rejectStructure(String structureId, String reason) async {
    await deleteStructure(structureId);
  }

  Future<void> suspendUser(String userId) async {
    try {
      await ApiService.put('users/$userId', {'active': false});
      notifyListeners();
    } catch (e) {
      debugPrint('suspendUser error: $e');
    }
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