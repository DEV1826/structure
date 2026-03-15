import 'package:flutter/material.dart';

class AppColors {
  // Primary colors
  static const Color primaryBlue = Color(0xFF1E88E5);
  static const Color primaryDark = Color(0xFF0D47A1);
  static const Color primaryLight = Color(0xFF90CAF9);
  
  // Accent colors
  static const Color accentBlue = Color(0xFF2962FF);
  static const Color accentLight = Color(0xFF82B1FF);
  
  // Text colors
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  
  // Background colors
  static const Color background = Color(0xFFFFFFFF);
  static const Color backgroundLight = Color(0xFFF5F5F5);
  
  // Status colors
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFF44336);
  static const Color warning = Color(0xFFFFC107);
  static const Color info = Color(0xFF2196F3);
  
  // UI colors
  static const Color divider = Color(0xFFE0E0E0);
  static const Color lightGrey = Color(0xFFF5F5F5);
  static const Color mediumGrey = Color(0xFF9E9E9E);
  static const Color darkGrey = Color(0xFF424242);
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  
  // Transparent
  static const Color transparent = Color(0x00000000);
  
  // Shadows
  static const List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Color(0x1F000000),
      blurRadius: 4,
      offset: Offset(0, 2),
    ),
  ];
  
  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryBlue, primaryDark],
  );

  static var lightBlue;
  
  // Opacity variants
  static Color withOpacity(Color color, double opacity) {
    return color.withOpacity(opacity);
  }
}
