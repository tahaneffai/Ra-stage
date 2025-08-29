# 🚂 TrainSight PostgreSQL Setup Guide

## 📋 Prerequisites

- ✅ Node.js installed
- ✅ PostgreSQL installed and running
- ✅ Dependencies installed (`npm install` completed)

## 🔧 Step-by-Step Setup

### 1. Create Environment File

Since `.env` files are protected, you need to manually create one. Copy the contents from `env.example` and create a `.env` file in the root directory:

```bash
# Copy env.example to .env
cp env.example .env
```

**Important:** Update the password in `.env`:
```env
DB_PASSWORD=YOUR_ACTUAL_POSTGRESQL_PASSWORD
```

### 2. Create Database

Run the database creation script:
```bash
node create-database.js
```

This will:
- Connect to PostgreSQL using your credentials
- Create the `gares_db` database if it doesn't exist

### 3. Initialize Database with Train Stations

Run the initialization script:
```bash
node init-db.js
```

This will:
- Create the `gares` table with the correct structure
- Insert 12 Moroccan train stations with exact coordinates and details

### 4. Verify Setup

Start the server to test the connection:
```bash
node index.js
```

## 🗄️ Database Structure

The `gares` table contains:
- `id` - SERIAL PRIMARY KEY
- `nom` - Station name (TEXT)
- `ville` - City (TEXT)
- `latitude` - GPS latitude (DOUBLE PRECISION)
- `longitude` - GPS longitude (DOUBLE PRECISION)
- `telephone` - Contact number (TEXT)
- `description` - Station description (TEXT)

## 🚉 Moroccan Train Stations

The database will be populated with these 12 stations:

1. **Tanger Ville** - Tanger (35.7806, -5.8136)
2. **Rabat Agdal** - Rabat (34.0049, -6.8443)
3. **Rabat Ville** - Rabat (34.0219, -6.8360)
4. **Casablanca Voyageurs** - Casablanca (33.5883, -7.6114)
5. **Fès** - Fès (34.0370, -4.9998)
6. **Marrakech** - Marrakech (31.6295, -7.9811)
7. **Kenitra** - Kenitra (34.2610, -6.5794)
8. **Oujda** - Oujda (34.6835, -1.9096)
9. **Oued Zem** - Oued Zem (32.8624, -6.5735)
10. **Settat** - Settat (33.0011, -7.6200)
11. **El Jadida** - El Jadida (33.2350, -8.5000)
12. **Safi** - Safi (32.2994, -9.2372)

## 🔍 Troubleshooting

### Common Issues:

1. **Connection refused**: Make sure PostgreSQL is running
2. **Authentication failed**: Check your password in `.env`
3. **Database doesn't exist**: Run `create-database.js` first
4. **Permission denied**: Ensure your PostgreSQL user has CREATE DATABASE privileges

### Test Connection:

```bash
node test-db-connection.js
```

## 🚀 Next Steps

After successful setup:
1. The database is ready for the TrainSight application
2. All 12 Moroccan train stations are available via API
3. You can start building the frontend to display the stations
4. The coordinates are ready for Google Maps integration

## 📚 Files Overview

- `db.js` - Database connection and initialization
- `create-database.js` - Creates the PostgreSQL database
- `init-db.js` - Sets up tables and populates with data
- `index.js` - Main server file
- `.env` - Environment configuration (create manually)
- `env.example` - Environment template


