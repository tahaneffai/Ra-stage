# 🚂 API Gares Backend

Backend Node.js avec Express.js et PostgreSQL pour gérer les gares du Maroc.

## 📋 Fonctionnalités

- ✅ **CRUD complet** pour les gares
- ✅ **Base de données PostgreSQL** avec table `gares`
- ✅ **API RESTful** avec endpoints standardisés
- ✅ **Validation des données** et gestion d'erreurs
- ✅ **CORS activé** pour les requêtes cross-origin
- ✅ **Variables d'environnement** pour la configuration
- ✅ **Logs détaillés** pour le debugging

## 🗄️ Structure de la base de données

### Table `gares`
| Colonne | Type | Description |
|---------|------|-------------|
| id | SERIAL PRIMARY KEY | Identifiant unique |
| nom | TEXT | Nom de la gare |
| ville | TEXT | Ville de la gare |
| latitude | DOUBLE PRECISION | Coordonnée latitude |
| longitude | DOUBLE PRECISION | Coordonnée longitude |
| telephone | TEXT | Numéro de téléphone |
| description | TEXT | Description de la gare |

### Données initiales
- **Tanger** : Gare maritime moderne au nord du Maroc
- **Rabat** : Capitale administrative du pays
- **Casablanca** : Plus grande ville économique du Maroc

## 🚀 Installation

### Prérequis
- Node.js (version 14 ou supérieure)
- PostgreSQL (version 12 ou supérieure)
- npm ou yarn

### Étapes d'installation

1. **Cloner le projet**
   ```bash
   git clone <repository-url>
   cd gares-backend
   ```

2. **Installer les dépendances**
   ```bash
   npm install
   ```

3. **Configurer la base de données PostgreSQL**
   ```sql
   CREATE DATABASE gares_db;
   ```

4. **Configurer les variables d'environnement**
   ```bash
   cp env.example .env
   ```
   
   Modifier le fichier `.env` avec vos informations :
   ```env
   DB_HOST=localhost
   DB_PORT=5432
   DB_USER=postgres
   DB_PASSWORD=votre_mot_de_passe
   DB_NAME=gares_db
   PORT=3000
   NODE_ENV=development
   ```

5. **Démarrer le serveur**
   ```bash
   # Mode développement (avec nodemon)
   npm run dev
   
   # Mode production
   npm start
   ```

## 📡 API Endpoints

### Base URL
```
http://localhost:3000/api
```

### Endpoints disponibles

#### 1. Récupérer toutes les gares
```http
GET /api/gares
```

**Réponse :**
```json
{
  "success": true,
  "message": "Gares récupérées avec succès",
  "data": [
    {
      "id": 1,
      "nom": "Tanger",
      "ville": "Tanger",
      "latitude": 35.7801,
      "longitude": -5.8125,
      "telephone": "+212-539-001",
      "description": "Gare maritime moderne au nord du Maroc"
    }
  ],
  "count": 3
}
```

#### 2. Récupérer une gare par ID
```http
GET /api/gares/:id
```

#### 3. Créer une nouvelle gare
```http
POST /api/gares
Content-Type: application/json

{
  "nom": "Marrakech",
  "ville": "Marrakech",
  "latitude": 31.6295,
  "longitude": -7.9811,
  "telephone": "+212-524-004",
  "description": "Ville touristique du sud"
}
```

#### 4. Mettre à jour une gare
```http
PUT /api/gares/:id
Content-Type: application/json

{
  "nom": "Tanger Ville",
  "ville": "Tanger",
  "latitude": 35.7801,
  "longitude": -5.8125,
  "telephone": "+212-539-001",
  "description": "Gare maritime moderne au nord du Maroc"
}
```

#### 5. Supprimer une gare
```http
DELETE /api/gares/:id
```

## 🧪 Tests avec Postman

### 1. Test de santé du serveur
```http
GET http://localhost:3000/api/health
```

### 2. Récupérer toutes les gares
```http
GET http://localhost:3000/api/gares
```

### 3. Créer une nouvelle gare
```http
POST http://localhost:3000/api/gares
Content-Type: application/json

{
  "nom": "Fès",
  "ville": "Fès",
  "latitude": 34.0181,
  "longitude": -5.0078,
  "telephone": "+212-535-005",
  "description": "Ville historique du Maroc"
}
```

## 📁 Structure du projet

```
gares-backend/
├── index.js              # Point d'entrée du serveur
├── db.js                 # Configuration PostgreSQL
├── package.json          # Dépendances et scripts
├── env.example           # Exemple de variables d'environnement
├── .env                  # Variables d'environnement (à créer)
├── README.md             # Documentation
└── routes/
    └── gares.js          # Routes pour les gares
```

## 🔧 Scripts disponibles

```bash
# Démarrer en mode développement
npm run dev

# Démarrer en mode production
npm start

# Tester l'application
npm test
```

## 🛠️ Technologies utilisées

- **Node.js** : Runtime JavaScript
- **Express.js** : Framework web
- **PostgreSQL** : Base de données
- **pg** : Client PostgreSQL pour Node.js
- **cors** : Middleware pour CORS
- **dotenv** : Gestion des variables d'environnement
- **nodemon** : Redémarrage automatique en développement

## 🚨 Gestion des erreurs

L'API retourne des réponses standardisées :

### Succès
```json
{
  "success": true,
  "message": "Opération réussie",
  "data": {...}
}
```

### Erreur
```json
{
  "success": false,
  "message": "Description de l'erreur",
  "error": "Détails techniques (en développement)"
}
```

## 📊 Codes de statut HTTP

- **200** : Succès
- **201** : Créé avec succès
- **400** : Requête invalide
- **404** : Ressource non trouvée
- **500** : Erreur interne du serveur

## 🔒 Sécurité

- Validation des données d'entrée
- Protection contre les injections SQL (paramètres préparés)
- Gestion des erreurs sans exposer d'informations sensibles
- CORS configuré pour les requêtes cross-origin

## 🚀 Déploiement

### Variables d'environnement de production
```env
NODE_ENV=production
PORT=3000
DB_HOST=your_db_host
DB_PORT=5432
DB_USER=your_db_user
DB_PASSWORD=your_db_password
DB_NAME=your_db_name
```

### Commandes de déploiement
```bash
# Installer les dépendances de production
npm install --production

# Démarrer le serveur
npm start
```

## 🤝 Contribution

1. Fork le projet
2. Créer une branche feature (`git checkout -b feature/AmazingFeature`)
3. Commit les changements (`git commit -m 'Add some AmazingFeature'`)
4. Push vers la branche (`git push origin feature/AmazingFeature`)
5. Ouvrir une Pull Request

## 📄 Licence

Ce projet est sous licence MIT. Voir le fichier `LICENSE` pour plus de détails.

## 📞 Support

Pour toute question ou problème, veuillez ouvrir une issue sur le repository. 