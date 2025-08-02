const express = require('express');
const router = express.Router();
const { pool } = require('../db');

// GET /api/gares - Récupérer toutes les gares
router.get('/', async (req, res) => {
  try {
    const query = 'SELECT * FROM gares ORDER BY nom';
    const result = await pool.query(query);
    
    res.json({
      success: true,
      message: 'Gares récupérées avec succès',
      data: result.rows,
      count: result.rows.length
    });
    
  } catch (error) {
    console.error('❌ Erreur lors de la récupération des gares:', error);
    res.status(500).json({
      success: false,
      message: 'Erreur lors de la récupération des gares',
      error: error.message
    });
  }
});

// GET /api/gares/:id - Récupérer une gare par ID
router.get('/:id', async (req, res) => {
  try {
    const { id } = req.params;
    const query = 'SELECT * FROM gares WHERE id = $1';
    const result = await pool.query(query, [id]);
    
    if (result.rows.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'Gare non trouvée'
      });
    }
    
    res.json({
      success: true,
      message: 'Gare récupérée avec succès',
      data: result.rows[0]
    });
    
  } catch (error) {
    console.error('❌ Erreur lors de la récupération de la gare:', error);
    res.status(500).json({
      success: false,
      message: 'Erreur lors de la récupération de la gare',
      error: error.message
    });
  }
});

// POST /api/gares - Créer une nouvelle gare
router.post('/', async (req, res) => {
  try {
    const { nom, ville, latitude, longitude, telephone, description } = req.body;
    
    // Validation des données
    if (!nom || !ville || !latitude || !longitude) {
      return res.status(400).json({
        success: false,
        message: 'Les champs nom, ville, latitude et longitude sont obligatoires'
      });
    }
    
    const query = `
      INSERT INTO gares (nom, ville, latitude, longitude, telephone, description)
      VALUES ($1, $2, $3, $4, $5, $6)
      RETURNING *
    `;
    
    const values = [nom, ville, latitude, longitude, telephone, description];
    const result = await pool.query(query, values);
    
    res.status(201).json({
      success: true,
      message: 'Gare créée avec succès',
      data: result.rows[0]
    });
    
  } catch (error) {
    console.error('❌ Erreur lors de la création de la gare:', error);
    res.status(500).json({
      success: false,
      message: 'Erreur lors de la création de la gare',
      error: error.message
    });
  }
});

// PUT /api/gares/:id - Mettre à jour une gare
router.put('/:id', async (req, res) => {
  try {
    const { id } = req.params;
    const { nom, ville, latitude, longitude, telephone, description } = req.body;
    
    const query = `
      UPDATE gares 
      SET nom = $1, ville = $2, latitude = $3, longitude = $4, telephone = $5, description = $6
      WHERE id = $7
      RETURNING *
    `;
    
    const values = [nom, ville, latitude, longitude, telephone, description, id];
    const result = await pool.query(query, values);
    
    if (result.rows.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'Gare non trouvée'
      });
    }
    
    res.json({
      success: true,
      message: 'Gare mise à jour avec succès',
      data: result.rows[0]
    });
    
  } catch (error) {
    console.error('❌ Erreur lors de la mise à jour de la gare:', error);
    res.status(500).json({
      success: false,
      message: 'Erreur lors de la mise à jour de la gare',
      error: error.message
    });
  }
});

// DELETE /api/gares/:id - Supprimer une gare
router.delete('/:id', async (req, res) => {
  try {
    const { id } = req.params;
    const query = 'DELETE FROM gares WHERE id = $1 RETURNING *';
    const result = await pool.query(query, [id]);
    
    if (result.rows.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'Gare non trouvée'
      });
    }
    
    res.json({
      success: true,
      message: 'Gare supprimée avec succès',
      data: result.rows[0]
    });
    
  } catch (error) {
    console.error('❌ Erreur lors de la suppression de la gare:', error);
    res.status(500).json({
      success: false,
      message: 'Erreur lors de la suppression de la gare',
      error: error.message
    });
  }
});

module.exports = router; 