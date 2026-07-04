import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

class HealthArticlesScreen extends StatefulWidget {
  const HealthArticlesScreen({super.key});

  @override
  State<HealthArticlesScreen> createState() => _HealthArticlesScreenState();
}

class _HealthArticlesScreenState extends State<HealthArticlesScreen> {
  final PageController _pageController = PageController(viewportFraction: 0.82);
  double _currentPage = 0.0;

  final List<Map<String, dynamic>> _articles = [
    {
      'image': 'assets/images/Article1.png',
      'title': 'Cardiovascular Fitness & Heart Health',
      'category': 'Cardiology',
      'readTime': '4 min read',
      'summary': 'Discover essential exercises, nutrition choices, and lifestyle habits that help optimize heart performance and prevent cardiovascular risks.',
      'isLiked': false,
      'isRead': false,
    },
    {
      'image': 'assets/images/Article2.png',
      'title': 'Advanced Skin Care Protocols',
      'category': 'Dermatology',
      'readTime': '5 min read',
      'summary': 'Learn the clinical secrets of skin hydration, antioxidant defense systems, UV protection, and custom ingredient pairing for radiant skin.',
      'isLiked': false,
      'isRead': false,
    },
    {
      'image': 'assets/images/Article3.png',
      'title': 'The Biology of Balanced Nutrition',
      'category': 'Nutrition',
      'readTime': '6 min read',
      'summary': 'Deconstruct macronutrient profiles, clean eating schedules, hydration guidelines, and metabolic enhancers that boost physical endurance.',
      'isLiked': false,
      'isRead': false,
    },
    {
      'image': 'assets/images/Article4.png',
      'title': 'Mental Wellness & Stress Resilience',
      'category': 'Psychiatry',
      'readTime': '3 min read',
      'summary': 'Incorporate evidence-based cognitive strategies, mindfulness triggers, breathing exercises, and sleep hygiene workflows for peak mental stamina.',
      'isLiked': false,
      'isRead': false,
    },
    {
      'image': 'assets/images/Article5.png',
      'title': 'Pediatric Preventive Care Guidelines',
      'category': 'Pediatrics',
      'readTime': '5 min read',
      'summary': 'A comprehensive walkthrough on immunization schedules, healthy growth markers, nutrient intakes, and cognitive stimulation routines for kids.',
      'isLiked': false,
      'isRead': false,
    },
  ];

  @override
  void initState() {
    super.initState();
    _pageController.addListener(() {
      if (_pageController.hasClients) {
        setState(() {
          _currentPage = _pageController.page ?? 0.0;
        });
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _toggleLike(int index) {
    setState(() {
      _articles[index]['isLiked'] = !_articles[index]['isLiked'];
    });
  }

  void _toggleRead(int index) {
    setState(() {
      _articles[index]['isRead'] = !_articles[index]['isRead'];
    });
    if (_articles[index]['isRead']) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Marked "${_articles[index]['title']}" as read!'),
          backgroundColor: AppColors.successGreen,
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: AppColors.textWhite, size: 18),
          onPressed: () => context.pop(),
        ),
        title: Text('Health Articles', style: AppTextStyles.appBarTitle),
      ),
      body: Column(
        children: [
          const SizedBox(height: 16),
          // Heading
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              'Explore Expert Insights',
              style: AppTextStyles.h2,
            ),
          ),
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              'Swipe to read the latest breakthroughs and medical guides.',
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.textDimmed),
            ),
          ),
          const SizedBox(height: 24),

          // Swiper PageView Carousel
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: _articles.length,
              itemBuilder: (ctx, index) {
                final article = _articles[index];
                
                // Calculate scale offset relative to current page
                final pageOffset = (index - _currentPage);
                final scale = (1.0 - (pageOffset.abs() * 0.12)).clamp(0.8, 1.0);
                final opacity = (1.0 - (pageOffset.abs() * 0.4)).clamp(0.5, 1.0);

                return Transform.scale(
                  scale: scale,
                  child: Opacity(
                    opacity: opacity,
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.border),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.medicalBlue.withOpacity(0.06),
                            blurRadius: 16,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(19),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Article Image
                            Expanded(
                              flex: 5,
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  Image.asset(
                                    article['image']!,
                                    fit: BoxFit.cover,
                                  ),
                                  // Category Badge Overlay
                                  Positioned(
                                    top: 14,
                                    left: 14,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: AppColors.background.withOpacity(0.8),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: AppColors.medicalBlue.withOpacity(0.5)),
                                      ),
                                      child: Text(
                                        article['category']!,
                                        style: AppTextStyles.caption.copyWith(
                                          color: AppColors.medicalBlue,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Details Area
                            Expanded(
                              flex: 4,
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          article['readTime']!,
                                          style: AppTextStyles.caption.copyWith(color: AppColors.textDimmed),
                                        ),
                                        if (article['isRead'])
                                          Row(
                                            children: const [
                                              Icon(Icons.check_circle, color: AppColors.successGreen, size: 14),
                                              SizedBox(width: 4),
                                              Text(
                                                'Read',
                                                style: TextStyle(fontSize: 11, color: AppColors.successGreen, fontWeight: FontWeight.bold),
                                              ),
                                            ],
                                          ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      article['title']!,
                                      style: AppTextStyles.labelLarge,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 6),
                                    Expanded(
                                      child: Text(
                                        article['summary']!,
                                        style: AppTextStyles.bodySmall.copyWith(color: AppColors.textDimmed),
                                        maxLines: 3,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        // Bookmark / Read button
                                        OutlinedButton.icon(
                                          onPressed: () => _toggleRead(index),
                                          style: OutlinedButton.styleFrom(
                                            side: BorderSide(
                                              color: article['isRead'] ? AppColors.successGreen : AppColors.border,
                                            ),
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                            padding: const EdgeInsets.symmetric(horizontal: 12),
                                          ),
                                          icon: Icon(
                                            article['isRead'] ? Icons.bookmark : Icons.bookmark_border,
                                            size: 14,
                                            color: article['isRead'] ? AppColors.successGreen : AppColors.textWhite,
                                          ),
                                          label: Text(
                                            article['isRead'] ? 'Completed' : 'Mark as Read',
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: article['isRead'] ? AppColors.successGreen : AppColors.textWhite,
                                            ),
                                          ),
                                        ),
                                        // Like button with scale animation
                                        IconButton(
                                          icon: Icon(
                                            article['isLiked'] ? Icons.favorite : Icons.favorite_border,
                                            color: article['isLiked'] ? AppColors.alertRed : AppColors.textDimmed,
                                            size: 20,
                                          ),
                                          onPressed: () => _toggleLike(index),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Custom Page Indicator Dots
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_articles.length, (i) {
                final pageOffset = (i - _currentPage).abs();
                final isSelected = pageOffset < 0.5;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: isSelected ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    color: isSelected ? AppColors.medicalBlue : AppColors.border,
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}
