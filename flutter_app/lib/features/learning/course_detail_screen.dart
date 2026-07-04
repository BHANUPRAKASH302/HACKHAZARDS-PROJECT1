import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:video_player/video_player.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../data/mock/learning_mock.dart';
import '../../shared/widgets/app_button.dart';
import '../../shared/widgets/gradient_card.dart';
import '../../core/router/app_router.dart';

class CourseDetailScreen extends StatelessWidget {
  final Course? course;
  const CourseDetailScreen({super.key, this.course});

  @override
  Widget build(BuildContext context) {
    final course = this.course ?? mockCourses.first;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: AppColors.background,
            expandedHeight: 180,
            pinned: true,
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios_new,
                  color: AppColors.textWhite, size: 18),
              onPressed: () => context.pop(),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    course.bannerAsset,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Color(0xFF0369A1), Color(0xFF0891B2)],
                          ),
                        ),
                      );
                    },
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.4),
                          Colors.transparent,
                          Colors.black.withOpacity(0.6),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Title & info
                Text(course.title, style: AppTextStyles.h1)
                    .animate().fadeIn(duration: 300.ms),
                const SizedBox(height: 6),
                Text(course.subtitle,
                    style: AppTextStyles.bodyMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis)
                    .animate().fadeIn(delay: 80.ms),
                const SizedBox(height: 12),

                Row(
                  children: [
                    Icon(Icons.star, color: Color(0xFFFBBF24), size: 16),
                    const SizedBox(width: 4),
                    Text('${course.rating}',
                        style: AppTextStyles.labelLarge),
                    const SizedBox(width: 4),
                    Text('(${course.ratingCount} reviews)',
                        style: AppTextStyles.bodySmall),
                    const Spacer(),
                    Text(course.level, style: AppTextStyles.bodySmall),
                    const SizedBox(width: 8),
                    Text('• ${course.duration}',
                        style: AppTextStyles.bodySmall),
                  ],
                ).animate().fadeIn(delay: 120.ms),

                const SizedBox(height: 20),

                // Progress
                GradientCard(
                  glowColor: AppColors.eduCyan,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Progress', style: AppTextStyles.labelLarge),
                          Text('${course.progressPercent}%',
                              style: AppTextStyles.labelLarge.copyWith(
                                  color: AppColors.secondaryPurple)),
                        ],
                      ),
                      const SizedBox(height: 10),
                      LinearPercentIndicator(
                        percent: course.progressPercent / 100,
                        lineHeight: 8,
                        backgroundColor: AppColors.border,
                        progressColor: AppColors.primaryPurple,
                        barRadius: const Radius.circular(4),
                        padding: EdgeInsets.zero,
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: 160.ms),

                const SizedBox(height: 24),

                // Course Introduction Video Option
                Text('Course Introduction Video', style: AppTextStyles.h3)
                    .animate().fadeIn(delay: 170.ms),
                const SizedBox(height: 12),
                CourseVideoPlayer(videoAsset: course.videoAsset)
                    .animate().fadeIn(delay: 180.ms),

                const SizedBox(height: 16),

                // Test Option Button
                ElevatedButton.icon(
                  icon: Icon(Icons.quiz, color: AppColors.textWhite, size: 20),
                  label: Text(
                    'Take Course Test',
                    style: AppTextStyles.labelLarge.copyWith(color: AppColors.textWhite),
                  ),
                  onPressed: () {
                    context.push(AppRoutes.courseTest, extra: course);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.secondaryPurple,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ).animate().fadeIn(delay: 190.ms),

                const SizedBox(height: 24),

                Text('Lessons', style: AppTextStyles.h3)
                    .animate().fadeIn(delay: 200.ms),
                const SizedBox(height: 12),

                ...course.lessons.asMap().entries.map((e) {
                  final lesson = e.value;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _LessonTile(lesson: lesson, index: e.key + 1)
                        .animate()
                        .fadeIn(
                          delay: Duration(milliseconds: 240 + 60 * e.key),
                          duration: 300.ms,
                        ),
                  );
                }),

                const SizedBox(height: 24),

                AppButton(
                  label: 'Continue Learning',
                  onPressed: () {},
                ).animate().fadeIn(delay: 600.ms),

                const SizedBox(height: 24),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _LessonTile extends StatelessWidget {
  final Lesson lesson;
  final int index;

  const _LessonTile({required this.lesson, required this.index});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: lesson.isCompleted
              ? AppColors.successGreen.withOpacity(0.3)
              : AppColors.border,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: lesson.isCompleted
                  ? AppColors.successGreen.withOpacity(0.15)
                  : AppColors.primaryPurple.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: lesson.isCompleted
                  ? Icon(Icons.check,
                      color: AppColors.successGreen, size: 16)
                  : Text(
                      '$index',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.secondaryPurple,
                      ),
                    ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(lesson.title, style: AppTextStyles.bodyLarge),
          ),
          Text(lesson.duration, style: AppTextStyles.caption),
          const SizedBox(width: 8),
          Icon(
            lesson.isCompleted
                ? Icons.lock_open_outlined
                : Icons.lock_outline,
            color: lesson.isCompleted
                ? AppColors.successGreen
                : AppColors.textDimmed,
            size: 16,
          ),
        ],
      ),
    );
  }
}

