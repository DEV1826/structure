import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:structure_mobile/features/admin/providers/dashboard_provider.dart';
import 'package:structure_mobile/features/structures/models/structure_model.dart';
import 'package:structure_mobile/features/structures/providers/structures_provider.dart';
import 'package:structure_mobile/themes/app_theme.dart';

class SuperAdminCreateAdminScreen extends StatefulWidget {
  const SuperAdminCreateAdminScreen({super.key});

  @override
  State<SuperAdminCreateAdminScreen> createState() => _SuperAdminCreateAdminScreenState();
}

class _SuperAdminCreateAdminScreenState extends State<SuperAdminCreateAdminScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nomController = TextEditingController();
  final _prenomController = TextEditingController();
  final _emailController = TextEditingController();
  final _telephoneController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  
  bool _isLoading = false;
  bool _obscurePassword = true;
  Structure? _selectedStructure;
  String _structureSearchQuery = '';

  @override
  void dispose() {
    _nomController.dispose();
    _prenomController.dispose();
    _emailController.dispose();
    _telephoneController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedStructure == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez sélectionner une structure'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    
    try {
      final response = await context.read<DashboardProvider>().createAdminForStructure(
        _selectedStructure!.id,
        {
          'nom': _nomController.text.trim(),
          'prenom': _prenomController.text.trim(),
          'email': _emailController.text.trim(),
          'telephone': _telephoneController.text.trim(),
          'username': _usernameController.text.trim(),
          'password': _passwordController.text,
        },
      );
      
      if (response['success'] == true) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Administrateur créé avec succès !')),
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
        title: const Text('Créer un Administrateur'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppTheme.paddingMedium),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                 Consumer<StructuresProvider>(
                  builder: (context, provider, child) {
                    // Filtrage des structures selon la saisie
                    final allStructures = provider.allStructuresUnfiltered;
                    final filteredStructures = allStructures.where((s) {
                      return s.name.toLowerCase().contains(_structureSearchQuery.toLowerCase());
                    }).toList();

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Structure', style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        // Champ de recherche / "Écrire" pour filtrer
                        TextField(
                          decoration: InputDecoration(
                            hintText: 'Rechercher ou écrire le nom...',
                            prefixIcon: const Icon(Icons.search, size: 20),
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(vertical: 12),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          onChanged: (val) {
                            setState(() {
                              _structureSearchQuery = val;
                            });
                          },
                        ),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<Structure>(
                          isExpanded: true,
                          decoration: const InputDecoration(
                            labelText: 'Sélectionner la structure *',
                            border: OutlineInputBorder(),
                          ),
                          value: _selectedStructure,
                          items: filteredStructures.map((s) {
                            final isFictive = int.tryParse(s.id) == null;
                            return DropdownMenuItem(
                              value: s,
                              child: Row(
                                children: [
                                  Expanded(child: Text(s.name, overflow: TextOverflow.ellipsis)),
                                  if (isFictive)
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                      decoration: BoxDecoration(color: Colors.orange[100], borderRadius: BorderRadius.circular(4)),
                                      child: const Text('DÉMO', style: TextStyle(fontSize: 10, color: Colors.orange)),
                                    ),
                                ],
                              ),
                            );
                          }).toList(),
                          onChanged: (val) {
                            setState(() {
                              _selectedStructure = val;
                            });
                          },
                          validator: (v) {
                            if (v == null) return 'Ce champ est requis';
                            if (int.tryParse(v.id) == null) return 'Sélectionnez une structure réelle (non démo)';
                            return null;
                          },
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 24),
                
                TextFormField(
                  controller: _prenomController,
                  decoration: const InputDecoration(labelText: 'Prénom *'),
                  validator: (v) => v == null || v.isEmpty ? 'Requis' : null,
                ),
                const SizedBox(height: 16),
                
                TextFormField(
                  controller: _nomController,
                  decoration: const InputDecoration(labelText: 'Nom *'),
                  validator: (v) => v == null || v.isEmpty ? 'Requis' : null,
                ),
                const SizedBox(height: 16),
                
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(labelText: 'Email *'),
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Requis';
                    if (!v.contains('@')) return 'Email invalide';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                TextFormField(
                  controller: _telephoneController,
                  decoration: const InputDecoration(labelText: 'Téléphone *'),
                  keyboardType: TextInputType.phone,
                  validator: (v) => v == null || v.isEmpty ? 'Requis' : null,
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _usernameController,
                  decoration: const InputDecoration(
                    labelText: 'Nom d\'utilisateur (Identifiant) *',
                    hintText: 'Ex: admin_nnd',
                  ),
                  validator: (v) => v == null || v.trim().isEmpty ? 'Identifiant obligatoire' : null,
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'Mot de passe temporaire *',
                    suffixIcon: IconButton(
                      icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Requis';
                    if (v.length < 6) return 'Minimum 6 caractères';
                    return null;
                  },
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
                      : const Text('Créer l\'administrateur'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
