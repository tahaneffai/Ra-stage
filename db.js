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
        ('Tanger Ville', 'Tanger', 35.7806, -5.8136, '+212-539-001', 'Gare maritime moderne au nord du Maroc'),
        ('Rabat Agdal', 'Rabat', 34.0049, -6.8443, '+212-537-020', 'Gare urbaine au cœur du quartier Agdal'),
        ('Rabat Ville', 'Rabat', 34.0219, -6.8360, '+212-537-021', 'Gare centrale à proximité de la médina'),
        ('Casablanca Voyageurs', 'Casablanca', 33.5883, -7.6114, '+212-522-002', 'Plus grande gare ferroviaire du Maroc'),
        ('Fès', 'Fès', 34.0370, -4.9998, '+212-535-003', 'Gare historique et hub ferroviaire du centre'),
        ('Marrakech', 'Marrakech', 31.6295, -7.9811, '+212-524-004', 'Gare touristique du sud du Maroc'),
        ('Kenitra', 'Kenitra', 34.2610, -6.5794, '+212-537-005', 'Gare stratégique sur la ligne TGV'),
        ('Oujda', 'Oujda', 34.6835, -1.9096, '+212-536-006', 'Gare de l''extrême est du Maroc'),
        ('Oued Zem', 'Oued Zem', 32.8624, -6.5735, '+212-523-007', 'Gare régionale au centre du pays'),
        ('Settat', 'Settat', 33.0011, -7.6200, '+212-523-008', 'Gare régionale entre Casa et Marrakech'),
        ('El Jadida', 'El Jadida', 33.2350, -8.5000, '+212-523-009', 'Gare touristique sur la côte Atlantique'),
        ('Safi', 'Safi', 32.2994, -9.2372, '+212-524-010', 'Gare portuaire sur l''océan Atlantique')
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