// ── Course Video Player Widget ──────────────────────────────────────────────

class CourseVideoPlayer extends StatefulWidget {
  final String videoAsset;

  const CourseVideoPlayer({super.key, required this.videoAsset});

  @override
  State<CourseVideoPlayer> createState() => _CourseVideoPlayerState();
}

class _CourseVideoPlayerState extends State<CourseVideoPlayer> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _initializeController();
  }

  @override
  void didUpdateWidget(CourseVideoPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.videoAsset != widget.videoAsset) {
      _controller.dispose();
      _isInitialized = false;
      _hasError = false;
      _initializeController();
    }
  }

  void _initializeController() {
    _controller = VideoPlayerController.asset(widget.videoAsset)
      ..initialize().then((_) {
        if (mounted) {
          setState(() {
            _isInitialized = true;
          });
        }
      }).catchError((error) {
        debugPrint('Video Player Error: $error');
        if (mounted) {
          setState(() {
            _hasError = true;
          });
        }
      });
    
    // Set volume to 1.0 (played with the volume)
    _controller.setVolume(1.0);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return Container(
        height: 200,
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, color: AppColors.alertRed, size: 40),
              const SizedBox(height: 8),
              Text(
                'Could not load demo video.',
                style: TextStyle(color: AppColors.textDimmed),
              ),
            ],
          ),
        ),
      );
    }

    if (!_isInitialized) {
      return Container(
        height: 200,
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(
          children: [
            AspectRatio(
              aspectRatio: _controller.value.aspectRatio,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  VideoPlayer(_controller),
                  // Pause / Play overlay
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        if (_controller.value.isPlaying) {
                          _controller.pause();
                        } else {
                          _controller.play();
                        }
                      });
                    },
                    child: Container(
                      color: Colors.black.withOpacity(0.3),
                      child: Center(
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 200),
                          child: Icon(
                            _controller.value.isPlaying
                                ? Icons.pause_circle_filled
                                : Icons.play_circle_filled,
                            color: Colors.white,
                            size: 64,
                            key: ValueKey<bool>(_controller.value.isPlaying),
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Volume indicator overlay in top right
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _controller.value.volume > 0
                                ? Icons.volume_up
                                : Icons.volume_off,
                            color: Colors.white,
                            size: 14,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${(_controller.value.volume * 100).toInt()}%',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Progress Bar / Scrub Bar
            VideoProgressIndicator(
              _controller,
              allowScrubbing: true,
              colors: VideoProgressColors(
                playedColor: AppColors.primaryPurple,
                bufferedColor: AppColors.border,
                backgroundColor: AppColors.card,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
