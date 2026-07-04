import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import '../../core/services/auth_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

class ConsultAdvocateScreen extends StatefulWidget {
  const ConsultAdvocateScreen({super.key});

  @override
  State<ConsultAdvocateScreen> createState() => _ConsultAdvocateScreenState();
}

class _ConsultAdvocateScreenState extends State<ConsultAdvocateScreen> {
  List<dynamic> _advocates = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchAdvocates();
  }

  Future<void> _fetchAdvocates() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final baseUrl = await AuthService.instance.getActiveBackendUrl();
      final response = await http.get(
        Uri.parse('$baseUrl/api/lawgen/advocates'),
      ).timeout(const Duration(seconds: 4));

      if (response.statusCode == 200) {
        if (mounted) {
          setState(() {
            _advocates = jsonDecode(response.body);
            _isLoading = false;
          });
        }
      } else {
        throw Exception('Failed to load advocates (Status: ${response.statusCode})');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _makeCall(String phone) async {
    final Uri url = Uri.parse('tel:${phone.replaceAll(' ', '')}');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      _showErrorSnackBar('Could not place call to $phone');
    }
  }

  Future<void> _sendEmail(String email, String advocateName) async {
    final Uri url = Uri.parse('mailto:$email?subject=Legal Consultation Inquiry&body=Dear $advocateName,\n\nI would like to schedule a consultation regarding a legal matter.');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      _showErrorSnackBar('Could not compose email to $email');
    }
  }

  void _showErrorSnackBar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
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
        title: Text('Consult Legal Advocate', style: AppTextStyles.appBarTitle),
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppColors.border),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.legalGold),
            )
          : _errorMessage != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline_rounded, color: AppColors.alertRed, size: 48),
                        const SizedBox(height: 16),
                        Text('Unable to fetch Advocates', style: AppTextStyles.h2),
                        const SizedBox(height: 8),
                        Text(_errorMessage!, style: AppTextStyles.bodyMedium, textAlign: TextAlign.center),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: _fetchAdvocates,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.legalGold,
                            foregroundColor: Colors.black,
                          ),
                          child: const Text('Try Again'),
                        ),
                      ],
                    ),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _advocates.length,
                  itemBuilder: (context, index) {
                    final adv = _advocates[index];
                    return _buildAdvocateCard(adv, index);
                  },
                ),
    );
  }

  Widget _buildAdvocateCard(Map<String, dynamic> adv, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.card,
            AppColors.cardElevated.withOpacity(0.9),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile Details Section
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile picture with green availability indicator
                Stack(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.legalGold, width: 2),
                        image: DecorationImage(
                          image: AssetImage(adv['photo']),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    if (adv['available'] == true)
                      Positioned(
                        right: 2,
                        bottom: 2,
                        child: Container(
                          width: 14,
                          height: 14,
                          decoration: BoxDecoration(
                            color: AppColors.successGreen,
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.card, width: 2),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 16),
                
                // Name & Titles
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              adv['name'],
                              style: AppTextStyles.h2.copyWith(
                                color: AppColors.textWhite,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.legalGold.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.star_rounded, color: AppColors.legalGold, size: 12),
                                const SizedBox(width: 2),
                                Text(
                                  '${adv['rating']}',
                                  style: AppTextStyles.caption.copyWith(
                                    color: AppColors.legalGold,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        adv['title'],
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.legalGold,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 6),
                      // Specialization Tag
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.border.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          adv['specialization'],
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.textGray,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Bio Description
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              adv['description'],
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textGray,
                height: 1.4,
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(height: 12),
          
          // Location & Experience Row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Icon(Icons.location_on_rounded, size: 14, color: AppColors.textDimmed),
                const SizedBox(width: 4),
                Text(
                  adv['location'],
                  style: AppTextStyles.caption.copyWith(color: AppColors.textGray),
                ),
                const Spacer(),
                Icon(Icons.work_history_rounded, size: 14, color: AppColors.textDimmed),
                const SizedBox(width: 4),
                Text(
                  '${adv['experience']} Exp',
                  style: AppTextStyles.caption.copyWith(color: AppColors.textGray),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          
          // Divider
          Container(height: 1, color: AppColors.border),
          
          // Action Buttons Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.border.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Call Button
                Expanded(
                  child: TextButton.icon(
                    onPressed: () => _makeCall(adv['contactPhone']),
                    style: TextButton.styleFrom(foregroundColor: AppColors.successGreen),
                    icon: const Icon(Icons.phone_rounded, size: 18),
                    label: const Text('Call Now', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
                Container(width: 1, height: 24, color: AppColors.border),
                // Email Button
                Expanded(
                  child: TextButton.icon(
                    onPressed: () => _sendEmail(adv['contactEmail'], adv['name']),
                    style: TextButton.styleFrom(foregroundColor: AppColors.legalGold),
                    icon: const Icon(Icons.email_rounded, size: 18),
                    label: const Text('Email Bio', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
                Container(width: 1, height: 24, color: AppColors.border),
                // Consultation Button
                Expanded(
                  child: TextButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor: AppColors.primaryPurple,
                          content: Text('Booking request sent to ${adv['name']}! They will contact you shortly.'),
                        ),
                      );
                    },
                    style: TextButton.styleFrom(foregroundColor: AppColors.secondaryPurple),
                    icon: const Icon(Icons.calendar_month_rounded, size: 18),
                    label: const Text('Consult', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    )
    .animate()
    .fadeIn(delay: Duration(milliseconds: 100 * index), duration: 400.ms)
    .slideY(begin: 0.08, end: 0, curve: Curves.easeOutCubic);
  }
}
