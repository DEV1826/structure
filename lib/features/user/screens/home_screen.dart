import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:structure_mobile/core/constants/app_constants.dart';
import 'package:structure_mobile/core/providers/auth_provider.dart';
import 'package:structure_mobile/core/routes/app_router.dart';
import 'package:structure_mobile/core/widgets/loading_widget.dart';
import 'package:structure_mobile/features/structures/models/structure_model.dart' as structures;
import 'package:structure_mobile/features/structures/providers/structures_provider.dart';
import 'package:structure_mobile/features/user/models/structure_model.dart' as user_models;
import 'package:structure_mobile/features/user/widgets/structure_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    // Charger les structures au démarrage
    Future.microtask(() {
      final provider = Provider.of<StructuresProvider>(context, listen: false);
      if (provider.allStructures.isEmpty) {
        provider.fetchStructures();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Affiche le menu administrateur
  void _showAdminMenu(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final isSuperAdmin = authProvider.isSuperAdmin;
    
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Déconnexion', style: TextStyle(color: Colors.red)),
            onTap: () {
              Navigator.pop(context);
              authProvider.logout();
              context.go(AppRouter.welcome);
            },
          ),
        ],
      ),
    );
  }

  // Affiche les options de connexion admin
  void _showLoginOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Connexion administrateur',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.admin_panel_settings),
            title: const Text('Administrateur'),
            subtitle: const Text('Gérez votre structure'),
            onTap: () {
              Navigator.pop(context);
              context.go(AppRouter.adminLogin);
            },
          ),
          ListTile(
            leading: const Icon(Icons.supervisor_account),
            title: const Text('Super Administrateur'),
            subtitle: const Text('Gérez toutes les structures'),
            onTap: () {
              Navigator.pop(context);
              context.go(AppRouter.superAdminLogin);
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final isAdmin = authProvider.isAdmin;
    final isSuperAdmin = authProvider.isSuperAdmin;
    final isLoggedIn = authProvider.isAuthenticated;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Structures'),
        centerTitle: true,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: isLoggedIn 
                      ? (isSuperAdmin 
                          ? Colors.deepPurple.withOpacity(0.2) 
                          : Colors.blue.withOpacity(0.2))
                      : Colors.grey.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isSuperAdmin ? Icons.security : Icons.admin_panel_settings,
                  color: isLoggedIn 
                      ? (isSuperAdmin ? Colors.deepPurple : Colors.blue)
                      : Colors.grey,
                  size: 24,
                ),
              ),
              onPressed: () {
                if (isLoggedIn) {
                  _showAdminMenu(context);
                } else {
                  _showLoginOptions(context);
                }
              },
              tooltip: isLoggedIn 
                  ? (isSuperAdmin ? 'Super Administrateur' : 'Administrateur')
                  : 'Se connecter',
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Barre de recherche
          Padding(
            padding: const EdgeInsets.all(AppConstants.mediumPadding),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Rechercher une structure...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppConstants.largeRadius),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.mediumPadding,
                  vertical: 0,
                ),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
            ),
          ),
          
          // Liste des structures
          Expanded(
            child: Consumer<StructuresProvider>(
              builder: (context, provider, _) {
                if (provider.isLoading && provider.allStructures.isEmpty) {
                  return const LoadingWidget(
                    message: 'Chargement des structures...',
                  );
                }

                if (provider.error != null) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 48,
                          color: Colors.red,
                        ),
                        const SizedBox(height: AppConstants.mediumPadding),
                        Text(
                          'Une erreur est survenue',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: AppConstants.smallPadding),
                        Text(
                          provider.error!,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: AppConstants.mediumPadding),
                        ElevatedButton(
                          onPressed: () => provider.fetchStructures(),
                          child: const Text('Réessayer'),
                        ),
                      ],
                    ),
                  );
                }

                final filteredStructures = provider.allStructures.where((structure) {
                  if (_searchQuery.isEmpty) return true;
                  
                  final name = structure.name.toLowerCase();
                  final address = structure.address?.toLowerCase() ?? '';
                  final description = structure.description?.toLowerCase() ?? '';
                  
                  return name.contains(_searchQuery) ||
                      address.contains(_searchQuery) ||
                      description.contains(_searchQuery);
                }).toList();

                if (filteredStructures.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.search_off,
                          size: 48,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: AppConstants.mediumPadding),
                        Text(
                          'Aucune structure trouvée',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        if (_searchQuery.isNotEmpty) ...[
                          const SizedBox(height: AppConstants.smallPadding),
                          Text(
                            'Aucun résultat pour "$_searchQuery"',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () => provider.fetchStructures(),
                  child: ListView.builder(
                    padding: const EdgeInsets.only(bottom: AppConstants.largePadding),
                    itemCount: filteredStructures.length,
                    itemBuilder: (context, index) {
                      final structure = filteredStructures[index];
                      // Convert Structure to StructureModel
                      final structureModel = user_models.StructureModel(
                        id: structure.id,
                        name: structure.name,
                        description: structure.description,
                        address: structure.address,
                        imageUrl: structure.imageUrl,
                        rating: structure.rating,
                        reviewCount: structure.reviewCount,
                        isOpen: true, // Set default value
                        categories: [structure.category],
                        phoneNumber: structure.phoneNumber,
                        email: structure.email,
                        website: structure.website,
                        latitude: structure.latitude,
                        longitude: structure.longitude,
                      );
                      
                      return StructureCard(
                        structure: structureModel,
                        onTap: () {
                          // Navigation vers le détail de la structure avec GoRouter
                          final route = '${AppRouter.structureDetail.replaceAll(':id', structure.id)}';
                          GoRouter.of(context).go(route);
                        },
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
