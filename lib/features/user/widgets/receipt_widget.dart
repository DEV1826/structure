import 'package:flutter/material.dart';
import 'package:structure_mobile/core/constants/app_constants.dart';
import 'package:structure_mobile/features/user/models/models.dart';
import 'package:intl/intl.dart';

class ReceiptWidget extends StatelessWidget {
  final String transactionId;
  final StructureModel structure;
  final ServiceModel service;
  final String customerName;
  final String customerPhone;
  final DateTime paymentDate;
  final bool showHeader;
  final bool showFooter;

  const ReceiptWidget({
    Key? key,
    required this.transactionId,
    required this.structure,
    required this.service,
    required this.customerName,
    required this.customerPhone,
    required this.paymentDate,
    this.showHeader = true,
    this.showFooter = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('dd/MM/yyyy à HH:mm');
    final currencyFormat = NumberFormat.currency(
      locale: 'fr_FR',
      symbol: 'FCFA',
      decimalDigits: 0,
    );

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(AppConstants.mediumRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // En-tête du reçu
          if (showHeader) ..._buildHeader(context, theme),
          
          // Corps du reçu
          Padding(
            padding: const EdgeInsets.all(AppConstants.mediumPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Informations de la transaction
                _buildInfoRow('Date', dateFormat.format(paymentDate)),
                const SizedBox(height: AppConstants.smallPadding / 2),
                _buildInfoRow('Référence', transactionId),
                
                const Divider(height: AppConstants.largePadding),
                
                // Informations du client
                Text(
                  'Client',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppConstants.smallPadding / 2),
                _buildInfoRow('Nom', customerName),
                const SizedBox(height: AppConstants.smallPadding / 2),
                _buildInfoRow('Téléphone', customerPhone),
                
                const Divider(height: AppConstants.largePadding),
                
                // Détails de la structure
                Text(
                  'Structure',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppConstants.smallPadding / 2),
                _buildInfoRow('Nom', structure.name),
                if (structure.phoneNumber?.isNotEmpty ?? false) ...[
                  const SizedBox(height: AppConstants.smallPadding / 2),
                  _buildInfoRow('Téléphone', structure.phoneNumber!),
                ],
                if (structure.address?.isNotEmpty ?? false) ...[
                  const SizedBox(height: AppConstants.smallPadding / 2),
                  _buildInfoRow('Adresse', structure.address!),
                ],
                
                const Divider(height: AppConstants.largePadding),
                
                // Détails du service
                Text(
                  'Détails du service',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppConstants.smallPadding / 2),
                _buildInfoRow('Service', service.name),
                if (service.description?.isNotEmpty ?? false) ...[
                  const SizedBox(height: AppConstants.smallPadding / 2),
                  _buildInfoRow('Description', service.description!),
                ],
                
                const Divider(height: AppConstants.largePadding),
                
                // Montant total
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Montant total',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      service.price != null 
                          ? '${service.price!.toStringAsFixed(0)} ${service.priceUnit ?? 'FCFA'}'
                          : 'Prix non disponible',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Pied de page du reçu
          if (showFooter) ..._buildFooter(theme),
        ],
      ),
    );
  }

  List<Widget> _buildHeader(BuildContext context, ThemeData theme) {
    return [
      Container(
        padding: const EdgeInsets.all(AppConstants.mediumPadding),
        decoration: BoxDecoration(
          color: theme.colorScheme.primary.withOpacity(0.1),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(AppConstants.mediumRadius),
            topRight: Radius.circular(AppConstants.mediumRadius),
          ),
        ),
        child: Column(
          children: [
            // Logo de l'application
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                borderRadius: BorderRadius.circular(AppConstants.mediumRadius),
              ),
              child: const Icon(
                Icons.receipt_long_outlined,
                color: Colors.white,
                size: 32,
              ),
            ),
            const SizedBox(height: AppConstants.mediumPadding),
            
            // Titre du reçu
            Text(
              'REÇU DE PAIEMENT',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: AppConstants.smallPadding / 2),
            Text(
              'Transaction effectuée avec succès',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.textTheme.bodySmall?.color,
              ),
            ),
          ],
        ),
      ),
      const Divider(height: 1, thickness: 1),
    ];
  }

  List<Widget> _buildFooter(ThemeData theme) {
    return [
      const Divider(height: 1, thickness: 1),
      Container(
        padding: const EdgeInsets.all(AppConstants.mediumPadding),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(AppConstants.mediumRadius),
            bottomRight: Radius.circular(AppConstants.mediumRadius),
          ),
        ),
        child: Column(
          children: [
            const Icon(
              Icons.verified_outlined,
              color: Colors.green,
              size: 32,
            ),
            const SizedBox(height: AppConstants.smallPadding),
            Text(
              'Paiement vérifié et approuvé',
              style: theme.textTheme.titleSmall?.copyWith(
                color: Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppConstants.smallPadding / 2),
            Text(
              'Merci pour votre confiance !',
              style: theme.textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    ];
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
        ),
        const Text(':  '),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
