import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

class AgriVideoInfo {
  final String title;
  final String duration;
  final String language;
  final String youtubeUrl;
  final String videoId;

  const AgriVideoInfo({
    required this.title,
    required this.duration,
    required this.language,
    required this.youtubeUrl,
    required this.videoId,
  });

  String get thumbnailUrl => 'https://img.youtube.com/vi/$videoId/hqdefault.jpg';
}

class LiveTrackingScreen extends StatelessWidget {
  const LiveTrackingScreen({super.key});

  final List<AgriVideoInfo> _videos = const [
    AgriVideoInfo(
      title: 'Future of Smart Agriculture & IoT Farming Techniques',
      duration: '14:25',
      language: 'English',
      youtubeUrl: 'https://www.youtube.com/watch?v=rqHW2HhgGQ0',
      videoId: 'rqHW2HhgGQ0',
    ),
    AgriVideoInfo(
      title: 'Modern Crop Management & Smart Pest Control Live Seminar',
      duration: 'Live',
      language: 'Hindi',
      youtubeUrl: 'https://www.youtube.com/live/N0YIbUiZL4o?si=5k2t2p36KZop7NOL',
      videoId: 'N0YIbUiZL4o',
    ),
    AgriVideoInfo(
      title: 'Sustainable Farming Practices & Soil Nutrition Workshop',
      duration: 'Live',
      language: 'Telugu',
      youtubeUrl: 'https://www.youtube.com/live/0aWcbBY1vDY?si=4TN5tWwJ2wu4iuH5',
      videoId: '0aWcbBY1vDY',
    ),
    AgriVideoInfo(
      title: 'Global Live Weather Feed & Climate Impact Updates',
      duration: 'Live',
      language: 'English',
      youtubeUrl: 'https://www.youtube.com/live/wt6SIE7BXS8?si=X7CxXTAGChA9YcZf',
      videoId: 'wt6SIE7BXS8',
    ),
  ];

  Future<void> _playVideo(BuildContext context, String urlString) async {
    final Uri url = Uri.parse(urlString);
    try {
      if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
        throw Exception('Could not launch $url');
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to open video link: $e')),
        );
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
        title: Text('Live Tracking & Guides', style: AppTextStyles.appBarTitle),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header info
            Text(
              'Field Monitoring & Video Guides',
              style: AppTextStyles.h2.copyWith(color: AppColors.agriGreen),
            ).animate().fadeIn(duration: 300.ms),
            const SizedBox(height: 4),
            Text(
              'Watch informative YouTube guides on modern farming techniques, regional crops, and organic methods.',
              style: AppTextStyles.bodySmall,
            ),
            const SizedBox(height: 20),

            // Videos List (Simple column mapping, highly robust)
            Column(
              children: _videos.asMap().entries.map((entry) {
                final i = entry.key;
                final v = entry.value;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: Card(
                    color: AppColors.card,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(color: AppColors.border),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Thumbnail Stack
                        GestureDetector(
                          onTap: () => _playVideo(context, v.youtubeUrl),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Image.network(
                                v.thumbnailUrl,
                                height: 180,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                loadingBuilder: (context, child, loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return Container(
                                    height: 180,
                                    color: Colors.black26,
                                    child: const Center(
                                      child: CircularProgressIndicator(color: Colors.red),
                                    ),
                                  );
                                },
                                errorBuilder: (ctx, err, stack) => Container(
                                  height: 180,
                                  color: Colors.black38,
                                  child: const Center(
                                    child: Icon(Icons.play_circle_fill, color: Colors.grey, size: 50),
                                  ),
                                ),
                              ),
                              // YouTube Red Play Icon Overlay
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.3),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.play_circle_filled,
                                  size: 64,
                                  color: Colors.red,
                                ),
                              ),
                              Positioned(
                                right: 12,
                                bottom: 12,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.75),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    v.duration,
                                    style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                        
                        // Metadata Panel
                        Padding(
                          padding: const EdgeInsets.all(14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: AppColors.agriGreen.withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      v.language,
                                      style: TextStyle(
                                        color: AppColors.agriGreen,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.red.withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: const Row(
                                      children: [
                                        Icon(Icons.video_library, color: Colors.red, size: 10),
                                        SizedBox(width: 4),
                                        Text(
                                          'YouTube',
                                          style: TextStyle(color: Colors.red, fontSize: 10, fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                v.title,
                                style: AppTextStyles.labelLarge.copyWith(fontWeight: FontWeight.bold, fontSize: 15),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ).animate().slideY(begin: 0.1, duration: 250.ms).fadeIn(delay: Duration(milliseconds: 50 * i));
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
