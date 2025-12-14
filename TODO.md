# 📝 TODO - Fonctionnalités Manquantes et Améliorations

**Date:** 13 Décembre 2025  
**Projet:** Structure Mobile App  

---

## 🔴 URGENT - Problèmes à Corriger

### 1. Mapping des Données Transaction (DTO)
**Statut:** ⚠️ **Partiellement fonctionnel**

**Problème:**  
Le `TransactionDto` ne mappe pas correctement tous les champs depuis l'entité `Transaction`, ce qui fait que certains champs sont `null` dans les reçus.

**Champs affectés:**
- `transactionDate` → affiche `null`
- `customerName` → affiche `null`
- `customerPhone` → affiche `null`
- `customerEmail` → affiche `null`
- `paymentMethod` → affiche `null`

**Solution:**
```java
// Dans TransactionDto.java
// Vérifier le mapper @Builder et ajouter tous les champs manquants
// Vérifier aussi la méthode fromEntity() pour mapper correctement
```

**Fichiers à modifier:**
- `structure_backend/src/main/java/com/NND/tech/Structure_Backend/DTO/TransactionDto.java`
- `structure_backend/src/main/java/com/NND/tech/Structure_Backend/Service/TransactionService.java`

---

### 2. Synchronisation des Adresses IP
**Statut:** ⚠️ **À faire manuellement à chaque changement de réseau**

**Problème:**  
L'adresse IP est codée en dur dans plusieurs fichiers Flutter. Si le réseau WiFi change, il faut modifier manuellement tous les fichiers.

**Fichiers concernés:**
- `lib/core/network/api_service.dart`
- `lib/core/services/receipt_service.dart`
- `lib/features/auth/providers/auth_provider.dart`
- `lib/features/admin/widgets/payments_tab.dart`
- `lib/features/payment/screens/payment_success_screen.dart`

**Solution recommandée:**
```dart
// Créer un fichier de configuration centralisé
// lib/core/config/app_config.dart

class AppConfig {
  // Modifier uniquement cette ligne lors du changement d'IP
  static const String baseUrl = 'http://10.111.71.137:8080';
  
  static String get apiUrl => '$baseUrl/api';
  static String receiptUrl(String reference) => '$baseUrl/api/transactions/receipt/$reference';
}
```

Ensuite, remplacer toutes les URL hardcodées par `AppConfig.apiUrl` ou `AppConfig.receiptUrl(reference)`.

---

## 🟡 IMPORTANT - Fonctionnalités Manquantes

### 3. Génération de Reçus PDF
**Statut:** ❌ **Non implémenté**

**Description:**  
Actuellement, les reçus sont générés en format texte simple (.txt). Il serait préférable d'avoir des reçus PDF professionnels avec logo, mise en forme, et QR code.

**À implémenter:**

**Backend:**
```xml
<!-- Ajouter dans pom.xml -->
<dependency>
    <groupId>com.itextpdf</groupId>
    <artifactId>itext7-core</artifactId>
    <version>8.0.2</version>
</dependency>
```

**Service à créer:**
```java
// PdfReceiptService.java
public class PdfReceiptService {
    public byte[] generatePdfReceipt(TransactionDto transaction) {
        // Utiliser iText7 pour créer un PDF professionnel
        // - En-tête avec logo de la structure
        // - Informations de transaction formatées
        // - QR code pour vérification
        // - Pied de page avec mentions légales
    }
}
```

**Endpoint à ajouter:**
```java
@GetMapping("/receipt/{reference}/pdf")
public ResponseEntity<byte[]> downloadPdfReceipt(@PathVariable String reference) {
    byte[] pdf = pdfReceiptService.generate(reference);
    headers.setContentType(MediaType.APPLICATION_PDF);
    headers.setContentDispositionFormData("attachment", "receipt_" + reference + ".pdf");
    return ResponseEntity.ok().headers(headers).body(pdf);
}
```

---

### 4. Envoi de Reçus par Email
**Statut:** ❌ **Non implémenté**

**Description:**  
Permettre aux utilisateurs de recevoir leur reçu directement par email après un paiement.

**À implémenter:**

