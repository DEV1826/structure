import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:structure_mobile/features/admin/models/admin_model.dart';
import 'package:structure_mobile/features/admin/providers/dashboard_provider.dart';
import 'package:structure_mobile/features/structures/data/structure_data.dart';
import 'package:structure_mobile/features/structures/models/structure_model.dart';
import 'package:structure_mobile/themes/app_theme.dart';

class SuperAdminCreateStructureScreen extends StatefulWidget {
  const SuperAdminCreateStructureScreen({super.key});

  @override
  State<SuperAdminCreateStructureScreen> createState() => _SuperAdminCreateStructureScreenState();
}

class _SuperAdminCreateStructureScreenState extends State<SuperAdminCreateStructureScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _imageUrlController = TextEditingController();
  bool _isLoading = false;

  Structure? _selectedDummyStructure;
  Admin? _selectedAdmin;
  String _adminSearchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DashboardProvider>().loadAdmins();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  void _fillFromDummy(Structure? dummy) {
    if (dummy == null) return;
    setState(() {
      _selectedDummyStructure = dummy;
      _nameController.text = dummy.name;
      _descriptionController.text = dummy.description;
      _addressController.text = dummy.address;
      _phoneController.text = dummy.phoneNumber ?? '';
      _emailController.text = dummy.email ?? '';
      _imageUrlController.text = dummy.imageUrl ?? '';
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final response = await context.read<DashboardProvider>().createStructure({
        'name': _nameController.text.trim(),
        'description': _descriptionController.text.trim(),
        'address': _addressController.text.trim(),
        'phone': _phoneController.text.trim(),
        'email': _emailController.text.trim(),
        'imageUrl': _imageUrlController.text.trim(),
        'adminId': _selectedAdmin != null ? int.tryParse(_selectedAdmin!.id) : null,
      });

      if (response['success'] == true) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Structure créée avec succès !')),
          );
          context.pop(); // Retour au dashboard
        }
      } else {
        throw Exception(response['error'] ?? 'Erreur lors de la création');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Créer une structure'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppTheme.paddingMedium),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                DropdownButtonFormField<Structure>(
                  isExpanded: true, // Éviter overflow horizontal
                  decoration: const InputDecoration(
                    labelText: 'Utiliser une structure fictive',
                    border: OutlineInputBorder(),
                  ),
                  value: _selectedDummyStructure,
                  items: StructureData.structures.map((s) {
                    return DropdownMenuItem(
                      value: s,
                      child: Text(
                        s.name,
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  }).toList(),
                  onChanged: _fillFromDummy,
                  hint: const Text(
                    'Sélectionnez pour remplir automatiquement',
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
                const SizedBox(height: 16),
                // Sélection de l'administrateur
                Consumer<DashboardProvider>(
                  builder: (context, provider, child) {
                    final filteredAdmins = provider.admins.where((a) {
                      return a.name.toLowerCase().contains(_adminSearchQuery.toLowerCase()) ||
                             a.email.toLowerCase().contains(_adminSearchQuery.toLowerCase());
                    }).toList();

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Administrateur', style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        // Champ de recherche / "Écrire" pour filtrer
                        TextField(
                          decoration: InputDecoration(
                            hintText: 'Rechercher un admin (nom ou email)...',
                            prefixIcon: const Icon(Icons.search, size: 20),
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(vertical: 12),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          onChanged: (val) {
                            setState(() {
                              _adminSearchQuery = val;
                            });
                          },
                        ),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<Admin>(
                          isExpanded: true,
                          decoration: const InputDecoration(
                            labelText: 'Assigner l\'admin sélectionné',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.person_outline),
                          ),
                          value: _selectedAdmin,
                          items: filteredAdmins.map((admin) {
                            return DropdownMenuItem(
                              value: admin,
                              child: Text(
                                '${admin.name} (${admin.email})',
                                overflow: TextOverflow.ellipsis,
                              ),
                            );
                          }).toList(),
                          onChanged: (Admin? val) {
                            setState(() {
                              _selectedAdmin = val;
                            });
                          },
                          hint: const Text('Sélectionnez un admin dans la liste'),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 24),
                const Divider(),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Nom de la structure *'),
                  validator: (v) => v == null || v.isEmpty ? 'Ce champ est requis' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(labelText: 'Description'),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _addressController,
                  decoration: const InputDecoration(labelText: 'Adresse'),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _phoneController,
                  decoration: const InputDecoration(labelText: 'Téléphone'),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(labelText: 'Email'),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _imageUrlController,
                  decoration: const InputDecoration(labelText: 'URL de l\'image (optionnel)'),
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: _isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('Créer la structure'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
