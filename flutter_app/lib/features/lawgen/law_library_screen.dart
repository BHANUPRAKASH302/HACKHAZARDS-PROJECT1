import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import '../../core/services/auth_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

class LawLibraryScreen extends StatefulWidget {
  const LawLibraryScreen({super.key});

  @override
  State<LawLibraryScreen> createState() => _LawLibraryScreenState();
}

class _LawLibraryScreenState extends State<LawLibraryScreen> {
  List<dynamic> _categories = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchCategories();
  }

  Future<void> _fetchCategories() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final baseUrl = await AuthService.instance.getActiveBackendUrl();
      final response = await http.get(
        Uri.parse('$baseUrl/api/lawgen/library/categories'),
      ).timeout(const Duration(seconds: 4));

      if (response.statusCode == 200) {
        if (mounted) {
          setState(() {
            _categories = jsonDecode(response.body);
            _isLoading = false;
          });
        }
      } else {
        throw Exception('Failed to load categories (Status: ${response.statusCode})');
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

  IconData _getIconData(String iconName) {
    return switch (iconName) {
      'gavel' => Icons.gavel_rounded,
      'shield' => Icons.shield_rounded,
      'business' => Icons.business_center_rounded,
      'people' => Icons.people_alt_rounded,
      'boat' => Icons.directions_boat_filled_rounded,
      'cash' => Icons.payments_rounded,
      _ => Icons.menu_book_rounded,
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
        title: Text('Indian Law Library', style: AppTextStyles.appBarTitle),
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
                        Text('Failed to read Law Library', style: AppTextStyles.h2),
                        const SizedBox(height: 8),
                        Text(_errorMessage!, style: AppTextStyles.bodyMedium, textAlign: TextAlign.center),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: _fetchCategories,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.legalGold,
                            foregroundColor: Colors.black,
                          ),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                )
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Text(
                      'Browse Legal Code by Category',
                      style: AppTextStyles.h2.copyWith(color: AppColors.legalGold),
                    ).animate().fadeIn(duration: 300.ms),
                    const SizedBox(height: 6),
                    Text(
                      'Explore thousands of acts, rules, and treaties compiled from official records.',
                      style: AppTextStyles.bodyMedium,
                    ).animate().fadeIn(delay: 50.ms),
                    const SizedBox(height: 20),
                    
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisExtent: 175,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                      ),
                      itemCount: _categories.length,
                      itemBuilder: (context, idx) {
                        final cat = _categories[idx];
                        final Color catColor = Color(int.parse(cat['color'].toString().replaceAll('#', '0xFF')));
                        
                        return _CategoryCard(
                          cat: cat,
                          catColor: catColor,
                          icon: _getIconData(cat['icon']),
                          index: idx,
                        );
                      },
                    ),
                  ],
                ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final Map<String, dynamic> cat;
  final Color catColor;
  final IconData icon;
  final int index;

  const _CategoryCard({
    required this.cat,
    required this.catColor,
    required this.icon,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => _LawsListScreen(
            categoryName: cat['name'],
            color: catColor,
          ),
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: catColor.withOpacity(0.18),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: catColor.withOpacity(0.04),
              blurRadius: 10,
              spreadRadius: 1,
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: Glowing Icon Badge & Count Pill
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Glowing circular icon badge
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [catColor.withOpacity(0.25), catColor.withOpacity(0.05)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    border: Border.all(
                      color: catColor.withOpacity(0.4),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: catColor.withOpacity(0.18),
                        blurRadius: 8,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: Icon(
                    icon,
                    color: catColor,
                    size: 20,
                  ),
                ),
                // Count Pill
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: catColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: catColor.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    '${cat['count']}',
                    style: AppTextStyles.caption.copyWith(
                      color: catColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                    ),
                  ),
                ),
              ],
            ),
            const Spacer(),
            // Category Name
            Text(
              cat['name'],
              style: AppTextStyles.labelLarge.copyWith(
                color: AppColors.textWhite,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 6),
            // Description
            Text(
              cat['description'],
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textGray.withOpacity(0.8),
                fontSize: 10,
                height: 1.35,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ).animate()
          .fadeIn(delay: Duration(milliseconds: 60 * index), duration: 250.ms)
          .slideY(begin: 0.08, end: 0, curve: Curves.easeOut),
    );
  }
}