**Configuration email (application.properties):**
```properties
spring.mail.host=smtp.gmail.com
spring.mail.port=587
spring.mail.username=votre.email@gmail.com
spring.mail.password=votre-mot-de-passe-app
spring.mail.properties.mail.smtp.auth=true
spring.mail.properties.mail.smtp.starttls.enable=true
```

**Service à créer:**
```java
// EmailService.java
@Service
public class EmailService {
    @Autowired
    private JavaMailSender mailSender;
    
    public void sendReceiptEmail(String toEmail, String reference, byte[] pdfReceipt) {
        MimeMessage message = mailSender.createMimeMessage();
        MimeMessageHelper helper = new MimeMessageHelper(message, true);
        
        helper.setTo(toEmail);
        helper.setSubject("Reçu de paiement - " + reference);
        helper.setText("Veuillez trouver ci-joint votre reçu de paiement.");
        helper.addAttachment("receipt_" + reference + ".pdf", new ByteArrayResource(pdfReceipt));
        
        mailSender.send(message);
    }
}
```

**Endpoint à ajouter:**
```java
@PostMapping("/receipt/{reference}/email")
public ResponseEntity<Void> emailReceipt(
    @PathVariable String reference,
    @RequestParam String email
) {
    emailService.sendReceipt(reference, email);
    return ResponseEntity.ok().build();
}
```

**Interface Flutter à ajouter:**
- Bouton "Envoyer par email" dans la page de détails de paiement
- Dialog pour saisir l'adresse email
- Message de confirmation d'envoi

---

### 5. Historique des Paiements Utilisateur
**Statut:** ❌ **Non implémenté**

**Description:**  
Les utilisateurs standards ne peuvent pas voir leur propre historique de transactions. Seuls les admins ont accès aux paiements.

**À implémenter:**

**Backend - Endpoint:**
```java
@GetMapping("/transactions/my-history")
public ResponseEntity<List<TransactionDto>> getMyTransactions(
    @RequestParam(required = false) LocalDate startDate,
    @RequestParam(required = false) LocalDate endDate
) {
    // Récupérer l'email de l'utilisateur depuis le JWT
    String userEmail = getCurrentUserEmail();
    
    // Filtrer les transactions par email client
    List<TransactionDto> transactions = transactionService
        .findByCustomerEmail(userEmail, startDate, endDate);
    
    return ResponseEntity.ok(transactions);
}
```

**Flutter - Page à créer:**
- `lib/features/user/screens/my_payments_screen.dart`
- Liste des paiements effectués par l'utilisateur
- Filtres par date
- Bouton pour télécharger chaque reçu
- Recherche par référence

---

### 6. Notifications Push
**Statut:** ❌ **Non implémenté**

**Description:**  
Envoyer des notifications aux utilisateurs lors d'événements importants.

**Événements à notifier:**
- ✅ Paiement confirmé
- ✅ Reçu disponible
- ✅ Nouveau service ajouté dans une structure favorite
- ✅ Promotion ou offre spéciale

**Technologies recommandées:**
- Firebase Cloud Messaging (FCM) pour Flutter
- Spring Boot avec Firebase Admin SDK pour le backend

**À implémenter:**

**Flutter - Configuration:**
```yaml
# pubspec.yaml
dependencies:
  firebase_core: ^2.24.0
  firebase_messaging: ^14.7.6
```

**Backend - Service:**
```java
@Service
public class NotificationService {
    public void sendPaymentConfirmation(String userToken, String reference) {
        // Utiliser Firebase Admin SDK
        Message message = Message.builder()
            .setToken(userToken)
            .setNotification(Notification.builder()
                .setTitle("Paiement confirmé")
                .setBody("Votre paiement " + reference + " a été confirmé")
                .build())
            .build();
        
        FirebaseMessaging.getInstance().send(message);
    }
}
```

---

### 7. Intégration CampostPay Complète
**Statut:** ⚠️ **Partiellement implémenté**

**Problème:**  
L'intégration CampostPay existe dans le code mais certaines fonctionnalités sont commentées ou non testées.

