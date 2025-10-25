class AppConstants {

  //URL de base de l'API Spring Boot
  static const String apiBaseUrl = 'http://10.0.2.2:8080/api'; // Pour émulateur Android
  // Pour iOS ou appareil physique, utilisez l'IP de votre machine
  // static const String apiBaseUrl = 'http://VOTRE_IP:8080/api';
  
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
