import 'package:flutter/foundation.dart';

class AppConstants {

  // =========================================================
  // 🔧 CONFIGURATION — changer à true après déploiement Render
  // =========================================================
  static const bool _useProduction = false;

  // URL de production (Render) — remplacez par votre vraie URL après déploiement
  static const String _productionUrl = 'https://structure-backend.onrender.com/api';

  // URL de développement (Vérifiez avec 'ipconfig' sur Windows)
  // L'IP 10.79.135.238 semble être l'IP actuelle du Wi-Fi de votre PC
  static const String _devUrl = 'http://10.79.135.238:8081/api';

  // URL active selon l'environnement (détection automatique)
  static String get apiBaseUrl {
    if (_useProduction) return _productionUrl;
    
    // En développement
    if (kIsWeb) return 'http://localhost:8081/api';
    
    // NOTE : Si vous utilisez un ÉMULATEUR Android, utilisez 'http://10.0.2.2:8081/api'
    // Sur téléphone PHYSIQUE, utilisez votre IP locale (_devUrl)
    // Assurez-vous que votre serveur backend écoute sur 0.0.0.0 (pas seulement localhost)
    return _devUrl;
  }
  
  // Endpoints API
  static const String login = '/auth/login';
  static const String registerAdmin = '/auth/register-admin';
  // Ajoutez d'autres endpoints ici
  // Durées d'animation
  static const Duration defaultAnimationDuration = Duration(milliseconds: 300);
  static const Duration buttonPressAnimationDuration = Duration(milliseconds: 100);
  
  // Tailles d'espacement
  static const double smallPadding = 8.0;
  static const double mediumPadding = 16.0;
  static const double largePadding = 24.0;
  static const double extraLargePadding = 32.0;
  
  // Rayons de bordure
  static const double smallRadius = 4.0;
  static const double mediumRadius = 8.0;
  static const double largeRadius = 16.0;
  static const double extraLargeRadius = 24.0;
  
  // Hauteurs d'éléments
  static const double buttonHeight = 48.0;
  static const double inputFieldHeight = 56.0;
  static const double appBarHeight = 56.0;
  
  // Largeurs d'éléments
  static const double buttonMinWidth = 120.0;
  
  // Autres constantes
  static const int maxPhoneNumberLength = 10;
  static const int otpLength = 6;
}

class AppAssets {
  // Chemins des images statiques
  static const String logo = 'assets/images/logo.png';
  static const String placeholder = 'assets/images/placeholder.png';
  static const String errorImage = 'assets/images/error.png';
  
  // Chemins des icônes
  static const String homeIcon = 'assets/icons/home.png';
  static const String searchIcon = 'assets/icons/search.png';
  static const String historyIcon = 'assets/icons/history.png';
  static const String profileIcon = 'assets/icons/profile.png';
  static const String backIcon = 'assets/icons/back.png';
  static const String closeIcon = 'assets/icons/close.png';
  static const String menuIcon = 'assets/icons/menu.png';
}