**Fonctionnalités manquantes:**
- ❌ Vérification automatique du statut de paiement
- ❌ Webhooks pour recevoir les confirmations de paiement
- ❌ Gestion des remboursements
- ❌ Gestion des paiements échoués

**À compléter:**

**Webhook endpoint:**
```java
@PostMapping("/api/payments/campost/webhook")
public ResponseEntity<Void> handleCampostWebhook(
    @RequestBody CampostWebhookDto webhook,
    @RequestHeader("X-Campost-Signature") String signature
) {
    // Vérifier la signature
    if (!campostService.verifySignature(webhook, signature)) {
        return ResponseEntity.status(403).build();
    }
    
    // Traiter le webhook
    campostService.processWebhook(webhook);
    
    return ResponseEntity.ok().build();
}
```

**Service de vérification:**
```java
public void verifyPaymentStatus(String orderId) {
    // Actuellement commenté dans CampostPaymentService.java
    // À décommenter et tester
}
```

---

### 8. Recherche et Filtres Avancés
**Statut:** ❌ **Non implémenté**

**Description:**  
Ajouter des fonctionnalités de recherche et filtrage dans toute l'application.

**Fonctionnalités à ajouter:**

**Page Structures:**
- 🔍 Recherche par nom
- 🏷️ Filtrer par catégorie (Hôtel, Restaurant, École, etc.)
- 📍 Filtrer par localisation/ville
- ⭐ Trier par popularité/nombre de transactions

**Page Services:**
- 🔍 Recherche par nom ou description
- 💰 Filtrer par gamme de prix
- ⏰ Filtrer par durée
- 📊 Trier par prix, popularité, nouveauté

**Page Paiements (Admin):**
- 🔍 Recherche par référence ou nom client
- 📅 Filtrer par plage de dates
- 💳 Filtrer par méthode de paiement
- ✅ Filtrer par statut (confirmé, en attente, échoué)
- 💰 Filtrer par montant min/max

**Backend - Exemple d'endpoint:**
```java
@GetMapping("/structures/search")
public ResponseEntity<List<StructureDto>> searchStructures(
    @RequestParam(required = false) String query,
    @RequestParam(required = false) String category,
    @RequestParam(required = false) String city,
    @RequestParam(required = false) String sortBy
) {
    return ResponseEntity.ok(structureService.search(query, category, city, sortBy));
}
```

---

### 9. Tableau de Bord Statistiques
**Statut:** ⚠️ **Basique**

**Problème:**  
Le dashboard admin est très basique. Il manque des graphiques et statistiques détaillées.

**Statistiques à ajouter:**

**Pour SUPER_ADMIN:**
- 📊 Graphique d'évolution du chiffre d'affaires (par jour/mois)
- 📈 Nombre de transactions par structure
- 👥 Nombre d'utilisateurs actifs
- 🏆 Top 5 des structures par revenus
- 💰 Top 5 des services les plus vendus
- 📅 Comparaison mois par mois

**Pour ADMIN (par structure):**
- 📊 Revenus de la structure sur différentes périodes
- 📈 Évolution du nombre de transactions
- 🎯 Objectifs de vente vs réalisations
- 💳 Répartition par méthode de paiement
- 📅 Heures/jours de pointe

**Bibliothèques recommandées:**
```yaml
# Flutter - pubspec.yaml
dependencies:
  fl_chart: ^0.66.0  # Pour les graphiques
  syncfusion_flutter_charts: ^30.2.4  # Déjà présent
```

---

### 10. Mode Hors Ligne
**Statut:** ❌ **Non implémenté**

**Description:**  
L'application ne fonctionne pas du tout sans connexion Internet. Il faudrait permettre la consultation des données en mode hors ligne.

**Fonctionnalités hors ligne souhaitées:**
- 📱 Consultation des structures et services (en cache)
- 📄 Consultation de l'historique des paiements
- 📥 Téléchargement des reçus déjà générés
- 🔄 Synchronisation automatique lors du retour en ligne

**Technologies recommandées:**
```yaml
# pubspec.yaml
dependencies:
  sqflite: ^2.3.0  # Base de données locale
  connectivity_plus: ^5.0.2  # Détection de connexion
  cached_network_image: ^3.3.0  # Cache d'images
```

