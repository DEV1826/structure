import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Couleurs principales
  static const Color primaryColor = Color(0xFF2563EB); // Bleu vif
  static const Color secondaryColor = Color(0xFF1E40AF); // Bleu foncé
  static const Color accentColor = Color(0xFF3B82F6); // Bleu clair
  static const Color backgroundColor = Color(0xFFF8FAFC); // Gris très clair
  static const Color surfaceColor = Colors.white; // Blanc
  static const Color errorColor = Color(0xFFDC2626); // Rouge d'erreur
  static const Color successColor = Color(0xFF059669); // Vert de succès
  static const Color warningColor = Color(0xFFD97706); // Orange d'avertissement
  static const Color infoColor = Color(0xFF0284C7); // Bleu info

  // Texte
  static const Color textPrimary = Color(0xFF1F2937); // Gris très foncé
  static const Color textSecondary = Color(0xFF6B7280); // Gris moyen
  static const Color textTertiary = Color(0xFF9CA3AF); // Gris clair
  static const Color textOnPrimary = Colors.white; // Texte sur fond primaire

  // Bordures
  static const Color borderColor = Color(0xFFE5E7EB); // Gris très clair

  // Dégradés
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryColor, secondaryColor],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Ombres
  static final BoxShadow cardShadow = BoxShadow(
    color: Colors.black.withOpacity(0.05),
    blurRadius: 8,
    offset: const Offset(0, 2),
  );

  // Thème clair par défaut
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.light(
      primary: primaryColor,
      secondary: accentColor,
      surface: surfaceColor,
      background: backgroundColor,
      error: errorColor,
      onPrimary: textOnPrimary,
      onSecondary: textOnPrimary,
      onSurface: textPrimary,
      onBackground: textPrimary,
      onError: textOnPrimary,
      brightness: Brightness.light,
      // Add surfaceTint to avoid deprecation warning
      surfaceTint: surfaceColor,
      // Add surfaceVariant for better Material 3 support
      surfaceVariant: Colors.grey.shade100,
    ),

    // Typographie
    textTheme: GoogleFonts.poppinsTextTheme(
      const TextTheme(
        displayLarge: TextStyle(
          fontWeight: FontWeight.bold,
          color: textPrimary,
        ),
        displayMedium: TextStyle(
          fontWeight: FontWeight.bold,
          color: textPrimary,
        ),
        displaySmall: TextStyle(
          fontWeight: FontWeight.bold,
          color: textPrimary,
        ),
        headlineLarge: TextStyle(
          fontWeight: FontWeight.bold,
          color: textPrimary,
        ),
        headlineMedium: TextStyle(
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        headlineSmall: TextStyle(
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        titleLarge: TextStyle(fontWeight: FontWeight.w600, color: textPrimary),
        titleMedium: TextStyle(fontWeight: FontWeight.w500, color: textPrimary),
        titleSmall: TextStyle(fontWeight: FontWeight.w500, color: textPrimary),
        bodyLarge: TextStyle(color: textPrimary),
        bodyMedium: TextStyle(color: textPrimary),
        bodySmall: TextStyle(color: textSecondary),
        labelLarge: TextStyle(fontWeight: FontWeight.w500, color: textPrimary),
        labelMedium: TextStyle(color: textSecondary),
        labelSmall: TextStyle(color: textTertiary, fontSize: 12),
      ),
    ),

    // Boutons
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        // Add visualDensity for better touch targets
        visualDensity: VisualDensity.standard,
        // Add tapTargetSize for better touch targets
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    ),

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primaryColor,
        side: const BorderSide(color: primaryColor),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
      ),
    ),

    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: primaryColor,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        textStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 15),
      ),
    ),

    // Champs de formulaire
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surfaceColor, // Use surfaceColor instead of hardcoded white
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: borderColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: borderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: primaryColor, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: errorColor),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: errorColor, width: 1.5),
      ),
      labelStyle: TextStyle(
        color: textSecondary.withOpacity(0.9),
      ), // Use withAlpha for better precision
      hintStyle: TextStyle(
        color: textTertiary.withOpacity(0.9),
      ), // Use withAlpha for better precision
      errorStyle: const TextStyle(color: errorColor, fontSize: 12),
    ),

    // Cartes
    cardTheme: CardThemeData(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: borderColor, width: 1),
      ),
      color: surfaceColor,
      shadowColor: Colors.black.withOpacity(0.1),
      margin: const EdgeInsets.all(8),
      surfaceTintColor: surfaceColor,
      clipBehavior: Clip.antiAlias,  // Ensures smooth clipping of content to card borders
    ),

    // AppBar
    appBarTheme: AppBarTheme(
      backgroundColor: surfaceColor,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: const TextStyle(
        color: textPrimary,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
      iconTheme: const IconThemeData(color: textPrimary),
      surfaceTintColor: surfaceColor,
    ),

    // Bouton flottant
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
      elevation: 2,
    ),

    // Indicateur de progression
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: primaryColor,
    ),

    // SnackBar
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      contentTextStyle: const TextStyle(color: Colors.white),
    ),

    // Diviseurs
    dividerTheme: const DividerThemeData(
      color: borderColor,
      thickness: 1,
      space: 1,
    ),
  );

  // Méthodes utilitaires

  // Style de texte avec couleur principale
  static TextStyle primaryTextStyle({
    double? fontSize,
    FontWeight? fontWeight,
    double? height,
    TextDecoration? decoration,
  }) {
    return TextStyle(
      color: primaryColor,
      fontSize: fontSize,
      fontWeight: fontWeight,
      height: height,
      decoration: decoration,
    );
  }

  // Style de texte avec couleur secondaire
  static TextStyle secondaryTextStyle({
    double? fontSize,
    FontWeight? fontWeight,
    double? height,
    TextDecoration? decoration,
  }) {
    return TextStyle(
      color: textSecondary,
      fontSize: fontSize,
      fontWeight: fontWeight,
      height: height,
      decoration: decoration,
    );
  }

  // Style de texte avec couleur d'erreur
  static TextStyle errorTextStyle({
    double? fontSize,
    FontWeight? fontWeight,
    double? height,
  }) {
    return TextStyle(
      color: errorColor,
      fontSize: fontSize,
      fontWeight: fontWeight,
      height: height,
    );
  }

  // Style de texte avec couleur de succès
  static TextStyle successTextStyle({
    double? fontSize,
    FontWeight? fontWeight,
    double? height,
  }) {
    return TextStyle(
      color: successColor,
      fontSize: fontSize,
      fontWeight: fontWeight,
      height: height,
    );
  }

  // Style de carte avec ombre
  static BoxDecoration cardDecoration = BoxDecoration(
    color: surfaceColor,
    borderRadius: BorderRadius.circular(12),
    border: Border.all(color: borderColor, width: 1),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.05),
        blurRadius: 8,
        offset: const Offset(0, 2),
      ),
    ],
  );
}
