const { Pool } = require('pg');
require('dotenv').config();

console.log('🗄️ Creating PostgreSQL database...');

// Connect to default postgres database first
const pool = new Pool({
  host: process.env.DB_HOST,
  port: process.env.DB_PORT,
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  database: 'postgres', // Connect to default database
});

async function createDatabase() {
  try {
    console.log('🔄 Connecting to PostgreSQL...');
    const client = await pool.connect();
    console.log('✅ Connected to PostgreSQL');
    
    // Check if database already exists
    console.log('🔍 Checking if database exists...');
    const checkResult = await client.query("SELECT datname FROM pg_database WHERE datname = 'gares_db'");
    
    if (checkResult.rows.length > 0) {
      console.log('✅ Database "gares_db" already exists');
    } else {
      console.log('📝 Creating database "gares_db"...');
      await client.query('CREATE DATABASE gares_db');
      console.log('✅ Database "gares_db" created successfully');
    }
    
    client.release();
    await pool.end();
    
    console.log('');
    console.log('🎉 Database setup complete!');
    console.log('🚀 You can now run: node init-db.js');
    
  } catch (error) {
    console.error('❌ Error creating database:', error.message);
    console.log('');
    console.log('🔧 Make sure:');
    console.log('   1. PostgreSQL is running');
    console.log('   2. Your password in .env is correct');
    console.log('   3. Your user has CREATE DATABASE privileges');
    
    await pool.end();
    process.exit(1);
  }
}

createDatabase(); 