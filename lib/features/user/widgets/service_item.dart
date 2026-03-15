import 'package:flutter/material.dart';
import 'package:structure_mobile/core/constants/app_constants.dart';
import 'package:structure_mobile/features/user/models/models.dart';

class ServiceItem extends StatelessWidget {
  final ServiceModel service;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? margin;
  final bool showPrice;
  final bool showDescription;
  final bool showActionButton;

  const ServiceItem({
    Key? key,
    required this.service,
    this.onTap,
    this.margin,
    this.showPrice = true,
    this.showDescription = true,
    this.showActionButton = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Card(
      margin: margin ?? const EdgeInsets.symmetric(
        horizontal: AppConstants.mediumPadding,
        vertical: AppConstants.smallPadding / 2,
      ),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.mediumRadius),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppConstants.mediumRadius),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.mediumPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // En-tête avec nom et prix
              Row(
                children: [
                  Expanded(
                    child: Text(
                      service.name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (showPrice) ...[
                    const SizedBox(width: AppConstants.smallPadding),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppConstants.smallPadding,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(AppConstants.mediumRadius),
                      ),
                      child: Text(
                        service.price != null
                            ? '${service.price!.toStringAsFixed(0)} ${service.priceUnit ?? 'FCFA'}'
                            : 'Prix sur demande',
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              
              // Description
              if (showDescription && service.description?.isNotEmpty == true) ...[
                const SizedBox(height: AppConstants.smallPadding / 2),
                Text(
                  service.description!,
                  style: theme.textTheme.bodyMedium,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              
              // Bouton d'action
              if (showActionButton && onTap != null) ...[
                const SizedBox(height: AppConstants.mediumPadding),
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    onPressed: onTap,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppConstants.mediumPadding,
                        vertical: AppConstants.smallPadding,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppConstants.mediumRadius),
                      ),
                    ),
                    child: const Text('Choisir'),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
