const dotenv = require('dotenv');
const mongoose = require('mongoose');
const { Sequelize } = require('sequelize');
const { createClient } = require('redis');
const Minio = require('minio');
const axios = require('axios');

dotenv.config();

console.log('===============================================');
console.log('       Vynedam Stack Health Connection Test    ');
console.log('===============================================');

async function testMongo() {
  const uri = process.env.MONGO_URI_ATLAS || process.env.MONGO_URI_LOCAL || 'mongodb://localhost:27017/User_Data';
  try {
    await mongoose.connect(uri, { serverSelectionTimeoutMS: 3000 });
    console.log('✅ MongoDB connection: SUCCESSFUL');
    await mongoose.disconnect();
  } catch (err) {
    console.log('❌ MongoDB connection: FAILED -', err.message);
  }
}

async function testRedis() {
  const url = process.env.REDIS_URL || 'redis://localhost:6379';
  const client = createClient({ url });
  try {
    await client.connect();
    console.log('✅ Redis connection: SUCCESSFUL');
    await client.disconnect();
  } catch (err) {
    console.log('❌ Redis connection: FAILED -', err.message);
  }
}

async function testMySQL() {
  const sequelize = new Sequelize(
    process.env.MYSQL_DATABASE || 'vynedam_db',
    process.env.MYSQL_USER || 'vynedam_user',
    process.env.MYSQL_PASSWORD || 'vynedam_password',
    {
      host: process.env.MYSQL_HOST || 'localhost',
      port: parseInt(process.env.MYSQL_PORT || '3306'),
      dialect: 'mysql',
      logging: false,
    }
  );
  try {
    await sequelize.authenticate();
    console.log('✅ MySQL connection: SUCCESSFUL');
    await sequelize.close();
  } catch (err) {
    console.log('❌ MySQL connection: FAILED -', err.message);
  }
}

async function testMinIO() {
  try {
    const minioClient = new Minio.Client({
      endPoint: process.env.MINIO_ENDPOINT || 'localhost',
      port: parseInt(process.env.MINIO_PORT || '9000'),
      useSSL: process.env.MINIO_USE_SSL === 'true',
      accessKey: process.env.MINIO_ACCESS_KEY || 'minioadmin',
      secretKey: process.env.MINIO_SECRET_KEY || 'minioadmin'
    });
    const exists = await minioClient.bucketExists(process.env.MINIO_BUCKET || 'vynedam-bucket');
    console.log(`✅ MinIO connection: SUCCESSFUL (Bucket Checked)`);
  } catch (err) {
    console.log('❌ MinIO connection: FAILED -', err.message);
  }
}

async function testOllama() {
  const host = process.env.OLLAMA_HOST || 'http://localhost:11434';
  const model = process.env.OLLAMA_MODEL || 'llama3';
  try {
    const res = await axios.get(`${host}/api/tags`, { timeout: 3000 });
    const models = res.data.models || [];
    console.log(`✅ Ollama connection: SUCCESSFUL (Active models: ${models.map(m => m.name).join(', ')})`);
  } catch (err) {
    console.log(`❌ Ollama connection: FAILED - Local LLM offline at ${host} (${err.message})`);
  }
}

async function testPHP() {
  const phpUrl = process.env.PHP_HASH_SERVICE_URL || 'http://localhost:8085';
  try {
    const testPassword = 'mySecurePassword';
    const hashRes = await axios.post(phpUrl, { action: 'hash', password: testPassword }, { timeout: 3000 });
    if (hashRes.data && hashRes.data.hash) {
      const verifyRes = await axios.post(phpUrl, { action: 'verify', password: testPassword, hash: hashRes.data.hash }, { timeout: 3000 });
      if (verifyRes.data && verifyRes.data.verified === true) {
        console.log('✅ PHP Hashing Microservice: SUCCESSFUL (Bcrypt integration verified)');
        return;
      }
    }
    throw new Error('Verification payload check failed');
  } catch (err) {
    console.log(`❌ PHP Hashing Microservice: FAILED at ${phpUrl} -`, err.message);
  }
}

async function testGoogleTranslate() {
  const apiKey = process.env.GOOGLE_TRANSLATE_API_KEY;
  if (!apiKey || apiKey.includes('YOUR_')) {
    console.log('⚠️ Google Translate: SKIPPED (API Key placeholder present)');
    return;
  }
  try {
    const url = `https://translation.googleapis.com/language/translate/v2?key=${apiKey}`;
    const response = await axios.post(url, { q: 'Hello', target: 'es' }, { timeout: 5000 });
    if (response.data && response.data.data) {
      console.log('✅ Google Translate API: SUCCESSFUL');
    }
  } catch (err) {
    console.log('❌ Google Translate API: FAILED -', err.message);
  }
}

async function run() {
  await testMongo();
  await testRedis();
  await testMySQL();
  await testMinIO();
  await testOllama();
  await testPHP();
  await testGoogleTranslate();
  console.log('===============================================');
}

run();
