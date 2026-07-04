const express = require('express');
const mongoose = require('mongoose');
const { authenticateToken } = require('./auth');
const router = express.Router();

// Use the database AgroGen_Collection_Data for agricultural data
const db = mongoose.connection.useDb('AgroGen_Collection_Data', { useCache: true });

// Schema matching the required farmer crop details
const farmDetailsSchema = new mongoose.Schema({
  userId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  cropName: { type: String, required: true },
  totalLandArea: { type: String },
  numberOfFields: { type: Number },
  farmLocation: { type: String }, // GPS coordinates
  farmBoundaryUrl: { type: String }, // Base64 or image url
  irrigationType: { 
    type: String, 
    enum: ['Rain-fed', 'Borewell', 'Canal', 'Drip Irrigation', 'Sprinkler', 'Water Source', 'FarmOwnership'] 
  },
  currentCrop: { type: String },
  previousCrop: { type: String },
  cropVariety: { type: String },
  sowingDate: { type: Date },
  expectedHarvestDate: { type: Date },
  cropGrowthStage: { type: String },
  cropSeason: { 
    type: String, 
    enum: ['Kharif', 'Rabi', 'Zaid'] 
  },
  estimatedYield: { type: String },
  isOrganic: { type: Boolean, default: false },
  createdAt: { type: Date, default: Date.now }
});

const FarmDetails = db.model('FarmDetails', farmDetailsSchema, 'AgroGen_Collection_Data');

// Schema for product orders
const productOrderSchema = new mongoose.Schema({
  userId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  productId: { type: String, required: true },
  productName: { type: String, required: true },
  category: { type: String, required: true },
  price: { type: String, required: true },
  orderedAt: { type: Date, default: Date.now }
});

const ProductOrder = db.model('ProductOrder', productOrderSchema, 'AgroGen_Collection_Data_Orders');

// ── Farm Details Endpoints ──────────────────────────────────────────────

// Save Farm Details
router.post('/farm-details', authenticateToken, async (req, res) => {
  try {
    const data = { ...req.body, userId: req.user.id };
    const farm = new FarmDetails(data);
    await farm.save();
    res.status(201).json({ message: 'Farm details saved successfully!', data: farm });
  } catch (err) {
    console.error('[AgroGen] Error saving farm details:', err);
    res.status(500).json({ error: err.message });
  }
});

// Fetch Farm Details for the current user
router.get('/farm-details', authenticateToken, async (req, res) => {
  try {
    const details = await FarmDetails.find({ userId: req.user.id }).sort({ createdAt: -1 });
    res.status(200).json(details);
  } catch (err) {
    console.error('[AgroGen] Error fetching farm details:', err);
    res.status(500).json({ error: err.message });
  }
});

// Save Product Order
router.post('/buy-product', authenticateToken, async (req, res) => {
  try {
    const data = { ...req.body, userId: req.user.id };
    const order = new ProductOrder(data);
    await order.save();
    res.status(201).json({ message: 'Order placed and saved successfully!', data: order });
  } catch (err) {
    console.error('[AgroGen] Error saving product order:', err);
    res.status(500).json({ error: err.message });
  }
});

// ── Weather Forecast Endpoint ───────────────────────────────────────────

router.get('/weather', async (req, res) => {
  const city = req.query.city || 'Bengaluru';
  const apiKey = process.env.OPENWEATHER_API_KEY;

  const mockWeatherList = [
    { day: 'Today', condition: '⛅ Partly Cloudy', tempHigh: 32, tempLow: 24, humidity: 68 },
    { day: 'Tomorrow', condition: '🌧 Light Rain', tempHigh: 28, tempLow: 21, humidity: 85 },
    { day: 'Wed', condition: '☀️ Sunny', tempHigh: 35, tempLow: 26, humidity: 55 },
    { day: 'Thu', condition: '🌩 Thunderstorm', tempHigh: 27, tempLow: 20, humidity: 90 },
    { day: 'Fri', condition: '⛅ Partly Cloudy', tempHigh: 31, tempLow: 23, humidity: 65 }
  ];

  if (!apiKey || apiKey === 'YOUR_OPENWEATHER_API_KEY' || apiKey.trim() === '') {
    console.log('[AgroGen Weather] OpenWeather API Key not configured. Using high-quality mock data.');
    return res.status(200).json({ source: 'mock', list: mockWeatherList });
  }

  try {
    const fetch = (await import('node-fetch')).default;
    const url = `https://api.openweathermap.org/data/2.5/forecast?q=${encodeURIComponent(city)}&units=metric&appid=${apiKey}`;
    const response = await fetch(url);
    
    if (!response.ok) {
      throw new Error(`OpenWeather API returned status ${response.status}`);
    }

    const data = await response.json();
    
    // Group 3-hour forecasts to 5 distinct days (take approx 12:00 PM for each day)
    const dailyForecasts = [];
    const list = data.list || [];
    const seenDates = new Set();

    for (const item of list) {
      const dateText = item.dt_txt.split(' ')[0]; // YYYY-MM-DD
      const timeText = item.dt_txt.split(' ')[1]; // HH:MM:SS
      
      // Select midday forecast or first forecast of the day if midday not found
      if (!seenDates.has(dateText) && (timeText.startsWith('12:') || timeText.startsWith('15:') || timeText.startsWith('09:'))) {
        seenDates.add(dateText);
        
        // Map OpenWeather weather conditions to clean labels and emojis
        const mainWeather = item.weather[0].main;
        let condition = '☀️ Sunny';
        if (mainWeather === 'Rain' || mainWeather === 'Drizzle') {
          condition = '🌧 Light Rain';
        } else if (mainWeather === 'Clouds') {
          condition = '⛅ Cloudy';
        } else if (mainWeather === 'Thunderstorm') {
          condition = '🌩 Thunderstorm';
        } else if (mainWeather === 'Clear') {
          condition = '☀️ Sunny';
        } else {
          condition = `⛅ ${mainWeather}`;
        }

        // Get Day Name
        const dateObj = new Date(item.dt * 1000);
        const days = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
        const dayLabel = dailyForecasts.length === 0 ? 'Today' : (dailyForecasts.length === 1 ? 'Tomorrow' : days[dateObj.getDay()]);

        dailyForecasts.push({
          day: dayLabel,
          condition: condition,
          tempHigh: Math.round(item.main.temp_max),
          tempLow: Math.round(item.main.temp_min),
          humidity: item.main.humidity
        });
      }

      if (dailyForecasts.length >= 5) break;
    }

    // Fallback if empty or insufficient
    if (dailyForecasts.length < 5) {
      return res.status(200).json({ source: 'api-fallback', list: mockWeatherList });
    }

    res.status(200).json({ source: 'api', list: dailyForecasts });
  } catch (err) {
    console.error('[AgroGen Weather] OpenWeather fetch failed, falling back to mock:', err.message);
    res.status(200).json({ source: 'error-fallback', list: mockWeatherList, error: err.message });
  }
});

module.exports = router;
