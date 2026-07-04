import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/router/app_router.dart';
import '../../data/mock/agrogen_mock.dart';
import '../../shared/widgets/gradient_card.dart';
import '../../core/services/auth_service.dart';

class AgrogenScreen extends StatefulWidget {
  const AgrogenScreen({super.key});

  @override
  State<AgrogenScreen> createState() => _AgrogenScreenState();
}

class _AgrogenScreenState extends State<AgrogenScreen> {
  List<dynamic> _weatherForecast = [];
  bool _isWeatherLoading = true;
  String _weatherCity = "Bengaluru";

  @override
  void initState() {
    super.initState();
    _loadWeather();
  }

  Future<void> _loadWeather() async {
    try {
      final baseUrl = await AuthService.instance.getActiveBackendUrl();
      final response = await http.get(Uri.parse('$baseUrl/api/agrogen/weather?city=$_weatherCity'));
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (mounted) {
          setState(() {
            _weatherForecast = data['list'] ?? [];
            _isWeatherLoading = false;
          });
        }
      } else {
        throw Exception("Failed to fetch weather status code: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("[AgroGen] Weather fetch error: $e. Falling back to local mock data.");
      if (mounted) {
        setState(() {
          // Fallback to local mock data from agrogen_mock.dart
          _weatherForecast = mockWeather.map((w) => {
            'day': w.day,
            'condition': w.condition,
            'tempHigh': w.tempHigh,
            'tempLow': w.tempLow,
            'humidity': w.humidity,
          }).toList();
          _isWeatherLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: AppColors.textWhite, size: 18),
          onPressed: () => context.pop(),
        ),
        title: Text('AGROGEN', style: AppTextStyles.appBarTitle),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Banner card with Smart Agriculture Logo
          GradientCard(
            glowColor: AppColors.agriGreen,
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Smart Agriculture',
                          style: AppTextStyles.h3.copyWith(
                              color: AppColors.agriGreen, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text('AI-powered farming solutions',
                          style: AppTextStyles.bodySmall),
                    ],
                  ),
                ),
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(color: AppColors.agriGreen.withOpacity(0.3), blurRadius: 8)
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Image.asset(
                      'assets/images/Smart_Agriculture_Logo.jpg',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(duration: 300.ms),

          const SizedBox(height: 20),

          // 2x3 service tiles with custom asset logos
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.5,
            children: [
              _AgroTile(
                imagePath: 'assets/images/AI_Crop_Advisor.jpg',
                title: 'Crop Advisor',
                subtitle: 'Chat with AI Advisor',
                onTap: () => context.push(AppRoutes.cropAdvisor),
              ),
              _AgroTile(
                imagePath: 'assets/images/Farm_Details.jpg',
                title: 'Farm Details',
                subtitle: 'Manage crop fields',
                onTap: () => context.push(AppRoutes.farmDetails),
              ),
              _AgroTile(
                imagePath: 'assets/images/Pesticides.png',
                title: 'Pesticides',
                subtitle: 'Pesticide guide',
                onTap: () => context.push(AppRoutes.pesticides),
              ),
              _AgroTile(
                imagePath: 'assets/images/Buy_Products.png',
                title: 'Buy Products',
                subtitle: 'Seeds, fertilizers & tools',
                onTap: () => context.push(AppRoutes.buyProducts),
              ),
              _AgroTile(
                imagePath: 'assets/images/Gov_Schemes_Logo.png',
                title: 'Gov. Schemes',
                subtitle: 'Subsidies & benefits',
                onTap: () => context.push(AppRoutes.govSchemes),
              ),
              _AgroTile(
                imagePath: 'assets/images/Live_Tracking.png',
                title: 'Live Tracking',
                subtitle: 'Video guides & monitoring',
                onTap: () => context.push(AppRoutes.liveTracking),
              ),
            ],
          ).animate().fadeIn(delay: 150.ms),

          const SizedBox(height: 24),

          // Weather Forecast Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Live Weather Forecast', style: AppTextStyles.h3),
              DropdownButton<String>(
                value: _weatherCity,
                dropdownColor: AppColors.card,
                underline: const SizedBox(),
                icon: Icon(Icons.location_on, color: AppColors.agriGreen, size: 16),
                style: TextStyle(color: AppColors.agriGreen, fontSize: 12, fontWeight: FontWeight.bold),
                items: ['Bengaluru', 'Delhi', 'Mumbai', 'Hyderabad', 'Chennai'].map((String val) {
                  return DropdownMenuItem<String>(
                    value: val,
                    child: Text(val),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) {
                    setState(() {
                      _weatherCity = val;
                      _isWeatherLoading = true;
                    });
                    _loadWeather();
                  }
                },
              ),
            ],
          ).animate().fadeIn(delay: 250.ms),
          const SizedBox(height: 12),

          // Redesigned Weather dashboard panel
          _isWeatherLoading
              ? Container(
                  height: 140,
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Center(child: CircularProgressIndicator()),
                )
              : _buildWeatherDashboard(),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildWeatherDashboard() {
    if (_weatherForecast.isEmpty) return const SizedBox();

    final today = _weatherForecast.first;
    final nextDays = _weatherForecast.skip(1).toList();

    return Column(
      children: [
        // Today weather main card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.agriGreen.withOpacity(0.35), const Color(0xFF0F1E36)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.agriGreen.withOpacity(0.5)),
            boxShadow: [
              BoxShadow(color: AppColors.agriGreen.withOpacity(0.15), blurRadius: 12, spreadRadius: 1)
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('TODAY IN $_weatherCity', style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                  const SizedBox(height: 8),
                  Text('${today['tempHigh']}°C', style: AppTextStyles.h1.copyWith(fontSize: 38, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 4),
                  Text(
                    '${today['condition']}',
                    style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textWhite, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    today['condition'].toString().split(' ').first,
                    style: const TextStyle(fontSize: 50),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.water_drop, color: Colors.blue, size: 14),
                      const SizedBox(width: 4),
                      Text('Humidity: ${today['humidity']}%', style: AppTextStyles.caption),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ).animate().fadeIn(duration: 300.ms),

        const SizedBox(height: 12),

        // Rest of 4 days forecast horizontal list
        SizedBox(
          height: 100,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: nextDays.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (ctx, i) {
              final w = nextDays[i];
              return Container(
                width: 82,
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(w['day'], style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(w['condition'].toString().split(' ').first,
                        style: const TextStyle(fontSize: 22)),
                    const SizedBox(height: 4),
                    Text('${w['tempHigh']}°/${w['tempLow']}°',
                        style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.bold)),
                  ],
                ),
              );
            },
          ),
        ).animate().fadeIn(delay: 150.ms),
      ],
    );
  }
}

class _AgroTile extends StatelessWidget {
  final String imagePath;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  const _AgroTile({
    required this.imagePath,
    required this.title,
    required this.subtitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(color: Colors.black12, blurRadius: 4, spreadRadius: 1)
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(
                  imagePath,
                  width: 32,
                  height: 32,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(title,
                style: AppTextStyles.labelLarge.copyWith(fontWeight: FontWeight.bold, fontSize: 13),
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
            Text(subtitle,
                style: AppTextStyles.caption.copyWith(fontSize: 10),
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }
}
