import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:structure_mobile/features/admin/models/admin_model.dart';
import 'package:structure_mobile/features/admin/providers/dashboard_provider.dart';
import 'package:structure_mobile/themes/app_theme.dart';

class AdminsTab extends StatefulWidget {
  const AdminsTab({super.key});

  @override
  State<AdminsTab> createState() => _AdminsTabState();
}

class _AdminsTabState extends State<AdminsTab> {
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = false;
  List<Admin> _admins = [];
  List<Admin> _filteredAdmins = [];

  @override
  void initState() {
    super.initState();
    _loadAdmins();
  }

  // Charger les administrateurs
  Future<void> _loadAdmins() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Simuler un chargement de données
      await Future.delayed(const Duration(seconds: 1));
      
      // Données de démonstration
      _admins = _getDemoAdmins();
      _filteredAdmins = List.from(_admins);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors du chargement des administrateurs: $e'),
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

  // Données de démonstration
  List<Admin> _getDemoAdmins() {
    return [
      Admin(
        id: 'ADM001',
        name: 'Admin Principal',
        email: 'admin@example.com',
        structureId: 'S001',
        structureName: 'Hôpital Central',
      ),
      Admin(
        id: 'ADM002',
        name: 'Responsable RH',
        email: 'rh@example.com',
        structureId: 'S001',
        structureName: 'Hôpital Central',
      ),
      Admin(
        id: 'ADM003',
        name: 'Admin École',
        email: 'ecole@example.com',
        structureId: 'S002',
        structureName: 'École Primaire',
      ),
    ];
  }

  // Appliquer le filtre de recherche
  void _applySearchFilter() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredAdmins = _admins.where((admin) {
        return admin.name.toLowerCase().contains(query) ||
               admin.email.toLowerCase().contains(query) ||
               admin.structureName.toLowerCase().contains(query);
      }).toList();
    });
  }

  // Afficher le dialogue d'ajout/modification d'administrateur
  Future<void> _showAdminForm({Admin? admin}) async {
    final nameController = TextEditingController(text: admin?.name ?? '');
    final emailController = TextEditingController(text: admin?.email ?? '');
    final structureNameController = TextEditingController(text: admin?.structureName ?? '');
    final passwordController = TextEditingController();
    
    final formKey = GlobalKey<FormState>();
    
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(admin == null ? 'Ajouter un administrateur' : 'Modifier l\'administrateur'),
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nom complet',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer un nom';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16.0),
                TextFormField(
                  controller: emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer un email';
                    }
                    if (!value.contains('@')) {
                      return 'Veuillez entrer un email valide';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16.0),
                if (admin == null) ...[
                  TextFormField(
                    controller: passwordController,
                    decoration: const InputDecoration(
                      labelText: 'Mot de passe',
                      border: OutlineInputBorder(),
                    ),
                    obscureText: true,
                    validator: (value) {
                      if (admin == null && (value == null || value.isEmpty)) {
                        return 'Veuillez entrer un mot de passe';
                      }
                      if (value != null && value.length < 6) {
                        return 'Le mot de passe doit contenir au moins 6 caractères';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16.0),
                ],
                TextFormField(
                  controller: structureNameController,
                  decoration: const InputDecoration(
                    labelText: 'Structure',
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.arrow_drop_down),
                  ),
                  readOnly: true,
                  onTap: () {
                    // TODO: Implémenter la sélection de la structure
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Sélection de la structure à implémenter'),
                      ),
                    );
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez sélectionner une structure';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                // TODO: Implémenter la sauvegarde de l'administrateur
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(admin == null 
                      ? 'Administrateur créé avec succès' 
                      : 'Administrateur mis à jour avec succès'),
                    backgroundColor: Colors.green,
                  ),
                );
                _loadAdmins();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
            ),
            child: const Text('Enregistrer'),
          ),
        ],
      ),
    );
  }

  // Confirmer la suppression d'un administrateur
  Future<void> _confirmDeleteAdmin(Admin admin) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer la suppression'),
        content: Text(
          'Êtes-vous sûr de vouloir supprimer l\'administrateur "${admin.name}" ?',
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
        // TODO: Implémenter la suppression de l'administrateur
        await Future.delayed(const Duration(milliseconds: 500));
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Administrateur supprimé avec succès'),
              backgroundColor: Colors.green,
            ),
          );
          _loadAdmins();
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
      body: Column(
        children: [
          // En-tête avec barre de recherche et bouton d'ajout
          Container(
            padding: const EdgeInsets.all(16.0),
            color: Colors.grey[50],
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Rechercher un administrateur...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                                _applySearchFilter();
                              },
                            )
                          : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    ),
                    onChanged: (_) => _applySearchFilter(),
                  ),
                ),
                const SizedBox(width: 16.0),
                ElevatedButton.icon(
                  onPressed: () => _showAdminForm(),
                  icon: const Icon(Icons.person_add, size: 20.0),
                  label: const Text('Nouveau'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 12.0,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // En-tête du tableau
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            color: Colors.grey[100],
            child: const Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Text('Nom', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                Expanded(
                  flex: 2,
                  child: Text('Email', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                Expanded(
                  child: Text('Structure', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                SizedBox(width: 80), // Pour les boutons d'action
              ],
            ),
          ),
          
          // Liste des administrateurs
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredAdmins.isEmpty
                    ? const Center(
                        child: Padding(
                          padding: EdgeInsets.all(32.0),
                          child: Text(
                            'Aucun administrateur trouvé',
                            style: TextStyle(color: Colors.grey, fontSize: 16.0),
                          ),
                        ),
                      )
                    : ListView.builder(
                        itemCount: _filteredAdmins.length,
                        itemBuilder: (context, index) {
                          final admin = _filteredAdmins[index];
                          return _buildAdminItem(admin);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  // Construire un élément de la liste des administrateurs
  Widget _buildAdminItem(Admin admin) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              admin.name,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 4.0),
            Text(
              admin.email,
              style: TextStyle(
                fontSize: 12.0,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 4.0),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(4.0),
                border: Border.all(color: Colors.blue[100]!),
              ),
              child: Text(
                admin.structureName,
                style: TextStyle(
                  fontSize: 12.0,
                  color: Colors.blue[800],
                ),
              ),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, size: 20.0, color: Colors.blueGrey),
              onPressed: () => _showAdminForm(admin: admin),
              tooltip: 'Modifier',
            ),
            IconButton(
              icon: const Icon(Icons.delete, size: 20.0, color: Colors.redAccent),
              onPressed: () => _confirmDeleteAdmin(admin),
              tooltip: 'Supprimer',
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
