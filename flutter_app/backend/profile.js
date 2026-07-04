const express = require('express');
const { MongoClient } = require('mongodb');
const cors = require('cors');

const app = express();
app.use(express.json());
app.use(cors());

// Connection URL
const url = 'mongodb://localhost:27017';
const client = new MongoClient(url);
const dbName = 'multi_domain_ai';

async function main() {
  await client.connect();
  console.log('Connected successfully to MongoDB server');
  const db = client.db(dbName);
  const profilesCollection = db.collection('profiles');

  // Update or Create Profile
  app.post('/api/profile', async (req, res) => {
    try {
      const { email, name, imageBase64 } = req.body;
      if (!email) {
        return res.status(400).json({ success: false, message: 'Email required' });
      }

      await profilesCollection.updateOne(
        { email },
        { $set: { name, imageBase64, updatedAt: new Date() } },
        { upsert: true }
      );

      res.json({ success: true, message: 'Profile updated' });
    } catch (err) {
      console.error(err);
      res.status(500).json({ success: false, message: 'Server Error' });
    }
  });

  // Get Profile
  app.get('/api/profile/:email', async (req, res) => {
    try {
      const { email } = req.params;
      const profile = await profilesCollection.findOne({ email });
      if (!profile) {
        return res.json({ success: true, data: null });
      }
      res.json({ success: true, data: profile });
    } catch (err) {
      console.error(err);
      res.status(500).json({ success: false, message: 'Server Error' });
    }
  });

  const port = process.env.PORT || 3000;
  app.listen(port, () => {
    console.log(`Profile service listening on port ${port}`);
  });
}

main().catch(console.error);
