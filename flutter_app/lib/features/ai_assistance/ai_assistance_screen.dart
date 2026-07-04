import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:uuid/uuid.dart';
import '../../core/services/api_config.dart';
import '../../core/services/auth_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/translation_service.dart';
import 'package:mime/mime.dart';
import 'package:path/path.dart' as p;

class AiAssistanceScreen extends ConsumerStatefulWidget {
  const AiAssistanceScreen({super.key});

  @override
  ConsumerState<AiAssistanceScreen> createState() => _AiAssistanceScreenState();
}

class _AiAssistanceScreenState extends ConsumerState<AiAssistanceScreen>
    with TickerProviderStateMixin {
  final List<Map<String, dynamic>> _messages = [];
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _loading = false;
  bool _jarvisOffline = false;
  String _selectedEngine = 'JARVIS';

  // Unique session ID — maintains conversation context with the JARVIS server
  final String _sessionId = const Uuid().v4();

  late AnimationController _radarController;
  late AnimationController _waveController;

  // Speech to Text & TTS
  final stt.SpeechToText _speechToText = stt.SpeechToText();
  bool _speechEnabled = false;
  final FlutterTts _flutterTts = FlutterTts();
  bool _isAssistantActive = false;
  bool _isProcessing = false;
  int _consecutiveSilenceCount = 0;

  // File attachment state
  XFile? _pendingFile;
  bool _isUploadingFile = false;
  String _baseUrl = ApiConfig.baseUrl;

  Future<void> _initActiveBaseUrl() async {
    final url = await AuthService.instance.getActiveBackendUrl();
    if (mounted) {
      setState(() {
        _baseUrl = url;
      });
    }
  }

  String _getSpeechLocaleId(String languageName) {
    switch (languageName) {
      case 'Telugu':  return 'te_IN';
      case 'Hindi':   return 'hi_IN';
      case 'Bengali': return 'bn_IN';
      case 'Marathi': return 'mr_IN';
      case 'English':
      default:        return 'en_US';
    }
  }

  String _getTtsLocale(String languageName) {
    switch (languageName) {
      case 'Telugu':  return 'te-IN';
      case 'Hindi':   return 'hi-IN';
      case 'Bengali': return 'bn-IN';
      case 'Marathi': return 'mr-IN';
      case 'English':
      default:        return 'en-US';
    }
  }

  @override
  void initState() {
    super.initState();
    _radarController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();

    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);

    _initActiveBaseUrl();
    _initSpeech();
    _initTts();
  }

  Future<void> _initSpeech() async {
    await Permission.microphone.request();
    _speechEnabled = await _speechToText.initialize(
      onError: (val) {
        print('Speech recognition error: $val');
        if (val.permanent) {
          _deactivateAssistant();
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Speech recognition unavailable: ${val.errorMsg}')),
            );
          }
        } else {
          _handleSilenceOrTimeout();
        }
      },
      onStatus: (val) {
        print('Speech status: $val');
        if (val == 'done' || val == 'notListening') {
          _handleSilenceOrTimeout();
        }
      },
    );
    setState(() {});
  }

  void _handleSilenceOrTimeout() {
    if (_isAssistantActive && !_isProcessing && mounted) {
      _consecutiveSilenceCount++;
      if (_consecutiveSilenceCount > 5) {
        _deactivateAssistant();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Voice assistant deactivated due to inactivity.')),
          );
        }
        return;
      }

      Future.delayed(const Duration(milliseconds: 1000), () {
        if (_isAssistantActive && !_isProcessing && mounted && !_speechToText.isListening) {
          _startListening();
        }
      });
    }
  }

  void _initTts() async {
    await _flutterTts.setSharedInstance(true);
    await _flutterTts.setIosAudioCategory(
      IosTextToSpeechAudioCategory.playback,
      [
        IosTextToSpeechAudioCategoryOptions.allowBluetooth,
        IosTextToSpeechAudioCategoryOptions.allowBluetoothA2DP,
        IosTextToSpeechAudioCategoryOptions.mixWithOthers,
        IosTextToSpeechAudioCategoryOptions.defaultToSpeaker
      ],
      IosTextToSpeechAudioMode.defaultMode
    );
    await _flutterTts.setLanguage("en-US");
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.0);

    _flutterTts.setCompletionHandler(() {
      print("TTS Speech Completed");
      if (mounted) {
        setState(() { _isProcessing = false; });
        if (_isAssistantActive) _startListening();
      }
    });

    _flutterTts.setCancelHandler(() {
      print("TTS Speech Cancelled");
      if (mounted) setState(() { _isProcessing = false; });
    });

    _flutterTts.setErrorHandler((msg) {
      print("TTS Speech Error: $msg");
      if (mounted) {
        setState(() { _isProcessing = false; });
        if (_isAssistantActive) _startListening();
      }
    });
  }

  void _toggleListening() {
    if (_isAssistantActive) {
      _deactivateAssistant();
    } else {
      _activateAssistant();
    }
  }

  void _activateAssistant() {
    setState(() {
      _isAssistantActive = true;
      _isProcessing = false;
      _consecutiveSilenceCount = 0;
    });
    _startListening();
  }

  void _deactivateAssistant() {
    setState(() {
      _isAssistantActive = false;
      _isProcessing = false;
      _consecutiveSilenceCount = 0;
    });
    _stopListening();
    _flutterTts.stop();
  }

  void _startListening() async {
    if (!_speechEnabled) {
      await _initSpeech();
      if (!_speechEnabled) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Microphone permission denied. Please enable it in Settings.')),
          );
        }
        setState(() { _isAssistantActive = false; });
        return;
      }
    }
    await _flutterTts.stop();
    if (!_isAssistantActive) return;

    final selectedLang = ref.read(currentLanguageProvider);
    final localeId = _getSpeechLocaleId(selectedLang);

    await _speechToText.listen(
      onResult: (result) {
        if (result.finalResult && result.recognizedWords.isNotEmpty) {
          _consecutiveSilenceCount = 0;
          _controller.text = result.recognizedWords;
          _sendMessage();
        }
      },
      localeId: localeId,
      listenFor: const Duration(seconds: 30),
      pauseFor: const Duration(seconds: 2),
      cancelOnError: true,
      partialResults: false,
    );
    setState(() {});
  }

  void _stopListening() async {
    await _speechToText.stop();
    setState(() {});
  }

  // ── File Picking ─────────────────────────────────────────────────────────────
  Future<void> _pickFile() async {
    try {
      final picker = ImagePicker();
      final result = await showModalBottomSheet<XFile?>(
        context: context,
        backgroundColor: const Color(0xFF051824),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (ctx) => _buildFilePickerSheet(ctx, picker),
      );
      if (result != null) {
        setState(() { _pendingFile = result; });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not pick file: $e')),
        );
      }
    }
  }

  Widget _buildFilePickerSheet(BuildContext ctx, ImagePicker picker) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Send File to JARVIS',
              style: TextStyle(
                color: Color(0xFF00E5FF),
                fontSize: 18,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'JARVIS can analyze images, documents, and text files.',
              style: TextStyle(color: Color(0xFF5EEAD4), fontSize: 13),
            ),
            const SizedBox(height: 20),
            _filePickOption(
              icon: Icons.photo_camera,
              label: 'Take a Photo',
              onTap: () async {
                final f = await picker.pickImage(source: ImageSource.camera, imageQuality: 85);
                if (ctx.mounted) Navigator.pop(ctx, f);
              },
            ),
            const SizedBox(height: 12),
            _filePickOption(
              icon: Icons.photo_library,
              label: 'Choose from Gallery',
              onTap: () async {
                final f = await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
                if (ctx.mounted) Navigator.pop(ctx, f);
              },
            ),
            const SizedBox(height: 12),
            _filePickOption(
              icon: Icons.video_library,
              label: 'Pick a Video',
              onTap: () async {
                final f = await picker.pickVideo(source: ImageSource.gallery);
                if (ctx.mounted) Navigator.pop(ctx, f);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _filePickOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFF031522),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF00E5FF).withOpacity(0.2)),
        ),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFF00E5FF), size: 22),
            const SizedBox(width: 14),
            Text(label, style: const TextStyle(color: Color(0xFFE0F7FF), fontSize: 15)),
          ],
        ),
      ),
    );
  }

  void _clearPendingFile() {
    setState(() { _pendingFile = null; });
  }

  // ── Send Message ─────────────────────────────────────────────────────────────
  @override
  void dispose() {
    _radarController.dispose();
    _waveController.dispose();
    _controller.dispose();
    _scrollController.dispose();
    _flutterTts.stop();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    final fileToSend = _pendingFile;

    if (text.isEmpty && fileToSend == null) {
      _isProcessing = false;
      return;
    }

    final isJarvis = _selectedEngine == 'JARVIS';

    setState(() {
      _messages.add({
        'role': 'user',
        'text': text.isNotEmpty ? text : '📎 ${fileToSend!.name}',
        'hasFile': fileToSend != null,
        'filePath': fileToSend?.path,
        'fileName': fileToSend?.name,
      });
      if (!isJarvis) {
        _messages.add({'role': 'ai', 'text': ''});
      }
      _loading = true;
      _jarvisOffline = false;
      _isProcessing = true;
      _pendingFile = null;
    });
    _controller.clear();
    _scrollToBottom();

    final selectedLang = ref.read(currentLanguageProvider);

    try {
      if (isJarvis) {
        String answer;

        if (fileToSend != null) {
          // ── Multipart file upload to JARVIS ──────────────────────────────
          setState(() { _isUploadingFile = true; });

          final uri = Uri.parse('${ApiConfig.jarvisUrl}/api/jarvis/chat-with-file');
          final fileBytes = await File(fileToSend.path).readAsBytes();
          final mimeType = lookupMimeType(fileToSend.path) ?? 'application/octet-stream';
          final mediaType = MediaType.parse(mimeType);

          final multipartRequest = http.MultipartRequest('POST', uri)
            ..fields['session_id'] = _sessionId
            ..fields['language']   = selectedLang
            ..fields['message']    = text.isNotEmpty ? text : 'Please analyze this file.'
            ..files.add(http.MultipartFile.fromBytes(
              'file',
              fileBytes,
              filename: fileToSend.name,
              contentType: mediaType,
            ));

          final streamResponse = await multipartRequest
              .send()
              .timeout(const Duration(seconds: 90));
          final response = await http.Response.fromStream(streamResponse);

          setState(() { _isUploadingFile = false; });

          if (!mounted) return;

          if (response.statusCode == 200) {
            final data = jsonDecode(response.body);
            answer = (data['answer'] as String?) ?? 'No response.';
          } else {
            final err = (() {
              try { return jsonDecode(response.body)['error'] ?? 'Unknown error'; }
              catch (_) { return 'Status ${response.statusCode}'; }
            })();
            setState(() {
              _loading = false;
              _jarvisOffline = true;
              _messages.add({'role': 'ai', 'text': 'JARVIS offline: $err'});
              _isProcessing = false;
            });
            _scrollToBottom();
            return;
          }
        } else {
          // ── Normal text chat ──────────────────────────────────────────────
          final uri = Uri.parse('${ApiConfig.jarvisUrl}/api/jarvis/chat');
          final response = await http.post(
            uri,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'message':    text,
              'session_id': _sessionId,
              'language':   selectedLang,
            }),
          ).timeout(
            const Duration(seconds: 60),
            onTimeout: () => http.Response(
              jsonEncode({'error': 'JARVIS took too long. Is the server running?'}),
              504,
            ),
          );

          if (!mounted) return;

          if (response.statusCode == 200) {
            final data = jsonDecode(response.body);
            answer = (data['answer'] as String?) ?? 'No response.';
          } else {
            final err = (() {
              try { return jsonDecode(response.body)['error'] ?? 'Unknown error'; }
              catch (_) { return 'Status ${response.statusCode}'; }
            })();
            setState(() {
              _loading = false;
              _jarvisOffline = true;
              _messages.add({'role': 'ai', 'text': 'JARVIS offline: $err'});
              _isProcessing = false;
            });
            _scrollToBottom();
            if (_isAssistantActive) {
              Future.delayed(const Duration(seconds: 2), () {
                if (_isAssistantActive && !_isProcessing && mounted) _startListening();
              });
            }
            return;
          }
        }

        // ── Success: display + speak ──────────────────────────────────────
        setState(() {
          _loading = false;
          _jarvisOffline = false;
          _messages.add({'role': 'ai', 'text': answer});
        });
        _scrollToBottom();
        await _flutterTts.setLanguage(_getTtsLocale(selectedLang));
        await _flutterTts.speak(answer);

      } else {
        // ── Ollama streaming ────────────────────────────────────────────────
        final request = http.Request('POST', Uri.parse('$_baseUrl/api/ai/chat'));
        request.headers['Content-Type'] = 'application/json';
        request.body = jsonEncode({'message': text, 'stream': true});

        final response = await http.Client().send(request);

        if (response.statusCode == 200) {
          response.stream.transform(utf8.decoder).listen(
            (chunk) {
              setState(() {
                _loading = false;
                _messages.last['text'] = (_messages.last['text'] ?? '') + chunk;
              });
              _scrollToBottom();
            },
            onError: (e) {
              setState(() {
                _messages.last['text'] = (_messages.last['text'] ?? '') + '\n[Stream Error]';
                _loading = false;
                _isProcessing = false;
              });
              if (_isAssistantActive && mounted) _startListening();
            },
            onDone: () {
              setState(() {
                _loading = false;
                _isProcessing = false;
              });
              if (_isAssistantActive && mounted) _startListening();
            },
          );
        } else {
          setState(() {
            _messages.add({'role': 'ai', 'text': 'Backend offline. Please ensure server is running.'});
            _loading = false;
            _isProcessing = false;
          });
          _scrollToBottom();
          if (_isAssistantActive && mounted) _startListening();
        }
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _isUploadingFile = false;
        _jarvisOffline = isJarvis;
        _messages.add({
          'role': 'ai',
          'text': isJarvis
              ? 'Cannot reach JARVIS server. Make sure jarvis_server.py is running on your Mac.'
              : 'Error: $e',
        });
        _isProcessing = false;
      });
      _scrollToBottom();
      if (_isAssistantActive && mounted) {
        Future.delayed(const Duration(seconds: 2), () {
          if (_isAssistantActive && !_isProcessing && mounted) _startListening();
        });
      }
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final isJarvis = _selectedEngine == 'JARVIS';

    return Scaffold(
      backgroundColor: isJarvis ? const Color(0xFF030E16) : AppColors.background,
      appBar: AppBar(
        title: Text(
          'AI Assistance',
          style: AppTextStyles.h2.copyWith(
            color: isJarvis ? const Color(0xFF00E5FF) : AppColors.textWhite,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(
          color: isJarvis ? const Color(0xFF00E5FF) : AppColors.textWhite,
        ),
        actions: [
          DropdownButton<String>(
            value: _selectedEngine,
            dropdownColor: isJarvis ? const Color(0xFF051824) : AppColors.card,
            style: AppTextStyles.bodyMedium.copyWith(
              color: isJarvis ? const Color(0xFF00E5FF) : AppColors.textWhite,
            ),
            underline: const SizedBox(),
            icon: Icon(
              Icons.arrow_drop_down,
              color: isJarvis ? const Color(0xFF00E5FF) : AppColors.textWhite,
            ),
            items: ['Ollama', 'JARVIS'].map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            onChanged: (newValue) {
              if (newValue != null) {
                setState(() {
                  _selectedEngine = newValue;
                  _flutterTts.stop();
                  _pendingFile = null;
                });
              }
            },
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: isJarvis ? _buildJarvisUI() : _buildChatUI(),
          ),
          _buildInputArea(isJarvis),
        ],
      ),
    );
  }

  // ── Ollama Chat UI ──────────────────────────────────────────────────────────
  Widget _buildChatUI() {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: _messages.length,
      itemBuilder: (ctx, i) {
        final msg = _messages[i];
        final isUser = msg['role'] == 'user';
        return Align(
          alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.symmetric(vertical: 4),
            decoration: BoxDecoration(
              color: isUser ? AppColors.primaryPurple : AppColors.card,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(msg['text'] ?? '', style: AppTextStyles.bodyMedium),
          ),
        );
      },
    );
  }

  // ── JARVIS UI ───────────────────────────────────────────────────────────────
  Widget _buildJarvisUI() {
    final aiMessages = _messages.where((m) => m['role'] == 'ai').toList();
    final latestResponse = aiMessages.isNotEmpty ? aiMessages.last['text'] as String? : null;
    final isListening = _speechToText.isListening;

    // Latest user message for display
    final userMessages = _messages.where((m) => m['role'] == 'user').toList();
    final latestUserMsg = userMessages.isNotEmpty ? userMessages.last['text'] as String? : null;

    return Stack(
      children: [
        // Background Grid
        CustomPaint(
          size: Size.infinite,
          painter: _GridPainter(),
        ),

        // Offline banner
        if (_jarvisOffline)
          Positioned(
            top: 8,
            left: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.withOpacity(0.5)),
              ),
              child: const Text(
                '⚠  JARVIS backend offline — run jarvis_server.py on your Mac',
                style: TextStyle(color: Colors.redAccent, fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ),
          ),

        // Upload progress banner
        if (_isUploadingFile)
          Positioned(
            top: _jarvisOffline ? 56 : 8,
            left: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF00E5FF).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFF00E5FF).withOpacity(0.3)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation(Color(0xFF00E5FF)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'Uploading file to JARVIS...',
                    style: TextStyle(color: Color(0xFF00E5FF), fontSize: 12),
                  ),
                ],
              ),
            ),
          ),

        // Latest user query (small, above circle)
        if (latestUserMsg != null && !isListening && !_loading)
          Positioned(
            top: 70,
            left: 24,
            right: 24,
            child: Text(
              'You: $latestUserMsg',
              style: const TextStyle(
                color: Color(0xFF5EEAD4),
                fontSize: 13,
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),

        // Circular Radar & Animations
        Center(
          child: AnimatedBuilder(
            animation: _radarController,
            builder: (context, child) {
              return CustomPaint(
                size: const Size(300, 300),
                painter: _JarvisRadarPainter(
                  rotation: _radarController.value * 2 * pi,
                  waveValue: _waveController.value,
                  isListening: isListening || _loading,
                ),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'J.A.R.V.I.S',
                        style: TextStyle(
                          color: const Color(0xFF00E5FF),
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 4,
                          shadows: [
                            Shadow(
                              color: const Color(0xFF00E5FF).withOpacity(0.5),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (isListening || _loading || _isUploadingFile)
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Color(0xFF00FF00),
                                shape: BoxShape.circle,
                                boxShadow: [BoxShadow(color: Color(0xFF00FF00), blurRadius: 4)],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              isListening
                                  ? 'LISTENING'
                                  : _isUploadingFile
                                      ? 'UPLOADING'
                                      : 'PROCESSING',
                              style: const TextStyle(
                                color: Color(0xFF00FF00),
                                fontWeight: FontWeight.bold,
                                letterSpacing: 2,
                                fontSize: 12,
                              ),
                            )
                          ],
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),

        // Latest AI response overlay
        if (latestResponse != null &&
            latestResponse.isNotEmpty &&
            !latestResponse.startsWith('JARVIS offline') &&
            !isListening &&
            !_loading &&
            !_isProcessing)
          Positioned(
            bottom: 32,
            left: 24,
            right: 24,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF031522).withOpacity(0.9),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF00E5FF).withOpacity(0.3)),
              ),
              child: Text(
                latestResponse,
                style: const TextStyle(color: Color(0xFF00E5FF), fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }

  // ── Input Area ─────────────────────────────────────────────────────────────
  Widget _buildInputArea(bool isJarvis) {
    if (isJarvis) {
      final isListening = _speechToText.isListening;
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Pending file chip
          if (_pendingFile != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Row(
                children: [
                  const Icon(Icons.attach_file, color: Color(0xFF00E5FF), size: 18),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      _pendingFile!.name,
                      style: const TextStyle(color: Color(0xFF00E5FF), fontSize: 13),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  GestureDetector(
                    onTap: _clearPendingFile,
                    child: const Icon(Icons.close, color: Colors.redAccent, size: 18),
                  ),
                ],
              ),
            ),

          // Status label
          AnimatedOpacity(
            opacity: (isListening || _isProcessing) ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 300),
            child: Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                _isUploadingFile
                    ? 'Uploading file to JARVIS...'
                    : _isProcessing
                        ? 'Processing response...'
                        : 'Listening... tap stop to cancel',
                style: const TextStyle(
                  color: Color(0xFF00E5FF),
                  fontSize: 13,
                  letterSpacing: 1,
                ),
              ),
            ),
          ),

          // Input row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: Row(
              children: [
                // Attach file button
                GestureDetector(
                  onTap: _loading ? null : _pickFile,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: _pendingFile != null
                          ? const Color(0xFF00E5FF).withOpacity(0.15)
                          : const Color(0xFF051824),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: _pendingFile != null
                            ? const Color(0xFF00E5FF)
                            : const Color(0xFF00E5FF).withOpacity(0.3),
                        width: 1.5,
                      ),
                    ),
                    child: Icon(
                      _pendingFile != null ? Icons.attach_file : Icons.add,
                      color: const Color(0xFF00E5FF),
                      size: 22,
                    ),
                  ),
                ),
                const SizedBox(width: 8),

                // Text input
                Expanded(
                  child: TextField(
                    controller: _controller,
                    style: const TextStyle(color: Color(0xFF00E5FF)),
                    decoration: InputDecoration(
                      hintText: _pendingFile != null
                          ? 'Add a message about the file...'
                          : 'Ask J.A.R.V.I.S. anything...',
                      hintStyle: TextStyle(color: const Color(0xFF00E5FF).withOpacity(0.4)),
                      filled: true,
                      fillColor: const Color(0xFF051824),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(28),
                        borderSide: BorderSide(
                          color: const Color(0xFF00E5FF).withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(28),
                        borderSide: const BorderSide(color: Color(0xFF00E5FF), width: 1.5),
                      ),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),

                // Mic Button
                GestureDetector(
                  onTap: _toggleListening,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: _isAssistantActive
                          ? const Color(0xFF00E5FF)
                          : const Color(0xFF051824),
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFF00E5FF), width: 1.5),
                      boxShadow: _isAssistantActive
                          ? [BoxShadow(
                              color: const Color(0xFF00E5FF).withOpacity(0.4),
                              blurRadius: 10,
                              spreadRadius: 2,
                            )]
                          : [],
                    ),
                    child: Icon(
                      _isAssistantActive ? Icons.stop : Icons.mic,
                      color: _isAssistantActive ? Colors.black : const Color(0xFF00E5FF),
                      size: 24,
                    ),
                  ),
                ),
                const SizedBox(width: 8),

                // Send Button
                GestureDetector(
                  onTap: _loading ? null : _sendMessage,
                  child: Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: const Color(0xFF051824),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFF00E5FF).withOpacity(0.3),
                        width: 1.5,
                      ),
                    ),
                    child: Icon(
                      Icons.send,
                      color: _loading
                          ? const Color(0xFF00E5FF).withOpacity(0.3)
                          : const Color(0xFF00E5FF),
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
      );
    }

    // ── Ollama input ──────────────────────────────────────────────────────────
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              style: AppTextStyles.bodyMedium,
              decoration: InputDecoration(
                hintText: 'Talk to $_selectedEngine...',
                hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.textDimmed),
                filled: true,
                fillColor: AppColors.card,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
              ),
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            decoration: const BoxDecoration(
              color: Colors.transparent,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.send, color: AppColors.primaryPurple),
              onPressed: _loading ? null : _sendMessage,
            ),
          )
        ],
      ),
    );
  }
}

