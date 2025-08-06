# 🗄️ **Database Setup Guide - TrainSight**

## 📋 **Prerequisites**

Before running the database initialization, make sure you have:

1. **PostgreSQL installed** and running on your system
2. **A database named "gares_db"** created
3. **Node.js and npm** installed
4. **All dependencies** installed (`npm install`)

## 🚀 **Step-by-Step Setup**

### **Step 1: Configure Environment Variables**

The `.env` file has been created from `env.example`. You need to update it with your PostgreSQL credentials:

```env
# Configuration PostgreSQL
DB_HOST=localhost
DB_PORT=5432
DB_USER=postgres
DB_PASSWORD=your_actual_password
DB_NAME=gares_db

# Configuration du serveur
PORT=3000
NODE_ENV=development
```

**Important:** Replace `your_actual_password` with your real PostgreSQL password.

### **Step 2: Create PostgreSQL Database**

If you haven't created the database yet, run these commands in PostgreSQL:

```sql
-- Connect to PostgreSQL as superuser
psql -U postgres

-- Create the database
CREATE DATABASE gares_db;

-- Verify the database was created
\l

-- Exit PostgreSQL
\q
```

### **Step 3: Run Database Initialization**

Now you can run the database initialization script:

```bash
node init-db.js
```

This will:
- ✅ Connect to PostgreSQL
- ✅ Create the `gares` table if it doesn't exist
- ✅ Insert all 12 Moroccan train stations
- ✅ Show success/error messages

### **Step 4: Verify the Data**

After successful initialization, you can verify the data:

```bash
# Start the server
node index.js

# Test the API endpoint
curl http://localhost:3000/api/gares
```

## 📊 **Station Data Being Inserted**

The script will insert these 12 Moroccan train stations:

| # | Station | City | Coordinates | Phone | Description |
|---|---------|------|-------------|-------|-------------|
| 1 | Tanger Ville | Tanger | 35.7801, -5.8125 | +212-539-001 | Gare maritime moderne au nord du Maroc |
| 2 | Casablanca Voyageurs | Casablanca | 33.5731, -7.5898 | +212-522-002 | Plus grande gare ferroviaire du Maroc |
| 3 | Rabat Ville | Rabat | 34.0209, -6.8416 | +212-537-003 | Gare historique du centre-ville |
| 4 | Rabat Agdal | Rabat | 34.0025, -6.8469 | +212-537-004 | Gare moderne pour les trains Al Boraq (TGV) |
| 5 | Fès | Fès | 34.0331, -5.0003 | +212-535-005 | Gare historique et hub ferroviaire du Maroc |
| 6 | Marrakech | Marrakech | 31.6295, -7.9811 | +212-524-006 | Gare touristique et emblématique |
| 7 | Oujda | Oujda | 34.6867, -1.9114 | +212-536-007 | Gare de l'Oriental, terminus est du réseau ONCF |
| 8 | Kénitra | Kénitra | 34.2610, -6.5790 | +212-537-008 | Gare importante pour le TGV |
| 9 | Settat | Settat | 33.0001, -7.6200 | +212-523-009 | Gare régionale entre Casa et Marrakech |
| 10 | Oued Zem | Oued Zem | 32.8662, -6.5653 | +212-523-010 | Petite gare régionale |
| 11 | Mohammedia | Mohammedia | 33.6835, -7.3843 | +212-523-011 | Gare côtière entre Rabat et Casa |
| 12 | El Jadida | El Jadida | 33.2560, -8.5081 | +212-523-012 | Gare touristique sur la côte Atlantique |

## 🔧 **Troubleshooting**

### **Common Issues and Solutions**

#### **1. Connection Error**
```
❌ Error: connect ECONNREFUSED 127.0.0.1:5432
```
**Solution:** Make sure PostgreSQL is running and the port is correct.

#### **2. Authentication Error**
```
❌ Error: password authentication failed
```
**Solution:** Check your password in the `.env` file.

#### **3. Database Not Found**
```
❌ Error: database "gares_db" does not exist
```
**Solution:** Create the database first using PostgreSQL commands.

#### **4. Permission Error**
```
❌ Error: permission denied for database
```
**Solution:** Make sure your PostgreSQL user has the right permissions.

### **Quick Commands**

```bash
# Install dependencies (if not already done)
npm install

# Run database initialization
node init-db.js

# Start the server
node index.js

# Test the API
curl http://localhost:3000/api/gares
```

## ✅ **Success Indicators**

When the database initialization is successful, you should see:

```
🚀 Initialisation de la base de données...
📋 Configuration requise:
   - PostgreSQL installé et en cours d'exécution
   - Base de données "gares_db" créée
   - Fichier .env configuré avec les bonnes informations

✅ Connecté à PostgreSQL
✅ Table gares créée ou vérifiée
✅ Données initiales insérées (12 stations)

✅ Base de données initialisée avec succès!
📊 12 stations marocaines ajoutées:
   1. Tanger Ville
   2. Casablanca Voyageurs
   ...
   12. El Jadida

🚂 Vous pouvez maintenant démarrer le serveur avec: node index.js
```

## 🎯 **Next Steps**

After successful database initialization:

1. **Start the server**: `node index.js`
2. **Test the API**: Visit `http://localhost:3000/api/gares`
3. **Run Flutter app**: `flutter run -d chrome`
4. **Test MapScreen**: Navigate to the map to see all 12 stations

---

**Your TrainSight database is now ready with real Moroccan train station data! 🚂✨** 