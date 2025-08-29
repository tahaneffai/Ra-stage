const fs = require('fs');
const path = require('path');

console.log('🔧 Creating .env file for TrainSight PostgreSQL setup...');

const envContent = `# Configuration PostgreSQL
DB_HOST=localhost
DB_PORT=5432
DB_USER=postgres
DB_PASSWORD=YOUR_PASSWORD
DB_NAME=gares_db

# Configuration du serveur
PORT=3000
NODE_ENV=development
`;

const envPath = path.join(__dirname, '.env');

try {
  // Check if .env already exists
  if (fs.existsSync(envPath)) {
    console.log('⚠️  .env file already exists');
    console.log('📝 Please manually update the DB_PASSWORD in your .env file');
  } else {
    // Create .env file
    fs.writeFileSync(envPath, envContent);
    console.log('✅ .env file created successfully!');
    console.log('');
    console.log('🔑 IMPORTANT: Update the DB_PASSWORD in .env with your actual PostgreSQL password');
    console.log('');
    console.log('📋 Next steps:');
    console.log('   1. Edit .env and set your actual PostgreSQL password');
    console.log('   2. Run: node create-database.js');
    console.log('   3. Run: node init-db.js');
  }
} catch (error) {
  console.error('❌ Error creating .env file:', error.message);
  console.log('');
  console.log('📝 Please manually create .env file with this content:');
  console.log('');
  console.log(envContent);
}





