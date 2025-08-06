const { initializeDatabase } = require('./db.js');

async function main() {
  try {
    console.log('🚀 Initialisation de la base de données...');
    console.log('📋 Configuration requise:');
    console.log('   - PostgreSQL installé et en cours d\'exécution');
    console.log('   - Base de données "gares_db" créée');
    console.log('   - Fichier .env configuré avec les bonnes informations');
    console.log('');
    
    await initializeDatabase();
    
    console.log('');
    console.log('✅ Base de données initialisée avec succès!');
    console.log('📊 12 stations marocaines ajoutées:');
    console.log('   1. Tanger Ville');
    console.log('   2. Casablanca Voyageurs');
    console.log('   3. Rabat Ville');
    console.log('   4. Rabat Agdal');
    console.log('   5. Fès');
    console.log('   6. Marrakech');
    console.log('   7. Oujda');
    console.log('   8. Kénitra');
    console.log('   9. Settat');
    console.log('   10. Oued Zem');
    console.log('   11. Mohammedia');
    console.log('   12. El Jadida');
    console.log('');
    console.log('🚂 Vous pouvez maintenant démarrer le serveur avec: node index.js');
    
    process.exit(0);
  } catch (error) {
    console.error('❌ Erreur lors de l\'initialisation:', error.message);
    console.log('');
    console.log('🔧 Vérifiez que:');
    console.log('   1. PostgreSQL est installé et en cours d\'exécution');
    console.log('   2. La base de données "gares_db" existe');
    console.log('   3. Le fichier .env contient les bonnes informations');
    console.log('   4. Les dépendances sont installées: npm install');
    process.exit(1);
  }
}

main(); 