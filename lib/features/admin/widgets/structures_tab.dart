import 'package:flutter/material.dart';
import 'package:structure_mobile/core/providers/auth_provider.dart';
import 'package:provider/provider.dart';
import 'package:structure_mobile/features/admin/providers/dashboard_provider.dart';
import 'package:structure_mobile/themes/app_theme.dart';

class StructuresTab extends StatefulWidget {
  const StructuresTab({super.key});

  @override
  State<StructuresTab> createState() => _StructuresTabState();
}

class _StructuresTabState extends State<StructuresTab> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'all';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DashboardProvider>().loadStructures();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _reload() async {
    await context.read<DashboardProvider>().loadStructures(
          status: _selectedFilter == 'all' ? null : _selectedFilter,
          searchQuery: _searchController.text.isEmpty
              ? null
              : _searchController.text,
        );
  }

  // ── Formulaire de création / édition ───────────────────────────

  void _showStructureForm({Map<String, dynamic>? existing}) {
    final isEdit = existing != null;
    final nameCtrl =
        TextEditingController(text: existing?['name'] ?? '');
    final emailCtrl =
        TextEditingController(text: existing?['email'] ?? '');
    final phoneCtrl =
        TextEditingController(text: existing?['phone'] ?? '');
    final addressCtrl =
        TextEditingController(text: existing?['address'] ?? '');
    final descCtrl =
        TextEditingController(text: existing?['description'] ?? '');
    final formKey = GlobalKey<FormState>();
    bool saving = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setLocalState) => AlertDialog(
          title: Text(isEdit ? 'Modifier la structure' : 'Nouvelle structure'),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _field(nameCtrl, 'Nom *', required: true),
                  const SizedBox(height: 12),
                  _field(emailCtrl, 'Email',
                      keyboard: TextInputType.emailAddress),
                  const SizedBox(height: 12),
                  _field(phoneCtrl, 'Téléphone',
                      keyboard: TextInputType.phone),
                  const SizedBox(height: 12),
                  _field(addressCtrl, 'Adresse'),
                  const SizedBox(height: 12),
                  _field(descCtrl, 'Description', maxLines: 3),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: saving
                  ? null
                  : () async {
                      if (!formKey.currentState!.validate()) return;
                      setLocalState(() => saving = true);

                      final payload = {
                        'name': nameCtrl.text.trim(),
                        'email': emailCtrl.text.trim(),
                        'phone': phoneCtrl.text.trim(),
                        'address': addressCtrl.text.trim(),
                        'description': descCtrl.text.trim(),
                      };

                      final provider = context.read<DashboardProvider>();
                      Map<String, dynamic> result;

                      if (isEdit) {
                        result = await provider.updateStructure(
                            existing!['id'].toString(), payload);
                      } else {
                        result = await provider.createStructure(payload);
                      }

                      if (ctx.mounted) Navigator.pop(ctx);

                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(result['success'] == true
                                ? isEdit
                                    ? 'Structure mise à jour !'
                                    : 'Structure créée avec succès !'
                                : result['error'] ?? 'Erreur inconnue'),
                            backgroundColor: result['success'] == true
                                ? Colors.green
                                : Colors.red,
                          ),
                        );
                      }
                    },
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor),
              child: saving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white)))
                  : Text(isEdit ? 'Enregistrer' : 'Créer'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _field(
    TextEditingController ctrl,
    String label, {
    bool required = false,
    TextInputType keyboard = TextInputType.text,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: ctrl,
      keyboardType: keyboard,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        isDense: true,
      ),
      validator: required
          ? (v) => (v == null || v.trim().isEmpty) ? 'Champ requis' : null
          : null,
    );
  }

  // ── Confirm delete ──────────────────────────────────────────────

  Future<void> _confirmDelete(Map<String, dynamic> structure) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Supprimer la structure'),
        content: Text(
            'Voulez-vous vraiment supprimer "${structure['name']}" ? Cette action est irréversible.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Annuler')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final result = await context
          .read<DashboardProvider>()
          .deleteStructure(structure['id'].toString());

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['success'] == true
                ? 'Structure supprimée'
                : result['error'] ?? 'Erreur'),
            backgroundColor:
                result['success'] == true ? Colors.green : Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Barre de recherche + filtres
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Rechercher une structure...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            _reload();
                          },
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.grey[200],
                  contentPadding: const EdgeInsets.symmetric(
                      vertical: 0, horizontal: 20),
                ),
                onSubmitted: (_) => _reload(),
              ),
              const SizedBox(height: 12),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    for (final f in [
                      {'id': 'all', 'label': 'Toutes'},
                      {'id': 'active', 'label': 'Actives'},
                      {'id': 'suspended', 'label': 'Suspendues'},
                    ])
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(f['label']!),
                          selected: _selectedFilter == f['id'],
                          onSelected: (sel) {
                            setState(() => _selectedFilter =
                                sel ? f['id']! : 'all');
                            _reload();
                          },
                          selectedColor:
                              AppTheme.primaryColor.withOpacity(0.15),
                          labelStyle: TextStyle(
                            color: _selectedFilter == f['id']
                                ? AppTheme.primaryColor
                                : Colors.black87,
                            fontWeight: _selectedFilter == f['id']
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Liste
        Expanded(
          child: Consumer<DashboardProvider>(
            builder: (_, provider, __) {
              if (provider.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }
              if (provider.error != null) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline,
                          size: 48, color: Colors.red),
                      const SizedBox(height: 12),
                      Text(provider.error!),
                      const SizedBox(height: 12),
                      ElevatedButton(
                          onPressed: _reload,
                          child: const Text('Réessayer')),
                    ],
                  ),
                );
              }
              if (provider.structures.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.business_outlined,
                          size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text('Aucune structure trouvée',
                          style: TextStyle(color: Colors.grey[600])),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () => _showStructureForm(),
                        icon: const Icon(Icons.add),
                        label: const Text('Créer une structure'),
                        style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryColor),
                      ),
                    ],
                  ),
                );
              }
              return RefreshIndicator(
                onRefresh: _reload,
                child: ListView.builder(
                  padding: const EdgeInsets.only(bottom: 80),
                  itemCount: provider.structures.length,
                  itemBuilder: (_, i) =>
                      _buildCard(provider.structures[i]),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCard(Map<String, dynamic> s) {
    final isActive = s['status'] == 'active';

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: s['imageUrl'] != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(s['imageUrl'],
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) =>
                                  const Icon(Icons.business,
                                      color: Colors.grey)))
                      : const Icon(Icons.business, color: Colors.grey),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        s['name'] ?? 'Sans nom',
                        style: const TextStyle(
                            fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                      if (s['address'] != null &&
                          (s['address'] as String).isNotEmpty)
                        Text(s['address'],
                            style: TextStyle(
                                fontSize: 12, color: Colors.grey[600])),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: (isActive ? Colors.green : Colors.orange)
                        .withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    isActive ? 'Active' : 'Suspendue',
                    style: TextStyle(
                      color: isActive ? Colors.green : Colors.orange,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            if (s['description'] != null &&
                (s['description'] as String).isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                s['description'],
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 13, color: Colors.grey[700]),
              ),
            ],
            const SizedBox(height: 10),
            Consumer<AuthProvider>(
              builder: (_, auth, __) {
                final canEdit = auth.isAdmin || auth.isSuperAdmin;
                if (!canEdit) return const SizedBox.shrink();
                return Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      onPressed: () => _showStructureForm(existing: s),
                      icon: const Icon(Icons.edit, size: 16),
                      label: const Text('Modifier'),
                      style: TextButton.styleFrom(
                          foregroundColor: AppTheme.primaryColor),
                    ),
                    const SizedBox(width: 8),
                    TextButton.icon(
                      onPressed: () => _confirmDelete(s),
                      icon: const Icon(Icons.delete_outline, size: 16),
                      label: const Text('Supprimer'),
                      style: TextButton.styleFrom(foregroundColor: Colors.red),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
