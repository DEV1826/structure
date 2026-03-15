import 'package:flutter/material.dart';

/// Classe de thème principal de l'application
/// Définit les couleurs, les styles de texte et les thèmes clair/sombre
class AppTheme {
  // Couleurs principales
  static const Color primaryColor = Color(0xFF1976D2); // Bleu vif
  static const Color secondaryColor = Color(0xFF42A5F5); // Bleu clair
  static const Color accentColor = Color(0xFF0D47A1); // Bleu foncé
  static const Color backgroundColor = Colors.white;
  static const Color surfaceColor = Color(0xFFF5F5F5); // Gris très clair
  static const Color errorColor = Color(0xFFD32F2F); // Rouge pour les erreurs
  static const Color textPrimary = Color(0xFF212121); // Noir pour le texte principal
  static const Color textSecondary = Color(0xFF757575); // Gris pour le texte secondaire

  // Thème clair
  static ThemeData lightTheme = ThemeData(
    useMaterial3: false, // Désactivé temporairement pour compatibilité
    colorScheme: const ColorScheme.light(
      primary: primaryColor,
      secondary: secondaryColor,
      background: backgroundColor,
      surface: surfaceColor,
      error: errorColor,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onBackground: textPrimary,
      onSurface: textPrimary,
      onError: Colors.white,
      brightness: Brightness.light,
    ),
    scaffoldBackgroundColor: backgroundColor,
    appBarTheme: const AppBarTheme(
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 2,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: primaryColor,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primaryColor,
        side: const BorderSide(color: primaryColor),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.all(16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: primaryColor, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: errorColor),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: errorColor, width: 2),
      ),
      labelStyle: const TextStyle(color: textSecondary),
      hintStyle: const TextStyle(color: Color(0xFF9E9E9E)),
    ),
    cardTheme: ThemeData().cardTheme.copyWith(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      margin: const EdgeInsets.all(8),
    ),
    dividerTheme: const DividerThemeData(
      color: Color(0xFFE0E0E0),
      thickness: 1,
      space: 1,
    ),
  );

  /// Thème sombre de l'application
  /// Actuellement en version bêta - à compléter avec les spécifications de design
  static ThemeData darkTheme = ThemeData.dark().copyWith(
    colorScheme: const ColorScheme.dark().copyWith(
      primary: primaryColor,
      secondary: secondaryColor,
      background: Color(0xFF121212),
      surface: Color(0xFF1E1E1E),
      error: Color(0xFFCF6679),
      onPrimary: Colors.black,
      onSecondary: Colors.black,
      onBackground: Colors.white,
      onSurface: Colors.white,
      onError: Colors.black,
    ),
    // Personnalisations supplémentaires pour le thème sommet
  );

  // Styles de texte personnalisés
  static const TextStyle headline1 = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: textPrimary,
  );

  static const TextStyle headline2 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: textPrimary,
  );

  static const TextStyle subtitle1 = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: textPrimary,
  );

  static const TextStyle bodyText1 = TextStyle(
    fontSize: 14,
    color: textPrimary,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 12,
    color: textSecondary,
  );

  // Espacements constants
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;
  static const double paddingXLarge = 32.0;

  // Rayons de bordure
  static const double borderRadiusSmall = 4.0;
  static const double borderRadiusMedium = 8.0;
  static const double borderRadiusLarge = 12.0;
}
