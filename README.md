# 📱 Structure Mobile - Application de Gestion

Application mobile Flutter avec backend Spring Boot pour la gestion de structures (hôtels, écoles, restaurants) et leurs services.

---

## 📚 Documentation

- **[QUICKSTART.md](QUICKSTART.md)** - Guide de démarrage rapide et configuration
- **[TODO.md](TODO.md)** - Liste des fonctionnalités manquantes et améliorations (en français)
- **[FINAL_STATUS.md](FINAL_STATUS.md)** - État actuel du système et tests

---

## 🚀 Démarrage Rapide

### 1. Configuration de la base de données
```bash
sudo mysql < structure_backend.sql
```

### 2. Démarrer le backend
```bash
./start_backend.sh
```

### 3. Lancer l'application Flutter
```bash
cd structure
flutter run -d <DEVICE_ID>
```

### 4. Se connecter
- **Email:** admin@example.com
- **Mot de passe:** admin123

---

## 🛠️ Technologies

**Backend:**
- Spring Boot 3.2.3
- MySQL/MariaDB
- JWT Authentication
- Maven

**Frontend:**
- Flutter 3.x
- Provider (state management)
- GoRouter (navigation)
- HTTP (API calls)

---

## ✨ Fonctionnalités

✅ Authentification JWT  
✅ Gestion des structures  
✅ Gestion des services  
✅ Gestion des transactions  
✅ Téléchargement de reçus  
✅ Dashboard administrateur  
✅ Navigation fluide  

---

## 📁 Structure du Projet

```
.
├── structure_backend/      # Backend Spring Boot
├── structure/              # Application Flutter
├── structure_backend.sql   # Schéma de base de données
├── start_backend.sh       # Script de démarrage
├── fix_database.sh        # Script de correction BD
└── README.md              # Ce fichier
```

---

## 🔧 Scripts Utiles

```bash
# Démarrer le backend
./start_backend.sh

# Corriger la base de données
./fix_database.sh

# Rebuild Flutter
cd structure && flutter clean && flutter pub get
```

---

## 📞 Support

Pour plus de détails, consultez les fichiers de documentation dans le dossier principal.

---

**Version:** 1.0.0  
**Dernière mise à jour:** 13 Décembre 2025
