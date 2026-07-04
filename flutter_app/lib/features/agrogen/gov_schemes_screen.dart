import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

class GovSchemeInfo {
  final String code;
  final String title;
  final String subtitle;
  final String benefit;
  final String eligibility;
  final String deadline;

  const GovSchemeInfo({
    required this.code,
    required this.title,
    required this.subtitle,
    required this.benefit,
    required this.eligibility,
    required this.deadline,
  });
}

class GovSchemesScreen extends StatelessWidget {
  const GovSchemesScreen({super.key});

  final List<GovSchemeInfo> _schemes = const [
    GovSchemeInfo(
      code: 'PM-KISAN',
      title: 'PM Kisan Samman Nidhi',
      subtitle: 'Direct financial income support for landholding farming families.',
      benefit: '₹6,000 per year in three equal installments directly to bank accounts.',
      eligibility: 'All landholding farmer families across the country.',
      deadline: '31 Aug 2026',
    ),
    GovSchemeInfo(
      code: 'PMFBY',
      title: 'Pradhan Mantri Fasal Bima',
      subtitle: 'Crop insurance protection against yield losses from natural hazards.',
      benefit: 'Full insurance coverage for crops with extremely low premium (1.5% - 2%).',
      eligibility: 'All farmers growing notified crops in notified areas.',
      deadline: '15 Jul 2026',
    ),
    GovSchemeInfo(
      code: 'KCC',
      title: 'Kisan Credit Card',
      subtitle: 'Concessional short-term credit facility for agricultural credit requirements.',
      benefit: 'Loans up to ₹3 Lakh at low interest (4%) with flexible repayment terms.',
      eligibility: 'All active crop cultivators, owner-cultivators, and tenant farmers.',
      deadline: 'Ongoing',
    ),
    GovSchemeInfo(
      code: 'SHC',
      title: 'Soil Health Card Scheme',
      subtitle: 'Provides detailed soil nutrient reports to optimize chemical and organic usage.',
      benefit: 'Free soil analysis test reports and customized fertilizer dosage recommendations.',
      eligibility: 'All farmers having cultivable land in India.',
      deadline: 'No Deadline',
    ),
    GovSchemeInfo(
      code: 'PMKSY',
      title: 'PM Krishi Sinchayee Yojana',
      subtitle: 'Promotes precision drip irrigation systems and water conservation.',
      benefit: 'Up to 55% financial subsidy on installing drip or sprinkler irrigation kits.',
      eligibility: 'Any farmer with cultivable land and access to a water source.',
      deadline: '30 Sep 2026',
    ),
    GovSchemeInfo(
      code: 'PM-KMY',
      title: 'Kisan Maandhan Yojana',
      subtitle: 'Voluntary contribution-based pension program for small and marginal farmers.',
      benefit: 'Assured minimum monthly pension of ₹3,000 after attaining 60 years of age.',
      eligibility: 'Small & marginal farmers between 18 and 40 years old.',
      deadline: 'Ongoing',
    ),
    GovSchemeInfo(
      code: 'e-NAM',
      title: 'National Agri Market',
      subtitle: 'Unified electronic trading portal linking physical APMC mandis.',
      benefit: 'Direct access to national buyers, transparency in price bid valuation.',
      eligibility: 'Farmers, traders, and agricultural cooperative societies.',
      deadline: 'Register Free',
    ),
    GovSchemeInfo(
      code: 'RKVY',
      title: 'Rashtriya Krishi Vikas',
      subtitle: 'Support for high-yield technology development and infrastructure projects.',
      benefit: 'Grants and low-interest loans to construct custom hiring centers, greenhouses.',
      eligibility: 'Farmer groups, Farmer Producer Organizations (FPOs), individuals.',
      deadline: '15 Oct 2026',
    ),
    GovSchemeInfo(
      code: 'ACABC',
      title: 'Agri-Clinics & Business Centres',
      subtitle: 'Support for set up of agriculture business startups.',
      benefit: '36% to 44% subsidy on capital loans to launch agri-clinics or centers.',
      eligibility: 'Agriculture graduates, diploma holders, and trained science graduates.',
      deadline: '30 Nov 2026',
    ),
  ];

  void _showApplyDialog(BuildContext context, GovSchemeInfo scheme) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: AppColors.border),
        ),
        title: Row(
          children: [
            Icon(Icons.assignment_turned_in, color: AppColors.agriGreen),
            const SizedBox(width: 8),
            const Text('Apply Initiated', style: TextStyle(color: Colors.white)),
          ],
        ),
        content: Text(
          'Your application file for "${scheme.code}" has been compiled. You will receive an SMS checklist link to submit your Aadhaar and land record papers shortly.',
          style: AppTextStyles.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Done', style: TextStyle(color: AppColors.agriGreen, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
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
        title: Text('Gov. Schemes', style: AppTextStyles.appBarTitle),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Government Benefits & Subsidies',
              style: AppTextStyles.h2.copyWith(color: AppColors.agriGreen),
            ).animate().fadeIn(duration: 300.ms),
            const SizedBox(height: 4),
            Text(
              'Apply for active schemes to secure financial aids, crop safety, and tech upgrades.',
              style: AppTextStyles.bodySmall,
            ),
            const SizedBox(height: 20),

            // Schemes list wrapped inside a simple Column (Highly robust, avoids GridView height crash)
            Column(
              children: _schemes.asMap().entries.map((entry) {
                final i = entry.key;
                final s = entry.value;
                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.agriGreen.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                s.code,
                                style: TextStyle(
                                  color: AppColors.agriGreen,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.grey.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                'Deadline: ${s.deadline}',
                                style: TextStyle(color: Colors.amber[400], fontSize: 10),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          s.title,
                          style: AppTextStyles.labelLarge.copyWith(fontWeight: FontWeight.bold, fontSize: 16),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          s.subtitle,
                          style: AppTextStyles.caption,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 16),
                        const Divider(color: Colors.grey, height: 1),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Benefit: ${s.benefit}',
                                    style: AppTextStyles.caption.copyWith(color: AppColors.textWhite, fontSize: 10),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Eligible: ${s.eligibility}',
                                    style: const TextStyle(color: Colors.grey, fontSize: 9),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            SizedBox(
                              height: 32,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.agriGreen,
                                  padding: const EdgeInsets.symmetric(horizontal: 16),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  minimumSize: const Size(0, 0),
                                ),
                                onPressed: () => _showApplyDialog(context, s),
                                child: const Text('Apply Now', style: TextStyle(color: Colors.white, fontSize: 11)),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ).animate().slideY(begin: 0.1, duration: 250.ms).fadeIn(delay: Duration(milliseconds: 30 * i));
              }).toList(),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
