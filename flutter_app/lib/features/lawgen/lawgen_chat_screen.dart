import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import '../../core/services/auth_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../data/mock/lawgen_mock.dart';

class LawgenChatScreen extends StatefulWidget {
  const LawgenChatScreen({super.key});

  @override
  State<LawgenChatScreen> createState() => _LawgenChatScreenState();
}

class _LawgenChatScreenState extends State<LawgenChatScreen> {
  final _msgCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  final List<ChatMessage> _messages = List.from(mockChatMessages);
  bool _isLoading = false;

  void _sendMessage() async {
    final text = _msgCtrl.text.trim();
    if (text.isEmpty || _isLoading) return;

    setState(() {
      _messages.add(ChatMessage(
        text: text,
        isUser: true,
        time: '${TimeOfDay.now().hour}:${TimeOfDay.now().minute.toString().padLeft(2, '0')} ${TimeOfDay.now().period.name.toUpperCase()}',
      ));
      _isLoading = true;
      _msgCtrl.clear();
    });

    // Add empty message for AI streaming
    setState(() {
      _messages.add(const ChatMessage(
        text: '',
        isUser: false,
        time: 'Just now',
      ));
    });

    _scrollToBottom();

    final systemPrompt = "System: You are an expert AI Legal Advisor specializing in Indian Law. Provide legal guidance and information specifically based on Indian laws, acts (such as the IPC/BNS, CrPC, CPC, and others), and the Indian Constitution. Answer the user's question clearly, detailing relevant sections or articles if applicable. Here is the user's query: ";
    
    String aiResponse = "";
    try {
      final baseUrl = await AuthService.instance.getActiveBackendUrl();
      final request = http.Request('POST', Uri.parse('$baseUrl/api/ai/chat'));
      request.headers['Content-Type'] = 'application/json';
      request.body = jsonEncode({
        'message': '$systemPrompt$text',
        'stream': true
      });

      final response = await http.Client().send(request);
      
      if (response.statusCode == 200) {
        response.stream.transform(utf8.decoder).listen(
          (chunk) {
            if (!mounted) return;
            aiResponse += chunk;
            setState(() {
              _messages[_messages.length - 1] = ChatMessage(
                text: aiResponse,
                isUser: false,
                time: 'Just now',
              );
              _isLoading = false;
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
                _messages[_messages.length - 1] = ChatMessage(
                  text: 'Error reading response stream: $err',
                  isUser: false,
                  time: 'Just now',
                );
                _isLoading = false;
              });
            }
          }
        );
      } else {
        setState(() {
          _messages[_messages.length - 1] = const ChatMessage(
            text: 'Error: Failed to connect to Ollama local LLM server.',
            isUser: false,
            time: 'Just now',
          );
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _messages[_messages.length - 1] = ChatMessage(
            text: 'Connection Error: $e. Please verify the backend and Ollama are running.',
            isUser: false,
            time: 'Just now',
          );
          _isLoading = false;
        });
      }
    }
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

  @override
  void dispose() {
    _msgCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.card,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new,
              color: AppColors.textWhite, size: 18),
          onPressed: () => context.pop(),
        ),
        title: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                image: DecorationImage(
                  image: AssetImage('assets/images/Legal_Assistance_Logo.png'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('LawGen Chat', style: AppTextStyles.h3),
                Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: AppColors.successGreen,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text('Online', style: AppTextStyles.caption
                        .copyWith(color: AppColors.successGreen)),
                  ],
                ),
              ],
            ),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppColors.border),
        ),
      ),
      body: Column(
        children: [
          // Messages
          Expanded(
            child: ListView.builder(
              controller: _scrollCtrl,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (ctx, i) {
                return _ChatBubble(msg: _messages[i])
                    .animate()
                    .fadeIn(duration: 300.ms)
                    .slideY(
                      begin: _messages[i].isUser ? 0.1 : -0.1,
                      end: 0,
                    );
              },
            ),
          ),

          // Input
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.card,
              border: Border(top: BorderSide(color: AppColors.border)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: AppColors.inputFill,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: TextField(
                      controller: _msgCtrl,
                      style: AppTextStyles.bodyLarge,
                      maxLines: null,
                      decoration: InputDecoration(
                        hintText: 'Type your question...',
                        hintStyle: AppTextStyles.bodyMedium,
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: _sendMessage,
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.send_rounded,
                        color: Colors.white, size: 20),
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

class _ChatBubble extends StatelessWidget {
  final ChatMessage msg;
  const _ChatBubble({required this.msg});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        mainAxisAlignment:
            msg.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!msg.isUser) ...[
            Container(
              width: 30,
              height: 30,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                image: DecorationImage(
                  image: AssetImage('assets/images/Legal_Assistance_Logo.png'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                gradient: msg.isUser ? AppColors.primaryGradient : null,
                color: msg.isUser ? null : AppColors.card,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft:
                      Radius.circular(msg.isUser ? 16 : 4),
                  bottomRight:
                      Radius.circular(msg.isUser ? 4 : 16),
                ),
                border: msg.isUser
                    ? null
                    : Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(msg.text, style: AppTextStyles.bodyLarge),
                  const SizedBox(height: 4),
                  Text(msg.time,
                      style: AppTextStyles.caption.copyWith(
                        color: msg.isUser
                            ? Colors.white60
                            : AppColors.textDimmed,
                      )),
                ],
              ),
            ),
          ),
          if (msg.isUser) const SizedBox(width: 4),
        ],
      ),
    );
  }
}
