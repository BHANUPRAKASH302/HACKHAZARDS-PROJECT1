import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/services/prescripto_service.dart';

class FindDoctorsScreen extends StatefulWidget {
  const FindDoctorsScreen({super.key});

  @override
  State<FindDoctorsScreen> createState() => _FindDoctorsScreenState();
}

class _FindDoctorsScreenState extends State<FindDoctorsScreen> {
  List<Map<String, dynamic>> _doctors = [];
  bool _isLoading = true;
  String _selectedSpecialty = 'All';
  String _searchQuery = '';

  final List<String> _specialties = [
    'All',
    'General Physician',
    'Cardiology',
    'Dermatology',
    'Dentistry',
    'Gynecology',
    'Neurology',
    'Orthopedics',
    'Pediatrics',
    'Psychiatry',
    'Ophthalmology'
  ];

  @override
  void initState() {
    super.initState();
    _loadDoctors();
  }

  Future<void> _loadDoctors() async {
    setState(() => _isLoading = true);
    try {
      final list = await PrescriptoService.instance.getDoctors();
      setState(() {
        _doctors = list;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading doctors: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Filter logic
    final filtered = _doctors.where((doc) {
      final spec = doc['specialty'] ?? '';
      final name = doc['name'] ?? '';

      final matchesSpec = _selectedSpecialty == 'All' || spec.toLowerCase() == _selectedSpecialty.toLowerCase();
      final matchesSearch = name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          spec.toLowerCase().contains(_searchQuery.toLowerCase());

      return matchesSpec && matchesSearch;
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: AppColors.textWhite, size: 18),
          onPressed: () => context.pop(),
        ),
        title: Text('Find Doctors', style: AppTextStyles.appBarTitle),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: AppColors.textWhite),
            onPressed: _loadDoctors,
          )
        ],
      ),
      body: Column(
        children: [
          // Search Box
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Container(
              height: 46,
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: TextField(
                style: AppTextStyles.bodyLarge,
                onChanged: (value) => setState(() => _searchQuery = value),
                decoration: InputDecoration(
                  hintText: 'Search doctor or specialty...',
                  hintStyle: AppTextStyles.bodyMedium,
                  prefixIcon: Icon(Icons.search, color: AppColors.textDimmed, size: 20),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ).animate().fadeIn(duration: 300.ms),
          ),

          // Specialty horizontal chips
          SizedBox(
            height: 40,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              itemCount: _specialties.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (ctx, i) {
                final spec = _specialties[i];
                final isSelected = spec == _selectedSpecialty;
                return GestureDetector(
                  onTap: () => setState(() => _selectedSpecialty = spec),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      gradient: isSelected ? AppColors.primaryGradient : null,
                      color: isSelected ? null : AppColors.card,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected ? AppColors.primaryPurple : AppColors.border,
                      ),
                    ),
                    child: Text(
                      spec,
                      style: AppTextStyles.labelMedium.copyWith(
                        color: isSelected ? AppColors.textWhite : AppColors.textGray,
                      ),
                    ),
                  ),
                );
              },
            ),
          ).animate().fadeIn(delay: 100.ms),

          const SizedBox(height: 16),

          // Doctors List View
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: AppColors.medicalBlue))
                : filtered.isEmpty
                    ? Center(
                        child: Text(
                          'No doctors found',
                          style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textDimmed),
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: filtered.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (ctx, i) {
                          final doc = filtered[i];
                          return _DoctorCard(doctor: doc)
                              .animate()
                              .fadeIn(
                                delay: Duration(milliseconds: 150 + 80 * i),
                                duration: 350.ms,
                              )
                              .slideY(begin: 0.1, end: 0);
                        },
                      ),
          ),
        ],
      ),
    );
  }
}

class _DoctorCard extends StatelessWidget {
  final Map<String, dynamic> doctor;
  const _DoctorCard({required this.doctor});

  @override
  Widget build(BuildContext context) {
    final name = doctor['name'] ?? 'Doctor';
    final specialty = doctor['specialty'] ?? '';
    final hospital = doctor['hospital'] ?? '';
    final rating = (doctor['rating'] ?? 5.0).toDouble();
    final experience = doctor['experience'] ?? 0;
    final isAvailable = doctor['isAvailable'] ?? true;
    final imageUrl = doctor['profileImage'] ?? '';
    
    // Generate initials for placeholder
    final nameParts = name.replaceAll('Dr. ', '').trim().split(' ');
    final initials = nameParts.length > 1
        ? '${nameParts[0][0]}${nameParts[1][0]}'.toUpperCase()
        : nameParts[0].substring(0, 2).toUpperCase();

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          // Doctor Avatar Profile Image
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              gradient: AppColors.medicalGradient,
              shape: BoxShape.circle,
            ),
            child: ClipOval(
              child: imageUrl.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: imageUrl,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => const CircularProgressIndicator(strokeWidth: 2),
                      errorWidget: (context, url, error) => Center(
                        child: Text(
                          initials,
                          style: AppTextStyles.labelLarge.copyWith(color: AppColors.textWhite),
                        ),
                      ),
                    )
                  : Center(
                      child: Text(
                        initials,
                        style: AppTextStyles.labelLarge.copyWith(color: AppColors.textWhite),
                      ),
                    ),
            ),
          ),
          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: AppTextStyles.labelLarge),
                Text(specialty, style: AppTextStyles.bodySmall),
                const SizedBox(height: 4),
                Text('$experience+ Yrs Exp. • $hospital', style: AppTextStyles.caption),
              ],
            ),
          ),

          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                children: [
                  const Icon(Icons.star, color: Color(0xFFFBBF24), size: 14),
                  const SizedBox(width: 3),
                  Text('$rating', style: AppTextStyles.caption.copyWith(color: AppColors.textWhite)),
                ],
              ),
              const SizedBox(height: 6),
              SizedBox(
                height: 30,
                child: ElevatedButton(
                  onPressed: isAvailable ? () => context.push('/prescripto/book', extra: doctor) : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isAvailable ? AppColors.medicalBlue : AppColors.border,
                    minimumSize: const Size(60, 30),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: Text(
                    isAvailable ? 'Book' : 'Busy',
                    style: AppTextStyles.caption.copyWith(color: AppColors.textWhite),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
