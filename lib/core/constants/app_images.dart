import 'package:flutter/material.dart';

/// Classe de constantes pour les chemins d'accès aux images de l'application
class AppImages {
  // Dossier de base pour les images
  static const String _basePath = 'assets/images';

  // Images du carrousel d'accueil
  static const String welcome1 = '$_basePath/welcome_1.jfif';
  static const String welcome2 = '$_basePath/welcome_2.jfif';
  static const String welcome3 = '$_basePath/welcome_3.jfif';
  static const String welcome4 = '$_basePath/welcome_4.jfif';

  // Liste de toutes les images du carrousel
  static List<String> get welcomeCarouselImages => [welcome1, welcome2, welcome3, welcome4];

  /// Crée un widget d'image par défaut avec une couleur de fond et une icône
  static Widget defaultImageWidget({
    required BuildContext context, 
    double? width, 
    double? height,
    Color? backgroundColor,
    IconData icon = Icons.image_not_supported,
    double iconSize = 80,
    Color? iconColor,
  }) {
    final theme = Theme.of(context);
    return Container(
      width: width,
      height: height,
      color: backgroundColor ?? theme.colorScheme.surfaceVariant.withOpacity(0.5),
      child: Center(
        child: Icon(
          icon,
          size: iconSize,
          color: iconColor ?? theme.colorScheme.onSurfaceVariant.withOpacity(0.6),
        ),
      ),
    );
  }
}
