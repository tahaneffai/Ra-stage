# 🚂 TrainSight - Fonctionnalités Temps Réel

## 📋 Vue d'ensemble

Le système TrainSight a été enrichi avec des fonctionnalités temps réel complètes utilisant **WebSocket** et **Socket.IO** pour offrir une expérience utilisateur dynamique et interactive.

## 🔌 Technologies Utilisées

- **Socket.IO** - Bibliothèque WebSocket pour la communication bidirectionnelle
- **Express.js** - Serveur HTTP avec support WebSocket
- **PostgreSQL** - Base de données pour les données des stations
- **JavaScript ES6+** - Code moderne et maintenable

## 🚀 Fonctionnalités Temps Réel

### 1. **Connexions WebSocket en Temps Réel**
- Connexions bidirectionnelles instantanées
- Gestion automatique des déconnexions/reconnexions
- Support multi-clients simultanés

### 2. **Mises à Jour Automatiques des Trains**
- Simulation réaliste des mouvements de trains
- Mises à jour toutes les 10 secondes
- Statuts dynamiques : en retard, à l'heure, en approche, etc.

### 3. **Notifications par Station**
- Abonnement aux mises à jour spécifiques à une station
- Informations en temps réel sur les trains arrivant/départant
- Données contextuelles (plateforme, retard, passagers)

### 4. **Suivi de Trains en Temps Réel**
- Suivi individuel de trains spécifiques
- Mises à jour de position et de statut
- Estimations d'arrivée dynamiques

### 5. **Système de Heartbeat**
- Vérification continue de la santé du système
- Notifications de statut opérationnel
- Détection automatique des problèmes

## 📡 API Endpoints Temps Réel

### **GET** `/api/realtime/status`
Récupère le statut du service temps réel.

**Réponse:**
```json
{
  "success": true,
  "message": "Real-time service status",
  "data": {
    "service": "realtime",
    "status": "active",
    "timestamp": "2025-08-24T19:30:00.000Z",
    "features": ["WebSocket connections", "Real-time train updates", ...],
    "endpoints": {
      "websocket": "/socket.io",
      "events": ["train-update", "station-updates", ...]
    }
  }
}
```

### **GET** `/api/realtime/connections`
Statistiques des connexions WebSocket actives.

### **GET** `/api/realtime/events`
Liste des événements temps réel disponibles.

### **POST** `/api/realtime/trigger-update`
Déclenche manuellement une mise à jour temps réel.

### **POST** `/api/realtime/broadcast`
Envoie un message de diffusion à tous les clients connectés.

### **POST** `/api/realtime/notify-station`
Envoie une notification à une station spécifique.

### **POST** `/api/realtime/notify-train`
Envoie une notification à un train spécifique.

## 🔌 Événements WebSocket

### **Événements Client → Serveur**

#### `join-station`
Rejoint une station pour recevoir ses mises à jour.
```javascript
socket.emit('join-station', stationId);
```

#### `leave-station`
Quitte une station.
```javascript
socket.emit('leave-station', stationId);
```

#### `track-train`
Commence le suivi d'un train spécifique.
```javascript
socket.emit('track-train', trainId);
```

#### `request-station-updates`
Demande des mises à jour pour une station.
```javascript
socket.emit('request-station-updates', stationId);
```

#### `request-train-status`
Demande le statut d'un train.
```javascript
socket.emit('request-train-status', trainId);
```

### **Événements Serveur → Client**

#### `train-update`
Mise à jour du statut d'un train.
```javascript
socket.on('train-update', (data) => {
  console.log('Train:', data.data.trainId, 'Status:', data.data.status);
});
```

#### `station-updates`
Mises à jour spécifiques à une station.
```javascript
socket.on('station-updates', (data) => {
  console.log('Station:', data.station.nom, 'Trains actifs:', data.activeTrains.length);
});
```