**À implémenter:**
```dart
// CacheService.dart
class CacheService {
  // Sauvegarder les structures localement
  Future<void> cacheStructures(List<Structure> structures);
  
  // Récupérer depuis le cache
  Future<List<Structure>> getCachedStructures();
  
  // Vérifier si les données sont à jour
  bool isCacheExpired();
  
  // Synchroniser quand connexion disponible
  Future<void> syncWhenOnline();
}
```

---

## 🟢 AMÉLIORATIONS - Nice to Have

### 11. Interface en Plusieurs Langues
**Statut:** ❌ **Non implémenté**

**Langues à supporter:**
- 🇫🇷 Français (actuel)
- 🇬🇧 Anglais
- 🇩🇪 Allemand (optionnel)

**À implémenter:**
```yaml
# pubspec.yaml
dependencies:
  flutter_localizations:
    sdk: flutter
  intl: ^0.18.1
```

**Fichiers de traduction à créer:**
- `lib/l10n/app_fr.arb` (Français)
- `lib/l10n/app_en.arb` (Anglais)

---

### 12. Système d'Évaluation et Avis
**Statut:** ❌ **Non implémenté**

**Description:**  
Permettre aux utilisateurs de noter et commenter les structures et services.

**Fonctionnalités:**
- ⭐ Notation 1-5 étoiles
- 💬 Commentaires textuels
- 🖼️ Photos jointes aux avis (optionnel)
- 👍 Signaler un avis inapproprié

**Base de données:**
```sql
CREATE TABLE reviews (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    structure_id BIGINT NOT NULL,
    service_id BIGINT,
    user_email VARCHAR(255) NOT NULL,
    rating INT NOT NULL CHECK (rating BETWEEN 1 AND 5),
    comment TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (structure_id) REFERENCES structures(id),
    FOREIGN KEY (service_id) REFERENCES services(id)
);
```

---

### 13. Programme de Fidélité
**Statut:** ❌ **Non implémenté**

**Description:**  
Récompenser les clients réguliers avec des points de fidélité.

**Système proposé:**
- 🎯 1 point = 1000 FCFA dépensés
- 🎁 10 points = 10% de réduction
- 🏆 Badges pour clients VIP
- 💝 Offres spéciales pour anniversaires

**Base de données:**
```sql
CREATE TABLE loyalty_points (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_email VARCHAR(255) NOT NULL,
    points INT DEFAULT 0,
    level VARCHAR(20) DEFAULT 'BRONZE', -- BRONZE, SILVER, GOLD, PLATINUM
    total_spent DECIMAL(10,2) DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY uk_loyalty_email (user_email)
);
```

---

### 14. Chat/Support Client
**Statut:** ❌ **Non implémenté**

**Description:**  
Système de messagerie entre clients et structures pour le support.

**Fonctionnalités:**
- 💬 Chat en temps réel
- 📎 Envoi de fichiers/images
- 🤖 Réponses automatiques FAQ
- 👨‍💼 Transfert vers un agent humain

**Technologies:**
- WebSocket pour le temps réel
- Firebase Firestore pour stocker les messages
- Firebase Cloud Functions pour les notifications

---

### 15. Gestion des Promotions
**Statut:** ❌ **Non implémenté**

**Description:**  
Permettre aux structures de créer des promotions et codes promo.

**Types de promotions:**
- 💰 Réduction en pourcentage (ex: -20%)
- 💵 Réduction fixe (ex: -5000 FCFA)
- 🎁 Offre groupée (ex: 2 pour le prix de 1)
- 🆓 Service gratuit à partir d'un certain montant
- 📅 Offres limitées dans le temps

**Base de données:**
```sql
CREATE TABLE promotions (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    code VARCHAR(50) UNIQUE NOT NULL,
    structure_id BIGINT NOT NULL,
    service_id BIGINT,
    discount_type ENUM('PERCENTAGE', 'FIXED') NOT NULL,
    discount_value DECIMAL(10,2) NOT NULL,
    min_purchase DECIMAL(10,2),
    max_uses INT,
    current_uses INT DEFAULT 0,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    active BOOLEAN DEFAULT TRUE,
    FOREIGN KEY (structure_id) REFERENCES structures(id),
    FOREIGN KEY (service_id) REFERENCES services(id)
);
```

