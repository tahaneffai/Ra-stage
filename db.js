const { Pool } = require('pg');
require('dotenv').config();

// Configuration de la connexion PostgreSQL
const pool = new Pool({
  host: process.env.DB_HOST,
  port: process.env.DB_PORT,
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  database: process.env.DB_NAME,
});

// Test de connexion
pool.on('connect', () => {
  console.log('✅ Connecté à PostgreSQL');
});

pool.on('error', (err) => {
  console.error('❌ Erreur de connexion PostgreSQL:', err);
});

// Fonction pour initialiser la base de données
async function initializeDatabase() {
  try {
    // Créer la table gares si elle n'existe pas
    const createTableQuery = `
      CREATE TABLE IF NOT EXISTS gares (
        id SERIAL PRIMARY KEY,
        nom TEXT NOT NULL,
        ville TEXT NOT NULL,
        latitude DOUBLE PRECISION NOT NULL,
        longitude DOUBLE PRECISION NOT NULL,
        telephone TEXT,
        description TEXT
      );
    `;
    
    await pool.query(createTableQuery);
    console.log('✅ Table gares créée ou vérifiée');

    // Vérifier si des données existent déjà
    const checkDataQuery = 'SELECT COUNT(*) FROM gares';
    const result = await pool.query(checkDataQuery);
    
    if (result.rows[0].count === '0') {
      // Insérer les données initiales avec toutes les stations demandées
      const insertDataQuery = `
        INSERT INTO gares (nom, ville, latitude, longitude, telephone, description) VALUES
        ('Tanger Ville', 'Tanger', 35.7801, -5.8125, '+212-539-001', 'Gare maritime moderne au nord du Maroc'),
        ('Casablanca Voyageurs', 'Casablanca', 33.5731, -7.5898, '+212-522-002', 'Plus grande gare ferroviaire du Maroc'),
        ('Rabat Ville', 'Rabat', 34.0209, -6.8416, '+212-537-003', 'Gare historique du centre-ville'),
        ('Rabat Agdal', 'Rabat', 34.0025, -6.8469, '+212-537-004', 'Gare moderne pour les trains Al Boraq (TGV)'),
        ('Fès', 'Fès', 34.0331, -5.0003, '+212-535-005', 'Gare historique et hub ferroviaire du Maroc'),
        ('Marrakech', 'Marrakech', 31.6295, -7.9811, '+212-524-006', 'Gare touristique et emblématique'),
        ('Oujda', 'Oujda', 34.6867, -1.9114, '+212-536-007', 'Gare de l''Oriental, terminus est du réseau ONCF'),
        ('Kénitra', 'Kénitra', 34.2610, -6.5790, '+212-537-008', 'Gare importante pour le TGV'),
        ('Settat', 'Settat', 33.0001, -7.6200, '+212-523-009', 'Gare régionale entre Casa et Marrakech'),
        ('Oued Zem', 'Oued Zem', 32.8662, -6.5653, '+212-523-010', 'Petite gare régionale'),
        ('Mohammedia', 'Mohammedia', 33.6835, -7.3843, '+212-523-011', 'Gare côtière entre Rabat et Casa'),
        ('El Jadida', 'El Jadida', 33.2560, -8.5081, '+212-523-012', 'Gare touristique sur la côte Atlantique')
      `;
      
      await pool.query(insertDataQuery);
      console.log('✅ Données initiales insérées (12 stations)');
    } else {
      console.log('✅ Données déjà présentes dans la base');
    }

  } catch (error) {
    console.error('❌ Erreur lors de l\'initialisation de la base de données:', error);
    throw error;
  }
}

module.exports = {
  pool,
  initializeDatabase
}; 