const fs = require('fs');
const path = require('path');

// Configuration par défaut
const defaultConfig = `# Configuration PostgreSQL
DB_HOST=localhost
DB_PORT=5432
DB_USER=postgres
DB_PASSWORD=postgres
DB_NAME=gares_db

# Configuration du serveur
PORT=3000
NODE_ENV=development
`;

// Vérifier si le fichier .env existe déjà
const envPath = path.join(__dirname, '.env');

if (!fs.existsSync(envPath)) {
  fs.writeFileSync(envPath, defaultConfig);
  console.log('✅ Fichier .env créé avec succès!');
  console.log('📝 Modifiez le fichier .env avec vos informations de base de données');
} else {
  console.log('ℹ️  Le fichier .env existe déjà');
}

console.log('\n🚀 Pour démarrer le serveur :');
console.log('   npm run dev');
console.log('\n📋 N\'oubliez pas de :');
console.log('   1. Créer la base de données PostgreSQL : gares_db');
console.log('   2. Modifier les informations de connexion dans .env');
console.log('   3. Installer PostgreSQL si ce n\'est pas déjà fait'); 