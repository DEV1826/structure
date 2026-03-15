import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:structure_mobile/features/user/models/models.dart';
import 'package:structure_mobile/features/user/theme/app_theme.dart';
import 'package:structure_mobile/features/user/widgets/loading_indicator.dart';


/// A card widget that displays a structure's information in a visually appealing way.
/// It shows the structure's image, name, status, rating, and other details.
/// Tapping the card will navigate to the structure's detail screen.

// Constants for text strings
class _Strings {
  static const String viewDetails = 'Voir les détails';
  static const String open = 'OUVERT';
  static const String closed = 'FERMÉ';
  static const String addressNotAvailable = 'Adresse non disponible';
  static const String noOpeningHours = 'Horaires non disponibles';
  static const String closedToday = "Fermé aujourd'hui";
  static const String openToday = "Ouvert aujourd'hui de";
}

class StructureCard extends StatelessWidget {
  final StructureModel structure;
  final VoidCallback? onTap;
  final bool showDetailsButton;
  final EdgeInsets? margin;
  final bool showRating;
  final bool isFavorite;
  final VoidCallback? onFavoriteTap;

  const StructureCard({
    Key? key,
    required this.structure,
    this.onTap,
    this.showDetailsButton = true,
    this.margin,
    this.showRating = true,
    this.isFavorite = false,
    this.onFavoriteTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      margin: margin ?? const EdgeInsets.symmetric(
        horizontal: 16.0,
        vertical: 8.0,
      ),
      decoration: AppTheme.cardDecoration.copyWith(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12.0),
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Image and header section
            _buildHeader(context),
            
            // Content section
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Structure name
                  Text(
                    structure.name,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  
                  const SizedBox(height: 8.0),
                  
                  // Categories
                  if (structure.categories?.isNotEmpty ?? false)
                    _buildCategories(),
                  
                  const SizedBox(height: 8.0),
                  
                  // Description
                  if (structure.description?.isNotEmpty ?? false)
                    _buildDescription(theme),
                    // Opening hours
                  _buildOpeningHours(context),
                  const SizedBox(height: 8.0),
                  
                  // Address and distance row
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          structure.address ?? _Strings.addressNotAvailable,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppTheme.textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (structure.distance != null) ...[
                        const SizedBox(width: 8.0),
                        Text(
                          '${structure.distance!.toStringAsFixed(1)} km',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppTheme.primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ],
                  ),
                  
                  // Address details
                  if (structure.address?.isNotEmpty ?? false) ...[
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          size: 16,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            structure.address!,
                            style: theme.textTheme.bodySmall,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8.0),
                  ],
                  
                  // Bouton d'action principal
                  if (showDetailsButton) ...[
                    const SizedBox(height: 16.0),
                    SizedBox(
                      width: double.infinity,
                      height: 40.0,
                      child: ElevatedButton(
                        onPressed: onTap,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                        child: Text(
                          _Strings.viewDetails.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 13.0,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  // Build the header section with image and status badges
  Widget _buildHeader(BuildContext context) {
    return Stack(
      children: [
        // Main image
        ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(12.0)),
          child: structure.imageUrl?.isNotEmpty == true
              ? CachedNetworkImage(
                  imageUrl: structure.imageUrl!,
                  width: double.infinity,
                  height: 160.0,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => const Center(
                    child: LoadingIndicator(size: 40.0),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: Colors.grey[200],
                    child: const Icon(Icons.broken_image, size: 40.0),
                  ),
                )
              : Container(
                  height: 160.0,
                  color: Colors.grey[200],
                  child: const Icon(Icons.store_mall_directory_outlined, size: 60.0),
                ),
        ),
        
        // Status badge (Open/Closed)
        Positioned(
          top: 12.0,
          left: 12.0,
          child: _buildStatusBadge(context),
        ),
        
        // Rating badge
        if (showRating && (structure.reviewCount > 0 || structure.rating > 0))
          Positioned(
            top: 12.0,
            right: 12.0,
            child: _buildRatingBadge(context),
          ),
          
        // Favorite button
        if (onFavoriteTap != null)
          Positioned(
            bottom: 12.0,
            right: 12.0,
            child: _buildFavoriteButton(context),
          ),
      ],
    );
  }
  
  // Build the status badge (Open/Closed)
  Widget _buildStatusBadge(BuildContext context) {
    final isOpen = structure.isOpen;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      decoration: BoxDecoration(
        color: isOpen ? Colors.green : Colors.red,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4.0,
            offset: const Offset(0, 2.0),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8.0,
            height: 8.0,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 4.0),
          Text(
            isOpen ? _Strings.open : _Strings.closed,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
  
  // Build the rating badge
  Widget _buildRatingBadge(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4.0,
            offset: const Offset(0, 2.0),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.star,
            color: Colors.amber,
            size: 16.0,
          ),
          const SizedBox(width: 4.0),
          Text(
            '${structure.rating.toStringAsFixed(1)} (${structure.reviewCount})',
            style: const TextStyle(
              fontSize: 12.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
  
  // Build the favorite button
  Widget _buildFavoriteButton(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4.0,
            offset: const Offset(0, 2.0),
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(
          isFavorite ? Icons.favorite : Icons.favorite_border,
          color: isFavorite ? Colors.red : Colors.grey[600],
        ),
        onPressed: onFavoriteTap,
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(),
        iconSize: 24.0,
      ),
    );
  }
  
  // Build categories chips
  Widget _buildCategories() {
    if (structure.categories.isEmpty) return const SizedBox.shrink();
    
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: structure.categories.map((category) {
          return Container(
            margin: const EdgeInsets.only(right: 6.0, bottom: 4.0),
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Text(
              category,
              style: TextStyle(
                color: AppTheme.primaryColor,
                fontSize: 12.0,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
  
  // Build description text
  Widget _buildDescription(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        structure.description!,
        style: theme.textTheme.bodySmall,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
  
  // Méthode utilitaire pour afficher les horaires d'ouverture
  Widget _buildOpeningHours(BuildContext context) {
    final now = DateTime.now();
    final weekday = now.weekday - 1; // 0 = lundi, 6 = dimanche
    final days = ['lundi', 'mardi', 'mercredi', 'jeudi', 'vendredi', 'samedi', 'dimanche'];
    
    if (structure.openingHours?.hours == null || 
        structure.openingHours!.hours.isEmpty) {
      return Text(
        _Strings.noOpeningHours,
        style: Theme.of(context).textTheme.bodySmall,
      );
    }
    
    final todayHours = structure.openingHours!.hours[days[weekday]];
    
    if (todayHours == null || todayHours.isEmpty) {
      return Text(
        _Strings.closedToday,
        style: Theme.of(context).textTheme.bodySmall,
      );
    }
    
    return Text(
      '${_Strings.openToday} $todayHours',
      style: Theme.of(context).textTheme.bodySmall,
    );
  }
}
