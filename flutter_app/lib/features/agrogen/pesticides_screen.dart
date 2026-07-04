import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

class CropPesticideInfo {
  final String name;
  final String imageUrl;
  final String recommendedPesticide;
  final String commonDiseases;
  final String applicationDosage;
  final double toxicityScore; // 0 to 1
  final String toxicityLabel;
  final Color toxicityColor;
  final double efficacyScore; // 0 to 1
  final double safetyPeriodScore; // 0 to 1
  final String safetyPeriodLabel;

  const CropPesticideInfo({
    required this.name,
    required this.imageUrl,
    required this.recommendedPesticide,
    required this.commonDiseases,
    required this.applicationDosage,
    required this.toxicityScore,
    required this.toxicityLabel,
    required this.toxicityColor,
    required this.efficacyScore,
    required this.safetyPeriodScore,
    required this.safetyPeriodLabel,
  });
}

class PesticidesScreen extends StatefulWidget {
  const PesticidesScreen({super.key});

  @override
  State<PesticidesScreen> createState() => _PesticidesScreenState();
}

class _PesticidesScreenState extends State<PesticidesScreen> {
  int _selectedIndex = 0;

  Widget _buildCropImage(String pathOrUrl, {required double size}) {
    if (pathOrUrl.startsWith('assets/')) {
      return Image.asset(
        pathOrUrl,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Container(
          color: AppColors.border,
          child: Icon(Icons.grass, size: size * 0.5, color: AppColors.agriGreen),
        ),
      );
    } else {
      return Image.network(
        pathOrUrl,
        width: size,
        height: size,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            width: size,
            height: size,
            color: AppColors.border,
            child: const Center(
              child: SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) => Container(
          color: AppColors.border,
          child: Icon(Icons.grass, size: size * 0.5, color: AppColors.agriGreen),
        ),
      );
    }
  }

