class AppConfig {
  // URLs de l'API
  static const String apiBaseUrl =
      'http://10.0.2.2/api/v1'; // Pour émulateur Android
  // static const String apiBaseUrl = 'http://VOTRE_IP/api/v1'; // Pour émulateur iOS ou appareil physique

  // Timeouts
  static const Duration apiTimeout = Duration(seconds: 30);

  // Chemins d'API
  static const String apiPaymentInit = '/payment/initiate.php';
  static const String apiPaymentVerify = '/payment/verify.php';
  static const String apiHealth = '/health.php';

  // Clés de stockage local
  static const String storageAuthToken = 'jwt_token';
  static const String storageLastOrderId = 'last_order_id';

  // Messages d'erreur
  static const String connectionError =
      'Impossible de se connecter au serveur. Vérifiez votre connexion internet.';
  static const String serverError =
      'Une erreur est survenue lors de la communication avec le serveur.';
  static const String unknownError = 'Une erreur inconnue est survenue.';

  // Configuration des requêtes
  static Map<String, String> get defaultHeaders => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  static Map<String, String> authHeaders(String token) => {
    ...defaultHeaders,
    'Authorization': 'Bearer $token',
  };
}
