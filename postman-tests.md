# 🧪 Tests Postman pour l'API Gares

## 📋 Configuration Postman

### Collection Postman
Créez une nouvelle collection nommée "API Gares Backend" avec les variables suivantes :

**Variables de collection :**
- `base_url` : `http://localhost:3000`
- `api_url` : `{{base_url}}/api`

## 🚀 Tests disponibles

### 1. Test de santé du serveur
```http
GET {{base_url}}/api/health
```

**Réponse attendue :**
```json
{
  "success": true,
  "message": "✅ Serveur opérationnel (Mode Test)",
  "timestamp": "2025-01-23T12:00:00.000Z",
  "environment": "test"
}
```

### 2. Récupérer toutes les gares
```http
GET {{api_url}}/gares
```

**Réponse attendue :**
```json
{
  "success": true,
  "message": "Gares récupérées avec succès (Mode Test)",
  "data": [
    {
      "id": 1,
      "nom": "Tanger",
      "ville": "Tanger",
      "latitude": 35.7801,
      "longitude": -5.8125,
      "telephone": "+212-539-001",
      "description": "Gare maritime moderne au nord du Maroc"
    },
    {
      "id": 2,
      "nom": "Rabat",
      "ville": "Rabat",
      "latitude": 34.0209,
      "longitude": -6.8416,
      "telephone": "+212-537-002",
      "description": "Capitale administrative du pays"
    },
    {
      "id": 3,
      "nom": "Casablanca",
      "ville": "Casablanca",
      "latitude": 33.5731,
      "longitude": -7.5898,
      "telephone": "+212-522-003",
      "description": "Plus grande ville économique du Maroc"
    }
  ],
  "count": 3
}
```

### 3. Récupérer une gare par ID
```http
GET {{api_url}}/gares/1
```

**Réponse attendue :**
```json
{
  "success": true,
  "message": "Gare récupérée avec succès",
  "data": {
    "id": 1,
    "nom": "Tanger",
    "ville": "Tanger",
    "latitude": 35.7801,
    "longitude": -5.8125,
    "telephone": "+212-539-001",
    "description": "Gare maritime moderne au nord du Maroc"
  }
}
```

### 4. Test d'erreur - Gare inexistante
```http
GET {{api_url}}/gares/999
```

**Réponse attendue :**
```json
{
  "success": false,
  "message": "Gare non trouvée"
}
```

### 5. Test de route inexistante
```http
GET {{api_url}}/inexistant
```

**Réponse attendue :**
```json
{
  "success": false,
  "message": "Route non trouvée",
  "path": "/api/inexistant"
}
```

## 📊 Tests automatisés

### Script de test pour Postman

Ajoutez ce script dans l'onglet "Tests" de chaque requête :

```javascript
// Test pour GET /api/gares
pm.test("Status code is 200", function () {
    pm.response.to.have.status(200);
});

pm.test("Response has success property", function () {
    var jsonData = pm.response.json();
    pm.expect(jsonData).to.have.property('success');
});

pm.test("Success is true", function () {
    var jsonData = pm.response.json();
    pm.expect(jsonData.success).to.eql(true);
});

pm.test("Response has data property", function () {
    var jsonData = pm.response.json();
    pm.expect(jsonData).to.have.property('data');
});

pm.test("Data is an array", function () {
    var jsonData = pm.response.json();
    pm.expect(jsonData.data).to.be.an('array');
});

pm.test("Count matches data length", function () {
    var jsonData = pm.response.json();
    pm.expect(jsonData.count).to.eql(jsonData.data.length);
});
```

## 🔧 Configuration pour le serveur complet

Une fois PostgreSQL configuré, remplacez `test-server.js` par `index.js` :

```bash
# Arrêter le serveur de test (Ctrl+C)
# Puis démarrer le serveur complet
npm run dev
```

### Tests supplémentaires pour le serveur complet

#### 6. Créer une nouvelle gare
```http
POST {{api_url}}/gares
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

#### 7. Mettre à jour une gare
```http
PUT {{api_url}}/gares/1
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

#### 8. Supprimer une gare
```http
DELETE {{api_url}}/gares/1
```

## 📋 Checklist de test

- [ ] Serveur démarre sans erreur
- [ ] Endpoint `/api/health` répond correctement
- [ ] Endpoint `/api/gares` retourne toutes les gares
- [ ] Endpoint `/api/gares/:id` retourne une gare spécifique
- [ ] Gestion des erreurs 404 fonctionne
- [ ] Réponses JSON sont valides
- [ ] CORS fonctionne (test depuis un navigateur)
- [ ] Variables d'environnement sont chargées

## 🚨 Dépannage

### Problème : Serveur ne démarre pas
**Solution :**
1. Vérifiez que le port 3000 est libre
2. Vérifiez que les dépendances sont installées : `npm install`
3. Vérifiez le fichier `.env`

### Problème : Erreur de connexion PostgreSQL
**Solution :**
1. Vérifiez que PostgreSQL est installé et en cours d'exécution
2. Vérifiez les informations de connexion dans `.env`
3. Créez la base de données : `CREATE DATABASE gares_db;`

### Problème : CORS
**Solution :**
1. Vérifiez que le middleware CORS est activé
2. Testez depuis Postman (pas de problème CORS)
3. Pour les tests navigateur, vérifiez les headers

## 📞 Support

Pour toute question ou problème avec les tests, consultez la documentation principale ou ouvrez une issue. 