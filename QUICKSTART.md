# 🚀 DÉMARRAGE RAPIDE - Structure Mobile App

## 📋 Prérequis

- **Java 17** (pour le backend)
- **Maven** (pour le backend)
- **MySQL/MariaDB** (base de données)
- **Flutter SDK** (pour l'application mobile)
- **Android Studio** ou un appareil Android physique
- **Git**

---

## ⚙️ Configuration Initiale

### 1. Configuration de la Base de Données

```bash
# Se connecter à MySQL
sudo mysql

# Créer la base de données
CREATE DATABASE structure_backend CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

# Créer l'utilisateur
CREATE USER 'structure_app'@'localhost' IDENTIFIED BY 'MotDePasseSecurise123!';

# Accorder les permissions
GRANT SELECT, INSERT, UPDATE, DELETE, ALTER ON structure_backend.* TO 'structure_app'@'localhost';
FLUSH PRIVILEGES;

# Importer le schéma
USE structure_backend;
SOURCE /chemin/vers/structure_backend.sql;
```

### 2. Configuration de l'Adresse IP

#### a) Trouver l'adresse IP de votre ordinateur

```bash
# Sur Linux/Mac
ip addr show wlan0 | grep "inet " | awk '{print $2}' | cut -d'/' -f1

# Ou
ifconfig | grep "inet " | grep -v 127.0.0.1
```

**Exemple de résultat:** `10.111.71.137`

#### b) Mettre à jour le Backend

Éditer: `structure_backend/src/main/resources/application.properties`

```properties
# Aucun changement nécessaire - le backend écoute sur toutes les interfaces
server.address=0.0.0.0
server.port=8080
```

#### c) Mettre à jour le Frontend Flutter

Éditer: `structure/lib/core/network/api_service.dart`

```dart
static const String _baseUrl = 'http://VOTRE_IP:8080/api';
```

**Remplacer `VOTRE_IP` par l'IP trouvée à l'étape a)**

Éditer aussi dans:
- `structure/lib/core/services/receipt_service.dart`
- `structure/lib/features/auth/providers/auth_provider.dart`
- `structure/lib/features/admin/widgets/payments_tab.dart`
- `structure/lib/features/payment/screens/payment_success_screen.dart`

**Rechercher et remplacer toutes les occurrences:**
```bash
cd structure
grep -r "10\.111\.71\.137" lib/ --include="*.dart" | grep -v ".g.dart"
```

---

## 🚀 Démarrage du Projet

### 1. Démarrer le Backend

```bash
cd ~/Projects/Japhet
./start_backend.sh
```

**Le backend démarre sur:** `http://VOTRE_IP:8080`

**Vérifier que le backend fonctionne:**
```bash
curl http://VOTRE_IP:8080/api/transactions
```

### 2. Démarrer l'Application Flutter

#### a) Connecter votre appareil Android

- Activer le **Mode Développeur** sur votre téléphone
- Activer le **Débogage USB**
- Connecter le téléphone à l'ordinateur via USB
- **Important:** Le téléphone et l'ordinateur doivent être sur le même réseau WiFi

#### b) Vérifier les appareils disponibles

```bash
cd ~/Projects/Japhet/structure
flutter devices
```

**Résultat attendu:**
```
Pixel 3 (mobile) • 94CX1Z414 • android-arm64 • Android 12 (API 31)
```

#### c) Lancer l'application

```bash
# Remplacer 94CX1Z414 par l'ID de votre appareil
flutter run -d 94CX1Z414
```

**Ou si l'application est déjà en cours d'exécution:**
```
R (Redémarrage à chaud)
r (Rechargement à chaud)
```

---

## 🔐 Connexion à l'Application

### Compte Administrateur

- **Email:** `admin@example.com`
- **Mot de passe:** `admin123`
- **Rôle:** SUPER_ADMIN

---

## 🧪 Tests

### Test du Backend

```bash
# Test de connexion
curl -X POST http://VOTRE_IP:8080/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"admin@example.com","password":"admin123"}'

# Test de téléchargement de reçu
curl http://VOTRE_IP:8080/api/transactions/receipt/TEST001
```

### Test de l'Application Flutter

