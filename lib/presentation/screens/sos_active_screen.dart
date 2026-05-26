import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/services/api_service.dart';
import 'home_screen.dart';
import '../../../data/services/sms_service.dart';

class SosActiveScreen extends StatefulWidget {
  final Map<String, dynamic> sosData;

  const SosActiveScreen({
    super.key,
    required this.sosData,
  });

  @override
  State<SosActiveScreen> createState() => _SosActiveScreenState();
}

class _SosActiveScreenState extends State<SosActiveScreen>
    with SingleTickerProviderStateMixin {

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  bool _isResolving = false;
  int _elapsedSeconds = 0;

  @override
  void initState() {
    super.initState();

    // Pulse animation
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: Curves.easeInOut,
      ),
    );

    // Start elapsed time counter
    _startTimer();
  }

  void _startTimer() {
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return false;
      setState(() => _elapsedSeconds++);
      return true;
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  // ─── Format Time ──────────────────────────────────────
  String get _formattedTime {
    final minutes = _elapsedSeconds ~/ 60;
    final seconds = _elapsedSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  Future<void> _resolveSOS() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(
          'Cancel SOS?',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: AppColors.darkGrey,
          ),
        ),
        content: Text(
          'Tapping "I\'m Safe" will notify all your guardians that you are safe and cancel the SOS.',
          style: GoogleFonts.poppins(
            fontSize: 13,
            color: AppColors.mediumGrey,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'No, Keep SOS',
              style: GoogleFonts.poppins(
                color: AppColors.sosRed,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.successGreen,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(
              'Yes, I\'m Safe',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 4),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() => _isResolving = true);

      try {
        final sosId = widget.sosData['sos']?['id'];
        if (sosId != null) {
          await ApiService.resolveSOS(sosId).timeout(
            const Duration(seconds: 8),
            onTimeout: () => {'success': true},
          );
        }

        // ✅ Send safe SMS from phone
        final guardians =
        widget.sosData['guardians'] as List?;
        final userName =
        widget.sosData['userName'] as String?;

        if (guardians != null &&
            guardians.isNotEmpty &&
            userName != null) {
          SmsService.sendSafeSms(
            guardians: guardians
                .map((g) => g as Map<String, dynamic>)
                .toList(),
            userName: userName,
          );
        }
        
      } catch (e) {
        print('Resolve error: $e');
      }

      if (!mounted) return;

      // ✅ Use pushAndRemoveUntil to clear entire stack
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => const HomeScreen(),
        ),
            (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final notified = widget.sosData['notified'] ?? 0;
    final guardians = widget.sosData['guardians'] as List? ?? [];

    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: AppColors.sosRed,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [

                const SizedBox(height: 20),

                // ─── SOS Active Header ─────────────────
                FadeInDown(
                  duration: const Duration(milliseconds: 600),
                  child: Column(
                    children: [
                      // Pulsing SOS Circle
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
                                color: Colors.white.withOpacity(0.2),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.5),
                                  width: 3,
                                ),
                              ),
                              child: const Icon(
                                Icons.warning_amber_rounded,
                                color: Colors.white,
                                size: 60,
                              ),
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 20),

                      Text(
                        'SOS ACTIVE',
                        style: GoogleFonts.poppins(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 4,
                        ),
                      ),

                      const SizedBox(height: 8),

                      // Timer
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.timer_outlined,
                              color: Colors.white,
                              size: 16,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              _formattedTime,
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // ─── Status Cards ──────────────────────
                FadeInUp(
                  duration: const Duration(milliseconds: 600),
                  delay: const Duration(milliseconds: 200),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      children: [

                        _buildStatusRow(
                          icon: Icons.location_on_rounded,
                          text: 'Location captured',
                          isDone: true,
                        ),

                        const SizedBox(height: 12),

                        _buildStatusRow(
                          icon: Icons.notifications_active_rounded,
                          text: '$notified guardian${notified != 1 ? 's' : ''} notified',
                          isDone: notified > 0,
                        ),

                        const SizedBox(height: 12),

                        _buildStatusRow(
                          icon: Icons.sms_rounded,
                          text: 'SMS alerts sent',
                          isDone: notified > 0,
                        ),

                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // ─── Guardian List ─────────────────────
                if (guardians.isNotEmpty) ...[
                  FadeInUp(
                    duration: const Duration(milliseconds: 600),
                    delay: const Duration(milliseconds: 300),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Guardians Alerted:',
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 10),
                          ...guardians.map((g) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              children: [
                                Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Text(
                                      (g['name'] ?? 'G')[0].toUpperCase(),
                                      style: GoogleFonts.poppins(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      g['name'] ?? 'Guardian',
                                      style: GoogleFonts.poppins(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                                    Text(
                                      g['phone'] ?? '',
                                      style: GoogleFonts.poppins(
                                        fontSize: 11,
                                        color: Colors.white70,
                                      ),
                                    ),
                                  ],
                                ),
                                const Spacer(),
                                const Icon(
                                  Icons.check_circle_rounded,
                                  color: Color(0xFF69F0AE),
                                  size: 20,
                                ),
                              ],
                            ),
                          )),
                        ],
                      ),
                    ),
                  ),
                ],

                const Spacer(),

                // ─── Cancel SOS Button ─────────────────
                FadeInUp(
                  duration: const Duration(milliseconds: 600),
                  delay: const Duration(milliseconds: 500),
                  child: SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: OutlinedButton.icon(
                      onPressed: _isResolving ? null : _resolveSOS,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(
                          color: Colors.white,
                          width: 2,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      icon: _isResolving
                          ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                          : const Icon(
                        Icons.check_circle_outline_rounded,
                        size: 22,
                      ),
                      label: Text(
                        _isResolving
                            ? 'Notifying guardians...'
                            : 'I\'m Safe — Cancel SOS',
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─── Status Row Widget ────────────────────────────────
  Widget _buildStatusRow({
    required IconData icon,
    required String text,
    required bool isDone,
  }) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: isDone
                ? Colors.white
                : Colors.white.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(
            isDone ? Icons.check_rounded : icon,
            size: 18,
            color: isDone ? AppColors.sosRed : Colors.white,
          ),
        ),
        const SizedBox(width: 14),
        Text(
          text,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: isDone ? FontWeight.w600 : FontWeight.normal,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}