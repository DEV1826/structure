import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:structure_mobile/core/constants/app_constants.dart';
import 'package:structure_mobile/features/structures/models/structure_model.dart' as structures;
import 'package:structure_mobile/features/user/models/service_model.dart';
import 'package:structure_mobile/features/user/models/structure_model.dart' as user_models;

class ServicesSelectionScreen extends StatefulWidget {
  final user_models.StructureModel structure;
  final List<ServiceModel> services;
  
  const ServicesSelectionScreen({
    Key? key,
    required this.structure,
    required this.services,
  }) : super(key: key);

  @override
  _ServicesSelectionScreenState createState() => _ServicesSelectionScreenState();
}

class _ServicesSelectionScreenState extends State<ServicesSelectionScreen> {
  final Map<String, int> _selectedServices = {}; // Map<serviceId, quantity>
  double _totalAmount = 0.0;

  @override
  Widget build(BuildContext context) {
    final structure = widget.structure;
    final services = widget.services;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sélection des services'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // En-tête avec le nom de la structure
          Container(
            padding: const EdgeInsets.all(AppConstants.mediumPadding),
            color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
            child: Row(
              children: [
                Icon(
                  Icons.business,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    structure.name,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          
          // Liste des services
          Expanded(
            child: services.isEmpty
                ? const Center(
                    child: Text('Aucun service disponible pour le moment'),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(AppConstants.mediumPadding),
                    itemCount: services.length,
                    itemBuilder: (context, index) {
                      final service = services[index];
                      final quantity = _selectedServices[service.id] ?? 0;
                      
                      return Card(
                        margin: const EdgeInsets.only(bottom: AppConstants.mediumPadding),
                        child: Padding(
                          padding: const EdgeInsets.all(AppConstants.mediumPadding),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Nom et prix du service
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      service.name,
                                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                  ),
                                  Text(
                                    service.price != null 
                                        ? '${service.price!.toStringAsFixed(0)} ${service.priceUnit ?? 'FCFA'}'
                                        : 'Prix sur demande',
                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                          color: Theme.of(context).colorScheme.primary,
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                ],
                              ),
                              
                              // Description si disponible
                              if (service.description?.isNotEmpty ?? false) ...{
                                const SizedBox(height: 8),
                                Text(
                                  service.description!,
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              },
                              
                              // Sélecteur de quantité
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Quantité:',
                                    style: Theme.of(context).textTheme.bodyLarge,
                                  ),
                                  Row(
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.remove_circle_outline),
                                        onPressed: quantity > 0
                                            ? () => _updateQuantity(service.id, quantity - 1)
                                            : null,
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 12),
                                        child: Text(
                                          quantity.toString(),
                                          style: Theme.of(context).textTheme.titleMedium,
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.add_circle_outline),
                                        onPressed: () => _updateQuantity(service.id, quantity + 1),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
          
          // Barre de total et bouton de validation
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.largePadding,
              vertical: AppConstants.mediumPadding,
            ),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Column(
              children: [
                // Montant total
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total:',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    Text(
                      '${_totalAmount.toStringAsFixed(0)} FCFA',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
                
                const SizedBox(height: AppConstants.mediumPadding),
                
                // Bouton de validation
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _totalAmount > 0 ? _proceedToPayment : null,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Text(
                      'Procéder au paiement',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  void _updateQuantity(String serviceId, int newQuantity) {
    setState(() {
      if (newQuantity <= 0) {
        _selectedServices.remove(serviceId);
      } else {
        _selectedServices[serviceId] = newQuantity;
      }
      
      // Recalculer le montant total
      _calculateTotal();
    });
  }
  
  void _calculateTotal() {
    double total = 0.0;
    
    _selectedServices.forEach((serviceId, quantity) {
      try {
        final service = widget.services.firstWhere((s) => s.id == serviceId);
        if (service.price != null) {
          total += service.price! * quantity;
        } else {
          debugPrint('Service with id $serviceId has no price');
        }
      } catch (e) {
        debugPrint('Service with id $serviceId not found in the services list');
      }
    });
    
    if (mounted) {
      setState(() {
        _totalAmount = total;
      });
    }
  }
  
  void _proceedToPayment() {
    if (_selectedServices.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez sélectionner au moins un service')),
      );
      return;
    }
    
    // Préparer la liste des services sélectionnés avec leurs quantités
    final selectedServices = <Map<String, dynamic>>[];
    
    for (final entry in _selectedServices.entries) {
      try {
        final service = widget.services.firstWhere((s) => s.id == entry.key);
        final total = service.price != null ? service.price! * entry.value : 0.0;
        selectedServices.add({
          'service': service,
          'quantity': entry.value,
          'total': total,
        });
      } catch (e) {
        debugPrint('Service with id ${entry.key} not found in the services list');
      }
    }
    
    if (selectedServices.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Aucun service valide sélectionné')),
      );
      return;
    }
    
    // Calculer le montant total
    final totalAmount = selectedServices.fold<double>(
      0,
      (sum, item) {
        final service = item['service'] as ServiceModel;
        final quantity = item['quantity'] as int;
        if (service.price == null) return sum;
        return sum + (service.price! * quantity);
      },
    );
    
    // Naviguer vers l'écran de paiement avec GoRouter
    context.go(
      '/payment',
      extra: {
        'structure': widget.structure,
        'selectedServices': selectedServices,
        'totalAmount': totalAmount,
      },
    );
  }
}
