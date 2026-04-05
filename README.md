# Structure Project - Guide de Démarrage 🚀

Ce document explique comment configurer et lancer les deux parties de l'application : le **Backend** (Serveur Spring Boot Java) et le **Frontend** (Application Mobile Flutter).

---

## 🛠️ Prérequis
Avant de commencer, assurez-vous d'avoir installé sur votre machine :
- **Java JDK** (17 ou 21 recommandé)
- **MySQL** ou **MariaDB** (actif en local)
- **IntelliJ IDEA** (pour le backend)
- **Flutter SDK** avec Android Studio ou VS Code (pour le frontend)
- **Un appareil de test** (Téléphone physique Android branché en USB ou un Émulateur Android)

---

## ⚙️ Partie 1 : Lancer le Serveur Backend (Java / Spring Boot)

1. **Ouvrir le projet** : Ouvrez le dossier `structure-backend` dans IntelliJ IDEA.
2. **Configurer la base de données MySQL** :
   - Assurez-vous que votre service MySQL tourne en local (sur le port 3306).
   - Créez une base de données vierge nommée `structure` (`CREATE DATABASE structure;`).
   - Vérifiez vos identifiants dans le fichier `src/main/resources/application.properties` :
     ```properties
     spring.datasource.username=root
     spring.datasource.password=
     ```
3. **Mettre à jour le code** (Important après chaque grande modification) :
   - Allez dans la barre du haut d'IntelliJ, et cliquez sur **Build > Rebuild Project**.
4. **Lancer le serveur** :
   - Cliquez sur le bouton ▶️ Play vert en haut à droite, ou exécutez `StructureBackendApplication.java`.
   - Le serveur démarrera sur l'adresse `http://localhost:8081` (ou votre IP) 🟢.

---

## 📱 Partie 2 : Lancer l'Application Mobile (Flutter)

1. **Ouvrir le projet** : Ouvrez le dossier `structure-main` dans VS Code ou Android Studio.
2. **Configurer l'IP de connexion** :
   - L'application sur votre téléphone **ne peut pas** utiliser `localhost` pour parler au serveur de votre ordinateur (ils sont sur deux mondes virtuels différents).
   - Ouvrez le fichier `lib/core/constants/app_constants.dart`.
   - Modifiez `apiBaseUrl` pour y mettre l'adresse IP Wi-Fi de votre ordinateur. Par exemple :
     ```dart
     static const String apiBaseUrl = 'http://10.79.135.238:8081/api';
     ```
   - *(Pour trouver votre IP : tapez `ipconfig` dans le cmd Windows et prenez l'IPv4).*
3. **Installer les dépendances** :
   - Ouvrez le terminal dans le dossier du projet Flutter et tapez :
     ```bash
     flutter pub get
     ```
4. **Exécuter l'application** :
   - Branchez votre téléphone ou allumez l'émulateur.
   - Si vous êtes sur un téléphone physique, **acceptez la demande "Autoriser l'installation via USB"** ⚠️ qui apparaîtra sur votre écran de smartphone !
   - Lancez la commande suivante (ou utilisez le bouton "Run" de VS Code) :
     ```bash
     flutter run
     ```

---

## ✅ Tester la connexion
Une bonne manière de vérifier si tout dialogue bien :
1. Sur l'application, naviguez vers la page de **Paiement** ou connectez-vous.
2. Appuyez sur le bouton **Tester la connexion**. Un message vert de succès ("Connecté au serveur avec succès") s'affichera si le Flutter arrive correctement à dialoguer avec le backend Java.

---

## 🌟 Fonctionnalités & Comment les utiliser

L'application est divisée en 3 grands rôles. Selon la façon dont vous l'utilisez, vous accédez à des fonctionnalités distinctes :

### 1. 🧑‍🦱 Espace Public / Client (Sans connexion)
Ce rôle est l'interface par défaut au lancement de l'application (Guest).
- **Exploration :** Sur l'écran d'accueil, vous pouvez rechercher ou parcourir les *Structures* enregistrées sur le système.
- **Achats de Services :** Cliquez sur une structure pour voir ses détails, ses images et surtout ses services.
- **Paiement CamPost :** Sélectionnez vos services et initiez un paiement. *(Astuce de Dev : Si l'URL de test `demo.campost.cm` est configurée sur le Backend, l'étape de paiement simulera un chargement puis un "Succès" automatique au bout de 2 secondes pour tester le flux UI !)*

### 2. 🛡️ Espace Administrateur
*(Accès : Bouton compte en haut à droite -> **Administrateur**)*
Ce compte est assigné à **une seule** structure.
- **Tableau de Bord Privé :** L'admin possède un environnement réservé où il ne peut voir que les données appartenant à son entreprise.
- **Gestion de Profil :** Mise à jour persistante des informations du gestionnaire (Nom, Prénom, Téléphone, etc.).
- **Consultation :** Visualisation simplifiée des transactions ou données liées exclusivement à sa structure (grâce à l'isolation par `structureId`).

### 3. 👑 Espace Super-Administrateur
*(Accès : Bouton compte en haut à droite -> **Super Administrateur**)*
C'est le chef d'orchestre de la base de données.
- **Contrôle Global :** Accès à l'intégralité des structures et des administrateurs du système.
- **Création d'Entités :** Ajouter de toutes pièces des nouvelles *Structures* (avec photos, description et localisation).
- **Création d'Autrui :** Générer de nouveaux sous-comptes *Administrateurs* et les assigner directement à des structures spécifiques via des formulaires interactifs.

Bon code et bon développement ! 🎉
