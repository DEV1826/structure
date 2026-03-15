import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
  bool _isLoading = false;
  List<ServiceProduct> _filteredServices = [];

  @override
  void initState() {
    super.initState();
    _loadServicesProducts();
  }

  // Méthode pour charger les services/produits
  Future<void> _loadServicesProducts() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Ici, vous pourriez charger les services/produits depuis une API
      // Pour l'instant, nous utilisons des données de démo
      await Future.delayed(const Duration(seconds: 1)); // Simuler un chargement
      
      // Mettre à jour la liste filtrée
      _filteredServices = _getDemoServices();
      
      // Appliquer le filtre de recherche s'il y en a un
      _applySearchFilter();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors du chargement des services/produits: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Méthode utilitaire pour obtenir des données de démo
  List<ServiceProduct> _getDemoServices() {
    // Dans une application réelle, cela viendrait d'une base de données
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
        name: 'Analyse Sanguine Complète',
        description: 'Examen sanguin pour vérifier divers indicateurs.',
        price: 15000.0,
        structureId: 'S001',
      ),
      ServiceProduct(
        id: 'SP003',
        name: 'Frais de Scolarité Annuel',
        description: 'Frais d\'inscription et de scolarité pour une année complète.',
        price: 75000.0,
        structureId: 'S002',
      ),
    ];
  }
  
  // Appliquer le filtre de recherche
  void _applySearchFilter() {
    final query = _searchController.text.toLowerCase();
    if (query.isEmpty) {
      setState(() {
        _filteredServices = _getDemoServices();
      });
      return;
    }
    
    setState(() {
      _filteredServices = _getDemoServices().where((service) {
        return service.name.toLowerCase().contains(query) ||
               service.description.toLowerCase().contains(query) ||
               service.price.toString().contains(query);
      }).toList();
    });
  }
  
  // Ajouter un nouveau service/produit
  void _addNewServiceProduct() async {
    final result = await Navigator.push<ServiceProduct?>(
      context,
      MaterialPageRoute(
        builder: (context) => ServiceProductFormScreen(
          onSave: (newService) {
            // Dans une application réelle, on ajouterait ici l'appel à l'API
            final newServices = List<ServiceProduct>.from(_getDemoServices())
              ..add(newService);
            return newService;
          },
          structureId: 'S001', // À remplacer par l'ID de la structure actuelle
          structureName: 'Hôpital Central', // À remplacer par le nom de la structure actuelle
        ),
      ),
    );
    
    if (result != null && mounted) {
      // Rafraîchir la liste après l'ajout
      await _loadServicesProducts();
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Service/produit ajouté avec succès'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }
  
  // Modifier un service/produit existant
  void _editServiceProduct(ServiceProduct serviceProduct) async {
    final result = await Navigator.push<ServiceProduct?>(
      context,
      MaterialPageRoute(
        builder: (context) => ServiceProductFormScreen(
          serviceProduct: serviceProduct,
          onSave: (updatedService) {
            // Dans une application réelle, on mettrait à jour ici l'API
            final services = _getDemoServices();
            final index = services.indexWhere((s) => s.id == updatedService.id);
            if (index != -1) {
              services[index] = updatedService;
            }
            return updatedService;
          },
          structureId: serviceProduct.structureId,
          structureName: 'Hôpital Central', // À remplacer par le nom de la structure
        ),
      ),
    );
    
    if (result != null && mounted) {
      // Rafraîchir la liste après la modification
      await _loadServicesProducts();
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Service/produit mis à jour avec succès'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }
  
  // Supprimer un service/produit
  Future<void> _deleteServiceProduct(ServiceProduct serviceProduct) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer la suppression'),
        content: Text(
          'Êtes-vous sûr de vouloir supprimer le service/produit "${serviceProduct.name}" ?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
    
    if (confirmed == true && mounted) {
      try {
        // Dans une application réelle, on supprimerait ici de l'API
        final services = _getDemoServices();
        services.removeWhere((s) => s.id == serviceProduct.id);
        
        // Mettre à jour l'interface
        await _loadServicesProducts();
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Service/produit supprimé avec succès'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erreur lors de la suppression: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Barre de recherche
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Rechercher un service ou produit...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.filter_list),
                        onPressed: () {
                          // TODO: Implémenter le filtre avancé
                        },
                      ),
                    ),
                    onChanged: (value) {
                      _applySearchFilter();
                    },
                  ),
                ),

                // Liste des services/produits
                Expanded(
                  child: ListView.builder(
                    itemCount: _filteredServices.length,
                    itemBuilder: (context, index) {
                      final service = _filteredServices[index];
                      return _buildServiceProductCard(context, service);
                    },
                  ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addNewServiceProduct,
        backgroundColor: AppTheme.primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
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
              onPressed: () => _editServiceProduct(service),
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.redAccent),
              onPressed: () => _deleteServiceProduct(service),
            ),
          ],
        ),
      ),
    );
  }


}
