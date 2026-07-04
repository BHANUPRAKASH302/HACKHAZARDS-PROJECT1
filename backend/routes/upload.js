const express = require('express');
const Minio = require('minio');
const { authenticateToken } = require('./auth');
const dotenv = require('dotenv');

dotenv.config();

const router = express.Router();

let minioClient;
try {
  minioClient = new Minio.Client({
    endPoint: process.env.MINIO_ENDPOINT || 'localhost',
    port: parseInt(process.env.MINIO_PORT || '9000'),
    useSSL: process.env.MINIO_USE_SSL === 'true',
    accessKey: process.env.MINIO_ACCESS_KEY || 'minioadmin',
    secretKey: process.env.MINIO_SECRET_KEY || 'minioadmin'
  });
} catch (error) {
  console.error('[MinIO] Client instantiation failed:', error.message);
}

const bucketName = process.env.MINIO_BUCKET || 'vynedam-bucket';
let bucketChecked = false;

async function ensureBucket() {
  if (bucketChecked) return true;
  if (!minioClient) return false;
  try {
    const exists = await minioClient.bucketExists(bucketName);
    if (!exists) {
      await minioClient.makeBucket(bucketName);
      console.log(`[MinIO] Bucket "${bucketName}" created.`);
    }
    bucketChecked = true;
    return true;
  } catch (error) {
    console.warn(`[MinIO] Bucket accessibility check failed: ${error.message}`);
    return false;
  }
}

// Route to get a presigned upload URL (S3 pattern)
router.get('/presigned', authenticateToken, async (req, res) => {
  const ready = await ensureBucket();
  if (!ready) {
    return res.status(503).json({ error: 'MinIO storage service is currently offline.' });
  }

  const originalName = req.query.name || 'upload.png';
  const cleanName = originalName.replace(/[^a-zA-Z0-9.]/g, '_');
  const fileName = `${Date.now()}-${cleanName}`;

  try {
    const url = await minioClient.presignedPutObject(bucketName, fileName, 24 * 60 * 60);
    const downloadUrl = `http://${process.env.MINIO_ENDPOINT || 'localhost'}:${process.env.MINIO_PORT || '9000'}/${bucketName}/${fileName}`;
    res.status(200).json({ uploadUrl: url, downloadUrl, fileName });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Route for direct Base64 upload
router.post('/base64', authenticateToken, async (req, res) => {
  const ready = await ensureBucket();
  if (!ready) {
    return res.status(503).json({ error: 'MinIO storage service is currently offline.' });
  }

  const { base64Data, name } = req.body;
  if (!base64Data) {
    return res.status(400).json({ error: 'base64Data is required' });
  }

  const buffer = Buffer.from(base64Data.replace(/^data:image\/\w+;base64,/, ""), 'base64');
  const originalName = name || 'upload.png';
  const cleanName = originalName.replace(/[^a-zA-Z0-9.]/g, '_');
  const fileName = `${Date.now()}-${cleanName}`;

  try {
    await minioClient.putObject(bucketName, fileName, buffer, buffer.length, {
      'Content-Type': 'image/png'
    });
    const downloadUrl = `http://${process.env.MINIO_ENDPOINT || 'localhost'}:${process.env.MINIO_PORT || '9000'}/${bucketName}/${fileName}`;
    res.status(200).json({ message: 'Upload completed', fileName, downloadUrl });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

module.exports = router;
