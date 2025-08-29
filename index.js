const express = require('express');
const cors = require('cors');
const http = require('http');
require('dotenv').config();

const { initializeDatabase } = require('./db');
const garesRoutes = require('./routes/gares');
const realtimeRoutes = require('./routes/realtime');
const RealtimeService = require('./realtime-service');

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Serve static files
app.use(express.static('public'));

// Routes
app.use('/api/gares', garesRoutes);
app.use('/api/realtime', realtimeRoutes);

// Route racine
app.get('/', (req, res) => {
  res.json({
    message: '🚂 API Gares Backend',
    version: '1.0.0',
    endpoints: {
      gares: '/api/gares',
      documentation: 'Consultez les routes disponibles'
    }
  });
});

// Route de test
app.get('/api/health', (req, res) => {
  res.json({
    success: true,
    message: '✅ Serveur opérationnel',
    timestamp: new Date().toISOString(),
    environment: process.env.NODE_ENV || 'development'
  });
});

// Gestion des erreurs 404
app.use('*', (req, res) => {
  res.status(404).json({
    success: false,
    message: 'Route non trouvée',
    path: req.originalUrl
  });
});

// Gestion globale des erreurs
app.use((error, req, res, next) => {
  console.error('❌ Erreur serveur:', error);
  res.status(500).json({
    success: false,
    message: 'Erreur interne du serveur',
    error: process.env.NODE_ENV === 'development' ? error.message : 'Erreur interne'
  });
});

// Démarrage du serveur
async function startServer() {
  try {
    // Initialiser la base de données
    await initializeDatabase();
    
    // Créer le serveur HTTP pour Socket.IO
    const server = http.createServer(app);
    
    // Initialiser le service temps réel
    const realtimeService = new RealtimeService(server);
    
    // Démarrer le serveur
    server.listen(PORT, () => {
      console.log('🚀 Serveur démarré avec succès!');
      console.log(`📍 URL: http://localhost:${PORT}`);
      console.log(`🌍 Environnement: ${process.env.NODE_ENV || 'development'}`);
      console.log('📋 Endpoints disponibles:');
      console.log(`   GET  http://localhost:${PORT}/api/gares`);
      console.log(`   GET  http://localhost:${PORT}/api/gares/:id`);
      console.log(`   POST http://localhost:${PORT}/api/gares`);
      console.log(`   PUT  http://localhost:${PORT}/api/gares/:id`);
      console.log(`   DELETE http://localhost:${PORT}/api/gares/:id`);
      console.log('🔌 WebSocket: ws://localhost:${PORT}/socket.io');
      console.log('📡 Temps réel: http://localhost:${PORT}/api/realtime');
      console.log('🔧 Utilisez Ctrl+C pour arrêter le serveur');
    });
    
  } catch (error) {
    console.error('❌ Erreur lors du démarrage du serveur:', error);
    process.exit(1);
  }
}

// Gestion de l'arrêt propre du serveur
process.on('SIGINT', () => {
  console.log('\n🛑 Arrêt du serveur...');
  process.exit(0);
});

process.on('SIGTERM', () => {
  console.log('\n🛑 Arrêt du serveur...');
  process.exit(0);
});

// Démarrer le serveur
startServer(); 