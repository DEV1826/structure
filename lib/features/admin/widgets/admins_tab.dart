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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<DashboardProvider>();
      provider.loadAdmins();
      provider.loadStructures();
    });
  }

  Future<void> _showAdminForm({Admin? admin}) async {
    final nameController = TextEditingController(text: admin?.name ?? '');
    final emailController = TextEditingController(text: admin?.email ?? '');
    final passwordController = TextEditingController();
    final provider = context.read<DashboardProvider>();
    final structures = provider.structures;

    String? selectedStructureId = admin?.structureId;
    // Auto-sélection de la première structure si création et liste non vide
    if (admin == null && selectedStructureId == null && structures.isNotEmpty) {
      selectedStructureId = structures.first['id']?.toString();
    }
    final formKey = GlobalKey<FormState>();

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            final backendStructures = dialogContext.watch<DashboardProvider>().structures;
            final fictiveStructures = [
              {'id': 'S001', 'name': 'Hôpital Central'},
              {'id': 'S002', 'name': 'École Primaire'},
              {'id': 'S003', 'name': 'Hôtel du Plateau'},
              {'id': 'S004', 'name': 'Restaurant Le Délicieux'},
              {'id': 'S005', 'name': 'Clinique du Cœur'},
            ];
            final existingIds = backendStructures.map((s) => s['id']?.toString()).toSet();
            final structures = [
              ...backendStructures,
              ...fictiveStructures.where((f) => !existingIds.contains(f['id']?.toString())),
            ];

            return Dialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.of(dialogContext).viewInsets.bottom,
                  ),
                  child: AlertDialog(
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    title: Text(
                      admin == null ? 'Ajouter un administrateur' : 'Modifier l\'administrateur',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                    ),
                    content: SingleChildScrollView(
                      child: Form(
                        key: formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TextFormField(
                              controller: nameController,
                              decoration: _inputDecoration('Nom complet'),
                              validator: (v) => (v == null || v.isEmpty) ? 'Veuillez entrer un nom' : null,
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: emailController,
                              decoration: _inputDecoration('Email'),
                              keyboardType: TextInputType.emailAddress,
                              validator: (v) {
                                if (v == null || v.isEmpty) return 'Veuillez entrer un email';
                                if (!v.contains('@')) return 'Email invalide';
                                return null;
                              },
                            ),
                            const SizedBox(height: 12),
                            if (admin == null) ...[
                              TextFormField(
                                controller: passwordController,
                                decoration: _inputDecoration('Mot de passe'),
                                obscureText: true,
                                validator: (v) {
                                  if (v == null || v.isEmpty) return 'Veuillez entrer un mot de passe';
                                  if (v.length < 6) return 'Minimum 6 caractères';
                                  return null;
                                },
                              ),
                              const SizedBox(height: 12),
                            ],
                            InputDecorator(
                              decoration: InputDecoration(
                                labelText: 'Structure',
                                labelStyle: TextStyle(
                                  color: selectedStructureId != null ? AppTheme.primaryColor : Colors.grey[600],
                                  fontSize: 13,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(
                                    color: selectedStructureId != null ? AppTheme.primaryColor : Colors.grey[300]!,
                                    width: selectedStructureId != null ? 2 : 1,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(
                                    color: selectedStructureId != null ? AppTheme.primaryColor : Colors.grey[300]!,
                                    width: selectedStructureId != null ? 2 : 1,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(color: AppTheme.primaryColor, width: 2),
                                ),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: structures.any((s) => s['id']?.toString() == selectedStructureId)
                                      ? selectedStructureId
                                      : null,
                                  isExpanded: true,
                                  hint: Text(
                                    structures.isEmpty ? 'Chargement...' : 'Sélectionner une structure',
                                    style: TextStyle(color: Colors.grey[400]),
                                  ),
                                  icon: const Icon(Icons.arrow_drop_down, color: AppTheme.primaryColor),
                                  items: structures.map((s) {
                                    final id = s['id']?.toString() ?? '';
                                    final name = s['name']?.toString() ?? '';
                                    return DropdownMenuItem<String>(
                                      value: id,
                                      child: Text(name, overflow: TextOverflow.ellipsis),
                                    );
                                  }).toList(),
                                  onChanged: (val) => setDialogState(() => selectedStructureId = val),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(dialogContext),
                        child: Text('Annuler', style: TextStyle(color: Colors.grey[600])),
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          if (formKey.currentState!.validate()) {
                            if (selectedStructureId == null) {
                              ScaffoldMessenger.of(dialogContext).showSnackBar(
                                const SnackBar(content: Text('Veuillez sélectionner une structure')),
                              );
                              return;
                            }

                            final nameParts = nameController.text.trim().split(' ');
                            final firstName = nameParts[0];
                            final lastName = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';

                            final provider = context.read<DashboardProvider>();
                            Map<String, dynamic> result;

                            if (admin == null) {
                              // CRÉATION
                              final payload = {
                                'prenom': firstName,
                                'nom': lastName.isEmpty ? firstName : lastName,
                                'email': emailController.text.trim(),
                                'username': emailController.text.trim(),
                                'password': passwordController.text,
                                'telephone': '', // À ajouter au formulaire plus tard si besoin
                                'role': 'ADMIN',
                                'active': true,
                              };
                              result = await provider.createAdminForStructure(selectedStructureId!, payload);
                            } else {
                              // MODIFICATION
                              final payload = {
                                'firstName': firstName,
                                'lastName': lastName.isEmpty ? firstName : lastName,
                                'email': emailController.text.trim(),
                                'role': 'ADMIN', // Crucial pour éviter l'erreur 500 Column 'role' cannot be null
                                'structureId': int.tryParse(selectedStructureId ?? ''),
                              };
                              // N'envoyer le mot de passe que s'il est saisi
                              if (passwordController.text.isNotEmpty) {
                                payload['password'] = passwordController.text;
                              }
                              result = await provider.updateUser(admin.id, payload);
                            }

                            if (dialogContext.mounted) Navigator.pop(dialogContext);

                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(result['success'] == true
                                      ? (admin == null
                                          ? 'Administrateur créé avec succès'
                                          : 'Administrateur mis à jour')
                                      : result['error'] ?? 'Erreur lors de l\'opération'),
                                  backgroundColor:
                                      result['success'] == true ? Colors.green : Colors.red,
                                ),
                              );
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                          padding:
                              const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        ),
                        child: const Text('Enregistrer'),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey[400]),
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[300]!)),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[300]!)),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppTheme.primaryColor, width: 2)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }

  Future<void> _confirmDeleteAdmin(Admin admin) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer la suppression'),
        content: Text('Êtes-vous sûr de vouloir supprimer "${admin.name}" ?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Annuler')),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      final provider = context.read<DashboardProvider>();
      final result = await provider.deleteUser(admin.id);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['success'] == true
                ? 'Administrateur supprimé'
                : result['error'] ?? 'Erreur lors de la suppression'),
            backgroundColor: result['success'] == true ? Colors.green : Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DashboardProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final admins = provider.admins;

        return RefreshIndicator(
          onRefresh: () => provider.loadAdmins(),
          child: CustomScrollView(
            slivers: [
              // En-tête : recherche + bouton Nouveau
              SliverToBoxAdapter(
                child: Container(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                  color: Colors.grey[50],
                  child: Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: TextField(
                          controller: _searchController,
                          style: const TextStyle(fontSize: 14),
                          decoration: InputDecoration(
                            hintText: 'Rechercher...',
                            prefixIcon: const Icon(Icons.search, size: 20),
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(vertical: 8),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onChanged: (val) {
                            setState(() {});
                            context.read<DashboardProvider>().loadAdmins(searchQuery: val);
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: () => _showAdminForm(),
                        icon: const Icon(Icons.add_circle, color: AppTheme.primaryColor),
                        tooltip: 'Nouveau',
                      ),
                    ],
                  ),
                ),
              ),
              // En-tête du tableau
              SliverToBoxAdapter(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  color: Colors.grey[100],
                  child: const Row(
                    children: [
                      Expanded(flex: 2, child: Text('Nom', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                      Expanded(flex: 2, child: Text('Email', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                      Expanded(child: Text('Structure', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                      SizedBox(width: 40),
                    ],
                  ),
                ),
              ),
              // Liste
              if (admins.isEmpty)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Text(
                      'Aucun administrateur trouvé',
                      style: TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                  ),
                )
              else
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => _buildAdminItem(admins[index]),
                    childCount: admins.length,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAdminItem(Admin admin) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(admin.name, style: const TextStyle(fontWeight: FontWeight.w500)),
            const SizedBox(height: 4),
            Text(admin.email, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: Colors.blue[100]!),
              ),
              child: Text(admin.structureName, style: TextStyle(fontSize: 12, color: Colors.blue[800])),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(icon: const Icon(Icons.edit, size: 20, color: Colors.blueGrey), onPressed: () => _showAdminForm(admin: admin), tooltip: 'Modifier'),
            IconButton(icon: const Icon(Icons.delete, size: 20, color: Colors.redAccent), onPressed: () => _confirmDeleteAdmin(admin), tooltip: 'Supprimer'),
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