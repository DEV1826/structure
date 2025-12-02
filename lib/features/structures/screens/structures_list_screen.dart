import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:structure_mobile/core/widgets/custom_app_bar.dart';
import 'package:structure_mobile/features/structures/models/structure_model.dart';
import 'package:structure_mobile/features/structures/providers/structures_provider.dart';

// Modèle de données pour les options de tri
class SortOption {
  final String value;
  final String label;

  const SortOption({required this.value, required this.label});
}

// Options de tri disponibles
final List<SortOption> sortOptions = [
  const SortOption(value: 'name', label: 'Nom (A-Z)'),
  const SortOption(value: 'rating', label: 'Note (plus haute d\'abord)'),
];

class StructuresListScreen extends StatefulWidget {
  const StructuresListScreen({super.key});

  @override
  State<StructuresListScreen> createState() => _StructuresListScreenState();
}

class _StructuresListScreenState extends State<StructuresListScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  String? _selectedCategory;
  String? _selectedSortOption = 'name'; // Valeur par défaut

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    // Charger les structures après le premier rendu
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadStructures();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
      if (!_isSearching) {
        _searchController.clear();
        _applyFilters();
      }
    });
  }

  Future<void> _loadStructures() async {
    final provider = context.read<StructuresProvider>();
    if (provider.allStructures.isEmpty) {
      await provider.loadStructures();
    }
  }

  void _onScroll() {
    // Peut être utilisé pour ajouter du chargement infini plus tard
  }

  void _applyFilters() {
    final provider = context.read<StructuresProvider>();

    provider.filterStructures(
      searchQuery: _searchController.text.isEmpty
          ? null
          : _searchController.text,
      category: _selectedCategory,
      sortBy: _selectedSortOption,
    );
  }

  // Construction d'une carte de structure
  Widget _buildStructureCard(Structure structure) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: InkWell(
        onTap: () {
          // Navigation vers la page de détail de la structure
          // Navigator.pushNamed(context, '/structure/${structure.id}');
        },
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              // Image de la structure
              ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: structure.imageUrl != null
                    ? Image.network(
                        structure.imageUrl!,
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            _buildPlaceholderIcon(),
                      )
                    : _buildPlaceholderText(structure),
              ),
              const SizedBox(width: 16),
              // Détails de la structure
              _buildStructureDetails(structure),
              const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  // Widget pour l'icône de remplacement
  Widget _buildPlaceholderIcon() {
    return Container(
      width: 80,
      height: 80,
      color: Colors.grey[200],
      child: Icon(Icons.business, size: 40, color: Colors.grey[500]),
    );
  }

  // Widget pour le texte de remplacement
  Widget _buildPlaceholderText(Structure structure) {
    return Container(
      width: 80,
      height: 80,
      color: Colors.grey[200],
      child: Center(
        child: Text(
          structure.name.isNotEmpty ? structure.name[0].toUpperCase() : '?',
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  // Détails de la structure
  Widget _buildStructureDetails(Structure structure) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            structure.name,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          if (structure.address.isNotEmpty) ...[
            Container(height: 4),
            Container(width: 8),
            Expanded(
              child: Text(
                structure.address,
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
            ),
            Container(width: 8),
          ],
          Container(height: 4),
          _buildRatingRow(structure),
        ],
      ),
    );
  }

  // Ligne d'évaluation
  Widget _buildRatingRow(Structure structure) {
    return Row(
      children: [
        const Icon(Icons.star, color: Colors.amber, size: 16),
        Container(width: 4),
        Text(
          structure.rating.toStringAsFixed(1),
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
        Container(width: 4),
        Text(
          '(${structure.reviewCount} avis)',
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Structures',
        showBackButton: true,
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: _toggleSearch,
          ),
        ],
      ),
      body: _isSearching
          ? Column(
              children: [
                // Barre de recherche
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Container(
                    height: 56,
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Rechercher une structure...',
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.close),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() {});
                                },
                              )
                            : null,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Theme.of(context).cardColor,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 0,
                          horizontal: 16,
                        ),
                      ),
                      onChanged: (value) {
                        setState(() {});
                      },
                    ),
                  ),
                ),
                // Filtres
                _buildFilterControls(),
                // Liste des structures
                Expanded(child: _buildStructuresList()),
              ],
            )
          : _buildStructuresList(),
    );
  }

  // Contrôles de filtrage
  Widget _buildFilterControls() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: [
          // Filtre par catégorie (exemple simplifié)
          Expanded(
            child: DropdownButtonFormField<String>(
              value: _selectedCategory,
              hint: const Text('Toutes les catégories'),
              items: [
                const DropdownMenuItem(
                  value: null,
                  child: Text('Toutes les catégories'),
                ),
                // Exemple de catégories (à remplacer par vos propres données)
                ...['Restaurant', 'Hôtel', 'Magasin', 'Service'].map((
                  category,
                ) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedCategory = value;
                });
                _applyFilters();
              },
              isExpanded: true,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Bouton de tri
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort),
            onSelected: (value) {
              setState(() {
                _selectedSortOption = value;
              });
              _applyFilters();
            },
            itemBuilder: (context) => sortOptions.map((option) {
              return PopupMenuItem<String>(
                value: option.value,
                child: Row(
                  children: [
                    if (_selectedSortOption == option.value)
                      const Icon(Icons.check, size: 20),
                    const SizedBox(width: 8),
                    Text(option.label),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // Liste des structures
  Widget _buildStructuresList() {
    return Consumer<StructuresProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.error != null) {
          return _buildErrorWidget(provider.error!);
        }

        final structures = provider.structures;

        if (structures.isEmpty) {
          return _buildEmptyState();
        }

        return ListView.builder(
          controller: _scrollController,
          itemCount: structures.length,
          itemBuilder: (context, index) {
            return _buildStructureCard(structures[index]);
          },
        );
      },
    );
  }

  // Widget d'erreur
  Widget _buildErrorWidget(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 48),
          Container(height: 16),
          const Text(
            'Erreur de chargement',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          Container(height: 8),
          Text(
            error,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 14),
          ),
          Container(height: 16),
          ElevatedButton(
            onPressed: _loadStructures,
            child: const Text('Réessayer'),
          ),
        ],
      ),
    );
  }

  // Widget pour l'état vide
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.search_off, size: 64, color: Colors.grey),
          Container(height: 16),
          const Text(
            'Aucun résultat trouvé',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
          ),
          Container(height: 8),
          const Text(
            'Essayez de modifier vos critères de recherche',
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  // Filtrage et tri des structures
  List<Structure> _filterAndSortStructures(List<Structure> structures) {
    // Filtrage par recherche
    var filtered = structures.where((structure) {
      final searchQuery = _searchController.text.toLowerCase();
      if (searchQuery.isNotEmpty) {
        return structure.name.toLowerCase().contains(searchQuery) ||
            structure.description.toLowerCase().contains(searchQuery) ||
            structure.address.toLowerCase().contains(searchQuery);
      }
      return true;
    }).toList();

    // Filtrage par catégorie
    if (_selectedCategory != null) {
      filtered = filtered
          .where((structure) => structure.category == _selectedCategory)
          .toList();
    }

    // Tri
    if (_selectedSortOption != null) {
      switch (_selectedSortOption) {
        case 'name':
          filtered.sort((a, b) => a.name.compareTo(b.name));
          break;
        case 'rating':
          filtered.sort((a, b) => b.rating.compareTo(a.rating));
          break;
        // Ajouter d'autres options de tri si nécessaire
      }
    }

    return filtered;
  }
}