#### `train-status`
Statut détaillé d'un train spécifique.
```javascript
socket.on('train-status', (data) => {
  console.log('Train status:', data);
});
```

#### `system-update`
Mise à jour générale du système.
```javascript
socket.on('system-update', (data) => {
  console.log('Active trains:', data.data.activeTrains);
});
```

#### `system-heartbeat`
Vérification de santé du système.
```javascript
socket.on('system-heartbeat', (data) => {
  console.log('System status:', data.data.status);
});
```

## 🧪 Client de Test

Un client de test HTML complet est disponible à `/realtime-test.html` pour tester toutes les fonctionnalités temps réel.

### **Fonctionnalités du Client de Test:**
- Interface utilisateur intuitive et moderne
- Contrôles pour rejoindre/quitter des stations
- Suivi de trains en temps réel
- Affichage des mises à jour avec formatage
- Statistiques en temps réel
- Logs détaillés des événements

## 🔧 Configuration et Démarrage

### **1. Installation des Dépendances**
```bash
npm install socket.io
```

### **2. Démarrage du Serveur**
```bash
node index.js
```

### **3. Accès au Client de Test**
Ouvrez votre navigateur et allez à :
```
http://localhost:3000/realtime-test.html
```

### **4. Connexion WebSocket**
Le client se connecte automatiquement au serveur WebSocket via Socket.IO.

## 📊 Données Simulées

Le système génère automatiquement des données réalistes :

### **Statuts de Trains:**
- `on-time` - À l'heure
- `delayed` - En retard
- `arriving` - En approche
- `departing` - En départ
- `boarding` - En embarquement

### **Informations Simulées:**
- **Retards:** 0, 2, 5, 8, 12, 15 minutes
- **Plateformes:** 1 à 4
- **Passagers:** 50 à 250
- **Arrivées estimées:** 1 à 30 minutes

## 🚀 Cas d'Usage

### **1. Applications Mobiles**
- Notifications push en temps réel
- Mises à jour de statut instantanées
- Suivi de position des trains

### **2. Tableaux d'Affichage**
- Mises à jour automatiques des horaires
- Informations sur les retards
- Statut des plateformes

### **3. Sites Web Interactifs**
- Interface utilisateur dynamique
- Mises à jour sans rechargement
- Expérience utilisateur fluide

### **4. Systèmes de Gestion**
- Surveillance en temps réel
- Alertes automatiques
- Statistiques en direct

## 🔍 Dépannage

### **Problèmes Courants:**

1. **Connexion WebSocket échoue**
   - Vérifiez que le serveur est démarré
   - Vérifiez les paramètres CORS
   - Vérifiez les logs du serveur

2. **Pas de mises à jour reçues**
   - Vérifiez que vous avez rejoint une station
   - Vérifiez la connexion WebSocket
   - Vérifiez les logs du client

3. **Erreurs de base de données**
   - Vérifiez la connexion PostgreSQL
   - Vérifiez les permissions de base de données
   - Vérifiez les logs du serveur

### **Logs et Debugging:**
- Le serveur affiche tous les événements WebSocket
- Le client de test affiche les logs détaillés
- Utilisez les outils de développement du navigateur

## 🔮 Évolutions Futures

### **Fonctionnalités Planifiées:**
- Intégration GPS réelle des trains
- Notifications push pour les retards
- Historique des mouvements
- Prédictions d'arrivée basées sur l'IA
- Intégration avec d'autres systèmes de transport

### **Améliorations Techniques:**
- Clustering pour la haute disponibilité
- Base de données en temps réel
- API GraphQL pour les requêtes complexes
- Microservices pour la scalabilité

## 📚 Ressources

- **Documentation Socket.IO:** https://socket.io/docs/
- **Documentation Express.js:** https://expressjs.com/
- **Documentation PostgreSQL:** https://www.postgresql.org/docs/
- **Client de Test:** `/realtime-test.html`

---

🚂 **TrainSight** - Connectant le Maroc en temps réel ! 🇲🇦








