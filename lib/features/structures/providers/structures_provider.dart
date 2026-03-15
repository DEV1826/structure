import 'package:flutter/material.dart';
import 'package:structure_mobile/core/network/api_service.dart';
import 'package:structure_mobile/features/structures/data/structure_data.dart';
import 'package:structure_mobile/features/structures/models/service_model.dart';
import 'package:structure_mobile/features/structures/models/structure_model.dart';
import 'package:structure_mobile/features/user/models/service_model.dart' as user_models;

class StructuresProvider extends ChangeNotifier {
  final BuildContext context;
  List<Structure> _allStructures = [];
  List<Structure> _filteredStructures = []; // Liste filtrée
  bool _isLoading = false;
  String? _error;
  String? _searchQuery;
  String? _selectedCategory;
  String? _selectedSortOption;

  StructuresProvider(this.context) {
    // Initialisation du provider avec le contexte
    _initialize();
  }

  // Initialisation asynchrone
  Future<void> _initialize() async {
    await loadStructures();
  }


  @override
  void dispose() {
    // Nettoyage
    super.dispose();
  }

  // Method aliases for compatibility
  Future<void> fetchStructures() => loadStructures();

  /// Retrieves a structure by its ID.
  /// 
  /// Returns the first structure with the matching [id], or null if:
  /// - The [id] is null or empty
  /// - No structure with the given ID exists
  Structure? getStructureById(String id) {
    if (!hasAccessToStructure(id)) {
      return null;
    }
    try {
      return _allStructures.firstWhere((structure) => structure.id == id);
    } catch (e) {
      return null;
    }
  }

  // Get services for a structure with access control
  List<user_models.ServiceModel> getServicesForStructure(String structureId) {
    // Vérifier l'accès à la structure
    if (!hasAccessToStructure(structureId)) return [];
    
    // Trouver la structure dans la liste complète
    try {
      final structure = _allStructures.firstWhere((s) => s.id == structureId);
      
      // Convertir le modèle interne Service en modèle utilisateur ServiceModel
      return structure.services
          .map(
            (service) => user_models.ServiceModel(
              id: service.id,
              name: service.name,
              description: service.description,
              price: service.price ?? 0.0, // Valeur par défaut pour un prix non nul
              duration: service.duration,
              structureId: structureId,
              category: service.category,
              isAvailable: service.isAvailable,
            ),
          )
          .toList();
    } catch (e) {
      debugPrint('Erreur lors de la récupération des services: $e');
      return [];
    }
  }

  // Get all structures (filtered by role)
  List<Structure> get allStructures => _filteredStructures;
  
  // Get all structures without filtering (for admin/superadmin only)
  List<Structure> get allStructuresUnfiltered => _allStructures;
  
  // Maintain backward compatibility
  @Deprecated('Use allStructures instead')
  List<Structure> get structures => _filteredStructures;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get searchQuery => _searchQuery;
  String? get selectedCategory => _selectedCategory;
  String? get selectedSortOption => _selectedSortOption;

  // Options de tri
  final Map<String, String> sortOptions = {
    'name_asc': 'Nom (A-Z)',
    'name_desc': 'Nom (Z-A)',
    'rating_desc': 'Mieux notés',
    'reviews_desc': 'Plus de commentaires',
  };

  // Catégories disponibles
  final List<String> categories = [
    'Toutes',
    'Restauration',
    'Hébergement',
    'Santé',
    'Éducation',
    'Commerce',
    'Services',
    'Loisirs',
    'Autre',
  ];

