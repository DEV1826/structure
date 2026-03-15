import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:structure_mobile/core/constants/app_constants.dart';
import 'package:structure_mobile/core/models/user_model.dart';
import 'package:structure_mobile/core/providers/auth_provider.dart';
import 'package:structure_mobile/core/routes/app_router.dart';
import 'package:structure_mobile/core/widgets/loading_widget.dart';
import 'package:structure_mobile/features/structures/models/structure_model.dart' as structures;
import 'package:structure_mobile/features/structures/providers/structures_provider.dart';
import 'package:structure_mobile/themes/app_theme.dart';
import 'package:structure_mobile/features/user/models/structure_model.dart' as user_models;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    // Load structures when the screen initializes
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
  void _showAdminMenu(BuildContext context, AuthProvider authProvider) {
    final isSuperAdmin = authProvider.isSuperAdmin;
    
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.admin_panel_settings),
            title: Text(
              'Espace administrateur',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(
              isSuperAdmin ? 'Super Administrateur' : 'Administrateur',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
          const Divider(),
          if (isSuperAdmin) ...[
            ListTile(
              leading: const Icon(Icons.business),
              title: const Text('Gérer toutes les structures'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Naviguer vers la gestion des structures
              },
            ),
            ListTile(
              leading: const Icon(Icons.add_business),
              title: const Text('Créer une structure'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Naviguer vers la création de structure
              },
            ),
            const Divider(),
          ],
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Se déconnecter'),
            onTap: () {
              authProvider.logout();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Déconnexion réussie')),
              );
            },
          ),
        ],
      ),
    );
  }

  // Affiche les options de connexion
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
        title: const Text('Structures disponibles'),
        centerTitle: true,
        elevation: 1,
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
                  _showAdminMenu(context, authProvider);
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
          // Search bar
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
          
          // Structures list
          Expanded(
            child: Consumer<StructuresProvider>(
              builder: (context, provider, _) {
                if (provider.isLoading && provider.allStructures.isEmpty) {
                  return const LoadingWidget(
                    message: 'Chargement des structures...',
                  );
                }

                if (provider.error != null && provider.allStructures.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, color: Colors.red, size: 60),
                        const SizedBox(height: 16),
                        Text(
                          'Erreur de chargement des structures',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(provider.error!),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: provider.fetchStructures,
                          child: const Text('Réessayer'),
                        ),
                      ],
                    ),
                  );
                }

                if (provider.allStructures.isEmpty) {
                  return const Center(
                    child: Text('Aucune structure disponible'),
                  );
                }

                final filteredStructures = provider.allStructures.where((structure) {
                  final nameMatch = structure.name.toLowerCase().contains(_searchQuery);
                  final addressMatch = structure.address.toLowerCase().contains(_searchQuery);
                  final descriptionMatch = structure.description?.toLowerCase().contains(_searchQuery) ?? false;
                  return nameMatch || addressMatch || descriptionMatch;
                }).toList();

                if (filteredStructures.isEmpty) {
                  return const Center(
                    child: Text('Aucune structure ne correspond à votre recherche'),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredStructures.length,
                  itemBuilder: (context, index) {
                    final structure = filteredStructures[index];
                    return _buildStructureCard(context, structure);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStructureCard(BuildContext context, structures.Structure structure) {
    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: AppConstants.mediumPadding,
        vertical: AppConstants.smallPadding,
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
          child: const Icon(Icons.business, color: AppTheme.primaryColor),
        ),
        title: Text(
          structure.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          structure.address ?? 'Adresse non disponible',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          Navigator.pushNamed(
            context,
            '/structure-detail',
            arguments: structure,
          );
        },
      ),
    );
  }
}
