import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import 'package:http/http.dart' as http;
import 'package:sentinel/core/constants/api_constants.dart';
import '../../../core/constants/app_colors.dart';

class LegalChatbotScreen extends StatefulWidget {
  const LegalChatbotScreen({super.key});

  @override
  State<LegalChatbotScreen> createState() =>
      _LegalChatbotScreenState();
}

class _LegalChatbotScreenState
    extends State<LegalChatbotScreen>
    with TickerProviderStateMixin {

  // Groq API key
  static const String _apikey = ApiConstants.groqApiKey;

  final TextEditingController _messageController =
  TextEditingController();
  final ScrollController _scrollController =
  ScrollController();

  final List<Map<String, dynamic>> _messages = [];
  bool _isLoading = false;
  String _selectedMode = 'safety';

  // ─── Chat Modes ───────────────────────────────────────
  final List<Map<String, dynamic>> _modes = [
    {
      'id': 'safety',
      'title': 'Safety Guide',
      'emoji': '🛡️',
      'color': const Color(0xFF4A148C),
      'description': 'Real-time safety tips & advice',
    },
    {
      'id': 'legal',
      'title': 'Legal Advisor',
      'emoji': '⚖️',
      'color': const Color(0xFF1565C0),
      'description': 'Indian women\'s laws & rights',
    },
    {
      'id': 'support',
      'title': 'Support Chat',
      'emoji': '💙',
      'color': const Color(0xFF00897B),
      'description': 'Emotional support & guidance',
    },
    {
      'id': 'emergency',
      'title': 'Emergency Guide',
      'emoji': '🚨',
      'color': const Color(0xFFE53935),
      'description': 'Step-by-step emergency help',
    },
  ];

  // ─── System Prompts per Mode ──────────────────────────
  final Map<String, String> _systemPrompts = {
    'safety': '''
You are Sentinel Safety Guide, an AI assistant specialized in women's personal safety.

Your role is to:
- Provide practical real-time safety tips and strategies
- Help women identify unsafe situations and escape routes
- Teach self-defense awareness and de-escalation techniques
- Guide on safe travel, nighttime safety, and public spaces
- Advise on digital safety and online harassment prevention
- Help with safety planning for daily routines

Guidelines:
- Give clear, actionable advice
- Use bullet points for easy reading
- Be direct and practical
- Prioritize immediate safety always
- If someone is in immediate danger, tell them to call 112 first
- Keep responses concise and easy to follow under stress
''',
    'legal': '''
You are Nyaya, an AI legal advisor specialized in Indian women's legal rights.

Your role is to help women understand:
- Domestic Violence Act 2005
- Sexual Harassment at Workplace (POSH Act 2013)
- Dowry Prohibition Act 1961
- IPC sections for crimes against women (354, 375, 498A etc.)
- Protection of Women from Domestic Violence
- Family law — divorce, maintenance, custody rights
- POCSO Act for child protection
- How to file FIR and police complaints
- How to access free legal aid
- Restraining orders and court procedures

Guidelines:
- Explain laws in simple language
- Mention specific act names and section numbers
- Give step-by-step guidance for filing complaints
- Always recommend consulting a lawyer for complex cases
- Be compassionate and non-judgmental
- Format with bullet points for clarity
''',
    'support': '''
You are Saheli (meaning friend in Hindi), a compassionate AI support companion for women going through difficult times.

Your role is to:
- Provide emotional support and a safe space to talk
- Help women process trauma, fear, and difficult emotions
- Offer coping strategies for stress, anxiety, and fear
- Guide towards professional mental health resources
- Help with self-confidence and empowerment
- Support women leaving abusive relationships

Guidelines:
- Be warm, empathetic, and non-judgmental
- Listen actively and validate feelings
- Never minimize or dismiss experiences
- Encourage professional help when needed
- Use gentle, caring language
- If someone mentions self-harm, immediately provide: iCall 9152987821, Vandrevala Foundation 1860-2662-345
''',
    'emergency': '''
You are Sentinel Emergency Guide, an AI that provides clear step-by-step guidance during emergency situations for women.

You help with situations like:
- Being followed or stalked
- Physical attack or threat
- Domestic violence situations
- Harassment in public places
- Sexual assault situations
- Getting out of dangerous relationships

Guidelines:
- Provide numbered step-by-step instructions
- Be extremely clear and concise
- Always start with immediate safety
- Include relevant helpline numbers
- Tell them to call 112 for immediate danger
- Be calm and reassuring in tone

Important helplines:
- Emergency: 112
- Police: 100
- Women Helpline: 1091
- Domestic Violence: 181
- Ambulance: 102
''',
  };

  // ─── Suggestions per Mode ─────────────────────────────
  final Map<String, List<String>> _suggestions = {
    'safety': [
      'How to stay safe traveling alone at night?',
      'What to do if someone is following me?',
      'How to be safe using ride sharing apps?',
      'Tips for safe solo travel',
    ],
    'legal': [
      'What is the Domestic Violence Act?',
      'How to file a sexual harassment complaint?',
      'How to get a restraining order?',
      'What is the POSH Act?',
    ],
    'support': [
      'I am feeling scared and don\'t know what to do',
      'I am in an abusive relationship',
      'I need help dealing with trauma',
      'How to rebuild confidence after abuse?',
    ],
    'emergency': [
      'Someone is following me right now',
      'I am in a domestic violence situation',
      'I was harassed at my workplace',
      'I need to escape an abusive home',
    ],
  };

  // ─── Welcome Messages per Mode ────────────────────────
  final Map<String, String> _welcomeMessages = {
    'safety':
    '🛡️ Hello! I am your **Safety Guide**.\n\nI\'m here to help you stay safe in any situation — whether you\'re traveling alone, facing harassment, or just want to improve your everyday safety.\n\nWhat safety concern can I help you with today?',
    'legal':
    '⚖️ Namaste! I am **Nyaya**, your legal advisor.\n\nI specialize in Indian women\'s legal rights. I can help you understand laws, how to file complaints, and what your rights are in any situation.\n\nWhat legal question can I help you with?',
    'support':
    '💙 Hi, I\'m **Saheli** — I\'m here for you.\n\nThis is a safe space to talk about anything you\'re going through. I\'m here to listen, support, and guide you without any judgment.\n\nHow are you feeling today?',
    'emergency':
    '🚨 I am your **Emergency Guide**.\n\nI provide clear step-by-step guidance for emergency situations. Tell me what situation you\'re facing.\n\n⚡ If you are in immediate danger, call **112** right now!',
  };

  @override
  void initState() {
    super.initState();
    _addWelcomeMessage();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // ─── Add Welcome Message ──────────────────────────────
  void _addWelcomeMessage() {
    _messages.clear();
    _messages.add({
      'role': 'assistant',
      'content': _welcomeMessages[_selectedMode]!,
      'isUser': false,
    });
  }

  // ─── Switch Mode ──────────────────────────────────────
  void _switchMode(String mode) {
    setState(() {
      _selectedMode = mode;
      _messages.clear();
    });
    _addWelcomeMessage();
    setState(() {});
  }

  Map<String, dynamic> get _currentMode =>
      _modes.firstWhere(
              (m) => m['id'] == _selectedMode);

  // ─── Send Message via Groq API ────────────────────────
  Future<void> _sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    final userMessage = text.trim();
    _messageController.clear();

    setState(() {
      _messages.add({
        'role': 'user',
        'content': userMessage,
        'isUser': true,
      });
      _isLoading = true;
    });

    _scrollToBottom();

    try {
      // ✅ Build messages for Groq
      final List<Map<String, String>> apiMessages = [];

      // Add system prompt first
      apiMessages.add({
        'role': 'system',
        'content': _systemPrompts[_selectedMode]!,
      });

      // Add conversation history
      for (final msg in _messages) {
        if (msg['content'] ==
            _welcomeMessages[_selectedMode]) {
          continue; // Skip welcome message
        }
        apiMessages.add({
          'role': msg['isUser'] == true
              ? 'user'
              : 'assistant',
          'content': msg['content'] as String,
        });
      }

      print('📤 Sending to Groq...');

      // ✅ Groq API call
      final response = await http
          .post(
        Uri.parse(
          'https://api.groq.com/openai/v1/chat/completions',
        ),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apikey',
        },
        body: jsonEncode({
          'model': 'llama-3.3-70b-versatile',
          'messages': apiMessages,
          'max_tokens': 1024,
          'temperature': 0.7,
        }),
      )
          .timeout(const Duration(seconds: 30));

      print('📥 Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final reply = data['choices'][0]['message']
        ['content'] as String;

        print('✅ Groq replied!');

        setState(() {
          _messages.add({
            'role': 'assistant',
            'content': reply,
            'isUser': false,
          });
          _isLoading = false;
        });
      } else {
        print('❌ Error: ${response.body}');
        _showError(
            'Failed to get response. Try again.');
        setState(() => _isLoading = false);
      }
    } catch (e) {
      print('❌ Exception: $e');
      _showError('Connection error. Check internet.');
      setState(() => _isLoading = false);
    }

    _scrollToBottom();
  }

  // ─── Scroll to Bottom ─────────────────────────────────
  void _scrollToBottom() {
    Future.delayed(
        const Duration(milliseconds: 300), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  // ─── Show Error ───────────────────────────────────────
  void _showError(String msg) {
    setState(() => _isLoading = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg,
            style: GoogleFonts.poppins(
                color: Colors.white)),
        backgroundColor: AppColors.sosRed,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final modeColor = _currentMode['color'] as Color;
    final modeEmoji = _currentMode['emoji'] as String;
    final modeTitle = _currentMode['title'] as String;

    return Scaffold(
      backgroundColor: AppColors.lightGrey,
      body: Column(
        children: [

          // ─── Header ───────────────────────────────────
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  modeColor,
                  modeColor.withOpacity(0.8),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(36),
                bottomRight: Radius.circular(36),
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                    20, 16, 20, 20),
                child: Column(
                  children: [

                    // ── App Bar ──────────────────────
                    FadeInDown(
                      duration: const Duration(
                          milliseconds: 600),
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: () =>
                                Navigator.pop(context),
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: Colors.white
                                    .withOpacity(0.2),
                                borderRadius:
                                BorderRadius
                                    .circular(12),
                              ),
                              child: const Icon(
                                Icons
                                    .arrow_back_ios_new_rounded,
                                color: Colors.white,
                                size: 18,
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: Colors.white
                                  .withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                modeEmoji,
                                style: const TextStyle(
                                    fontSize: 22),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                              CrossAxisAlignment
                                  .start,
                              children: [
                                Text(
                                  modeTitle,
                                  style:
                                  GoogleFonts.poppins(
                                    fontSize: 18,
                                    fontWeight:
                                    FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                Text(
                                  _currentMode[
                                  'description']
                                  as String,
                                  style:
                                  GoogleFonts.poppins(
                                    fontSize: 11,
                                    color: Colors.white70,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // ── Mode Selector ────────────────
                    FadeInUp(
                      duration: const Duration(
                          milliseconds: 600),
                      delay: const Duration(
                          milliseconds: 200),
                      child: SingleChildScrollView(
                        scrollDirection:
                        Axis.horizontal,
                        child: Row(
                          children:
                          _modes.map((mode) {
                            final isSelected =
                                _selectedMode ==
                                    mode['id'];
                            return Padding(
                              padding:
                              const EdgeInsets
                                  .only(right: 8),
                              child: GestureDetector(
                                onTap: () =>
                                    _switchMode(
                                        mode['id']
                                        as String),
                                child:
                                AnimatedContainer(
                                  duration:
                                  const Duration(
                                      milliseconds:
                                      300),
                                  padding:
                                  const EdgeInsets
                                      .symmetric(
                                    horizontal: 14,
                                    vertical: 8,
                                  ),
                                  decoration:
                                  BoxDecoration(
                                    color: isSelected
                                        ? Colors.white
                                        : Colors.white
                                        .withOpacity(
                                        0.2),
                                    borderRadius:
                                    BorderRadius
                                        .circular(
                                        20),
                                    boxShadow: isSelected
                                        ? [
                                      BoxShadow(
                                        color: Colors
                                            .black
                                            .withOpacity(
                                            0.15),
                                        blurRadius:
                                        8,
                                        offset:
                                        const Offset(
                                            0,
                                            3),
                                      ),
                                    ]
                                        : [],
                                  ),
                                  child: Row(
                                    mainAxisSize:
                                    MainAxisSize.min,
                                    children: [
                                      Text(
                                        mode['emoji']
                                        as String,
                                        style:
                                        const TextStyle(
                                            fontSize:
                                            14),
                                      ),
                                      const SizedBox(
                                          width: 6),
                                      Text(
                                        mode['title']
                                        as String,
                                        style: GoogleFonts
                                            .poppins(
                                          fontSize: 12,
                                          fontWeight:
                                          FontWeight
                                              .w600,
                                          color: isSelected
                                              ? modeColor
                                              : Colors
                                              .white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ─── Messages ─────────────────────────────────
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.fromLTRB(
                  16, 16, 16, 8),
              itemCount: _messages.length +
                  (_messages.length == 1 ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == 1 &&
                    _messages.length == 1) {
                  return _buildSuggestions(modeColor);
                }
                return _buildMessageBubble(
                    _messages[index], modeColor);
              },
            ),
          ),

          // ─── Typing Indicator ──────────────────────────
          if (_isLoading)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  16, 4, 16, 4),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color:
                      modeColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        modeEmoji,
                        style: const TextStyle(
                            fontSize: 18),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                      BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildTypingDot(modeColor, 0),
                        const SizedBox(width: 4),
                        _buildTypingDot(
                            modeColor, 200),
                        const SizedBox(width: 4),
                        _buildTypingDot(
                            modeColor, 400),
                      ],
                    ),
                  ),
                ],
              ),
            ),

          // ─── Input Box ─────────────────────────────────
          Container(
            padding: const EdgeInsets.fromLTRB(
                16, 8, 16, 16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -3),
                ),
              ],
            ),
            child: SafeArea(
              top: false,
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding:
                      const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.lightGrey,
                        borderRadius:
                        BorderRadius.circular(28),
                        border: Border.all(
                          color: modeColor
                              .withOpacity(0.2),
                        ),
                      ),
                      child: TextField(
                        controller: _messageController,
                        maxLines: 3,
                        minLines: 1,
                        textCapitalization:
                        TextCapitalization.sentences,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: AppColors.darkGrey,
                        ),
                        decoration: InputDecoration(
                          hintText: _getHintText(),
                          hintStyle: GoogleFonts.poppins(
                            fontSize: 13,
                            color: AppColors.mediumGrey,
                          ),
                          border: InputBorder.none,
                        ),
                        onSubmitted: _sendMessage,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: () => _sendMessage(
                        _messageController.text),
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: modeColor,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: modeColor
                                .withOpacity(0.4),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.send_rounded,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Get Hint Text ────────────────────────────────────
  String _getHintText() {
    switch (_selectedMode) {
      case 'safety':
        return 'Ask about staying safe...';
      case 'legal':
        return 'Ask about your legal rights...';
      case 'support':
        return 'Share what\'s on your mind...';
      case 'emergency':
        return 'Describe your situation...';
      default:
        return 'Type your message...';
    }
  }

  // ─── Message Bubble ───────────────────────────────────
  Widget _buildMessageBubble(
      Map<String, dynamic> msg, Color modeColor) {
    final isUser = msg['isUser'] as bool;
    final content = msg['content'] as String;
    final modeEmoji = _currentMode['emoji'] as String;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: isUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser) ...[
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: modeColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(modeEmoji,
                    style:
                    const TextStyle(fontSize: 16)),
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              decoration: BoxDecoration(
                color:
                isUser ? modeColor : Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(20),
                  topRight: const Radius.circular(20),
                  bottomLeft:
                  Radius.circular(isUser ? 20 : 4),
                  bottomRight:
                  Radius.circular(isUser ? 4 : 20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: isUser
                        ? modeColor.withOpacity(0.3)
                        : Colors.black
                        .withOpacity(0.06),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: _buildFormattedText(
                  content, isUser),
            ),
          ),
          if (isUser) ...[
            const SizedBox(width: 8),
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: modeColor.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.person_rounded,
                  color: modeColor, size: 18),
            ),
          ],
        ],
      ),
    );
  }

  // ─── Format Text ──────────────────────────────────────
  Widget _buildFormattedText(
      String text, bool isUser) {
    final lines = text.split('\n');
    final widgets = <Widget>[];

    for (final line in lines) {
      if (line.trim().isEmpty) {
        widgets.add(const SizedBox(height: 4));
      } else if (line.startsWith('- ') ||
          line.startsWith('• ') ||
          line.startsWith('* ')) {
        final content = line.length > 2
            ? line.substring(2)
            : line;
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Row(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  '• ',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: isUser
                        ? Colors.white70
                        : _currentMode['color']
                    as Color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Expanded(
                  child: _buildInlineText(
                      content, isUser),
                ),
              ],
            ),
          ),
        );
      } else {
        widgets
            .add(_buildInlineText(line, isUser));
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: widgets,
    );
  }

  // ─── Inline Text with Bold ────────────────────────────
  Widget _buildInlineText(
      String text, bool isUser) {
    final parts = text.split('**');
    if (parts.length == 1) {
      return Text(
        text,
        style: GoogleFonts.poppins(
          fontSize: 13,
          height: 1.5,
          color: isUser
              ? Colors.white
              : AppColors.darkGrey,
        ),
      );
    }

    final spans = <TextSpan>[];
    for (int i = 0; i < parts.length; i++) {
      if (parts[i].isEmpty) continue;
      spans.add(TextSpan(
        text: parts[i],
        style: TextStyle(
          fontWeight: i % 2 == 1
              ? FontWeight.bold
              : FontWeight.normal,
          color: isUser
              ? Colors.white
              : AppColors.darkGrey,
        ),
      ));
    }

    return RichText(
      text: TextSpan(
        style: GoogleFonts.poppins(
            fontSize: 13, height: 1.5),
        children: spans,
      ),
    );
  }

  // ─── Suggestions ──────────────────────────────────────
  Widget _buildSuggestions(Color modeColor) {
    final suggestions =
        _suggestions[_selectedMode] ?? [];

    return FadeInUp(
      duration: const Duration(milliseconds: 600),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(
                left: 44, bottom: 10),
            child: Text(
              'Try asking:',
              style: GoogleFonts.poppins(
                fontSize: 11,
                color: AppColors.mediumGrey,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          SizedBox(
            height: 38,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding:
              const EdgeInsets.only(left: 44),
              itemCount: suggestions.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () => _sendMessage(
                      suggestions[index]),
                  child: Container(
                    margin: const EdgeInsets.only(
                        right: 8),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                      BorderRadius.circular(20),
                      border: Border.all(
                        color:
                        modeColor.withOpacity(0.3),
                      ),
                    ),
                    child: Text(
                      suggestions[index],
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: modeColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  // ─── Typing Dot ───────────────────────────────────────
  Widget _buildTypingDot(
      Color color, int delayMs) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.3, end: 1.0),
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeInOut,
      builder: (context, value, child) {
        return Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color.withOpacity(value),
            shape: BoxShape.circle,
          ),
        );
      },
    );
  }
}