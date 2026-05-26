import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sentinel/presentation/screens/profile_setup_screen.dart';
import '../../../core/constants/app_colors.dart';

class OtpScreen extends StatefulWidget {
  final String verificationId;
  final String phoneNumber;

  const OtpScreen({
    super.key,
    required this.verificationId,
    required this.phoneNumber,
  });

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  // 6 controllers for 6 OTP boxes
  final List<TextEditingController> _controllers =
  List.generate(6, (_) => TextEditingController());

  // 6 focus nodes for auto-jumping between boxes
  final List<FocusNode> _focusNodes =
  List.generate(6, (_) => FocusNode());

  bool _isLoading = false;
  int _resendSeconds = 60;
  bool _canResend = false;

  @override
  void initState() {
    super.initState();
    _startResendTimer();
  }

  @override
  void dispose() {
    for (var c in _controllers) {
      c.dispose();
    }
    for (var f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  // ─── Resend Timer ─────────────────────────────────────
  void _startResendTimer() {
    setState(() {
      _resendSeconds = 60;
      _canResend = false;
    });
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return false;
      setState(() {
        if (_resendSeconds > 0) {
          _resendSeconds--;
        } else {
          _canResend = true;
        }
      });
      return _resendSeconds > 0;
    });
  }

  // ─── Get Full OTP ─────────────────────────────────────
  String get _otp =>
      _controllers.map((c) => c.text).join();

