import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:structure_mobile/core/providers/auth_provider.dart';
import 'package:structure_mobile/features/admin/models/service_product_model.dart';
import 'package:structure_mobile/features/admin/providers/dashboard_provider.dart';
import 'package:structure_mobile/features/admin/widgets/service_product_form_screen.dart';
import 'package:structure_mobile/themes/app_theme.dart';

class ServicesProductsTab extends StatefulWidget {
  const ServicesProductsTab({super.key});

  @override
  State<ServicesProductsTab> createState() => _ServicesProductsTabState();
}

class _ServicesProductsTabState extends State<ServicesProductsTab> {
  final TextEditingController _searchController = TextEditingController();

  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _initialized = true;
      WidgetsBinding.instance.addPostFrameCallback((_) => _loadServicesProducts());
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Méthode pour charger les services/produits
  Future<void> _loadServicesProducts() async {
    final auth = context.read<AuthProvider>();
    final provider = context.read<DashboardProvider>();
    final structureId = auth.user?.structureId ?? provider.selectedStructureId;
    if (structureId != null) {
      provider.loadServices(structureId);
    }
  }

  // Ajouter un nouveau service/produit
  void _addNewServiceProduct() async {
    final auth = context.read<AuthProvider>();
    final provider = context.read<DashboardProvider>();
    final structureId = provider.selectedStructureId ?? auth.user?.structureId ?? '';
    final isSuperAdmin = auth.isSuperAdmin;

    if (int.tryParse(structureId) == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isSuperAdmin
              ? 'En tant que super admin, créez d\'abord une structure puis assignez-lui un admin.'
              : 'Votre compte n\'est pas associé à une structure. Contactez votre super administrateur.'),
          backgroundColor: Colors.orange,
          duration: const Duration(seconds: 5),
        ),
      );
      return;
    }

    String? structureName;
    if (structureId.isNotEmpty) {
      try {
        final struct = provider.structures.firstWhere((s) => s['id'].toString() == structureId);
        structureName = struct['name'];
      } catch (_) {
        structureName = auth.user?.firstName; // Fallback
      }
    }

    final result = await Navigator.push<ServiceProduct?>(
      context,
      MaterialPageRoute(
        builder: (context) => ServiceProductFormScreen(
          onSave: (newService) async {
            final success = await provider.createService(newService);
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(success
                      ? 'Service/produit enregistré avec succès'
                      : provider.error ?? 'Erreur lors de la création'),
                  backgroundColor: success ? Colors.green : Colors.red,
                ),
              );
            }
            if (!success) throw Exception(provider.error ?? 'Erreur API');
          },
          initialStructureId: structureId,
          initialStructureName: structureName ?? 'Ma Structure',
          structures: provider.structures,
          isSuperAdmin: isSuperAdmin,
        ),
      ),
    );

    if (result != null && mounted) {
      _loadServicesProducts();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DashboardProvider>(
      builder: (context, provider, _) {
        final query = _searchController.text.toLowerCase();
        final filteredServices = provider.services.where((service) {
          if (query.isEmpty) return true;
          return service.name.toLowerCase().contains(query) ||
              service.description.toLowerCase().contains(query);
        }).toList();

        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        return RefreshIndicator(
          onRefresh: _loadServicesProducts,
          child: CustomScrollView(
            slivers: [
              // Barre de recherche
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Rechercher un service ou produit...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {});
                    },
                  ),
                ),
              ),

              // Liste des services/produits
              if (filteredServices.isEmpty)
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 100.0),
                    child: Center(child: Text('Aucun service trouvé')),
                  ),
                )
              else
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final service = filteredServices[index];
                      return _buildServiceProductCard(context, service);
                    },
                    childCount: filteredServices.length,
                  ),
                ),

              // Bouton d'ajout
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _addNewServiceProduct,
                      icon: const Icon(Icons.add),
                      label: const Text('Ajouter un service/produit'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        backgroundColor: AppTheme.primaryColor,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildServiceProductCard(BuildContext context, ServiceProduct service) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: ListTile(
        leading: const CircleAvatar(
          backgroundColor: AppTheme.primaryColor,
          child: Icon(Icons.medical_services, color: Colors.white),
        ),
        title: Text(
          service.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(service.description),
            const SizedBox(height: 4.0),
            Text(
              'XAF ${service.price.toStringAsFixed(0)}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryColor,
              ),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blueGrey),
              onPressed: () {
                // TODO: Implémenter la modification
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.redAccent),
              onPressed: () {
                // TODO: Implémenter la suppression
              },
            ),
          ],
        ),
      ),
    );
  }
}