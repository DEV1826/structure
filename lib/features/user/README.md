# Module Utilisateur

Ce module gère la partie utilisateur de l'application, permettant aux visiteurs de consulter les structures, les services et d'effectuer des paiements sans authentification obligatoire.

## Fonctionnalités

- Consultation de la liste des structures
- Affichage détaillé d'une structure et de ses services
- Sélection de services
- Paiement en ligne sécurisé
- Génération de reçus de paiement

## Structure des dossiers

```
lib/features/user/
├── models/                 # Modèles de données
│   ├── service_model.dart
│   ├── structure_model.dart
│   ├── transaction_model.dart
│   └── models.dart         # Fichier d'export des modèles
├── screens/                # Écrans de l'application
│   ├── home_screen.dart    # Écran d'accueil avec la liste des structures
│   ├── structure_detail_screen.dart  # Détail d'une structure
│   ├── payment_screen.dart           # Écran de paiement
│   └── payment_success_screen.dart   # Confirmation de paiement
├── widgets/                # Widgets réutilisables
│   ├── payment_form.dart   # Formulaire de paiement
│   ├── receipt_widget.dart # Affichage du reçu
│   ├── service_item.dart   # Affichage d'un service
│   └── structure_card.dart # Carte de structure pour les listes
├── navigation/             # Gestion de la navigation
│   └── user_router.dart    # Configuration des routes
├── utils/                  # Utilitaires
└── user_exports.dart       # Fichier d'export global
```

## Navigation

La navigation est gérée par `UserRouter` qui utilise `go_router` pour une navigation déclarative. Voici les routes disponibles :

- `/` : Écran d'accueil (liste des structures)
- `/structure/:id` : Détail d'une structure
- `/payment` : Écran de paiement
- `/payment/success` : Confirmation de paiement

### Méthodes utilitaires

Utilisez les méthodes statiques de `UserRouter` pour naviguer :

```dart
// Navigation vers l'accueil
UserRouter.goToHome(context);

// Navigation vers le détail d'une structure
UserRouter.goToStructureDetail(context, 'structure-id');

// Navigation vers l'écran de paiement
UserRouter.goToPayment(
  context,
  structure: structure,
  service: service,
);

// Navigation vers la page de succès
UserRouter.goToPaymentSuccess(
  context,
  transactionId: 'txn-123',
  structure: structure,
  service: service,
  customerName: 'John Doe',
  customerPhone: '0123456789',
  paymentDate: DateTime.now(),
);
```

## Modèles de données

### StructureModel
Représente une structure avec ses informations et services.

### ServiceModel
Représente un service proposé par une structure.

### TransactionModel
Représente une transaction de paiement.

## Widgets réutilisables

### StructureCard
Affiche une prévisualisation d'une structure dans une liste.

### ServiceItem
Affiche les détails d'un service avec un bouton de sélection.

### PaymentForm
Formulaire de paiement avec validation.

### ReceiptWidget
Affiche un reçu de paiement avec les détails de la transaction.

## Intégration avec le reste de l'application

1. Ajoutez le `UserRouter.router` à votre `MaterialApp.router` :

```dart
MaterialApp.router(
  title: 'Structure Mobile',
  routerConfig: UserRouter.router,
  // ... autres configurations
)
```

2. Importez les modèles et écrans nécessaires depuis `user_exports.dart`.

## Personnalisation

### Thème
Les couleurs, espacements et autres propriétés visuelles peuvent être personnalisés dans `AppConstants`.

### Traductions
Les textes sont directement inclus dans les widgets. Pour une application multilingue, envisagez d'utiliser `flutter_localizations` et d'extraire les chaînes de caractères.

## Prochaines étapes

- [ ] Implémenter la sauvegarde locale des transactions
- [ ] Ajouter la fonctionnalité de partage de reçu
- [ ] Implémenter la recherche avancée de structures
- [ ] Ajouter des filtres par catégorie de service
- [ ] Intégrer un véritable système de paiement en ligne
