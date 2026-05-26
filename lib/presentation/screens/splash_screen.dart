// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:animate_do/animate_do.dart';
//
// class SplashScreen extends StatefulWidget {
//   const SplashScreen({super.key});
//
//   @override
//   State<SplashScreen> createState() => _SplashScreenState();
// }
//
// class _SplashScreenState extends State<SplashScreen> {
//
//   @override
//   void initState() {
//     super.initState();
//     // Navigate to next screen after 3 seconds
//     _navigateToNext();
//   }
//
//   void _navigateToNext() async {
//     // Wait 3 seconds on splash screen
//     await Future.delayed(const Duration(seconds: 3));
//     // For now just stay on splash — we will add navigation on Day 5
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Container(
//         width: double.infinity,
//         height: double.infinity,
//
//         // Purple gradient background
//         decoration: const BoxDecoration(
//           gradient: LinearGradient(
//             begin: Alignment.topLeft,
//             end: Alignment.bottomRight,
//             colors: [
//               Color(0xFF4A148C), // Deep Purple
//               Color(0xFF7B1FA2), // Soft Purple
//               Color(0xFF4A148C), // Deep Purple
//             ],
//           ),
//         ),
//
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//
//             // ─── Shield Icon with Animation ───────────────
//             FadeInDown(
//               duration: const Duration(milliseconds: 800),
//               child: Container(
//                 width: 130,
//                 height: 130,
//                 decoration: BoxDecoration(
//                   color: Colors.white.withOpacity(0.15),
//                   shape: BoxShape.circle,
//                   border: Border.all(
//                     color: Colors.white.withOpacity(0.3),
//                     width: 2,
//                   ),
//                 ),
//                 child: const Icon(
//                   Icons.shield,
//                   color: Colors.white,
//                   size: 75,
//                 ),
//               ),
//             ),
//
//             const SizedBox(height: 35),
//
//             // ─── App Name with Animation ──────────────────
//             FadeInUp(
//               duration: const Duration(milliseconds: 800),
//               delay: const Duration(milliseconds: 300),
//               child: Text(
//                 'SENTINEL',
//                 style: GoogleFonts.poppins(
//                   fontSize: 38,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.white,
//                   letterSpacing: 8,
//                 ),
//               ),
//             ),
//
//             const SizedBox(height: 12),
//
//             // ─── Tagline with Animation ───────────────────
//             FadeInUp(
//               duration: const Duration(milliseconds: 800),
//               delay: const Duration(milliseconds: 500),
//               child: Text(
//                 'Guardian Who Never Sleeps',
//                 style: GoogleFonts.poppins(
//                   fontSize: 16,
//                   fontWeight: FontWeight.w300,
//                   color: Colors.white70,
//                   letterSpacing: 2,
//                 ),
//               ),
//             ),
//
//             const SizedBox(height: 80),
//
//             // ─── Loading Indicator with Animation ─────────
//             FadeIn(
//               duration: const Duration(milliseconds: 800),
//               delay: const Duration(milliseconds: 800),
//               child: Column(
//                 children: [
//                   const SizedBox(
//                     width: 35,
//                     height: 35,
//                     child: CircularProgressIndicator(
//                       color: Colors.white,
//                       strokeWidth: 2,
//                     ),
//                   ),
//                   const SizedBox(height: 20),
//                   Text(
//                     'Initializing...',
//                     style: GoogleFonts.poppins(
//                       fontSize: 13,
//                       color: Colors.white54,
//                       letterSpacing: 1,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//
//           ],
//         ),
//       ),
//     );
//   }
// }



import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../data/services/api_service.dart';
import 'home_screen.dart';
import 'phone_input_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  @override
  void initState() {
    super.initState();
    _navigateToNext();
  }

  void _navigateToNext() async {
    await Future.delayed(const Duration(seconds: 3));
    if (!mounted) return;

    // Check if token exists in secure storage
    final token = await ApiService.getToken();

    if (token != null) {
      // Already logged in — go to Home
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const HomeScreen(),
        ),
      );
    } else {
      // Not logged in — go to Phone Input
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const PhoneInputScreen(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,

        // Purple gradient background
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF4A148C), // Deep Purple
              Color(0xFF7B1FA2), // Soft Purple
              Color(0xFF4A148C), // Deep Purple
            ],
          ),
        ),

        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            // ─── Logo with Animation ───────────────────────
            FadeInDown(
              duration: const Duration(milliseconds: 800),
              child: Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
                    width: 2,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: SvgPicture.asset(
                    'assets/images/sentinel_logo.svg',
                    width: 100,
                    height: 100,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 35),

            // ─── App Name with Animation ──────────────────
            FadeInUp(
              duration: const Duration(milliseconds: 800),
              delay: const Duration(milliseconds: 300),
              child: Text(
                'SENTINEL',
                style: GoogleFonts.poppins(
                  fontSize: 38,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 8,
                ),
              ),
            ),

            const SizedBox(height: 12),

            // ─── Tagline with Animation ───────────────────
            FadeInUp(
              duration: const Duration(milliseconds: 800),
              delay: const Duration(milliseconds: 500),
              child: Text(
                'Guardian Who Never Sleeps',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w300,
                  color: Colors.white70,
                  letterSpacing: 2,
                ),
              ),
            ),

            const SizedBox(height: 80),

            // ─── Loading Indicator with Animation ─────────
            FadeIn(
              duration: const Duration(milliseconds: 800),
              delay: const Duration(milliseconds: 800),
              child: Column(
                children: [
                  const SizedBox(
                    width: 35,
                    height: 35,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Initializing...',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: Colors.white54,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
            ),

          ],
        ),
      ),
    );
  }
}