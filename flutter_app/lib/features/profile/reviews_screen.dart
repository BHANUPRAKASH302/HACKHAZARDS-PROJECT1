import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../core/services/api_config.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

class ReviewsScreen extends StatefulWidget {
  const ReviewsScreen({super.key});

  @override
  State<ReviewsScreen> createState() => _ReviewsScreenState();
}

class _ReviewsScreenState extends State<ReviewsScreen> {
  final _commentCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  int _rating = 5;
  bool _isSubmitting = false;
  bool _isLoading = true;
  List<dynamic> _reviews = [];

  @override
  void initState() {
    super.initState();
    _fetchReviews();
  }

  Future<void> _fetchReviews() async {
    try {
      final response = await http.get(Uri.parse('${ApiConfig.baseUrl}/api/reviews'));
      if (response.statusCode == 200) {
        if (mounted) {
          setState(() {
            _reviews = jsonDecode(response.body);
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
      debugPrint('Error fetching reviews: $e');
    }
  }

  Future<void> _submitReview() async {
    final comment = _commentCtrl.text.trim();
    if (comment.isEmpty) return;

    setState(() => _isSubmitting = true);
    
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/api/reviews'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userName': _nameCtrl.text.isNotEmpty ? _nameCtrl.text : 'Anonymous User',
          'rating': _rating,
          'comment': comment,
        }),
      );

      if (response.statusCode == 201) {
        _commentCtrl.clear();
        _nameCtrl.clear();
        setState(() => _rating = 5);
        await _fetchReviews();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: const Text('Review submitted!'), backgroundColor: AppColors.successGreen),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.alertRed),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('App Reviews', style: AppTextStyles.h2),
        backgroundColor: AppColors.background,
        iconTheme: IconThemeData(color: AppColors.textWhite),
      ),
      body: Column(
        children: [
          _buildReviewForm(),
          const Divider(height: 1),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _reviews.isEmpty
                    ? const Center(child: Text('No reviews yet. Be the first!'))
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _reviews.length,
                        itemBuilder: (context, index) {
                          final rev = _reviews[index];
                          return Card(
                            color: AppColors.card,
                            margin: const EdgeInsets.only(bottom: 12),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(rev['userName'] ?? 'Anonymous', style: AppTextStyles.labelLarge),
                                      Row(
                                        children: List.generate(
                                          5,
                                          (i) => Icon(
                                            i < (rev['rating'] ?? 0) ? Icons.star : Icons.star_border,
                                            size: 16,
                                            color: Colors.amber,
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(rev['comment'] ?? '', style: AppTextStyles.bodyMedium),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewForm() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: AppColors.cardElevated,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Leave a Review', style: AppTextStyles.h3),
          const SizedBox(height: 12),
          TextField(
            controller: _nameCtrl,
            style: AppTextStyles.bodyMedium,
            decoration: InputDecoration(
              hintText: 'Your Name (Optional)',
              hintStyle: AppTextStyles.bodySmall,
              filled: true,
              fillColor: AppColors.card,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Text('Rating: ', style: AppTextStyles.bodyMedium),
              ...List.generate(5, (index) {
                return IconButton(
                  icon: Icon(
                    index < _rating ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                  ),
                  onPressed: () => setState(() => _rating = index + 1),
                );
              }),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _commentCtrl,
            maxLines: 3,
            style: AppTextStyles.bodyMedium,
            decoration: InputDecoration(
              hintText: 'Write your review here...',
              hintStyle: AppTextStyles.bodySmall,
              filled: true,
              fillColor: AppColors.card,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryPurple),
              onPressed: _isSubmitting ? null : _submitReview,
              child: _isSubmitting 
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text('Submit Review', style: TextStyle(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}
