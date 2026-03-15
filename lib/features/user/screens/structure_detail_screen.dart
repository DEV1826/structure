import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:structure_mobile/core/constants/app_constants.dart';
import 'package:structure_mobile/core/widgets/loading_widget.dart';
import 'package:structure_mobile/features/structures/models/structure_model.dart'
    as structures;
import 'package:structure_mobile/features/structures/providers/structures_provider.dart';
import 'package:structure_mobile/features/user/models/structure_model.dart'
    as user_models;
import 'package:structure_mobile/features/user/navigation/user_router.dart';
import 'package:structure_mobile/features/user/widgets/service_item.dart';

class StructureDetailScreen extends StatelessWidget {
  final String structureId;

  const StructureDetailScreen({Key? key, required this.structureId})
    : super(key: key);

  Future<void> _launchMaps(structures.Structure structure) async {
    final lat = structure.latitude;
    final lng = structure.longitude;
    final name = Uri.encodeComponent(structure.name);

    if (lat != null && lng != null) {
      final url =
          'https://www.google.com/maps/search/?api=1&query=$lat,$lng&query_place_id=$name';

      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
      }
    }
  }

  Future<void> _launchPhoneCall(String? phoneNumber) async {
    if (phoneNumber == null) return;

    final url = 'tel:$phoneNumber';

    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      throw 'Impossible d\'effectuer l\'appel sur ce téléphone';
    }
  }

  Future<void> _launchEmail(String? email) async {
    if (email == null) return;

    final url = 'mailto:$email';

    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      throw 'Aucune application de messagerie trouvée';
    }
  }

  Future<void> _launchWebsite(String? url) async {
    if (url == null) return;

    String formattedUrl = url;
    if (!formattedUrl.startsWith('http://') &&
        !formattedUrl.startsWith('https://')) {
      formattedUrl = 'https://$formattedUrl';
    }

    if (await canLaunchUrl(Uri.parse(formattedUrl))) {
      await launchUrl(
        Uri.parse(formattedUrl),
        mode: LaunchMode.externalApplication,
      );
    } else {
      throw 'Impossible d\'ouvrir le site web';
    }
  }

  Widget _buildServicesSection(
    structures.Structure structure,
    BuildContext context,
  ) {
    final provider = Provider.of<StructuresProvider>(context, listen: false);
    final services = provider.getServicesForStructure(structure.id);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Services disponibles',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              if (services.isNotEmpty)
                TextButton(
                  onPressed: () => _navigateToServices(context, structure),
                  child: const Text('Voir tout'),
                ),
            ],
          ),
        ),
        if (services.isEmpty)
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text('Aucun service disponible pour le moment'),
          )
        else
          SizedBox(
            height: 180,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              itemCount: services.length > 5 ? 5 : services.length,
              itemBuilder: (context, index) {
                final service = services[index];
                return Container(
                  width: 200,
                  margin: const EdgeInsets.symmetric(
                    horizontal: 8.0,
                    vertical: 4.0,
                  ),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            service.name,
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          if (service.description?.isNotEmpty ?? false)
                            Text(
                              service.description!,
                              style: Theme.of(context).textTheme.bodySmall,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          const Spacer(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                service.price != null
                                    ? '${service.price!.toStringAsFixed(0)} ${service.priceUnit ?? 'FCFA'}'
                                    : 'Prix sur demande',
                                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                      color: Theme.of(context).colorScheme.primary,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.add_shopping_cart,
                                  size: 20,
                                ),
                                onPressed: () {
                                  // Ajouter directement au panier ou naviguer vers la sélection
                                  _navigateToServices(context, structure);
                                },
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        if (services.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () => _navigateToServices(context, structure),
                icon: const Icon(Icons.list_alt),
                label: const Text('Voir tous les services'),
              ),
            ),
          ),
      ],
    );
  }

  void _navigateToServices(
    BuildContext context,
    structures.Structure structure,
  ) {
    // Vérifier s'il y a des services disponibles
    final provider = Provider.of<StructuresProvider>(context, listen: false);
    final services = provider.getServicesForStructure(structure.id);

    if (services.isEmpty) {
      // Afficher un message s'il n'y a pas de services
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Aucun service disponible pour le moment'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    // Convertir la structure en StructureModel
    final structureModel = user_models.StructureModel(
      id: structure.id,
      name: structure.name,
      address: structure.address,
      description: structure.description,
      imageUrl: structure.imageUrl,
      rating: structure.rating,
      reviewCount: structure.reviewCount,
      categories: [structure.category ?? 'Non spécifiée'],
      phoneNumber: structure.phoneNumber,
      email: structure.email,
      website: structure.website,
      isOpen: true,
      serviceIds: structure.services.map((s) => s.id).toList(),
    );

    // Naviguer vers l'écran de sélection des services avec GoRouter
    GoRouter.of(context).go(
      UserRouter.servicesSelection,
      extra: {'structure': structureModel, 'services': services},
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: Consumer<StructuresProvider>(
        builder: (context, provider, _) {
          final structure = provider.getStructureById(structureId);
          if (structure == null) return const SizedBox.shrink();

          return FloatingActionButton.extended(
            onPressed: () => _navigateToServices(context, structure),
            label: const Text('Voir tous les services'),
            icon: const Icon(Icons.list_alt),
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Colors.white,
            elevation: 4.0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30.0),
            ),
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      body: Consumer<StructuresProvider>(
        builder: (context, provider, _) {
          final structure = provider.getStructureById(structureId);

          if (structure == null && !provider.isLoading) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: AppConstants.mediumPadding),
                  Text(
                    'Structure introuvable',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: AppConstants.mediumPadding),
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Retour'),
                  ),
                ],
              ),
            );
          }

          if (structure == null) {
            return const LoadingWidget(
              message: 'Chargement des détails...',
              withScaffold: true,
            );
          }

          return CustomScrollView(
            slivers: [
              // AppBar avec image de la structure
              SliverAppBar(
                expandedHeight: 250.0,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(
                    structure.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(
                          offset: Offset(1, 1),
                          blurRadius: 3.0,
                          color: Colors.black45,
                        ),
                      ],
                    ),
                  ),
                  background: structure.imageUrl != null
                      ? Hero(
                          tag: 'structure-image-${structure.id}',
                          child: Image.network(
                            structure.imageUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Container(
                                  color: Colors.grey[300],
                                  child: const Icon(
                                    Icons.business,
                                    size: 80,
                                    color: Colors.grey,
                                  ),
                                ),
                          ),
                        )
                      : Container(
                          color: Colors.grey[300],
                          child: const Center(
                            child: Icon(
                              Icons.business,
                              size: 80,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                ),
              ),

              // Contenu détaillé
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(AppConstants.mediumPadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Description
                      if (structure.description?.isNotEmpty ?? false) ...[
                        Text(
                          'Description',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: AppConstants.smallPadding),
                        Text(
                          structure.description!,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        const SizedBox(height: AppConstants.mediumPadding),
                      ],

                      // Informations de contact
                      const Text(
                        'Informations de contact',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: AppConstants.smallPadding),

                      // Adresse
                      if (structure.address?.isNotEmpty ?? false) ...[
                        ListTile(
                          leading: const Icon(Icons.location_on_outlined),
                          title: const Text('Adresse'),
                          subtitle: Text(structure.address!),
                          onTap: () => _launchMaps(structure),
                          trailing: const Icon(Icons.directions),
                        ),
                        const Divider(height: 1),
                      ],

                      // Téléphone
                      if (structure.phoneNumber?.isNotEmpty ?? false) ...[
                        ListTile(
                          leading: const Icon(Icons.phone_outlined),
                          title: const Text('Téléphone'),
                          subtitle: Text(structure.phoneNumber!),
                          onTap: () => _launchPhoneCall(structure.phoneNumber),
                          trailing: const Icon(Icons.phone_forwarded),
                        ),
                        const Divider(height: 1),
                      ],

                      // Email
                      if (structure.email?.isNotEmpty ?? false) ...[
                        ListTile(
                          leading: const Icon(Icons.email_outlined),
                          title: const Text('Email'),
                          subtitle: Text(structure.email!),
                          onTap: () => _launchEmail(structure.email),
                          trailing: const Icon(Icons.mail_outline),
                        ),
                        const Divider(height: 1),
                      ],

                      // Site web
                      if (structure.website?.isNotEmpty ?? false) ...[
                        ListTile(
                          leading: const Icon(Icons.language_outlined),
                          title: const Text('Site web'),
                          subtitle: Text(
                            structure.website!.replaceAll(
                              RegExp(r'^https?://'),
                              '',
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          onTap: () => _launchWebsite(structure.website),
                          trailing: const Icon(Icons.open_in_new),
                        ),
                        const Divider(height: 1),
                      ],

                      const SizedBox(height: AppConstants.largePadding),

                      // Services proposés
                      Text(
                        'Services proposés',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: AppConstants.mediumPadding),
                      _buildServicesSection(structure, context),
                    ],
                  ),
                ),
              ),

              // Liste des services
              Consumer<StructuresProvider>(
                builder: (context, provider, _) {
                  final services = provider.getServicesForStructure(
                    structure.id,
                  );

                  if (provider.isLoading) {
                    return const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.only(
                          bottom: AppConstants.largePadding,
                        ),
                        child: LoadingWidget(),
                      ),
                    );
                  }

                  if (services.isEmpty) {
                    return const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.only(
                          bottom: AppConstants.largePadding,
                        ),
                        child: Center(
                          child: Text(
                            'Aucun service disponible pour le moment',
                          ),
                        ),
                      ),
                    );
                  }

                  return SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final service = services[index];
                      return ServiceItem(
                        service: service,
                        onTap: () {
                          // Navigation vers l'écran de paiement
                          Navigator.pushNamed(
                            context,
                            '/payment',
                            arguments: {
                              'structure': structure,
                              'service': service,
                            },
                          );
                        },
                      );
                    }, childCount: services.length),
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
