import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

class ExploreScreen extends ConsumerStatefulWidget {
  const ExploreScreen({super.key});

  @override
  ConsumerState<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends ConsumerState<ExploreScreen> {
  List<dynamic> _articles = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchNews();
  }

  Future<void> _fetchNews() async {
    setState(() {
      _loading = true;
    });
    try {
      final url = Uri.parse('http://newsapi.ai/api/v1/article/getArticles?query=%7B%22%24query%22%3A%7B%22keyword%22%3A%22AI%22%2C%22keywordLoc%22%3A%22title%22%7D%7D&resultType=articles&articlesSortBy=date&apiKey=9c9561dd-3cec-41b7-b11a-b9063abde1dc');
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['articles'] != null && data['articles']['results'] != null) {
          final results = data['articles']['results'] as List<dynamic>;
          
          if (!mounted) return;
          setState(() {
            _articles = results;
            _loading = false;
          });
          return;
        }
      }
    } catch (e) {
      debugPrint('News Fetch Error: $e');
    }
    if (mounted) {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Explore News', style: AppTextStyles.h2),
        backgroundColor: AppColors.background,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _articles.length,
              itemBuilder: (ctx, i) {
                final article = _articles[i];
                return ListTile(
                  title: Text(article['title'] ?? 'No Title', style: AppTextStyles.h3),
                  subtitle: Text(article['body'] ?? '', maxLines: 2, overflow: TextOverflow.ellipsis, style: AppTextStyles.bodySmall),
                );
              },
            ),
    );
  }
}