1. Ouvrir l'application sur votre téléphone
2. Cliquer sur "Se connecter"
3. Entrer les identifiants admin
4. Naviguer vers "Paiements"
5. Cliquer sur "Télécharger le reçu"

---

## 🛠️ Résolution des Problèmes Courants

### Backend ne démarre pas

```bash
# Vérifier si le port 8080 est déjà utilisé
netstat -tlnp | grep 8080

# Tuer le processus existant
kill <PID>

# Redémarrer
cd ~/Projects/Japhet
./start_backend.sh
```

### Application Flutter ne se connecte pas

1. **Vérifier que le téléphone et l'ordinateur sont sur le même WiFi**
2. **Vérifier l'adresse IP dans les fichiers Flutter**
3. **Redémarrer l'application (appuyer sur R)**
4. **Vérifier que le backend fonctionne:**
   ```bash
   curl http://VOTRE_IP:8080/api/transactions
   ```

### Erreur "JWT signature does not match"

**Solution:** Effacer les données de l'application

1. **Option 1:** Sur le téléphone: Paramètres → Apps → Structure Mobile → Stockage → Effacer les données
2. **Option 2:** Dans Flutter, appuyer sur `R` pour redémarrer
3. **Se reconnecter à l'application**

### Erreur de compilation Flutter

```bash
cd ~/Projects/Japhet/structure
flutter clean
flutter pub get
flutter run -d 94CX1Z414
```

---

## 📱 Fonctionnalités Disponibles

✅ **Authentification** - Connexion avec JWT  
✅ **Dashboard Admin** - Vue d'ensemble des transactions  
✅ **Gestion des Structures** - CRUD des structures  
✅ **Gestion des Services** - CRUD des services  
✅ **Gestion des Paiements** - Visualisation des transactions  
✅ **Téléchargement de Reçus** - Génération et téléchargement de reçus  
✅ **Navigation** - Navigation fluide avec GoRouter  

---

## 📂 Structure du Projet

```
Japhet/
├── structure_backend/          # Backend Spring Boot
│   ├── src/
│   │   └── main/
│   │       ├── java/          # Code Java
│   │       └── resources/     # Configuration
│   └── pom.xml                # Dépendances Maven
│
├── structure/                  # Application Flutter
│   ├── lib/
│   │   ├── core/              # Services, réseau, routes
│   │   └── features/          # Fonctionnalités (auth, admin, etc.)
│   └── pubspec.yaml           # Dépendances Flutter
│
├── structure_backend.sql       # Schéma de base de données
├── start_backend.sh           # Script de démarrage backend
├── fix_database.sh            # Script de correction BD
└── QUICKSTART.md              # Ce fichier
```

---

## 🔧 Scripts Utiles

### Démarrer le Backend
```bash
cd ~/Projects/Japhet
./start_backend.sh
```

### Arrêter le Backend
```bash
ps aux | grep "[j]ava.*Structure" | awk '{print $2}' | xargs kill
```

### Corriger la Base de Données
```bash
cd ~/Projects/Japhet
./fix_database.sh
```

### Rebuild complet Backend
```bash
cd ~/Projects/Japhet/structure_backend
./mvnw clean package -DskipTests
./mvnw spring-boot:run
```

### Rebuild complet Flutter
```bash
cd ~/Projects/Japhet/structure
flutter clean
flutter pub get
flutter run -d 94CX1Z414
```

---

## 📞 Support

Pour toute question ou problème, vérifiez d'abord:

1. ✅ Le backend est démarré
2. ✅ Le téléphone et l'ordinateur sont sur le même WiFi
3. ✅ L'adresse IP est correctement configurée dans Flutter
4. ✅ Les logs du backend pour voir les erreurs:
   ```bash
   cd ~/Projects/Japhet/structure_backend
   tail -f application.log
   ```

---

## 🎯 Prochaines Étapes

Après le démarrage réussi:

1. **Tester toutes les fonctionnalités** de l'application
2. **Créer de nouvelles structures** et services
3. **Tester les paiements** et téléchargements de reçus
4. **Consulter le fichier TODO.md** pour les améliorations à venir

---

**Bonne utilisation ! 🚀**
