import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/router/app_router.dart';
import '../../data/mock/learning_mock.dart';
import '../../shared/widgets/gradient_card.dart';

class LearningScreen extends StatefulWidget {
  const LearningScreen({super.key});

  @override
  State<LearningScreen> createState() => _LearningScreenState();
}

class _LearningScreenState extends State<LearningScreen> {
  final _searchCtrl = TextEditingController();
  String _selectedCategory = 'All';

  final _continueCourse = mockCourses.firstWhere(
      (c) => c.id == mockContinueLearningCourseId);

  @override
  Widget build(BuildContext context) {
    final categories = [
      const CourseCategory(name: 'All', icon: ''),
      ...mockCategories
    ];
    final filteredCourses = _selectedCategory == 'All'
        ? mockCourses
        : mockCourses.where((c) => c.category == _selectedCategory).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new,
              color: AppColors.textWhite, size: 18),
          onPressed: () => context.pop(),
        ),
        title: Text('LEARNING', style: AppTextStyles.appBarTitle),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Search bar
          Container(
            height: 46,
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: TextField(
              controller: _searchCtrl,
              style: AppTextStyles.bodyLarge,
              decoration: InputDecoration(
                hintText: 'Search courses, topics...',
                hintStyle: AppTextStyles.bodyMedium,
                prefixIcon: Icon(Icons.search,
                    color: AppColors.textDimmed, size: 20),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ).animate().fadeIn(duration: 300.ms),

          const SizedBox(height: 20),

          // Continue Learning card
          _ContinueLearningCard(course: _continueCourse)
              .animate().fadeIn(delay: 100.ms).slideY(begin: 0.1, end: 0),

          const SizedBox(height: 24),

          // Top Categories
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Top Categories', style: AppTextStyles.h3),
              TextButton(
                onPressed: () {},
                child: Text('View All',
                    style: AppTextStyles.labelMedium
                        .copyWith(color: AppColors.secondaryPurple)),
              ),
            ],
          ).animate().fadeIn(delay: 150.ms),

          const SizedBox(height: 12),

          SizedBox(
            height: 40,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: categories.length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (ctx, i) {
                final cat = categories[i];
                final isSelected = cat.name == _selectedCategory;
                return GestureDetector(
                  onTap: () => setState(() => _selectedCategory = cat.name),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      gradient: isSelected ? AppColors.primaryGradient : null,
                      color: isSelected ? null : AppColors.card,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primaryPurple
                            : AppColors.border,
                      ),
                    ),
                    child: Text(
                      '${cat.icon} ${cat.name}',
                      style: AppTextStyles.labelMedium.copyWith(
                        color: isSelected
                            ? AppColors.textWhite
                            : AppColors.textGray,
                      ),
                    ),
                  ),
                );
              },
            ),
          ).animate().fadeIn(delay: 200.ms),

          const SizedBox(height: 24),

          // Recommended
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Recommended for You', style: AppTextStyles.h3),
              TextButton(
                onPressed: () {},
                child: Text('View All',
                    style: AppTextStyles.labelMedium
                        .copyWith(color: AppColors.secondaryPurple)),
              ),
            ],
          ).animate().fadeIn(delay: 250.ms),

          const SizedBox(height: 12),

          ...filteredCourses.asMap().entries.map((e) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _CourseCard(
                course: e.value,
                onTap: () => context.push(AppRoutes.courseDetail, extra: e.value),
              )
                  .animate()
                  .fadeIn(
                      delay: Duration(milliseconds: 300 + 80 * e.key),
                      duration: 400.ms)
                  .slideY(begin: 0.1, end: 0),
            );
          }),
        ],
      ),
    );
  }
}

// ── Continue Learning Card ────────────────────────────────────────────────────

class _ContinueLearningCard extends StatelessWidget {
  final Course course;
  const _ContinueLearningCard({required this.course});

  @override
  Widget build(BuildContext context) {
    return GradientCard(
      glowColor: AppColors.eduCyan,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Continue Learning', style: AppTextStyles.labelMedium),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.eduCyan.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text('In Progress',
                    style: AppTextStyles.caption
                        .copyWith(color: AppColors.eduCyan)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(course.title, style: AppTextStyles.h3),
          const SizedBox(height: 4),
          Text(course.subtitle,
              style: AppTextStyles.bodySmall,
              maxLines: 1,
              overflow: TextOverflow.ellipsis),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: LinearProgressIndicator(
                  value: course.progressPercent / 100,
                  backgroundColor: AppColors.border,
                  valueColor:
                      const AlwaysStoppedAnimation(AppColors.primaryPurple),
                  borderRadius: BorderRadius.circular(4),
                  minHeight: 6,
                ),
              ),
              const SizedBox(width: 12),
              Text('${course.progressPercent}% Complete',
                  style: AppTextStyles.caption),
            ],
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton(
              onPressed: () => context.push(AppRoutes.courseDetail, extra: course),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryPurple,
                minimumSize: const Size(100, 36),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              child: Text('Continue',
                  style: AppTextStyles.labelMedium
                      .copyWith(color: AppColors.textWhite)),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Course Card ───────────────────────────────────────────────────────────────

class _CourseCard extends StatelessWidget {
  final Course course;
  final VoidCallback onTap;

  const _CourseCard({required this.course, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.cardElevated,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Image.asset(
                  course.logoAsset,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      decoration: BoxDecoration(
                        gradient: AppColors.eduGradient,
                      ),
                      child: const Center(
                        child: Text('📖', style: TextStyle(fontSize: 26)),
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(course.title,
                      style: AppTextStyles.labelLarge,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 2),
                  Text(course.instructor, style: AppTextStyles.bodySmall),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(Icons.star,
                          color: Color(0xFFFBBF24), size: 14),
                      const SizedBox(width: 3),
                      Text('${course.rating}',
                          style: AppTextStyles.caption
                              .copyWith(color: AppColors.textWhite)),
                      const SizedBox(width: 8),
                      Text(course.level, style: AppTextStyles.caption),
                      const Spacer(),
                      Text(course.duration, style: AppTextStyles.caption),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
