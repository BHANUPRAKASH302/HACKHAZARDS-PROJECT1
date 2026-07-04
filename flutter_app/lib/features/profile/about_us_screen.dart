import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

class AboutUsScreen extends StatefulWidget {
  const AboutUsScreen({super.key});

  @override
  State<AboutUsScreen> createState() => _AboutUsScreenState();
}

class _AboutUsScreenState extends State<AboutUsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _subjectCtrl = TextEditingController();
  final _messageCtrl = TextEditingController();
  bool _isSubmitting = false;

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isSubmitting = true);

    try {
      final response = await http.post(
        Uri.parse('https://api.web3forms.com/submit'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'access_key': '034922d7-8eaa-44ca-92e6-bad9d88925ac',
          'name': _nameCtrl.text,
          'email': _emailCtrl.text,
          'subject': _subjectCtrl.text,
          'message': _messageCtrl.text,
        }),
      );

      if (response.statusCode == 200) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Message sent successfully!'),
            backgroundColor: AppColors.successGreen,
          ),
        );
        _nameCtrl.clear();
        _emailCtrl.clear();
        _subjectCtrl.clear();
        _messageCtrl.clear();
      } else {
        throw Exception('Failed to send message');
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: AppColors.alertRed,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('About Us', style: AppTextStyles.h2),
        backgroundColor: AppColors.background,
        iconTheme: IconThemeData(color: AppColors.textWhite),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('What We Do'),
            const SizedBox(height: 8),
            Text(
              'Comprehensive technology solutions tailored to your business needs',
              style: AppTextStyles.bodyMedium,
            ),
            const SizedBox(height: 16),
            
            _buildSubsectionTitle('Strategic IT Consulting'),
            Text('Expert guidance for digital transformation and technology strategy aligned with business goals.', style: AppTextStyles.bodySmall),
            const SizedBox(height: 12),
            
            _buildSubsectionTitle('AI & Software Engineering'),
            Text('Cutting-edge AI solutions and custom software development for modern enterprises.', style: AppTextStyles.bodySmall),
            const SizedBox(height: 12),

            _buildSubsectionTitle('Cloud & Infrastructure'),
            Text('Scalable cloud solutions and robust infrastructure management for optimal performance.', style: AppTextStyles.bodySmall),
            const SizedBox(height: 12),

            _buildSubsectionTitle('R&D and Innovation'),
            Text('Research-driven innovation in emerging technologies to keep you ahead of the curve.', style: AppTextStyles.bodySmall),
            const SizedBox(height: 24),

            _buildSectionTitle('Why Choose LogSagittarius'),
            const SizedBox(height: 8),
            Text(
              'We combine technical excellence with strategic thinking to deliver solutions that drive real business value and sustainable growth.',
              style: AppTextStyles.bodyMedium,
            ),
            const SizedBox(height: 8),
            _buildBulletPoint('Expert engineers with proven track records'),
            _buildBulletPoint('Scalable solutions built for growth'),
            _buildBulletPoint('Enterprise-grade security standards'),
            _buildBulletPoint('Innovation-driven mindset and approach'),
            const SizedBox(height: 16),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStat('50+', 'Projects Delivered'),
                _buildStat('98%', 'Client Satisfaction'),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStat('24/7', 'Support Available'),
                _buildStat('10+', 'Years Experience'),
              ],
            ),
            const SizedBox(height: 24),

            _buildSectionTitle('Ready to Transform Your Business?'),
            const SizedBox(height: 8),
            Text('Let\'s discuss how we can help you achieve your technology goals', style: AppTextStyles.bodyMedium),
            const SizedBox(height: 24),

            _buildSectionTitle('Our Services'),
            const SizedBox(height: 8),
            Text('Comprehensive technology solutions designed to empower your business and accelerate digital transformation', style: AppTextStyles.bodyMedium),
            const SizedBox(height: 16),

            _buildServiceItem('Strategic IT Consultancy', 'Transform your business with expert technology guidance and strategic planning.', [
              'Software architecture design',
              'Cloud strategy & migration',
              'Cybersecurity assessment',
              'Digital transformation roadmaps'
            ]),
            _buildServiceItem('Managed IT Infrastructure', 'Reliable, scalable infrastructure management for optimal performance and uptime.', [
              'Cloud infrastructure management',
              'Network operations & monitoring',
              'Backup & disaster recovery',
              'Performance optimization'
            ]),
            _buildServiceItem('Software Implementation & Integration', 'Custom software solutions designed to streamline operations and drive growth.', [
              'Web & mobile applications',
              'Enterprise software solutions',
              'API & system integration',
              'DevOps & CI/CD pipelines'
            ]),
            _buildServiceItem('R&D and Innovation', 'Cutting-edge research and development in emerging technologies and AI.', [
              'AI/ML solutions',
              'IoT platforms',
              'Data analytics',
              'Emerging technologies'
            ]),
            
            const SizedBox(height: 24),
            _buildSectionTitle('Additional Capabilities'),
            const SizedBox(height: 8),
            Text('Specialized services to complement your technology strategy', style: AppTextStyles.bodyMedium),
            const SizedBox(height: 16),
            
            _buildSubsectionTitle('Cybersecurity'),
            Text('Comprehensive security audits and protection', style: AppTextStyles.bodySmall),
            const SizedBox(height: 8),
            
            _buildSubsectionTitle('Performance Optimization'),
            Text('System tuning and optimization services', style: AppTextStyles.bodySmall),
            const SizedBox(height: 8),

            _buildSubsectionTitle('Data Management'),
            Text('Database design and data analytics', style: AppTextStyles.bodySmall),
            const SizedBox(height: 8),

            _buildSubsectionTitle('DevOps Services'),
            Text('CI/CD and automation solutions', style: AppTextStyles.bodySmall),
            const SizedBox(height: 32),

            // Contact Form specific styles per the image
            Center(
              child: Text(
                'LET\'S GET IN TOUCH',
                style: AppTextStyles.h1.copyWith(
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.2,
                  color: AppColors.textWhite,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: Container(
                height: 3,
                width: 60,
                color: const Color(0xFFD64A38),
              ),
            ),
            const SizedBox(height: 32),

            Form(
              key: _formKey,
              child: Column(
                children: [
                  _buildContactField('YOURNAME...*', _nameCtrl, false, 1),
                  const SizedBox(height: 16),
                  _buildContactField('YOUR EMAIL...', _emailCtrl, false, 1),
                  const SizedBox(height: 16),
                  _buildContactField('SUBJECT...*', _subjectCtrl, false, 1),
                  const SizedBox(height: 16),
                  _buildContactField('YOUR MESSAGE...', _messageCtrl, true, 5),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD64A38),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      onPressed: _isSubmitting ? null : _submitForm,
                      child: _isSubmitting
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              'SEND MESSAGE NOW',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.5,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
          ],
        ).animate().fadeIn(duration: 500.ms),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: AppTextStyles.h2.copyWith(color: AppColors.secondaryPurple),
    );
  }

  Widget _buildSubsectionTitle(String title) {
    return Text(
      title,
      style: AppTextStyles.labelLarge.copyWith(fontWeight: FontWeight.bold),
    );
  }

  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('• ', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.primaryPurple)),
          Expanded(child: Text(text, style: AppTextStyles.bodyMedium)),
        ],
      ),
    );
  }

  Widget _buildStat(String value, String label) {
    return Column(
      children: [
        Text(value, style: AppTextStyles.h2.copyWith(color: AppColors.primaryPurple)),
        Text(label, style: AppTextStyles.bodySmall),
      ],
    );
  }

  Widget _buildServiceItem(String title, String desc, List<String> points) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: AppTextStyles.h3),
            const SizedBox(height: 8),
            Text(desc, style: AppTextStyles.bodySmall),
            const SizedBox(height: 12),
            ...points.map((p) => _buildBulletPoint(p)),
          ],
        ),
      ),
    );
  }

  Widget _buildContactField(String hint, TextEditingController controller, bool isMultiline, int maxLines) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      style: AppTextStyles.bodyMedium.copyWith(color: Colors.black87),
      validator: (val) {
        if (hint.contains('*') && (val == null || val.isEmpty)) {
          return 'This field is required';
        }
        return null;
      },
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: AppTextStyles.bodyMedium.copyWith(color: Colors.black38),
        filled: true,
        fillColor: const Color(0xFFF7F9FA),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE0E5EC)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE0E5EC)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFD64A38)),
        ),
      ),
    );
  }
}