---

### 16. Export de Rapports
**Statut:** ❌ **Non implémenté**

**Description:**  
Permettre aux admins d'exporter des rapports comptables.

**Formats d'export:**
- 📄 PDF (rapport formaté)
- 📊 Excel/CSV (pour analyse)
- 📧 Envoi automatique par email (rapport mensuel)

**Types de rapports:**
- 📈 Rapport de ventes mensuel
- 💰 Rapport comptable annuel
- 📊 Rapport par service
- 👥 Rapport par utilisateur/client
- 📅 Rapport personnalisé par période

---

### 17. Paiement Récurrent/Abonnement
**Statut:** ❌ **Non implémenté**

**Description:**  
Pour les services d'abonnement (loyer, abonnement salle de sport, etc.)

**Fonctionnalités:**
- 🔄 Paiement automatique mensuel/annuel
- 💳 Enregistrement de carte bancaire
- 📅 Rappel avant échéance
- ⏸️ Suspension/Annulation d'abonnement
- 📊 Historique des paiements récurrents

---

### 18. Authentification Biométrique
**Statut:** ❌ **Non implémenté**

**Description:**  
Connexion rapide avec empreinte digitale ou reconnaissance faciale.

**À implémenter:**
```yaml
# pubspec.yaml
dependencies:
  local_auth: ^2.1.7
```

```dart
// Exemple d'utilisation
Future<bool> authenticateWithBiometrics() async {
  final LocalAuthentication auth = LocalAuthentication();
  
  try {
    return await auth.authenticate(
      localizedReason: 'Veuillez vous authentifier pour accéder à l\'application',
      options: const AuthenticationOptions(
        biometricOnly: true,
        stickyAuth: true,
      ),
    );
  } catch (e) {
    return false;
  }
}
```

---

### 19. Partage de Reçu sur Réseaux Sociaux
**Statut:** ❌ **Non implémenté**

**Description:**  
Permettre aux utilisateurs de partager leurs reçus/preuves de paiement.

**Plateformes:**
- 📱 WhatsApp
- 📧 Email
- 📲 SMS
- 🔗 Copier le lien

**À implémenter:**
```yaml
# pubspec.yaml
dependencies:
  share_plus: ^7.2.1
```

---

### 20. Optimisation des Performances
**Statut:** ⚠️ **À améliorer**

**Problèmes potentiels:**
- 📱 Chargement lent des listes de structures
- 🖼️ Images non optimisées/mises en cache
- 🔄 Pas de pagination des transactions
- 💾 Pas de lazy loading

**Optimisations à faire:**

**Backend:**
- Implémenter la pagination
```java
@GetMapping("/transactions")
public ResponseEntity<Page<TransactionDto>> getTransactions(
    @RequestParam(defaultValue = "0") int page,
    @RequestParam(defaultValue = "20") int size
) {
    Pageable pageable = PageRequest.of(page, size, Sort.by("transactionDate").descending());
    return ResponseEntity.ok(transactionService.findAll(pageable));
}
```

**Flutter:**
- Lazy loading des listes
- Mise en cache des images
- Optimisation des requêtes réseau

---

## 📊 Résumé des Priorités

### 🔴 Priorité HAUTE (à faire en premier)
1. ✅ Corriger le mapping TransactionDto
2. ✅ Créer un fichier de configuration centralisé pour les IPs
3. ✅ Implémenter la génération de reçus PDF

### 🟡 Priorité MOYENNE (important mais pas urgent)
4. Envoi de reçus par email
5. Historique des paiements utilisateur
6. Notifications push
7. Finaliser l'intégration CampostPay

### 🟢 Priorité BASSE (améliorations futures)
8. Recherche et filtres avancés
9. Dashboard avec statistiques détaillées
10. Mode hors ligne
11. Système d'évaluation
12. Programme de fidélité

---

**Dernière mise à jour:** 13 Décembre 2025  
**Par:** Équipe de développement Structure Mobile