// ── Secondary screen listing laws under selected category ──────────────────
class _LawsListScreen extends StatefulWidget {
  final String categoryName;
  final Color color;

  const _LawsListScreen({
    required this.categoryName,
    required this.color,
  });

  @override
  State<_LawsListScreen> createState() => _LawsListScreenState();
}

class _LawsListScreenState extends State<_LawsListScreen> {
  List<dynamic> _laws = [];
  bool _isLoading = true;
  String? _errorMessage;
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchLaws();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _fetchLaws({String search = ''}) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final categoryEncoded = Uri.encodeComponent(widget.categoryName);
      final searchEncoded = Uri.encodeComponent(search);
      final baseUrl = await AuthService.instance.getActiveBackendUrl();
      final response = await http.get(
        Uri.parse('$baseUrl/api/lawgen/library/laws?category=$categoryEncoded&search=$searchEncoded'),
      ).timeout(const Duration(seconds: 4));

      if (response.statusCode == 200) {
        if (mounted) {
          setState(() {
            _laws = jsonDecode(response.body);
            _isLoading = false;
          });
        }
      } else {
        throw Exception('Failed to load laws');
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

  Future<void> _openLawUrl(String? urlString) async {
    if (urlString == null || urlString.isEmpty) return;
    try {
      final Uri url = Uri.parse(urlString);
      if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not open page: $urlString')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Invalid URL: $urlString')),
      );
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
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(widget.categoryName, style: AppTextStyles.appBarTitle),
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppColors.border),
        ),
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: AppColors.inputFill,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.border),
              ),
              child: TextField(
                controller: _searchCtrl,
                style: AppTextStyles.bodyLarge,
                decoration: InputDecoration(
                  hintText: 'Search laws in this category...',
                  hintStyle: AppTextStyles.bodyMedium,
                  border: InputBorder.none,
                  icon: Icon(Icons.search_rounded, color: widget.color),
                  suffixIcon: IconButton(
                    icon: Icon(Icons.clear_rounded, color: AppColors.textDimmed, size: 18),
                    onPressed: () {
                      _searchCtrl.clear();
                      _fetchLaws();
                    },
                  ),
                ),
                onSubmitted: (val) {
                  _fetchLaws(search: val.trim());
                },
              ),
            ),
          ),

          // Laws List
          Expanded(
            child: _isLoading
                ? Center(
                    child: CircularProgressIndicator(color: widget.color),
                  )
                : _errorMessage != null
                    ? Center(
                        child: Text(_errorMessage!, style: AppTextStyles.bodyMedium),
                      )
                    : _laws.isEmpty
                        ? Center(
                            child: Text('No laws found matching search', style: AppTextStyles.bodyMedium),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: _laws.length,
                            itemBuilder: (context, index) {
                              final law = _laws[index];
                              return Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: AppColors.card,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(color: AppColors.border),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      law['title'] ?? 'Untitled Law',
                                      style: AppTextStyles.labelLarge.copyWith(
                                        color: AppColors.textWhite,
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    _buildMetaRow('Source / Enactment', law['source']),
                                    _buildMetaRow('Commencement Date', law['commencement_date']),
                                    _buildMetaRow('Published Date', law['published_date']),
                                    const SizedBox(height: 12),
                                    
                                    if (law['url'] != null && law['url'].toString().startsWith('http'))
                                      Align(
                                        alignment: Alignment.centerRight,
                                        child: TextButton.icon(
                                          onPressed: () => _openLawUrl(law['url']),
                                          style: TextButton.styleFrom(
                                            foregroundColor: widget.color,
                                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                          ),
                                          icon: const Icon(Icons.open_in_new_rounded, size: 14),
                                          label: const Text(
                                            'Read in Indian Kanoon',
                                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              );
                            },
                          ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetaRow(String label, String? val) {
    final displayVal = (val == null || val.trim().isEmpty || val.trim().toUpperCase() == 'NA') ? 'Not Available' : val;
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: AppTextStyles.caption.copyWith(color: AppColors.textGray, fontSize: 11),
          ),
          Expanded(
            child: Text(
              displayVal,
              style: AppTextStyles.caption.copyWith(color: AppColors.textWhite, fontSize: 11),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