  final List<CropPesticideInfo> _crops = const [
    CropPesticideInfo(
      name: 'Rice',
      imageUrl: 'https://images.unsplash.com/photo-1586201375761-83865001e31c?q=80&w=600',
      recommendedPesticide: 'Tricyclazole (Blast Buster) / Cartap Hydrochloride',
      commonDiseases: 'Blast Disease, Stem Borer, Leaf Folder',
      applicationDosage: '120g to 150g per acre mixed with 200L water',
      toxicityScore: 0.45,
      toxicityLabel: 'Moderately Toxic (Yellow)',
      toxicityColor: Colors.yellow,
      efficacyScore: 0.88,
      safetyPeriodScore: 0.50,
      safetyPeriodLabel: '15 Days waiting period before harvest',
    ),
    CropPesticideInfo(
      name: 'Cotton',
      imageUrl: 'assets/images/cotton_crop.png',
      recommendedPesticide: 'Imidacloprid / Cypermethrin',
      commonDiseases: 'Whitefly, Bollworm, Jassids',
      applicationDosage: '80ml to 100ml per acre mixed with 200L water',
      toxicityScore: 0.75,
      toxicityLabel: 'Highly Toxic (Orange)',
      toxicityColor: Colors.orange,
      efficacyScore: 0.92,
      safetyPeriodScore: 0.70,
      safetyPeriodLabel: '21 Days waiting period before harvest',
    ),
    CropPesticideInfo(
      name: 'Maize',
      imageUrl: 'assets/images/maize_crop.png',
      recommendedPesticide: 'Chlorantraniliprole (Coragen)',
      commonDiseases: 'Fall Armyworm, Maize Stem Borer',
      applicationDosage: '80ml per acre mixed with 200L water',
      toxicityScore: 0.25,
      toxicityLabel: 'Slightly Toxic (Green)',
      toxicityColor: Colors.green,
      efficacyScore: 0.95,
      safetyPeriodScore: 0.30,
      safetyPeriodLabel: '10 Days waiting period before harvest',
    ),
    CropPesticideInfo(
      name: 'Red Gram',
      imageUrl: 'assets/images/red_gram_crop.png',
      recommendedPesticide: 'Indoxacarb (Avant) / Emamectin Benzoate',
      commonDiseases: 'Pod Borer, Plume Moth',
      applicationDosage: '150ml to 200ml per acre mixed with 200L water',
      toxicityScore: 0.55,
      toxicityLabel: 'Moderately Toxic (Yellow)',
      toxicityColor: Colors.yellow,
      efficacyScore: 0.85,
      safetyPeriodScore: 0.45,
      safetyPeriodLabel: '14 Days waiting period before harvest',
    ),
    CropPesticideInfo(
      name: 'Groundnut',
      imageUrl: 'https://images.unsplash.com/photo-1568254183919-78a4f43a2877?q=80&w=600',
      recommendedPesticide: 'Mancozeb / Carbendazim',
      commonDiseases: 'Tikka Leaf Spot, Rust, Root Rot',
      applicationDosage: '300g to 400g per acre mixed with 200L water',
      toxicityScore: 0.20,
      toxicityLabel: 'Slightly Toxic (Green)',
      toxicityColor: Colors.green,
      efficacyScore: 0.80,
      safetyPeriodScore: 0.25,
      safetyPeriodLabel: '7 Days waiting period before harvest',
    ),
    CropPesticideInfo(
      name: 'Chili',
      imageUrl: 'https://images.unsplash.com/photo-1588252303782-cb80119abd6d?q=80&w=600',
      recommendedPesticide: 'Fipronil / Acetamiprid',
      commonDiseases: 'Thrips, Aphids, Powdery Mildew, Dieback',
      applicationDosage: '100ml to 120ml per acre mixed with 200L water',
      toxicityScore: 0.60,
      toxicityLabel: 'Moderately Toxic (Yellow-Orange)',
      toxicityColor: Colors.amber,
      efficacyScore: 0.90,
      safetyPeriodScore: 0.40,
      safetyPeriodLabel: '12 Days waiting period before harvest',
    ),
    CropPesticideInfo(
      name: 'Turmeric',
      imageUrl: 'https://images.unsplash.com/photo-1615485290382-441e4d049cb5?q=80&w=600',
      recommendedPesticide: 'Azoxystrobin (Amistar) / Metalaxyl',
      commonDiseases: 'Leaf Spot, Rhizome Rot',
      applicationDosage: '200ml per acre mixed with 200L water',
      toxicityScore: 0.15,
      toxicityLabel: 'Slightly Toxic (Green)',
      toxicityColor: Colors.green,
      efficacyScore: 0.86,
      safetyPeriodScore: 0.30,
      safetyPeriodLabel: '10 Days waiting period before harvest',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final selectedCrop = _crops[_selectedIndex];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: AppColors.textWhite, size: 18),
          onPressed: () => context.pop(),
        ),
        title: Text('Pesticides Guide', style: AppTextStyles.appBarTitle),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header introduction
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Crop Protection Recommendations',
                  style: AppTextStyles.h2.copyWith(color: AppColors.agriGreen),
                ),
                const SizedBox(height: 4),
                Text(
                  'Select a crop below to view recommended pesticides and safety profiles.',
                  style: AppTextStyles.bodySmall,
                ),
              ],
            ),
          ).animate().fadeIn(duration: 300.ms),

          // Horizontal Crop Selector
          const SizedBox(height: 12),
          Container(
            height: 90,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _crops.length,
              itemBuilder: (ctx, i) {
                final c = _crops[i];
                final isSelected = i == _selectedIndex;
                return GestureDetector(
                  onTap: () => setState(() => _selectedIndex = i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(right: 12),
                    width: 80,
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.agriGreen.withOpacity(0.15) : AppColors.card,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected ? AppColors.agriGreen : AppColors.border,
                        width: isSelected ? 2 : 1,
                      ),
                      boxShadow: isSelected
                          ? [BoxShadow(color: AppColors.agriGreen.withOpacity(0.3), blurRadius: 8, spreadRadius: 1)]
                          : null,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: _buildCropImage(c.imageUrl, size: 38),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          c.name,
                          style: AppTextStyles.caption.copyWith(
                            color: isSelected ? AppColors.agriGreen : AppColors.textWhite,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ).animate().fadeIn(delay: 100.ms),

          const SizedBox(height: 16),

          // Detailed Crop Pesticide Info
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Card(
                color: AppColors.card,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                  side: BorderSide(color: AppColors.border),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Crop Hero Details
                      Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: _buildCropImage(selectedCrop.imageUrl, size: 75),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  selectedCrop.name,
                                  style: AppTextStyles.h2.copyWith(color: AppColors.agriGreen),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(Icons.shield_outlined, size: 14, color: AppColors.agriGreen),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        'Diseases: ${selectedCrop.commonDiseases}',
                                        style: AppTextStyles.caption,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const Divider(height: 24, color: Colors.grey),

                      // Recommended Chem
                      _buildInfoRow(
                        title: 'Recommended Chemicals:',
                        content: selectedCrop.recommendedPesticide,
                        icon: Icons.science_outlined,
                      ),
                      const SizedBox(height: 12),
                      _buildInfoRow(
                        title: 'Recommended Dosage:',
                        content: selectedCrop.applicationDosage,
                        icon: Icons.opacity_outlined,
                      ),

                      const SizedBox(height: 24),
                      Text(
                        'Chemical Profile Metrics (Interactive)',
                        style: AppTextStyles.labelLarge.copyWith(fontWeight: FontWeight.bold, color: AppColors.agriGreen),
                      ),
                      const SizedBox(height: 16),

                      // Horizontal Bar Metric 1: Efficacy
                      _buildMetricBar(
                        label: 'Pesticide Efficacy Rate',
                        value: selectedCrop.efficacyScore,
                        displayValue: '${(selectedCrop.efficacyScore * 100).toInt()}%',
                        activeColor: Colors.blue,
                      ),

                      // Horizontal Bar Metric 2: Toxicity Level
                      _buildMetricBar(
                        label: 'Chemical Toxicity Factor',
                        value: selectedCrop.toxicityScore,
                        displayValue: selectedCrop.toxicityLabel,
                        activeColor: selectedCrop.toxicityColor,
                      ),

                      // Horizontal Bar Metric 3: Safety Waiting Period
                      _buildMetricBar(
                        label: 'Safety Interval (Days)',
                        value: selectedCrop.safetyPeriodScore,
                        displayValue: selectedCrop.safetyPeriodLabel.split(' ').first + ' Days',
                        activeColor: Colors.teal,
                      ),

                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.info_outline, color: AppColors.agriGreen, size: 18),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                selectedCrop.safetyPeriodLabel,
                                style: AppTextStyles.caption.copyWith(color: AppColors.textWhite),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ).animate().scale(duration: 250.ms, curve: Curves.easeOut),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({required String title, required String content, required IconData icon}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppColors.agriGreen, size: 20),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 2),
              Text(content, style: AppTextStyles.bodyMedium),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMetricBar({
    required String label,
    required double value,
    required String displayValue,
    required Color activeColor,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: AppTextStyles.caption.copyWith(color: Colors.grey)),
              Text(
                displayValue,
                style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.bold, color: activeColor),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Stack(
            children: [
              Container(
                height: 10,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                height: 10,
                width: MediaQuery.of(context).size.width * 0.72 * value,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [activeColor.withOpacity(0.6), activeColor],
                  ),
                  borderRadius: BorderRadius.circular(5),
                  boxShadow: [
                    BoxShadow(color: activeColor.withOpacity(0.3), blurRadius: 4, spreadRadius: 1)
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