  // Méthodes utilitaires privées
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }

  void _setError(String message) {
    _error = message;
    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadStructures() async {
    try {
      _setLoading(true);
      _clearError();

      // Toujours commencer avec les données de test (statiques)
      _allStructures = List.from(StructureData.structures);

      // Appel à l'API pour récupérer les structures réelles
      final response = await ApiService.get('structures');

      if (response['success'] == true) {
        final data = response['data'];
        List<dynamic> apiList;
        if (data is List) {
          apiList = data;
        } else if (data is Map && data.containsKey('content')) {
          apiList = data['content'] as List;
        } else {
          apiList = [];
        }

        final apiStructures = apiList.map<Structure>((e) {
          final m = Map<String, dynamic>.from(e as Map);
          if (m['status'] == null) {
            m['status'] = (m['active'] == true) ? 'active' : 'suspended';
          }
          if (m['id'] != null) {
            m['id'] = m['id'].toString();
          }
          return Structure.fromMap(m);
        }).toList();

        // Ajouter les structures de l'API à la liste
        _allStructures.addAll(apiStructures);
      } else {
        // Optionnel : logger l'erreur mais on garde quand même les données statiques
        debugPrint('Note: Impossible de charger les structures depuis l\'API : ${response['error']}');
      }

      _applyRoleFilter();
    } catch (e) {
      _setError('Erreur lors du chargement des structures: $e');
      // On garde quand même les données statiques si possible, mais on informe de l'erreur
      if (_allStructures.isEmpty) {
        _allStructures = List.from(StructureData.structures);
        _applyRoleFilter();
      }
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // Filtrer les structures
  void filterStructures({
    String? searchQuery,
    String? category,
    String? sortBy,
  }) {
    _searchQuery = searchQuery?.toLowerCase() ?? _searchQuery;
    _selectedCategory = (category == 'Toutes' || category == null)
        ? null
        : category;
    _selectedSortOption = sortBy ?? _selectedSortOption;

    // Démarrer avec toutes les structures (déjà filtrées par rôle)
    _filteredStructures = _allStructures.where((structure) {
      // Vérifier l'accès à la structure
      if (!hasAccessToStructure(structure.id)) return false;
      
      // Filtre par recherche
      final matchesSearch =
          _searchQuery == null ||
          structure.name.toLowerCase().contains(_searchQuery!) ||
          (structure.description?.toLowerCase().contains(_searchQuery!) ??
              false) ||
          structure.address.toLowerCase().contains(_searchQuery!);

      // Filtre par catégorie
      final matchesCategory =
          _selectedCategory == null || structure.category == _selectedCategory;

      return matchesSearch && matchesCategory;
    }).toList();

    // Trier les résultats
    _sortStructures();

    notifyListeners();
  }

  // Appliquer le filtre (plus de restriction par rôle pour la recherche)
  void _applyRoleFilter() {
    // Pour tout le monde (Admin, SuperAdmin, Client), montrer toutes les structures
    _filteredStructures = List.from(_allStructures);
    _sortStructures();
    notifyListeners();
  }

  // Vérifier si l'utilisateur a accès à une structure spécifique
  bool hasAccessToStructure(String structureId) {
    // Tout le monde peut voir et accéder aux détails des structures dans la liste de recherche
    return true;
  }

  // Trier les structures
  void _sortStructures() {
    if (_filteredStructures.isEmpty) return;
    
    switch (_selectedSortOption) {
      case 'name_asc':
        _filteredStructures.sort((a, b) => a.name.compareTo(b.name));
        break;
      case 'name_desc':
        _filteredStructures.sort((a, b) => b.name.compareTo(a.name));
        break;
      case 'rating_desc':
        _filteredStructures.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      case 'reviews_desc':
        _filteredStructures.sort(
          (a, b) => b.reviewCount.compareTo(a.reviewCount),
        );
        break;
      default:
        // Par défaut, trier par nom croissant
        _filteredStructures.sort((a, b) => a.name.compareTo(b.name));
    }
  }

  // Basculer le statut favori d'une structure
  Future<void> toggleFavorite(String structureId) async {
    try {
      // Vérifier l'accès à la structure
      if (!hasAccessToStructure(structureId)) {
        throw Exception('Accès non autorisé à cette structure');
      }
      
      final index = _allStructures.indexWhere((s) => s.id == structureId);
      if (index != -1) {
        // Mettre à jour la structure dans la liste complète
        _allStructures[index] = _allStructures[index].copyWith(
          isFavorite: !_allStructures[index].isFavorite,
        );

        // Mettre à jour la structure dans la liste filtrée si elle y est présente
        final filteredIndex = _filteredStructures.indexWhere(
          (s) => s.id == structureId,
        );
        if (filteredIndex != -1) {
          _filteredStructures[filteredIndex] = _allStructures[index];
        }

        notifyListeners();

        // Ici, vous pourriez appeler une API pour enregistrer le favori
        await Future.delayed(const Duration(milliseconds: 300));
      }
    } catch (e) {
      debugPrint('Erreur lors de la mise à jour des favoris: $e');
      rethrow;
    }
  }

  // Réinitialiser les filtres
  void resetFilters() {
    _searchQuery = null;
    _selectedCategory = null;
    _selectedSortOption = null;
    _applyRoleFilter();
  }
}

extension on Service {
  get category => null;
}
