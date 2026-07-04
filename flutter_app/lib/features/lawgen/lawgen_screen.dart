import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/router/app_router.dart';
import '../../data/mock/lawgen_mock.dart';
import '../../shared/widgets/gradient_card.dart';

class LawgenScreen extends StatelessWidget {
  const LawgenScreen({super.key});

  static const List<String> _serviceAssetPaths = [
    'assets/images/Legal_advisor.webp',
    'assets/images/Law_Judge.jpg',
    'assets/images/Legal_Documents.png',
    'assets/images/Law_Library.jpg',
    'assets/images/Consult_Advocate.webp',
  ];

  static const List<String> _serviceRoutes = [
    AppRoutes.lawgenChat,
    AppRoutes.myCases,
    AppRoutes.legalDocuments,
    AppRoutes.lawLibrary,
    AppRoutes.consultAdvocate,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new,
              color: AppColors.textWhite, size: 18),
          onPressed: () => context.pop(),
        ),
        title: Text('LAWGEN AI', style: AppTextStyles.appBarTitle),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Header card with Brand Logo image
          GradientCard(
            glowColor: AppColors.legalGold,
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Legal Assistance',
                          style: AppTextStyles.h3.copyWith(
                              color: AppColors.legalGold)),
                      const SizedBox(height: 4),
                      Text('AI-powered legal guidance',
                          style: AppTextStyles.bodySmall),
                    ],
                  ),
                ),
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.legalGold.withOpacity(0.3)),
                    image: const DecorationImage(
                      image: AssetImage('assets/images/Legal_Assistance_Logo.png'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(duration: 300.ms),

          const SizedBox(height: 24),

          // Services
          Text('Legal Services', style: AppTextStyles.h3)
              .animate().fadeIn(delay: 100.ms),
          const SizedBox(height: 12),

          ...mockLegalServices.asMap().entries.map((e) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _LegalServiceTile(
                iconPath: _serviceAssetPaths[e.key],
                title: e.value,
                onTap: () => context.push(_serviceRoutes[e.key]),
              )
                  .animate()
                  .fadeIn(
                      delay: Duration(milliseconds: 150 + 60 * e.key),
                      duration: 350.ms)
                  .slideY(begin: 0.1, end: 0),
            );
          }),

          const SizedBox(height: 28),

          // ── INNOVATIVE CORNER ──
          // Text('AI Legal Innovation', style: AppTextStyles.h3)
          //     .animate().fadeIn(delay: 450.ms),
          // const SizedBox(height: 12),

          // // 1. AI Document Scanner Preview Card
          // Container(
          //   padding: const EdgeInsets.all(16),
          //   decoration: BoxDecoration(
          //     gradient: LinearGradient(
          //       colors: [
          //         AppColors.card,
          //         AppColors.cardElevated.withOpacity(0.5),
          //       ],
          //     ),
          //     borderRadius: BorderRadius.circular(16),
          //     border: Border.all(color: AppColors.legalGold.withOpacity(0.25), width: 1.2),
          //   ),
          //   child: Column(
          //     crossAxisAlignment: CrossAxisAlignment.start,
          //     children: [
          //       Row(
          //         children: [
          //           Icon(Icons.document_scanner_rounded, color: AppColors.legalGold, size: 18),
          //           const SizedBox(width: 8),
          //           Text(
          //             'AI CONTRACT ANALYZER',
          //             style: AppTextStyles.caption.copyWith(
          //               color: AppColors.legalGold,
          //               fontWeight: FontWeight.bold,
          //               letterSpacing: 1.0,
          //             ),
          //           ),
          //         ],
          //       ),
          //       const SizedBox(height: 8),
          //       Text(
          //         'Scan Documents for Hidden Risks',
          //         style: AppTextStyles.h2.copyWith(fontSize: 15),
          //       ),
          //       const SizedBox(height: 4),
          //       Text(
          //         'Upload or take a photo of any agreement to instantly highlight unfavorable clauses, liabilities, and key terms in plain English.',
          //         style: AppTextStyles.bodyMedium.copyWith(height: 1.4),
          //       ),
          //       const SizedBox(height: 14),
          //       SizedBox(
          //         width: double.infinity,
          //         child: Container(
          //           decoration: BoxDecoration(
          //             gradient: AppColors.legalGradient,
          //             borderRadius: BorderRadius.circular(24),
          //           ),
          //           child: ElevatedButton.icon(
          //             onPressed: () {
          //               ScaffoldMessenger.of(context).showSnackBar(
          //                 const SnackBar(
          //                   content: Text('Legal Document Scanner is loading...'),
          //                   backgroundColor: AppColors.legalGold,
          //                 ),
          //               );
          //             },
          //             style: ElevatedButton.styleFrom(
          //               backgroundColor: Colors.transparent,
          //               shadowColor: Colors.transparent,
          //               padding: const EdgeInsets.symmetric(vertical: 12),
          //             ),
          //             icon: const Icon(Icons.cloud_upload_rounded, color: Colors.black, size: 18),
          //             label: Text(
          //               'Upload & Scan Contract',
          //               style: AppTextStyles.buttonText.copyWith(color: Colors.black, fontWeight: FontWeight.bold),
          //             ),
          //           ),
          //         ),
          //       ),
          //     ],
          //   ),
          // ).animate().fadeIn(delay: 500.ms, duration: 400.ms).slideY(begin: 0.05, end: 0),

          // const SizedBox(height: 24),

          // 2. Landmark Indian Cases Feed
          Text('Landmark Judgments Simplified', style: AppTextStyles.h3)
              .animate().fadeIn(delay: 550.ms),
          const SizedBox(height: 12),

          SizedBox(
            height: 150,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _buildCaseCard(
                  context,
                  title: 'Right to Privacy (2017)',
                  caseRef: 'Puttaswamy vs. Union of India',
                  description: 'Supreme Court declared Right to Privacy as a fundamental right under Article 21.',
                  gradient: const LinearGradient(colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)]),
                ),
                _buildCaseCard(
                  context,
                  title: 'Decriminalizing Sec 377',
                  caseRef: 'Navtej Johar vs. UOI (2018)',
                  description: 'Consensual homosexual acts decriminalized, upholding equality and personal liberty.',
                  gradient: const LinearGradient(colors: [Color(0xFFEC4899), Color(0xFFBE185D)]),
                ),
                _buildCaseCard(
                  context,
                  title: 'Basic Structure Doctrine',
                  caseRef: 'Kesavananda Bharati (1973)',
                  description: 'Ruled that Parliament cannot amend the fundamental framework of the Constitution.',
                  gradient: const LinearGradient(colors: [Color(0xFFF59E0B), Color(0xFFD97706)]),
                ),
              ],
            ),
          ).animate().fadeIn(delay: 600.ms, duration: 450.ms),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildCaseCard(
    BuildContext context, {
    required String title,
    required String caseRef,
    required String description,
    required Gradient gradient,
  }) {
    return Container(
      width: 250,
      margin: const EdgeInsets.only(right: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  gradient: gradient,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  title,
                  style: AppTextStyles.labelMedium.copyWith(color: AppColors.textWhite, fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            caseRef,
            style: AppTextStyles.caption.copyWith(color: AppColors.legalGold, fontWeight: FontWeight.w600),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Text(
              description,
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.textGray, height: 1.3),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _LegalServiceTile extends StatelessWidget {
  final String iconPath;
  final String title;
  final VoidCallback? onTap;

  const _LegalServiceTile(
      {required this.iconPath, required this.title, this.onTap});

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
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.legalGold.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
                image: !iconPath.endsWith('.svg')
                    ? DecorationImage(
                        image: AssetImage(iconPath),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: iconPath.endsWith('.svg')
                  ? Center(
                      child: SvgPicture.asset(
                        iconPath,
                        width: 22,
                        height: 22,
                        colorFilter: const ColorFilter.mode(AppColors.legalGold, BlendMode.srcIn),
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(title, style: AppTextStyles.labelLarge),
            ),
            Icon(Icons.chevron_right,
                color: AppColors.textDimmed, size: 20),
          ],
        ),
      ),
    );
  }
}
