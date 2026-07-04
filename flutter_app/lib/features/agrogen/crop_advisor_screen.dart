import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/services/auth_service.dart';

class CropAdvisorScreen extends StatefulWidget {
  const CropAdvisorScreen({super.key});

  @override
  State<CropAdvisorScreen> createState() => _CropAdvisorScreenState();
}

class _CropAdvisorScreenState extends State<CropAdvisorScreen> {
  final _msgCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  final List<Map<String, dynamic>> _messages = [
    {
      'text': 'Hello! I am your AI Crop Advisor. 🌾 What kind of crop are you currently growing, or planning to grow?',
      'isUser': false,
      'time': 'Just now',
    }
  ];
  bool _isLoading = false;

  final List<String> _quickSuggestions = [
    'Rice',
    'Cotton',
    'Maize',
    'Red Gram',
    'Groundnut',
    'Chili',
    'Turmeric',
  ];

  @override
  void dispose() {
    _msgCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _sendMessage(String text) async {
    if (text.trim().isEmpty || _isLoading) return;

    final userMessage = text.trim();
    _msgCtrl.clear();

    setState(() {
      _messages.add({
        'text': userMessage,
        'isUser': true,
        'time': '${TimeOfDay.now().hour}:${TimeOfDay.now().minute.toString().padLeft(2, '0')} ${TimeOfDay.now().period.name.toUpperCase()}',
      });
      _isLoading = true;
    });
    
    // Add empty response placeholder for streaming/response load
    setState(() {
      _messages.add({
        'text': '',
        'isUser': false,
        'time': 'Just now',
      });
    });
    _scrollToBottom();

    final systemPrompt = "System: You are an expert AI Crop Advisor. You help farmers optimize their yield, diagnose crop diseases, recommend fertilizers, and guide them on irrigation and harvesting. Keep your answers concise, practical, and highly relevant to agriculture. Always start by helping with their specific crop. Here is the user's query: ";

    try {
      final baseUrl = await AuthService.instance.getActiveBackendUrl();
      final token = await AuthService.instance.getToken();

      final request = http.Request('POST', Uri.parse('$baseUrl/api/ai/chat'));
      request.headers['Content-Type'] = 'application/json';
      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }
      request.body = jsonEncode({
        'message': '$systemPrompt$userMessage',
        'stream': true
      });

      final response = await http.Client().send(request);
      
      String aiResponse = "";
      if (response.statusCode == 200) {
        response.stream.transform(utf8.decoder).listen(
          (chunk) {
            if (!mounted) return;
            aiResponse += chunk;
            setState(() {
              _messages[_messages.length - 1] = {
                'text': aiResponse,
                'isUser': false,
                'time': 'Just now',
              };
            });
            _scrollToBottom();
          },
          onDone: () {
            if (mounted) {
              setState(() {
                _isLoading = false;
              });
            }
          },
          onError: (err) {
            if (mounted) {
              setState(() {
                _messages[_messages.length - 1] = {
                  'text': 'Error reading stream response: $err',
                  'isUser': false,
                  'time': 'Just now',
                };
                _isLoading = false;
              });
            }
          }
        );
      } else {
        setState(() {
          _messages[_messages.length - 1] = {
            'text': 'Error: Failed to connect to Ollama local LLM server.',
            'isUser': false,
            'time': 'Just now',
          };
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _messages[_messages.length - 1] = {
            'text': 'Connection Error: $e. Please verify the backend and Ollama are running.',
            'isUser': false,
            'time': 'Just now',
          };
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
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: AppColors.textWhite, size: 18),
          onPressed: () => context.pop(),
        ),
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundImage: const AssetImage('assets/images/AI_Crop_Advisor.jpg'),
              backgroundColor: AppColors.card,
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Crop Advisor', style: AppTextStyles.labelLarge.copyWith(fontWeight: FontWeight.bold)),
                Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text('Online', style: AppTextStyles.caption.copyWith(color: Colors.green)),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Chat Messages
          Expanded(
            child: ListView.builder(
              controller: _scrollCtrl,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (ctx, i) {
                final m = _messages[i];
                final isUser = m['isUser'] == true;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Align(
                    alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.78),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: isUser ? AppColors.agriGreen : AppColors.card,
                        borderRadius: BorderRadius.only(
                          topLeft: const Radius.circular(16),
                          topRight: const Radius.circular(16),
                          bottomLeft: Radius.circular(isUser ? 16 : 0),
                          bottomRight: Radius.circular(isUser ? 0 : 16),
                        ),
                        border: isUser ? null : Border.all(color: AppColors.border),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            m['text'],
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: isUser ? AppColors.textWhite : AppColors.textWhite,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Align(
                            alignment: Alignment.bottomRight,
                            child: Text(
                              m['time'],
                              style: AppTextStyles.caption.copyWith(
                                color: isUser ? Colors.white60 : Colors.grey,
                                fontSize: 10,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ).animate().fadeIn(duration: 200.ms);
              },
            ),
          ),

          // Suggestion Pills (Only shown when first starting or not loading)
          if (_messages.length == 1 && !_isLoading)
            Container(
              height: 40,
              margin: const EdgeInsets.only(bottom: 8),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _quickSuggestions.length,
                itemBuilder: (ctx, idx) {
                  final suggestion = _quickSuggestions[idx];
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ActionChip(
                      label: Text(
                        suggestion,
                        style: TextStyle(color: AppColors.agriGreen, fontWeight: FontWeight.w600),
                      ),
                      backgroundColor: AppColors.card,
                      side: BorderSide(color: AppColors.agriGreen.withOpacity(0.5)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      onPressed: () => _sendMessage(suggestion),
                    ),
                  );
                },
              ),
            ),

          // Input Bar
          Container(
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 24, top: 8),
            decoration: BoxDecoration(
              color: AppColors.background,
              border: Border(top: BorderSide(color: AppColors.border)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _msgCtrl,
                    style: TextStyle(color: AppColors.textWhite),
                    decoration: InputDecoration(
                      hintText: 'Type your message...',
                      hintStyle: const TextStyle(color: Colors.grey),
                      filled: true,
                      fillColor: AppColors.card,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide(color: AppColors.border),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide(color: AppColors.agriGreen),
                      ),
                    ),
                    onSubmitted: (val) => _sendMessage(val),
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: AppColors.agriGreen,
                  radius: 22,
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white, size: 18),
                    onPressed: () => _sendMessage(_msgCtrl.text),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
