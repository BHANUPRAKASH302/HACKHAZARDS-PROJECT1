import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import '../../core/services/auth_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

class LegalDocumentsScreen extends StatefulWidget {
  const LegalDocumentsScreen({super.key});

  @override
  State<LegalDocumentsScreen> createState() => _LegalDocumentsScreenState();
}

class _LegalDocumentsScreenState extends State<LegalDocumentsScreen> {
  List<dynamic> _documents = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchDocuments();
  }

  Future<void> _fetchDocuments() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final baseUrl = await AuthService.instance.getActiveBackendUrl();
      final response = await http.get(
        Uri.parse('$baseUrl/api/lawgen/documents'),
      ).timeout(const Duration(seconds: 4));

      if (response.statusCode == 200) {
        if (mounted) {
          setState(() {
            _documents = jsonDecode(response.body);
            _isLoading = false;
          });
        }
      } else {
        throw Exception('Failed to load documents (Status: ${response.statusCode})');
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
        title: Text('Legal Documents Database', style: AppTextStyles.appBarTitle),
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh_rounded, color: AppColors.legalGold),
            onPressed: _fetchDocuments,
          ),
        ],
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
                        Text(
                          'Error loading document streams',
                          style: AppTextStyles.h2,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _errorMessage!,
                          style: AppTextStyles.bodyMedium,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: _fetchDocuments,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.legalGold,
                            foregroundColor: Colors.black,
                          ),
                          child: const Text('Retry Connection'),
                        ),
                      ],
                    ),
                  ),
                )
              : RefreshIndicator(
                  color: AppColors.legalGold,
                  onRefresh: _fetchDocuments,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _documents.length,
                    itemBuilder: (context, idx) {
                      final doc = _documents[idx];
                      return _buildDocumentCard(doc, idx);
                    },
                  ),
                ),
    );
  }

  Widget _buildDocumentCard(Map<String, dynamic> doc, int index) {
    final domain = doc['domain'] ?? '';
    
    // Choose theme colors & icon based on domain
    Color domainColor;
    IconData domainIcon;
    List<Widget> details = [];

    switch (domain) {
      case 'Award':
        domainColor = AppColors.legalGold;
        domainIcon = Icons.emoji_events_rounded;
        details = [
          _buildDetailRow('Organization', doc['organization']),
          _buildDetailRow('Award Category', doc['award_category']),
          _buildDetailRow('Award', doc['award']),
          _buildDetailRow('Year', doc['year']),
          if (doc['role'] != null && doc['role'].toString().isNotEmpty)
            _buildDetailRow('Role in Project', doc['role']),
          _buildDetailRow('Result', doc['result'], isHighlight: true),
        ];
        break;
      case 'Credit':
        domainColor = AppColors.primaryPurple;
        domainIcon = Icons.badge_rounded;
        details = [
          _buildDetailRow('Category', doc['category']),
          _buildDetailRow('Role', doc['role']),
          _buildDetailRow('Episode ID', doc['episode_id']),
          _buildDetailRow('Credited in Cast', doc['credited'] == 'true' ? 'Yes' : 'No'),
        ];
        break;
      case 'Episode':
        domainColor = AppColors.eduCyan;
        domainIcon = Icons.movie_creation_rounded;
        details = [
          _buildDetailRow('Series Name', doc['series']),
          _buildDetailRow('Season & Episode', 'Season ${doc['season']}, Ep ${doc['episode']}'),
          _buildDetailRow('Air Date', doc['air_date']),
          _buildDetailRow('Rating', '${doc['rating']} (${doc['votes']} votes)'),
          const SizedBox(height: 6),
          Text(
            'Summary:',
            style: AppTextStyles.labelSmall.copyWith(color: AppColors.textGray, fontSize: 10),
          ),
          const SizedBox(height: 2),
          Text(
            doc['summary'] ?? 'No summary available.',
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.textGray, height: 1.4),
          ),
        ];
        break;
      case 'Keyword':
        domainColor = AppColors.safetyOrange;
        domainIcon = Icons.local_offer_rounded;
        details = [
          _buildDetailRow('Keyword Tag', '#${doc['keyword']}', isHighlight: true),
          _buildDetailRow('Associated Episode ID', doc['episode_id']),
        ];
        break;
      case 'Person':
        domainColor = Colors.pinkAccent;
        domainIcon = Icons.portrait_rounded;
        details = [
          _buildDetailRow('Full Name', doc['name']),
          if (doc['nickname'] != null && doc['nickname'].toString().isNotEmpty)
            _buildDetailRow('Nickname', doc['nickname']),
          _buildDetailRow('Birth Date', doc['birthdate']),
          _buildDetailRow('Birth Place', '${doc['birth_place']}, ${doc['birth_region']} (${doc['birth_country']})'),
          if (doc['height_meters'] != null && doc['height_meters'].toString().isNotEmpty)
            _buildDetailRow('Height', '${doc['height_meters']} meters'),
        ];
        break;
      case 'Vote':
        domainColor = AppColors.successGreen;
        domainIcon = Icons.rate_review_rounded;
        details = [
          _buildDetailRow('Episode ID', doc['episode_id']),
          _buildDetailRow('Stars Given', '${doc['stars']} / 10'),
          _buildDetailRow('Total Votes', doc['votes']),
          _buildDetailRow('Percentage of Votes', '${doc['percent']}%', isHighlight: true),
        ];
        break;
      default:
        domainColor = Colors.blueGrey;
        domainIcon = Icons.description_rounded;
        details = [Text(doc.toString(), style: AppTextStyles.bodySmall)];
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 1),
        boxShadow: [
          BoxShadow(
            color: domainColor.withOpacity(0.04),
            blurRadius: 10,
            spreadRadius: 2,
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Banner bar with domain type
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: domainColor.withOpacity(0.08),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(15),
                topRight: Radius.circular(15),
              ),
              border: Border(
                bottom: BorderSide(color: AppColors.border),
              ),
            ),
            child: Row(
              children: [
                Icon(domainIcon, color: domainColor, size: 18),
                const SizedBox(width: 8),
                Text(
                  domain.toUpperCase(),
                  style: AppTextStyles.labelMedium.copyWith(
                    color: domainColor,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
                const Spacer(),
                Text(
                  'DOC-${index + 1001}',
                  style: AppTextStyles.caption.copyWith(color: AppColors.textDimmed),
                ),
              ],
            ),
          ),

          // Details List
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: details,
            ),
          ),
        ],
      ),
    )
    .animate()
    .fadeIn(delay: Duration(milliseconds: 60 * index), duration: 300.ms)
    .slideY(begin: 0.05, end: 0);
  }

  Widget _buildDetailRow(String label, String? value, {bool isHighlight = false}) {
    final displayVal = (value == null || value.trim().isEmpty) ? 'N/A' : value;
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textGray,
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              displayVal,
              style: AppTextStyles.bodyMedium.copyWith(
                color: isHighlight ? AppColors.legalGold : AppColors.textWhite,
                fontWeight: isHighlight ? FontWeight.bold : FontWeight.normal,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
