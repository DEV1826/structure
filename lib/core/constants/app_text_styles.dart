import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTextStyles {
  // Titres
  static const TextStyle heading1 = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: AppColors.onBackground,
    letterSpacing: -0.5,
  );

  static const TextStyle heading2 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: AppColors.onBackground,
    letterSpacing: -0.5,
  );

  static const TextStyle heading3 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.onBackground,
  );

  // Corps de texte
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: AppColors.onBackground,
    height: 1.5,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: AppColors.onBackground,
    height: 1.5,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: AppColors.hint,
    height: 1.5,
  );

  // Boutons
  static const TextStyle button = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.onPrimary,
    letterSpacing: 0.5,
  );

  // Champs de formulaire
  static const TextStyle inputLabel = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.onBackground,
  );

  static const TextStyle inputText = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: AppColors.onBackground,
  );

  static const TextStyle inputHint = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: AppColors.hint,
  );

  // Liens
  static const TextStyle link = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.primary,
    decoration: TextDecoration.underline,
  );

  // Messages d'erreur
  static const TextStyle error = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: AppColors.error,
  );

  // Badges et étiquettes
  static const TextStyle badge = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: AppColors.onPrimary,
    letterSpacing: 0.5,
  );

  // Styles personnalisés
  static TextStyle sectionTitle = const TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.onBackground,
  );

  static TextStyle cardTitle = const TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.onBackground,
  );

  static TextStyle cardSubtitle = const TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: AppColors.hint,
  );
}
