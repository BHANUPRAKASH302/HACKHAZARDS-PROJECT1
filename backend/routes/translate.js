const express = require('express');
const axios = require('axios');
const dotenv = require('dotenv');

dotenv.config();

const router = express.Router();

router.post('/', async (req, res) => {
  const { text, target } = req.body;

  if (!text || !target) {
    return res.status(400).json({ error: 'Missing "text" or "target" fields.' });
  }

  const apiKey = process.env.GOOGLE_TRANSLATE_API_KEY;

  if (!apiKey || apiKey.includes('YOUR_')) {
    console.warn('[Translate] API Key not set. Using local mock translation.');
    return res.status(200).json({
      translatedText: `[Local Mock - Translation to ${target.toUpperCase()}]: ${text}`,
      detectedSourceLanguage: 'en',
      mock: true
    });
  }

  try {
    const googleTranslateUrl = `https://translation.googleapis.com/language/translate/v2?key=${apiKey}`;
    const response = await axios.post(googleTranslateUrl, {
      q: text,
      target: target
    }, { timeout: 5000 });

    if (response.data && response.data.data && response.data.data.translations) {
      const translation = response.data.data.translations[0];
      return res.status(200).json({
        translatedText: translation.translatedText,
        detectedSourceLanguage: translation.detectedSourceLanguage,
        mock: false
      });
    } else {
      throw new Error('Invalid response structure from translation service');
    }
  } catch (error) {
    console.error('[Translate] Google Translate API error:', error.message);
    // Graceful fallback during hackathon testing
    return res.status(200).json({
      translatedText: `[Fallback - Translation to ${target.toUpperCase()}]: ${text}`,
      detectedSourceLanguage: 'en',
      mock: true,
      error: error.message
    });
  }
});

module.exports = router;
