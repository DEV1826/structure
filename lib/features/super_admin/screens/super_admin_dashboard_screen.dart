import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:structure_mobile/core/providers/auth_provider.dart';
import 'package:structure_mobile/core/routes/app_router.dart';
import 'package:structure_mobile/features/structures/providers/structures_provider.dart';
import 'package:structure_mobile/themes/app_theme.dart';

class SuperAdminDashboardScreen extends StatefulWidget {
  const SuperAdminDashboardScreen({super.key});

  @override
  State<SuperAdminDashboardScreen> createState() => _SuperAdminDashboardScreenState();
}

class _SuperAdminDashboardScreenState extends State<SuperAdminDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StructuresProvider>().loadStructures();
    });
  }

  void _handleLogout() async {
    await context.read<AuthProvider>().logout();
    if (mounted) {
      context.go(AppRouter.welcome);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tableau de bord Super Admin'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Déconnexion'),
                  content: const Text('Voulez-vous vraiment vous déconnecter ?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Annuler'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _handleLogout();
                      },
                      child: const Text('Déconnexion', style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: Consumer<StructuresProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final structures = provider.allStructuresUnfiltered;

          if (structures.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.business_outlined, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text('Aucune structure disponible'),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () {
                       context.push(AppRouter.superAdminCreateStructure);
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Créer une structure'),
                  )
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => provider.loadStructures(),
            child: ListView.builder(
              padding: const EdgeInsets.all(AppTheme.paddingMedium),
              itemCount: structures.length,
              itemBuilder: (context, index) {
                final structure = structures[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: AppTheme.paddingMedium),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(AppTheme.paddingMedium),
                    leading: CircleAvatar(
                      backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                      child: const Icon(Icons.business, color: AppTheme.primaryColor),
                    ),
                    title: Text(
                      structure.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                         const SizedBox(height: 4),
                         Text(structure.category),
                         Text(structure.address, style: const TextStyle(fontSize: 12)),
                         if (structure.adminName != null) ...[
                           const SizedBox(height: 4),
                           Text(
                             'Admin: ${structure.adminName}',
                             style: const TextStyle(
                               fontSize: 12,
                               fontWeight: FontWeight.bold,
                               color: AppTheme.primaryColor,
                             ),
                           ),
                         ],
                      ],
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                       // Action optionnelle: View details
                    },
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
           context.push(AppRouter.superAdminCreateAdmin);
        },
        icon: const Icon(Icons.person_add),
        label: const Text('Créer Admin'),
      ),
    );
  }
}
