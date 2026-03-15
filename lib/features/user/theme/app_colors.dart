import 'package:flutter/material.dart';

/// A class that holds the color palette for the application.
class AppColors {
  // Primary colors
  static const Color primary = Color(0xFF4361EE);
  static const Color primaryDark = Color(0xFF3A56E8);
  static const Color primaryLight = Color(0xFFE7ECFF);
  
  // Secondary colors
  static const Color secondary = Color(0xFF3F37C9);
  static const Color secondaryDark = Color(0xFF3A0CA3);
  
  // Accent colors
  static const Color accent = Color(0xFF4CC9F0);
  static const Color accentLight = Color(0xFF90E0EF);
  
  // Status colors
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFF44336);
  static const Color warning = Color(0xFFFFC107);
  static const Color info = Color(0xFF2196F3);
  
  // Neutral colors
  static const Color background = Color(0xFFF8F9FA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color onSurface = Color(0xFF212121);
  static const Color onSurfaceLight = Color(0xFF757575);
  
  // Text colors
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textHint = Color(0xFF9E9E9E);
  static const Color textDisabled = Color(0xFFBDBDBD);
  
  // Border colors
  static const Color border = Color(0xFFE0E0E0);
  static const Color borderLight = Color(0xFFEEEEEE);
  
  // Background colors
  static const Color backgroundGrey = Color(0xFFF5F5F5);
  static const Color backgroundDark = Color(0xFF121212);
  
  // Social colors
  static const Color facebook = Color(0xFF3B5998);
  static const Color google = Color(0xFFDB4437);
  static const Color apple = Color(0xFF000000);
  
  // Gradient
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, primaryDark],
  );
  
  // Disabled
  static const Color disabled = Color(0xFFE0E0E0);
  static const Color onDisabled = Color(0xFF9E9E9E);
}
