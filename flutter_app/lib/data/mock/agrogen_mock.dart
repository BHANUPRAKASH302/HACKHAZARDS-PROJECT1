/// Mock data for AgroGen (Agriculture) domain.

class CropHealth {
  final String cropName;
  final int healthScore;
  final String status;
  final List<String> recommendations;
  const CropHealth({
    required this.cropName,
    required this.healthScore,
    required this.status,
    required this.recommendations,
  });
}

class WeatherData {
  final String day;
  final String condition;
  final int tempHigh;
  final int tempLow;
  final int humidity;
  const WeatherData({
    required this.day,
    required this.condition,
    required this.tempHigh,
    required this.tempLow,
    required this.humidity,
  });
}

class MarketPrice {
  final String crop;
  final String price;
  final String change;
  final bool isUp;
  const MarketPrice({
    required this.crop,
    required this.price,
    required this.change,
    required this.isUp,
  });
}

class GovernmentScheme {
  final String name;
  final String description;
  final String deadline;
  const GovernmentScheme({
    required this.name,
    required this.description,
    required this.deadline,
  });
}

// ── Mock Data ─────────────────────────────────────────────────────────────

const mockCropHealth = CropHealth(
  cropName: 'Wheat',
  healthScore: 85,
  status: 'Healthy',
  recommendations: [
    'Irrigate every 7 days',
    'Apply Fertiliser in 3 days',
    'No pesticide needed',
  ],
);

const List<WeatherData> mockWeather = [
  WeatherData(day: 'Today', condition: '⛅ Partly Cloudy', tempHigh: 32, tempLow: 24, humidity: 68),
  WeatherData(day: 'Tomorrow', condition: '🌧 Light Rain', tempHigh: 28, tempLow: 21, humidity: 85),
  WeatherData(day: 'Wed', condition: '☀️ Sunny', tempHigh: 35, tempLow: 26, humidity: 55),
  WeatherData(day: 'Thu', condition: '🌩 Thunderstorm', tempHigh: 27, tempLow: 20, humidity: 90),
  WeatherData(day: 'Fri', condition: '⛅ Partly Cloudy', tempHigh: 31, tempLow: 23, humidity: 65),
];

const List<MarketPrice> mockMarketPrices = [
  MarketPrice(crop: 'Wheat', price: '₹2,250/quintal', change: '+1.2%', isUp: true),
  MarketPrice(crop: 'Rice', price: '₹1,980/quintal', change: '-0.5%', isUp: false),
  MarketPrice(crop: 'Cotton', price: '₹6,800/quintal', change: '+2.8%', isUp: true),
  MarketPrice(crop: 'Soybean', price: '₹4,200/quintal', change: '+0.9%', isUp: true),
  MarketPrice(crop: 'Maize', price: '₹1,750/quintal', change: '-1.1%', isUp: false),
];

const List<GovernmentScheme> mockSchemes = [
  GovernmentScheme(
    name: 'PM-KISAN',
    description: '₹6,000 annual income support for farmers',
    deadline: '30 Jun 2026',
  ),
  GovernmentScheme(
    name: 'Fasal Bima Yojana',
    description: 'Crop insurance against natural calamities',
    deadline: '15 Jul 2026',
  ),
  GovernmentScheme(
    name: 'Soil Health Card Scheme',
    description: 'Free soil testing and health card for farmers',
    deadline: 'Ongoing',
  ),
];
