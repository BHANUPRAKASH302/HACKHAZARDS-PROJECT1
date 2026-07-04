import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

class CaseDetail {
  final String title;
  final String status;
  final String advocate;
  final String date;
  final String description;
  final String judgment;
  final String type;

  const CaseDetail({
    required this.title,
    required this.status,
    required this.advocate,
    required this.date,
    required this.description,
    required this.judgment,
    required this.type,
  });
}

class MyCasesScreen extends StatelessWidget {
  const MyCasesScreen({super.key});

  static const List<CaseDetail> _cases = [
    CaseDetail(
      title: 'Land Dispute: Kumar vs. State of Karnataka',
      status: 'Active',
      advocate: 'Advocate Rajesh K. Sharma',
      date: '10 Jun 2026',
      description: 'Dispute over ancestral boundary encroachment in Devanahalli. Government survey team has been ordered to submit fresh survey reports verifying the village maps of 1974.',
      judgment: 'Awaiting report submission by the Assistant Commissioner of Land Records on the next hearing (July 14, 2026).',
      type: 'Property Law',
    ),
    CaseDetail(
      title: 'Employment Dispute: Nair vs. Infosys Systems',
      status: 'Under Review',
      advocate: 'Advocate Meera Chaudhary',
      date: '05 Jun 2026',
      description: 'Wrongful termination claim filed in the Labour Court. The petitioner claims dismissal without proper notice or payment in lieu, in violation of employment standing orders.',
      judgment: 'Employer filed response statements. Mediation session scheduled for negotiation on severance payout.',
      type: 'Labour Law',
    ),
    CaseDetail(
      title: 'Consumer Complaint: Verma vs. Electra Retailers',
      status: 'Resolved',
      advocate: 'Advocate Priya S. Nair',
      date: '15 May 2026',
      description: 'Complaint filed in the District Consumer Forum regarding delivery of a defective high-end server. Retailer refused refund claiming warranty expiration.',
      judgment: 'District Forum ruled in favor of consumer. Retailer ordered to replace the server and pay ₹50,000 compensation for business interruption.',
      type: 'Consumer Law',
    ),
    CaseDetail(
      title: 'Taxation Appeal: Gupta vs. Income Tax Department',
      status: 'Resolved',
      advocate: 'Advocate Amit V. Patel',
      date: '28 Apr 2026',
      description: 'Appeal filed under Section 246A against arbitrary reassessment of capital gains on agricultural land sale, which was incorrectly classified as urban land.',
      judgment: 'Commissioner of Appeals allowed the appeal, holding that the land is situated beyond 8km from municipality limits and exempt from capital gains.',
      type: 'Tax Law',
    ),
  ];

  Color _getStatusColor(String status) {
    return switch (status) {
      'Active' => AppColors.successGreen,
      'Under Review' => AppColors.legalGold,
      _ => AppColors.textDimmed,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.card,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: AppColors.textWhite, size: 18),
          onPressed: () => context.pop(),
        ),
        title: Text('My Case Directory', style: AppTextStyles.appBarTitle),
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppColors.border),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        itemCount: _cases.length,
        itemBuilder: (context, idx) {
          final c = _cases[idx];
          final statusColor = _getStatusColor(c.status);
          
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.card,
                  AppColors.cardElevated.withOpacity(0.8),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border, width: 1.2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top header bar of the case card
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.border.withOpacity(0.3),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(15),
                      topRight: Radius.circular(15),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: statusColor.withOpacity(0.5)),
                        ),
                        child: Text(
                          c.status.toUpperCase(),
                          style: AppTextStyles.caption.copyWith(
                            color: statusColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        c.type,
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.legalGold,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        c.date,
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textDimmed,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Case Content Details
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        c.title,
                        style: AppTextStyles.h2.copyWith(
                          color: AppColors.textWhite,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      
                      // Advocate Info Row
                      Row(
                        children: [
                          Icon(Icons.person_pin_rounded, size: 16, color: AppColors.textGray),
                          const SizedBox(width: 6),
                          Text(
                            c.advocate,
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.textWhite,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      
                      // Case Description
                      Text(
                        'Case Description',
                        style: AppTextStyles.labelSmall.copyWith(color: AppColors.textGray),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        c.description,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textGray,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 14),
                      
                      // Final Judgment
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.background.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.border.withOpacity(0.5)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.gavel_rounded, size: 15, color: AppColors.legalGold),
                                const SizedBox(width: 6),
                                Text(
                                  c.status == 'Resolved' ? 'Final Judgment' : 'Current Proceedings',
                                  style: AppTextStyles.labelSmall.copyWith(
                                    color: AppColors.legalGold,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              c.judgment,
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.textWhite,
                                fontStyle: FontStyle.italic,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )
          .animate()
          .fadeIn(delay: Duration(milliseconds: 100 * idx), duration: 400.ms)
          .slideY(begin: 0.1, end: 0, curve: Curves.easeOutQuad);
        },
      ),
    );
  }
}
