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
        ('Tanger Ville', 'Tanger', 35.7801, -5.8125, '+212-539-001', 'Gare maritime moderne au nord du Maroc, point de départ vers l\'Europe'),
        ('Casablanca Voyageurs', 'Casablanca', 33.5731, -7.5898, '+212-522-003', 'Plus grande gare du Maroc, hub principal du réseau ferroviaire'),
        ('Rabat Ville', 'Rabat', 34.0209, -6.8416, '+212-537-002', 'Gare principale de la capitale administrative'),
        ('Rabat Agdal', 'Rabat', 34.0189, -6.8486, '+212-537-004', 'Gare secondaire de Rabat, desservant le quartier Agdal'),
        ('Fès', 'Fès', 34.0181, -5.0078, '+212-535-005', 'Gare historique de la ville impériale, centre culturel du Maroc'),
        ('Marrakech', 'Marrakech', 31.6295, -7.9811, '+212-524-006', 'Gare de la ville rouge, destination touristique majeure'),
        ('Oujda', 'Oujda', 34.6814, -1.9086, '+212-536-007', 'Gare de l\'est du Maroc, proche de la frontière algérienne'),
        ('Kénitra', 'Kénitra', 34.2610, -6.5802, '+212-537-008', 'Gare importante entre Rabat et Casablanca'),
        ('Settat', 'Settat', 33.0013, -7.6167, '+212-523-009', 'Gare de la région de Chaouia-Ouardigha'),
        ('Oued Zem', 'Oued Zem', 32.8636, -6.5736, '+212-523-010', 'Gare de la ville minière, centre économique local'),
        ('Mohammedia', 'Mohammedia', 33.6944, -7.3829, '+212-523-011', 'Gare côtière entre Casablanca et Rabat'),
        ('El Jadida', 'El Jadida', 33.2316, -8.5007, '+212-523-012', 'Gare de la ville côtière, patrimoine UNESCO')
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