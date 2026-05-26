import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:vibration/vibration.dart';
import '../../../core/constants/app_colors.dart';

class FakeCallScreen extends StatefulWidget {
  const FakeCallScreen({super.key});

  @override
  State<FakeCallScreen> createState() =>
      _FakeCallScreenState();
}

class _FakeCallScreenState extends State<FakeCallScreen>
    with TickerProviderStateMixin {

  // Audio
  final AudioPlayer _audioPlayer = AudioPlayer();

  // Caller details
  String _callerName = 'Mom';
  String _callerNumber = '+91 98765 43210';

  // Call state
  bool _isRinging = true;
  bool _isInCall = false;
  bool _isMuted = false;
  bool _isSpeaker = false;
  int _callSeconds = 0;

  // Schedule
  int _scheduleSeconds = 5;
  bool _isScheduled = false;
  bool _callStarted = false;

  // Timers
  Timer? _callTimer;
  Timer? _scheduleTimer;
  Timer? _ringTimer;

  // Animation controllers
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  late AnimationController _rippleController;
  late Animation<double> _rippleAnimation;

  // Caller presets
  final List<Map<String, dynamic>> _callerPresets = [
    {'name': 'Mom', 'number': '+91 98765 43210', 'emoji': '👩'},
    {'name': 'Dad', 'number': '+91 98765 43211', 'emoji': '👨'},
    {'name': 'Sister', 'number': '+91 98765 43212', 'emoji': '👧'},
    {'name': 'Best Friend', 'number': '+91 98765 43213', 'emoji': '👫'},
    {'name': 'Boss', 'number': '+91 98765 43214', 'emoji': '👔'},
    {'name': 'Doctor', 'number': '+91 98765 43215', 'emoji': '👨‍⚕️'},
  ];

  @override
  void initState() {
    super.initState();

    // Pulse animation
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.08,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    // Ripple animation
    _rippleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();

    _rippleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.6,
    ).animate(CurvedAnimation(
      parent: _rippleController,
      curve: Curves.easeOut,
    ));
  }

  @override
  void dispose() {
    _callTimer?.cancel();
    _scheduleTimer?.cancel();
    _ringTimer?.cancel();
    _pulseController.dispose();
    _rippleController.dispose();
    _audioPlayer.dispose();
    Vibration.cancel();
    super.dispose();
  }

  // ─── Play Ringtone ─────────────────────────────────────
  Future<void> _playRingtone() async {
    try {
      await _audioPlayer.setReleaseMode(ReleaseMode.loop);
      await _audioPlayer.play(
        AssetSource('audio/ringtone.mp3'),
      );

      if (await Vibration.hasVibrator() ?? false) {
        Vibration.vibrate(
          pattern: [0, 1000, 1000, 1000],
          repeat: 2,
        );
      }
    } catch (e) {
      print('Audio error: $e');
    }
  }

  // ─── Stop Ringtone ─────────────────────────────────────
  Future<void> _stopRingtone() async {
    try {
      await _audioPlayer.stop();
      Vibration.cancel();
    } catch (e) {
      print('Stop audio error: $e');
    }
  }

  // ─── Start Immediate Call ──────────────────────────────
  void _startImmediateCall() {
    setState(() {
      _callStarted = true;
      _isRinging = true;
      _isInCall = false;
      _isScheduled = false;
    });

    HapticFeedback.vibrate();
    _playRingtone();

    _ringTimer = Timer(const Duration(seconds: 30), () {
      if (mounted && _isRinging) {
        _declineCall();
      }
    });
  }

  // ─── Schedule Fake Call ────────────────────────────────
  void _scheduleCall() {
    setState(() {
      _isScheduled = true;
      _callStarted = false;
    });

    _scheduleTimer = Timer(
      Duration(seconds: _scheduleSeconds),
          () {
        if (mounted) _startImmediateCall();
      },
    );
  }

  // ─── Accept Call ───────────────────────────────────────
  void _acceptCall() {
    _ringTimer?.cancel();
    _stopRingtone();
    HapticFeedback.mediumImpact();

    setState(() {
      _isRinging = false;
      _isInCall = true;
      _callSeconds = 0;
    });

    _callTimer = Timer.periodic(
      const Duration(seconds: 1),
          (_) {
        if (mounted) setState(() => _callSeconds++);
      },
    );
  }

  // ─── Decline Call ──────────────────────────────────────
  void _declineCall() {
    _ringTimer?.cancel();
    _scheduleTimer?.cancel();
    _stopRingtone();
    HapticFeedback.mediumImpact();

    setState(() {
      _isRinging = false;
      _isInCall = false;
      _callStarted = false;
      _isScheduled = false;
    });
  }

  // ─── End Call ──────────────────────────────────────────
  void _endCall() {
    _callTimer?.cancel();
    _stopRingtone();
    HapticFeedback.mediumImpact();

    setState(() {
      _isInCall = false;
      _isRinging = false;
      _callStarted = false;
    });
  }

  // ─── Format Call Duration ──────────────────────────────
  String get _callDuration {
    final minutes = _callSeconds ~/ 60;
    final seconds = _callSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    if (_callStarted && _isRinging) {
      return _buildIncomingCallScreen();
    }
    if (_isInCall) {
      return _buildInCallScreen();
    }
    return _buildSetupScreen();
  }

  // ─── Setup Screen ──────────────────────────────────────
  Widget _buildSetupScreen() {
    return Scaffold(
      backgroundColor: AppColors.lightGrey,
      body: Column(
        children: [

          // ── Purple Header ──────────────────────────────
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: AppColors.purpleGradient,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(36),
                bottomRight: Radius.circular(36),
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                    20, 16, 20, 30),
                child: Column(
                  children: [

                    // App Bar
                    FadeInDown(
                      duration:
                      const Duration(milliseconds: 600),
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
                                BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons
                                    .arrow_back_ios_new_rounded,
                                color: Colors.white,
                                size: 18,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Text(
                            'Fake Call',
                            style: GoogleFonts.poppins(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Phone icon
                    FadeInUp(
                      duration:
                      const Duration(milliseconds: 600),
                      delay: const Duration(milliseconds: 200),
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color:
                          Colors.white.withOpacity(0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.phone_in_talk_rounded,
                          color: Colors.white,
                          size: 40,
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    FadeInUp(
                      duration:
                      const Duration(milliseconds: 600),
                      delay: const Duration(milliseconds: 300),
                      child: Text(
                        'Setup your fake call',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.white70,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Content ────────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  const SizedBox(height: 8),

                  // Caller Name Label
                  FadeInLeft(
                    duration:
                    const Duration(milliseconds: 600),
                    child: Text(
                      'Caller Name',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkGrey,
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Caller Presets
                  FadeInUp(
                    duration:
                    const Duration(milliseconds: 600),
                    delay: const Duration(milliseconds: 100),
                    child: Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: _callerPresets.map((preset) {
                        final isSelected =
                            _callerName == preset['name'];
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _callerName =
                              preset['name'] as String;
                              _callerNumber =
                              preset['number'] as String;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.deepPurple
                                  : Colors.white,
                              borderRadius:
                              BorderRadius.circular(20),
                              border: Border.all(
                                color: isSelected
                                    ? AppColors.deepPurple
                                    : Colors.grey.shade200,
                              ),
                              boxShadow: isSelected
                                  ? [
                                BoxShadow(
                                  color: AppColors
                                      .deepPurple
                                      .withOpacity(0.3),
                                  blurRadius: 8,
                                  offset:
                                  const Offset(0, 3),
                                ),
                              ]
                                  : [],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  preset['emoji'] as String,
                                  style: const TextStyle(
                                      fontSize: 16),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  preset['name'] as String,
                                  style: GoogleFonts.poppins(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: isSelected
                                        ? Colors.white
                                        : AppColors.darkGrey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Custom Name Field
                  FadeInUp(
                    duration:
                    const Duration(milliseconds: 600),
                    delay: const Duration(milliseconds: 200),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                        BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.deepPurple
                                .withOpacity(0.06),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: TextField(
                        onChanged: (val) {
                          if (val.isNotEmpty) {
                            setState(() => _callerName = val);
                          }
                        },
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: AppColors.darkGrey,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Or type custom name...',
                          hintStyle: GoogleFonts.poppins(
                            fontSize: 13,
                            color: AppColors.mediumGrey,
                          ),
                          border: InputBorder.none,
                          prefixIcon: const Icon(
                            Icons.person_outline_rounded,
                            color: AppColors.deepPurple,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 28),

                  // When to Call Label
                  FadeInLeft(
                    duration:
                    const Duration(milliseconds: 600),
                    child: Text(
                      'When to Call?',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkGrey,
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Schedule options
                  FadeInUp(
                    duration:
                    const Duration(milliseconds: 600),
                    delay: const Duration(milliseconds: 200),
                    child: Row(
                      children: [5, 10, 30, 60].map((seconds) {
                        final isSelected =
                            _scheduleSeconds == seconds;
                        final label = seconds < 60
                            ? '${seconds}s'
                            : '1 min';
                        return Expanded(
                          child: GestureDetector(
                            onTap: () => setState(
                                    () => _scheduleSeconds =
                                    seconds),
                            child: Container(
                              margin: const EdgeInsets
                                  .symmetric(horizontal: 4),
                              padding:
                              const EdgeInsets.symmetric(
                                  vertical: 12),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.deepPurple
                                    : Colors.white,
                                borderRadius:
                                BorderRadius.circular(14),
                                boxShadow: [
                                  BoxShadow(
                                    color: isSelected
                                        ? AppColors.deepPurple
                                        .withOpacity(0.3)
                                        : Colors.black
                                        .withOpacity(0.05),
                                    blurRadius: 8,
                                    offset:
                                    const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Text(
                                label,
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: isSelected
                                      ? Colors.white
                                      : AppColors.darkGrey,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Action Buttons
                  FadeInUp(
                    duration:
                    const Duration(milliseconds: 600),
                    delay: const Duration(milliseconds: 300),
                    child: Row(
                      children: [

                        // Schedule Button
                        Expanded(
                          child: SizedBox(
                            height: 54,
                            child: OutlinedButton.icon(
                              onPressed: _isScheduled
                                  ? null
                                  : _scheduleCall,
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(
                                  color: _isScheduled
                                      ? Colors.grey
                                      : AppColors.deepPurple,
                                  width: 2,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                  BorderRadius.circular(16),
                                ),
                              ),
                              icon: Icon(
                                Icons.schedule_rounded,
                                color: _isScheduled
                                    ? Colors.grey
                                    : AppColors.deepPurple,
                                size: 20,
                              ),
                              label: Text(
                                _isScheduled
                                    ? 'Scheduled!'
                                    : 'In ${_scheduleSeconds < 60 ? '${_scheduleSeconds}s' : '1 min'}',
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: _isScheduled
                                      ? Colors.grey
                                      : AppColors.deepPurple,
                                ),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(width: 12),

                        // Call Now Button
                        Expanded(
                          child: SizedBox(
                            height: 54,
                            child: ElevatedButton.icon(
                              onPressed: _startImmediateCall,
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                AppColors.successGreen,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                  BorderRadius.circular(16),
                                ),
                              ),
                              icon: const Icon(
                                Icons.phone_rounded,
                                size: 20,
                              ),
                              label: Text(
                                'Call Now',
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Info Card
                  FadeInUp(
                    duration:
                    const Duration(milliseconds: 600),
                    delay: const Duration(milliseconds: 400),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.deepPurple
                            .withOpacity(0.06),
                        borderRadius:
                        BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColors.deepPurple
                              .withOpacity(0.15),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.info_outline_rounded,
                            color: AppColors.deepPurple,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Use this feature to escape uncomfortable situations. Tap "Call Now" for immediate fake call or schedule for later.',
                              style: GoogleFonts.poppins(
                                fontSize: 11,
                                color: AppColors.deepPurple,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
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

  // ─── Incoming Call Screen ──────────────────────────────
  Widget _buildIncomingCallScreen() {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF1A1A2E),
                  Color(0xFF16213E),
                  Color(0xFF0F3460),
                ],
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [

                const SizedBox(height: 60),

                // Incoming call label
                FadeInDown(
                  duration: const Duration(milliseconds: 600),
                  child: Text(
                    'Incoming Call',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: Colors.white60,
                      letterSpacing: 1,
                    ),
                  ),
                ),

                const SizedBox(height: 40),

                // Ripple + Avatar
                FadeInUp(
                  duration: const Duration(milliseconds: 600),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [

                      // Ripple ring
                      AnimatedBuilder(
                        animation: _rippleAnimation,
                        builder: (context, child) {
                          return Container(
                            width: 180 *
                                _rippleAnimation.value,
                            height: 180 *
                                _rippleAnimation.value,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white
                                    .withOpacity(0.1 *
                                    (2 -
                                        _rippleAnimation
                                            .value)),
                                width: 2,
                              ),
                            ),
                          );
                        },
                      ),

                      // Pulse avatar
                      AnimatedBuilder(
                        animation: _pulseAnimation,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: _pulseAnimation.value,
                            child: Container(
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  colors: [
                                    AppColors.deepPurple,
                                    AppColors.softPurple,
                                  ],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors
                                        .deepPurple
                                        .withOpacity(0.5),
                                    blurRadius: 20,
                                    spreadRadius: 5,
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Text(
                                  _callerName.isNotEmpty
                                      ? _callerName[0]
                                      .toUpperCase()
                                      : '?',
                                  style: GoogleFonts.poppins(
                                    fontSize: 48,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // Caller name
                FadeInUp(
                  duration: const Duration(milliseconds: 600),
                  delay: const Duration(milliseconds: 200),
                  child: Text(
                    _callerName,
                    style: GoogleFonts.poppins(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                // Phone number
                FadeInUp(
                  duration: const Duration(milliseconds: 600),
                  delay: const Duration(milliseconds: 300),
                  child: Text(
                    _callerNumber,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: Colors.white60,
                    ),
                  ),
                ),

                const Spacer(),

                // Accept / Decline
                FadeInUp(
                  duration: const Duration(milliseconds: 600),
                  delay: const Duration(milliseconds: 400),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 60,
                      vertical: 50,
                    ),
                    child: Row(
                      mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                      children: [

                        // Decline
                        Column(
                          children: [
                            GestureDetector(
                              onTap: _declineCall,
                              child: Container(
                                width: 72,
                                height: 72,
                                decoration: BoxDecoration(
                                  color: AppColors.sosRed,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.sosRed
                                          .withOpacity(0.5),
                                      blurRadius: 20,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.call_end_rounded,
                                  color: Colors.white,
                                  size: 32,
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Decline',
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),

                        // Accept
                        Column(
                          children: [
                            GestureDetector(
                              onTap: _acceptCall,
                              child: Container(
                                width: 72,
                                height: 72,
                                decoration: BoxDecoration(
                                  color:
                                  AppColors.successGreen,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors
                                          .successGreen
                                          .withOpacity(0.5),
                                      blurRadius: 20,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.call_rounded,
                                  color: Colors.white,
                                  size: 32,
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Accept',
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── In Call Screen ────────────────────────────────────
  Widget _buildInCallScreen() {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF1A1A2E),
                  Color(0xFF16213E),
                  Color(0xFF0F3460),
                ],
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [

                const SizedBox(height: 60),

                Text(
                  'On Call',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: AppColors.successGreen,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1,
                  ),
                ),

                const SizedBox(height: 40),

                // Avatar
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        AppColors.deepPurple,
                        AppColors.softPurple,
                      ],
                    ),
                  ),
                  child: Center(
                    child: Text(
                      _callerName.isNotEmpty
                          ? _callerName[0].toUpperCase()
                          : '?',
                      style: GoogleFonts.poppins(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Name
                Text(
                  _callerName,
                  style: GoogleFonts.poppins(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: 8),

                // Duration
                Text(
                  _callDuration,
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    color: AppColors.successGreen,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const Spacer(),

                // Controls
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 40),
                  child: Row(
                    mainAxisAlignment:
                    MainAxisAlignment.spaceEvenly,
                    children: [

                      // Mute
                      _buildCallControl(
                        icon: _isMuted
                            ? Icons.mic_off_rounded
                            : Icons.mic_rounded,
                        label: _isMuted ? 'Unmute' : 'Mute',
                        isActive: _isMuted,
                        onTap: () => setState(
                                () => _isMuted = !_isMuted),
                      ),

                      // Speaker
                      _buildCallControl(
                        icon: _isSpeaker
                            ? Icons.volume_up_rounded
                            : Icons.volume_down_rounded,
                        label: 'Speaker',
                        isActive: _isSpeaker,
                        onTap: () => setState(
                                () => _isSpeaker = !_isSpeaker),
                      ),

                      // Keypad
                      _buildCallControl(
                        icon: Icons.dialpad_rounded,
                        label: 'Keypad',
                        isActive: false,
                        onTap: () {},
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 48),

                // End Call
                GestureDetector(
                  onTap: _endCall,
                  child: Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: AppColors.sosRed,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.sosRed
                              .withOpacity(0.5),
                          blurRadius: 20,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.call_end_rounded,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                Text(
                  'End',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: Colors.white70,
                  ),
                ),

                const SizedBox(height: 50),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── Call Control Button ───────────────────────────────
  Widget _buildCallControl({
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: isActive
                  ? Colors.white
                  : Colors.white.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: isActive
                  ? AppColors.deepPurple
                  : Colors.white,
              size: 26,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: Colors.white60,
            ),
          ),
        ],
      ),
    );
  }
}