  // ─── Verify OTP ───────────────────────────────────────
  Future<void> _verifyOTP() async {
    if (_otp.length != 6) {
      _showError('Please enter the complete 6-digit OTP');
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Create credential from verification ID and OTP
      final credential = PhoneAuthProvider.credential(
        verificationId: widget.verificationId,
        smsCode: _otp,
      );

      // Sign in with credential
      await FirebaseAuth.instance.signInWithCredential(credential);

      setState(() => _isLoading = false);

      // Show success
      _showSuccess('Phone verified successfully!');

      await Future.delayed(const Duration(seconds: 1));

      if (!mounted) return;

// Navigate to Profile Setup Screen
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => ProfileSetupScreen(
            phoneNumber: widget.phoneNumber,
          ),
        ),
            (route) => false,
      );

    } on FirebaseAuthException catch (e) {
      setState(() => _isLoading = false);
      if (e.code == 'invalid-verification-code') {
        _showError('Invalid OTP. Please try again.');
      } else {
        _showError(e.message ?? 'Verification failed.');
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _showError('Something went wrong. Please try again.');
    }
  }

  // ─── Show Error ───────────────────────────────────────
  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.poppins(color: Colors.white),
        ),
        backgroundColor: AppColors.sosRed,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  // ─── Show Success ─────────────────────────────────────
  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.poppins(color: Colors.white),
        ),
        backgroundColor: AppColors.successGreen,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  // ─── Build Single OTP Box ─────────────────────────────
  Widget _buildOtpBox(int index) {
    return SizedBox(
      width: 48,
      height: 56,
      child: TextFormField(
        controller: _controllers[index],
        focusNode: _focusNodes[index],
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        maxLength: 1,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        style: GoogleFonts.poppins(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: AppColors.deepPurple,
        ),
        decoration: InputDecoration(
          counterText: '',
          filled: true,
          fillColor: _controllers[index].text.isNotEmpty
              ? AppColors.deepPurple.withOpacity(0.08)
              : AppColors.lightGrey,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: AppColors.deepPurple,
              width: 2,
            ),
          ),
        ),
        onChanged: (value) {
          setState(() {});
          if (value.isNotEmpty && index < 5) {
            // Move to next box
            _focusNodes[index + 1].requestFocus();
          } else if (value.isEmpty && index > 0) {
            // Move to previous box on delete
            _focusNodes[index - 1].requestFocus();
          }
          // Auto verify when all 6 digits entered
          if (_otp.length == 6) {
            _verifyOTP();
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightGrey,
      body: Column(
        children: [

          // ─── Top Purple Section ───────────────────────
          Container(
            height: MediaQuery.of(context).size.height * 0.38,
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: AppColors.purpleGradient,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(40),
                bottomRight: Radius.circular(40),
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [

                const SizedBox(height: 40),

                // Lock Icon
                FadeInDown(
                  duration: const Duration(milliseconds: 600),
                  child: Container(
                    width: 95,
                    height: 95,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 2,
                      ),
                    ),
                    child: const Icon(
                      Icons.lock_outline_rounded,
                      color: Colors.white,
                      size: 48,
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                FadeInUp(
                  duration: const Duration(milliseconds: 600),
                  delay: const Duration(milliseconds: 200),
                  child: Text(
                    'Verify your number',
                    style: GoogleFonts.poppins(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                FadeInUp(
                  duration: const Duration(milliseconds: 600),
                  delay: const Duration(milliseconds: 300),
                  child: Text(
                    'Code sent to ${widget.phoneNumber}',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w300,
                      color: Colors.white70,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ─── Bottom Card Section ──────────────────────
          Expanded(
            child: SingleChildScrollView(
              child: FadeInUp(
                duration: const Duration(milliseconds: 700),
                delay: const Duration(milliseconds: 400),
                child: Container(
                  margin: const EdgeInsets.all(20),
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.deepPurple.withOpacity(0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      // ─── Title ────────────────────────
                      Text(
                        'Enter OTP',
                        style: GoogleFonts.poppins(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.darkGrey,
                        ),
                      ),

                      const SizedBox(height: 8),

                      Text(
                        'Enter the 6-digit code we sent you',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: AppColors.mediumGrey,
                        ),
                      ),

                      const SizedBox(height: 32),

                      // ─── 6 OTP Boxes ──────────────────
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: List.generate(
                          6,
                              (index) => _buildOtpBox(index),
                        ),
                      ),

                      const SizedBox(height: 32),

                      // ─── Verify Button ─────────────────
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _verifyOTP,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.deepPurple,
                            foregroundColor: Colors.white,
                            disabledBackgroundColor:
                            AppColors.deepPurple.withOpacity(0.6),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            elevation: 4,
                            shadowColor:
                            AppColors.deepPurple.withOpacity(0.4),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          )
                              : Text(
                            'Verify OTP',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 28),

                      // ─── Resend OTP Section ────────────
                      Center(
                        child: Column(
                          children: [

                            // Label text
                            Text(
                              _canResend
                                  ? 'Didn\'t receive the code?'
                                  : 'Resend code in',
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                color: AppColors.mediumGrey,
                              ),
                            ),

                            const SizedBox(height: 10),

                            // Timer OR Resend Button
                            _canResend

                            // ── Resend Button ─────────────
                                ? GestureDetector(
                              onTap: () {
                                // Clear all OTP boxes
                                for (var c in _controllers) {
                                  c.clear();
                                }
                                setState(() {});
                                _startResendTimer();
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 32,
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.deepPurple
                                      .withOpacity(0.08),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: AppColors.deepPurple
                                        .withOpacity(0.4),
                                    width: 1.5,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.refresh_rounded,
                                      size: 18,
                                      color: AppColors.deepPurple,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Resend OTP',
                                      style: GoogleFonts.poppins(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.deepPurple,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )

                            // ── Countdown Timer ───────────
                                : Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.lightGrey,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.timer_outlined,
                                    size: 18,
                                    color: AppColors.mediumGrey,
                                  ),
                                  const SizedBox(width: 8),
                                  RichText(
                                    text: TextSpan(
                                      text: '00:',
                                      style: GoogleFonts.poppins(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.mediumGrey,
                                      ),
                                      children: [
                                        TextSpan(
                                          text: _resendSeconds
                                              .toString()
                                              .padLeft(2, '0'),
                                          style: GoogleFonts.poppins(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.deepPurple,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // ─── Change Number Button ──────────
                      Center(
                        child: TextButton.icon(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(
                            Icons.arrow_back_ios,
                            size: 14,
                            color: AppColors.mediumGrey,
                          ),
                          label: Text(
                            'Change phone number',
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              color: AppColors.mediumGrey,
                            ),
                          ),
                        ),
                      ),

                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}