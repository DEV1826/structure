/// Fichier contenant toutes les chaînes de caractères de l'application
/// pour la partie utilisateur, afin de faciliter la traduction et la maintenance.

class AppStrings {
  // Général
  static const String appName = 'Structure Mobile';
  static const String loading = 'Chargement...';
  static const String retry = 'Réessayer';
  static const String cancel = 'Annuler';
  static const String confirm = 'Confirmer';
  static const String back = 'Retour';
  static const String next = 'Suivant';
  static const String save = 'Enregistrer';
  static const String search = 'Rechercher...';
  static const String noResults = 'Aucun résultat trouvé';
  static const String errorOccurred = 'Une erreur est survenue';
  
  // Écran d'accueil
  static const String homeTitle = 'Structures';
  static const String featuredStructures = 'Structures en vedette';
  static const String allStructures = 'Toutes les structures';
  static const String viewAll = 'Voir tout';
  
  // Détail d'une structure
  static const String structureDetails = 'Détails de la structure';
  static const String contactInfo = 'Coordonnées';
  static const String address = 'Adresse';
  static const String phone = 'Téléphone';
  static const String email = 'Email';
  static const String website = 'Site web';
  static const String services = 'Services';
  static const String selectService = 'Sélectionner un service';
  static const String noServicesAvailable = 'Aucun service disponible pour le moment';
  static const String seeOnMap = 'Voir sur la carte';
  static const String callNow = 'Appeler maintenant';
  static const String sendEmail = 'Envoyer un email';
  static const String visitWebsite = 'Visiter le site web';
  
  // Services
  static const String serviceDetails = 'Détails du service';
  static const String price = 'Prix';
  static const String duration = 'Durée';
  static const String description = 'Description';
  static const String select = 'Sélectionner';
  static const String selected = 'Sélectionné';
  
  // Paiement
  static const String payment = 'Paiement';
  static const String paymentMethod = 'Méthode de paiement';
  static const String cardPayment = 'Carte bancaire';
  static const String mobileMoney = 'Mobile Money';
  static const String cash = 'Espèces';
  static const String otherPayment = 'Autre méthode';
  static const String cardNumber = 'Numéro de carte';
  static const String cardHolderName = 'Titulaire de la carte';
  static const String expiryDate = 'Date d\'expiration';
  static const String cvv = 'CVV';
  static const String payNow = 'Payer maintenant';
  static const String securePayment = 'Paiement sécurisé';
  static const String paymentConfirmation = 'Confirmation de paiement';
  static const String paymentSuccess = 'Paiement effectué avec succès !';
  static const String paymentFailed = 'Échec du paiement';
  static const String paymentProcessing = 'Traitement du paiement...';
  static const String paymentDetails = 'Détails du paiement';
  static const String transactionId = 'Référence de transaction';
  static const String transactionDate = 'Date de la transaction';
  static const String amount = 'Montant';
  static const String processingFee = 'Frais de traitement';
  static const String totalAmount = 'Montant total';
  static const String enterPhoneNumber = 'Entrez votre numéro de téléphone';
  static const String phoneNumber = 'Numéro de téléphone';
  static const String fullName = 'Nom complet';
  static const String enterFullName = 'Entrez votre nom complet';
  
  // Reçu
  static const String receipt = 'Reçu';
  static const String downloadReceipt = 'Télécharger le reçu';
  static const String shareReceipt = 'Partager le reçu';
  static const String receiptSaved = 'Reçu enregistré avec succès';
  static const String receiptError = 'Erreur lors de la génération du reçu';
  static const String receiptDetails = 'Détails du reçu';
  static const String clientInfo = 'Informations client';
  static const String serviceInfo = 'Informations sur le service';
  static const String paymentInfo = 'Informations de paiement';
  static const String thankYou = 'Merci pour votre confiance !';
  
  // Validation
  static const String fieldRequired = 'Ce champ est requis';
  static const String invalidEmail = 'Adresse email invalide';
  static const String invalidPhone = 'Numéro de téléphone invalide';
  static const String invalidCardNumber = 'Numéro de carte invalide';
  static const String invalidExpiryDate = 'Date d\'expiration invalide';
  static const String invalidCvv = 'Code de sécurité invalide';
  
  // Messages d'erreur
  static const String networkError = 'Erreur de connexion. Veuillez vérifier votre connexion internet.';
  static const String serverError = 'Erreur du serveur. Veuillez réessayer plus tard.';
  static const String unexpectedError = 'Une erreur inattendue est survenue.';
  static const String tryAgain = 'Réessayer';
  
  // Messages de succès
  static const String operationSuccessful = 'Opération effectuée avec succès';
  static const String paymentSuccessful = 'Paiement effectué avec succès';
  
  // Boutons
  static const String continueButton = 'Continuer';
  static const String confirmButton = 'Confirmer';
  static const String backToHome = 'Retour à l\'accueil';
  static const String viewReceipt = 'Voir le reçu';
  
  // Filtres
  static const String filter = 'Filtrer';
  static const String sortBy = 'Trier par';
  static const String priceLowToHigh = 'Prix croissant';
  static const String priceHighToLow = 'Prix décroissant';
  static const String nameAZ = 'Nom (A-Z)';
  static const String nameZA = 'Nom (Z-A)';
  static const String resetFilters = 'Réinitialiser les filtres';
  
  // Placeholders
  static const String searchStructures = 'Rechercher des structures...';
  static const String searchServices = 'Rechercher des services...';
  static const String noDescriptionAvailable = 'Aucune description disponible';
  
  // Format de date
  static String formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
           '${date.month.toString().padLeft(2, '0')}/'
           '${date.year} ${date.hour.toString().padLeft(2, '0')}:'
           '${date.minute.toString().padLeft(2, '0')}';
  }
  
  // Format de prix
  static String formatPrice(double price) {
    return '${price.toStringAsFixed(0)} FCFA';
  }
  
  // Format de durée
  static String formatDuration(int minutes) {
    if (minutes < 60) {
      return '$minutes min';
    } else {
      final hours = minutes ~/ 60;
      final remainingMinutes = minutes % 60;
      if (remainingMinutes == 0) {
        return '$hours h';
      } else {
        return '$hours h ${remainingMinutes}min';
      }
    }
  }
}