// ── Painters ──────────────────────────────────────────────────────────────────
class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF00E5FF).withOpacity(0.05)
      ..strokeWidth = 1;

    for (double i = 0; i < size.width; i += 40) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }
    for (double i = 0; i < size.height; i += 40) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }

    final dotPaint = Paint()..color = const Color(0xFF00E5FF).withOpacity(0.2);
    for (double x = 0; x < size.width; x += 40) {
      for (double y = 0; y < size.height; y += 40) {
        canvas.drawCircle(Offset(x, y), 1, dotPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _JarvisRadarPainter extends CustomPainter {
  final double rotation;
  final double waveValue;
  final bool isListening;

  _JarvisRadarPainter({
    required this.rotation,
    required this.waveValue,
    required this.isListening,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final cyanPaint = Paint()
      ..color = const Color(0xFF00E5FF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    final dimCyanPaint = Paint()
      ..color = const Color(0xFF00E5FF).withOpacity(0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final glowPaint = Paint()
      ..color = const Color(0xFF00E5FF).withOpacity(0.05)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, radius * 0.4, glowPaint);
    canvas.drawCircle(center, radius * 0.5, glowPaint);
    canvas.drawCircle(center, radius * 0.6, glowPaint);

    canvas.drawCircle(center, radius * 0.4, cyanPaint);

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(rotation);
    _drawDashedCircle(canvas, 0, 0, radius * 0.8, cyanPaint, 8, 4);
    canvas.restore();

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(-rotation * 0.5);
    _drawDashedCircle(canvas, 0, 0, radius * 0.95, dimCyanPaint, 30, 2);
    canvas.restore();

    canvas.drawLine(Offset(0, center.dy), Offset(size.width * 0.1, center.dy), dimCyanPaint);
    canvas.drawLine(Offset(size.width * 0.9, center.dy), Offset(size.width, center.dy), dimCyanPaint);
    canvas.drawLine(Offset(center.dx, 0), Offset(center.dx, size.height * 0.1), dimCyanPaint);
    canvas.drawLine(Offset(center.dx, size.height * 0.9), Offset(center.dx, size.height), dimCyanPaint);

    if (isListening) {
      final wavePaint = Paint()
        ..color = const Color(0xFF00E5FF)
        ..style = PaintingStyle.fill;

      const numBars = 40;
      const barWidth = 3.0;
      const maxBarHeight = 20.0;
      const totalWidth = numBars * (barWidth + 2);
      final startX = center.dx - (totalWidth / 2);
      final baseY = center.dy + radius * 0.7;

      for (int i = 0; i < numBars; i++) {
        final x = startX + i * (barWidth + 2);
        final factor = sin((i / numBars) * pi + waveValue * 2 * pi);
        final height = maxBarHeight * factor.abs() * (0.3 + 0.7 * sin(waveValue * 10 + i).abs());
        canvas.drawRect(
          Rect.fromLTWH(x, baseY - height, barWidth, height * 2),
          wavePaint,
        );
      }
    }
  }

  void _drawDashedCircle(Canvas canvas, double cx, double cy, double radius,
      Paint paint, int dashCount, double dashLength) {
    final path = Path();
    for (int i = 0; i < dashCount; i++) {
      final startAngle = (i * 2 * pi) / dashCount;
      final sweepAngle = dashLength / radius;
      path.addArc(
        Rect.fromCircle(center: Offset(cx, cy), radius: radius),
        startAngle,
        sweepAngle,
      );
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _JarvisRadarPainter oldDelegate) {
    return oldDelegate.rotation != rotation ||
        oldDelegate.waveValue != waveValue ||
        oldDelegate.isListening != isListening;
  }
}
