const express = require('express');
const cors = require('cors');
require('dotenv').config();

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Données de test (simulation de la base de données)
const garesTest = [
  {
    id: 1,
    nom: "Tanger",
    ville: "Tanger",
    latitude: 35.7801,
    longitude: -5.8125,
    telephone: "+212-539-001",
    description: "Gare maritime moderne au nord du Maroc"
  },
  {
    id: 2,
    nom: "Rabat",
    ville: "Rabat",
    latitude: 34.0209,
    longitude: -6.8416,
    telephone: "+212-537-002",
    description: "Capitale administrative du pays"
  },
  {
    id: 3,
    nom: "Casablanca",
    ville: "Casablanca",
    latitude: 33.5731,
    longitude: -7.5898,
    telephone: "+212-522-003",
    description: "Plus grande ville économique du Maroc"
  }
];

// Routes de test
app.get('/', (req, res) => {
  res.json({
    message: '🚂 API Gares Backend (Mode Test)',
    version: '1.0.0',
    status: 'Test sans base de données',
    endpoints: {
      gares: '/api/gares',
      health: '/api/health'
    }
  });
});

app.get('/api/health', (req, res) => {
  res.json({
    success: true,
    message: '✅ Serveur opérationnel (Mode Test)',
    timestamp: new Date().toISOString(),
    environment: 'test'
  });
});

app.get('/api/gares', (req, res) => {
  res.json({
    success: true,
    message: 'Gares récupérées avec succès (Mode Test)',
    data: garesTest,
    count: garesTest.length
  });
});

app.get('/api/gares/:id', (req, res) => {
  const id = parseInt(req.params.id);
  const gare = garesTest.find(g => g.id === id);
  
  if (!gare) {
    return res.status(404).json({
      success: false,
      message: 'Gare non trouvée'
    });
  }
  
  res.json({
    success: true,
    message: 'Gare récupérée avec succès',
    data: gare
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

// Démarrage du serveur
app.listen(PORT, () => {
  console.log('🚀 Serveur de test démarré avec succès!');
  console.log(`📍 URL: http://localhost:${PORT}`);
  console.log('🧪 Mode: Test (sans base de données)');
  console.log('📋 Endpoints disponibles:');
  console.log(`   GET  http://localhost:${PORT}/api/gares`);
  console.log(`   GET  http://localhost:${PORT}/api/gares/:id`);
  console.log(`   GET  http://localhost:${PORT}/api/health`);
  console.log('🔧 Utilisez Ctrl+C pour arrêter le serveur');
});

// Gestion de l'arrêt propre du serveur
process.on('SIGINT', () => {
  console.log('\n🛑 Arrêt du serveur...');
  process.exit(0);
}); 