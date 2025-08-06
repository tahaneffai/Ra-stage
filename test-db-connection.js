const { Pool } = require('pg');
require('dotenv').config();

console.log('🔍 Testing PostgreSQL connection...');
console.log('📋 Current configuration:');
console.log(`   Host: ${process.env.DB_HOST || 'localhost'}`);
console.log(`   Port: ${process.env.DB_PORT || '5432'}`);
console.log(`   User: ${process.env.DB_USER || 'postgres'}`);
console.log(`   Database: ${process.env.DB_NAME || 'gares_db'}`);
console.log(`   Password: ${process.env.DB_PASSWORD ? '***SET***' : '***NOT SET***'}`);
console.log('');

if (!process.env.DB_PASSWORD) {
  console.log('❌ Error: DB_PASSWORD not set in .env file');
  console.log('📝 Please create a .env file with your PostgreSQL password:');
  console.log('');
  console.log('DB_HOST=localhost');
  console.log('DB_PORT=5432');
  console.log('DB_USER=postgres');
  console.log('DB_PASSWORD=your_actual_password');
  console.log('DB_NAME=gares_db');
  console.log('');
  process.exit(1);
}

const pool = new Pool({
  host: process.env.DB_HOST,
  port: process.env.DB_PORT,
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  database: process.env.DB_NAME,
});

async function testConnection() {
  try {
    console.log('🔄 Attempting to connect...');
    const client = await pool.connect();
    console.log('✅ Successfully connected to PostgreSQL!');
    
    // Test query
    const result = await client.query('SELECT version()');
    console.log('📊 PostgreSQL version:', result.rows[0].version);
    
    // Check if database exists
    const dbResult = await client.query("SELECT datname FROM pg_database WHERE datname = 'gares_db'");
    if (dbResult.rows.length > 0) {
      console.log('✅ Database "gares_db" exists');
    } else {
      console.log('❌ Database "gares_db" does not exist');
      console.log('💡 Create it with: CREATE DATABASE gares_db;');
    }
    
    client.release();
    await pool.end();
    
    console.log('');
    console.log('🎉 Connection test successful!');
    console.log('🚀 You can now run: node init-db.js');
    
  } catch (error) {
    console.error('❌ Connection failed:', error.message);
    console.log('');
    console.log('🔧 Common solutions:');
    console.log('   1. Check if PostgreSQL is running');
    console.log('   2. Verify your password in .env file');
    console.log('   3. Make sure database "gares_db" exists');
    console.log('   4. Check if port 5432 is correct');
    
    await pool.end();
    process.exit(1);
  }
}

testConnection(); 