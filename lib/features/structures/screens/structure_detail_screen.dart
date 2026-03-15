import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:structure_mobile/features/structures/models/structure_model.dart';
import 'package:structure_mobile/features/structures/providers/structures_provider.dart';
import 'package:structure_mobile/features/shared/widgets/loading_indicator.dart';
import 'package:structure_mobile/features/user/widgets/loading_indicator.dart';

class StructureDetailScreen extends StatefulWidget {
  final String? structureId;
  final Structure? structure;

  const StructureDetailScreen({Key? key, this.structureId, this.structure})
    : assert(
        structureId != null || structure != null,
        'Either structureId or structure must be provided',
      ),
      super(key: key);

  @override
  _StructureDetailScreenState createState() => _StructureDetailScreenState();
}

class _StructureDetailScreenState extends State<StructureDetailScreen> {
  late Future<Structure?> _structureFuture;

  Structure? get structure => null;

  @override
  void initState() {
    super.initState();
    if (widget.structure != null) {
      _structureFuture = Future.value(widget.structure);
    } else {
      _loadStructure();
    }
  }

  Future<void> _loadStructure() async {
    setState(() {
      _structureFuture = _fetchStructure();
    });
  }

  Future<Structure?> _fetchStructure() async {
    if (widget.structureId == null) return null;

    final provider = Provider.of<StructuresProvider>(context, listen: false);

    try {
      return provider.getStructureById(widget.structureId!);
    } catch (e) {
      debugPrint('Error loading structure: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Détails de la structure')),
      body: FutureBuilder<Structure?>(
        future: _structureFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: LoadingIndicator());
          }

          if (snapshot.hasError || !snapshot.hasData) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  const Text(
                    'Impossible de charger les détails de la structure',
                    style: TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _loadStructure,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Réessayer'),
                  ),
                ],
              ),
            );
          }

          final structure = snapshot.data!;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // En-tête avec le nom et les actions
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        structure.name,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                    ),
                    if (widget.structureId !=
                        null) // Afficher le bouton d'édition uniquement si on est en mode chargement par ID
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () {
                          _showEditStructureDialog(context, structure);
                        },
                      ),
                  ],
                ),
                const SizedBox(height: 16),

                // Image de la structure
                if (structure.imageUrl != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      structure.imageUrl!,
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        height: 200,
                        color: Colors.grey[200],
                        child: const Icon(Icons.business, size: 50),
                      ),
                    ),
                  )
                else
                  Container(
                    height: 200,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.business, size: 50),
                  ),

                const SizedBox(height: 16),

                // Informations de base
                _buildInfoSection(
                  context,
                  title: 'Description',
                  content: structure.description,
                  icon: Icons.description,
                ),

                _buildInfoSection(
                  context,
                  title: 'Adresse',
                  content: structure.address,
                  icon: Icons.location_on,
                ),

                if (structure.phoneNumber != null)
                  _buildInfoSection(
                    context,
                    title: 'Téléphone',
                    content: structure.phoneNumber!,
                    icon: Icons.phone,
                  ),

                if (structure.email != null)
                  _buildInfoSection(
                    context,
                    title: 'Email',
                    content: structure.email!,
                    icon: Icons.email,
                  ),

                if (structure.website != null)
                  _buildInfoSection(
                    context,
                    title: 'Site web',
                    content: structure.website!,
                    icon: Icons.language,
                  ),

                const SizedBox(height: 24),

                // Services
                _buildSectionTitle('Services proposés'),
                const SizedBox(height: 8),
                if (structure.services.isNotEmpty)
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: structure.services
                        .map(
                          (service) => Chip(
                            label: Text(service.name),
                            backgroundColor: Theme.of(
                              context,
                            ).colorScheme.primaryContainer,
                          ),
                        )
                        .toList(),
                  )
                else
                  const Text('Aucun service disponible pour le moment.'),

                const SizedBox(height: 24),

                // Galerie d'images
                if (structure.galleryImages?.isNotEmpty ?? false) ...[
                  _buildSectionTitle('Galerie photos'),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 120,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: structure.galleryImages!.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              structure.galleryImages![index],
                              width: 160,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  Container(
                                    width: 160,
                                    color: Colors.grey[200],
                                    child: const Icon(Icons.broken_image),
                                  ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                // Bouton d'action principal
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // Naviguer vers la sélection des services
                    },
                    icon: const Icon(Icons.shopping_cart),
                    label: const Text('Sélectionner les services'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed: () {
            _showContactOptions(context, structure!);
          },
          child: const Text('Contacter la structure'),
        ),
      ),
    );
  }

  Widget _buildInfoSection(
    BuildContext context, {
    required String title,
    required String content,
    required IconData icon,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: Theme.of(context).primaryColor),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.only(left: 28.0),
            child: Text(content),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    );
  }

  void _showEditStructureDialog(BuildContext context, Structure structure) {
    // Implémentation de la boîte de dialogue d'édition
    // (à adapter selon vos besoins)
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Modifier la structure'),
        content: const Text('Fonctionnalité de modification à implémenter.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              // TODO: Save changes
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Modifications enregistrées')),
              );
            },
            child: const Text('Enregistrer'),
          ),
        ],
      ),
    );
  }

  void _showContactOptions(BuildContext context, Structure structure) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SizedBox(
        height: 200,
        child: Column(
          children: [
            ListTile(
              leading: const Icon(Icons.phone),
              title: const Text('Appeler'),
              onTap: () {
                Navigator.pop(context);
                if (structure.phoneNumber != null) {
                  // TODO: Implement phone call
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Appel vers ${structure.phoneNumber}...'),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.email),
              title: const Text('Envoyer un email'),
              onTap: () {
                Navigator.pop(context);
                if (structure.email != null) {
                  // TODO: Implement email
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Ouverture de l\'application email pour ${structure.email}...',
                      ),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.map),
              title: const Text('Voir sur la carte'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Implement map view
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Ouverture de la carte...'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
