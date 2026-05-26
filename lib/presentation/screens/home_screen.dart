// // import 'package:flutter/material.dart';
// // import 'package:flutter/services.dart';
// // import 'package:google_fonts/google_fonts.dart';
// // import '../../../core/constants/app_colors.dart';
// //
// // class HomeScreen extends StatelessWidget {
// //   const HomeScreen({super.key});
// //
// //   // ─── Show Exit Dialog ─────────────────────────────────
// //   Future<bool> _onWillPop(BuildContext context) async {
// //     final shouldExit = await showDialog<bool>(
// //       context: context,
// //       builder: (context) => AlertDialog(
// //         shape: RoundedRectangleBorder(
// //           borderRadius: BorderRadius.circular(20),
// //         ),
// //         title: Row(
// //           children: [
// //             Container(
// //               width: 40,
// //               height: 40,
// //               decoration: BoxDecoration(
// //                 color: AppColors.sosRed.withOpacity(0.1),
// //                 shape: BoxShape.circle,
// //               ),
// //               child: const Icon(
// //                 Icons.exit_to_app_rounded,
// //                 color: AppColors.sosRed,
// //                 size: 22,
// //               ),
// //             ),
// //             const SizedBox(width: 12),
// //             Text(
// //               'Exit Sentinel?',
// //               style: GoogleFonts.poppins(
// //                 fontSize: 18,
// //                 fontWeight: FontWeight.bold,
// //                 color: AppColors.darkGrey,
// //               ),
// //             ),
// //           ],
// //         ),
// //         content: Text(
// //           'Are you sure you want to exit? Your guardian protection will be disabled.',
// //           style: GoogleFonts.poppins(
// //             fontSize: 13,
// //             color: AppColors.mediumGrey,
// //             height: 1.5,
// //           ),
// //         ),
// //         actions: [
// //           // Cancel Button
// //           TextButton(
// //             onPressed: () => Navigator.pop(context, false),
// //             child: Text(
// //               'Stay',
// //               style: GoogleFonts.poppins(
// //                 fontSize: 14,
// //                 fontWeight: FontWeight.w600,
// //                 color: AppColors.deepPurple,
// //               ),
// //             ),
// //           ),
// //
// //           // Exit Button
// //           ElevatedButton(
// //             onPressed: () {
// //               Navigator.pop(context, true);
// //             },
// //             style: ElevatedButton.styleFrom(
// //               backgroundColor: AppColors.sosRed,
// //               foregroundColor: Colors.white,
// //               shape: RoundedRectangleBorder(
// //                 borderRadius: BorderRadius.circular(10),
// //               ),
// //               padding: const EdgeInsets.symmetric(
// //                 horizontal: 20,
// //                 vertical: 10,
// //               ),
// //             ),
// //             child: Text(
// //               'Exit',
// //               style: GoogleFonts.poppins(
// //                 fontSize: 14,
// //                 fontWeight: FontWeight.w600,
// //               ),
// //             ),
// //           ),
// //
// //           const SizedBox(width: 4),
// //         ],
// //       ),
// //     );
// //
// //     // If user confirmed exit — close app
// //     if (shouldExit == true) {
// //       SystemNavigator.pop();
// //     }
// //
// //     return false; // Always return false — we handle exit manually
// //   }
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return WillPopScope(
// //       onWillPop: () => _onWillPop(context),
// //       child: Scaffold(
// //         body: Container(
// //           width: double.infinity,
// //           height: double.infinity,
// //           decoration: const BoxDecoration(
// //             gradient: AppColors.purpleGradient,
// //           ),
// //           child: Column(
// //             mainAxisAlignment: MainAxisAlignment.center,
// //             children: [
// //               const Icon(
// //                 Icons.shield,
// //                 color: Colors.white,
// //                 size: 80,
// //               ),
// //               const SizedBox(height: 20),
// //               Text(
// //                 'Welcome to Sentinel!',
// //                 style: GoogleFonts.poppins(
// //                   fontSize: 24,
// //                   fontWeight: FontWeight.bold,
// //                   color: Colors.white,
// //                 ),
// //               ),
// //               const SizedBox(height: 10),
// //               Text(
// //                 'Home Screen — Coming Day 6',
// //                 style: GoogleFonts.poppins(
// //                   fontSize: 14,
// //                   color: Colors.white70,
// //                 ),
// //               ),
// //             ],
// //           ),
// //         ),
// //       ),
// //     );
// //   }
// // }
//
//
//
//
// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:animate_do/animate_do.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:sentinel/presentation/screens/live_location_screen.dart';
// import 'package:sentinel/presentation/screens/sos_active_screen.dart';
// import '../../../core/constants/app_colors.dart';
// import '../../../providers/user_provider.dart';
// import '../../data/services/sos_service.dart';
// import 'guardian_circle_screen.dart';
// import 'fake_call_screen.dart';
// import 'helplines_screen.dart';
// import 'safe_places_screen.dart';
// import 'package:sensors_plus/sensors_plus.dart';
//
// class HomeScreen extends ConsumerStatefulWidget {
//   const HomeScreen({super.key});
//
//   @override
//   ConsumerState<HomeScreen> createState() => _HomeScreenState();
// }
//
// class _HomeScreenState extends ConsumerState<HomeScreen>
//     with SingleTickerProviderStateMixin {
//
//   // Bottom nav index
//   int _currentIndex = 0;
//
//   // SOS pulse animation controller
//   late AnimationController _pulseController;
//   late Animation<double> _pulseAnimation;
//
//   // SOS active state
//   bool _isSosActive = false;
//
//   // SHake Detection Variables
//   int _countdownValue = 3;
//   bool _isCountingDown = false;
//   StreamSubscription? _shakeSubscription;
//   DateTime? _lastShakeTime;
//   int _shakeCount = 0;
//   bool _isSosScreenActive = false;
//
//   @override
//   void initState() {
//     super.initState();
//
//     // Setup pulse animation
//     _pulseController = AnimationController(
//       vsync: this,
//       duration: const Duration(seconds: 1),
//     )..repeat(reverse: true);
//
//     _pulseAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(
//       CurvedAnimation(
//         parent: _pulseController,
//         curve: Curves.easeInOut,
//       ),
//     );
//
//     // Load user data
//     WidgetsBinding.instance.addPostFrameCallback((_) async {
//       await ref.read(userProvider.notifier).loadUser();
//     });
//
//     // Setup Shake Detection
//     _setupShakeDetection();
//   }
//
//   @override
//   void dispose() {
//     _pulseController.dispose();
//     _shakeSubscription?.cancel();
//     super.dispose();
//   }
//
//   void _setupShakeDetection() {
//     _shakeSubscription = accelerometerEventStream().listen((event) {
//       double acceleration =
//           (event.x.abs() + event.y.abs() + event.z.abs()) - 9.8;
//
//       if (acceleration > 20) {
//         final now = DateTime.now();
//
//         if (_lastShakeTime == null ||
//             now.difference(_lastShakeTime!) >
//                 const Duration(seconds: 3)) {
//           _shakeCount = 0;
//         }
//
//         _lastShakeTime = now;
//         _shakeCount++;
//
//         if (_shakeCount >= 3) {
//           _shakeCount = 0;
//           // ✅ Only trigger if SOS screen is not already showing
//           if (!_isSosScreenActive && !_isCountingDown) {
//             _triggerSOS(triggerType: 'shake');
//           }
//         }
//       }
//     });
//   }
//
//   // ─── Exit Dialog ──────────────────────────────────────
//   Future<bool> _onWillPop() async {
//     final shouldExit = await showDialog<bool>(
//       context: context,
//       builder: (context) => AlertDialog(
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(20),
//         ),
//         title: Row(
//           children: [
//             Container(
//               width: 40,
//               height: 40,
//               decoration: BoxDecoration(
//                 color: AppColors.sosRed.withOpacity(0.1),
//                 shape: BoxShape.circle,
//               ),
//               child: const Icon(
//                 Icons.exit_to_app_rounded,
//                 color: AppColors.sosRed,
//                 size: 22,
//               ),
//             ),
//             const SizedBox(width: 12),
//             Text(
//               'Exit Sentinel?',
//               style: GoogleFonts.poppins(
//                 fontSize: 18,
//                 fontWeight: FontWeight.bold,
//                 color: AppColors.darkGrey,
//               ),
//             ),
//           ],
//         ),
//         content: Text(
//           'Are you sure you want to exit? Your guardian protection will be disabled.',
//           style: GoogleFonts.poppins(
//             fontSize: 13,
//             color: AppColors.mediumGrey,
//             height: 1.5,
//           ),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context, false),
//             child: Text(
//               'Stay',
//               style: GoogleFonts.poppins(
//                 fontSize: 14,
//                 fontWeight: FontWeight.w600,
//                 color: AppColors.deepPurple,
//               ),
//             ),
//           ),
//           ElevatedButton(
//             onPressed: () {
//               Navigator.pop(context, true);
//               SystemNavigator.pop();
//             },
//             style: ElevatedButton.styleFrom(
//               backgroundColor: AppColors.sosRed,
//               foregroundColor: Colors.white,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(10),
//               ),
//             ),
//             child: Text(
//               'Exit',
//               style: GoogleFonts.poppins(
//                 fontSize: 14,
//                 fontWeight: FontWeight.w600,
//               ),
//             ),
//           ),
//           const SizedBox(width: 4),
//         ],
//       ),
//     );
//     return shouldExit ?? false;
//   }
//
//   // ─── SOS Countdown and Trigger ────────────────────────
//   void _startSOSCountdown() {
//     if (_isCountingDown) return;
//     setState(() {
//       _isCountingDown = true;
//       _countdownValue = 3;
//     });
//
//     // Show countdown dialog
//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (context) => _buildCountdownDialog(),
//     );
//     // Show loading
//     // showDialog(
//     //   context: context,
//     //   barrierDismissible: false,
//     //   barrierColor: Colors.black54,
//     //   builder: (context) => const Center(
//     //     child: CircularProgressIndicator(
//     //       color: AppColors.deepPurple,
//     //     ),
//     //   ),
//     // );
//   }
//
//   Widget _buildCountdownDialog() {
//     return StatefulBuilder(
//       builder: (context, setDialogState) {
//
//         // Start countdown
//         Future.doWhile(() async {
//           await Future.delayed(const Duration(seconds: 1));
//           if (!mounted) return false;
//           if (_countdownValue > 1) {
//             setState(() => _countdownValue--);
//             setDialogState(() {});
//             return true;
//           } else {
//             // Countdown finished — trigger SOS
//             Navigator.pop(context);
//             setState(() => _isCountingDown = false);
//             _triggerSOS();
//             return false;
//           }
//         });
//
//         return WillPopScope(
//           onWillPop: () async => false,
//           child: Dialog(
//             backgroundColor: Colors.transparent,
//             child: Container(
//               padding: const EdgeInsets.all(32),
//               decoration: BoxDecoration(
//                 color: AppColors.sosRed,
//                 borderRadius: BorderRadius.circular(24),
//               ),
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   Text(
//                     'SOS in',
//                     style: GoogleFonts.poppins(
//                       fontSize: 18,
//                       color: Colors.white70,
//                     ),
//                   ),
//                   const SizedBox(height: 10),
//                   Text(
//                     '$_countdownValue',
//                     style: GoogleFonts.poppins(
//                       fontSize: 72,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.white,
//                     ),
//                   ),
//                   const SizedBox(height: 20),
//                   SizedBox(
//                     width: double.infinity,
//                     height: 48,
//                     child: OutlinedButton(
//                       onPressed: () {
//                         setState(() {
//                           _isCountingDown = false;
//                           _countdownValue = 3;
//                         });
//                         Navigator.pop(context);
//                       },
//                       style: OutlinedButton.styleFrom(
//                         foregroundColor: Colors.white,
//                         side: const BorderSide(color: Colors.white, width: 2),
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(12),
//                         ),
//                       ),
//                       child: Text(
//                         'Cancel',
//                         style: GoogleFonts.poppins(
//                           fontSize: 15,
//                           fontWeight: FontWeight.w600,
//                           color: Colors.white,
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }
//
// // ─── Actual SOS Trigger ───────────────────────────────
// //   Future<void> _triggerSOS({String triggerType = 'manual'}) async {
// //     // Show loading
// //     showDialog(
// //       context: context,
// //       barrierDismissible: false,
// //       builder: (context) => const Center(
// //         child: CircularProgressIndicator(color: Colors.white),
// //       ),
// //     );
// //
// //     // Call SOS service
// //     final result = await SosService.triggerSOS(
// //       triggerType: triggerType,
// //     );
// //
// //     if (!mounted) return;
// //     Navigator.pop(context); // Close loading
// //
// //     if (result['success'] == true) {
// //       // Navigate to SOS Active Screen
// //       final response = await Navigator.push(
// //         context,
// //         MaterialPageRoute(
// //           builder: (context) => SosActiveScreen(sosData: result),
// //         ),
// //       );
// //     } else {
// //       // Show error
// //       ScaffoldMessenger.of(context).showSnackBar(
// //         SnackBar(
// //           content: Text(
// //             result['message'] ?? 'SOS failed. Check your connection.',
// //             style: GoogleFonts.poppins(color: Colors.white),
// //           ),
// //           backgroundColor: AppColors.sosRed,
// //           behavior: SnackBarBehavior.floating,
// //           shape: RoundedRectangleBorder(
// //             borderRadius: BorderRadius.circular(10),
// //           ),
// //         ),
// //       );
// //     }
// //   }
//
//   // Future<void> _triggerSOS({String triggerType = 'manual'}) async {
//   //
//   //   // ✅ Prevent multiple SOS triggers
//   //   if (_isSosScreenActive) return;
//   //   setState(() => _isSosScreenActive = true);
//   //
//   //   // Show loading
//   //   showDialog(
//   //     context: context,
//   //     barrierDismissible: false,
//   //     barrierColor: Colors.black54,
//   //     builder: (context) => const Center(
//   //       child: CircularProgressIndicator(
//   //         color: AppColors.deepPurple,
//   //       ),
//   //     ),
//   //   );
//   //
//   //   // Call SOS service
//   //   final result = await SosService.triggerSOS(
//   //     triggerType: triggerType,
//   //   );
//   //
//   //   if (!mounted) return;
//   //   Navigator.pop(context); // Close loading
//   //
//   //   if (result['success'] == true) {
//   //     // Navigate to SOS Active Screen
//   //     await Navigator.push(
//   //       context,
//   //       MaterialPageRoute(
//   //         builder: (context) => SosActiveScreen(sosData: result),
//   //       ),
//   //     );
//   //
//   //     // ✅ Reset flag when user comes back
//   //     if (mounted) {
//   //       setState(() => _isSosScreenActive = false);
//   //     }
//   //
//   //   } else {
//   //     // ✅ Reset flag on error too
//   //     setState(() => _isSosScreenActive = false);
//   //
//   //     ScaffoldMessenger.of(context).showSnackBar(
//   //       SnackBar(
//   //         content: Text(
//   //           result['message'] ?? 'SOS failed. Check your connection.',
//   //           style: GoogleFonts.poppins(color: Colors.white),
//   //         ),
//   //         backgroundColor: AppColors.sosRed,
//   //         behavior: SnackBarBehavior.floating,
//   //         shape: RoundedRectangleBorder(
//   //           borderRadius: BorderRadius.circular(10),
//   //         ),
//   //       ),
//   //     );
//   //   }
//   // }
//
//   Future<void> _triggerSOS({String triggerType = 'manual'}) async {
//
//     // Prevent multiple triggers
//     if (_isSosScreenActive) return;
//     setState(() => _isSosScreenActive = true);
//
//     // Show loading
//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       barrierColor: Colors.black54,
//       builder: (context) => Center(
//         child: Container(
//           padding: const EdgeInsets.all(28),
//           decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.circular(16),
//           ),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               const CircularProgressIndicator(
//                 color: AppColors.deepPurple,
//               ),
//               const SizedBox(height: 16),
//               Text(
//                 'Sending SOS...',
//                 style: GoogleFonts.poppins(
//                   fontSize: 14,
//                   fontWeight: FontWeight.w600,
//                   color: AppColors.darkGrey,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//
//     try {
//       // Call SOS service with timeout
//       final result = await SosService.triggerSOS(
//         triggerType: triggerType,
//       ).timeout(
//         const Duration(seconds: 15),
//         onTimeout: () {
//           return {
//             'success': false,
//             'message': 'Request timed out. Check your connection.'
//           };
//         },
//       );
//
//       if (!mounted) return;
//
//       // Close loading dialog
//       Navigator.pop(context);
//
//       if (result['success'] == true) {
//         // Navigate to SOS Active Screen
//         await Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (context) => SosActiveScreen(sosData: result),
//           ),
//         );
//         if (mounted) setState(() => _isSosScreenActive = false);
//       } else {
//         setState(() => _isSosScreenActive = false);
//         _showSOSError(result['message'] ?? 'SOS failed.');
//       }
//
//     } catch (e) {
//       if (!mounted) return;
//       Navigator.pop(context); // Close loading
//       setState(() => _isSosScreenActive = false);
//       _showSOSError('Something went wrong. Try again.');
//     }
//   }
//
// // ─── Show SOS Error ───────────────────────────────────
//   void _showSOSError(String message) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Row(
//           children: [
//             const Icon(Icons.error_outline,
//                 color: Colors.white, size: 20),
//             const SizedBox(width: 10),
//             Expanded(
//               child: Text(
//                 message,
//                 style: GoogleFonts.poppins(color: Colors.white),
//               ),
//             ),
//           ],
//         ),
//         backgroundColor: AppColors.sosRed,
//         behavior: SnackBarBehavior.floating,
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(10),
//         ),
//       ),
//     );
//   }
//
//   // ─── SOS Active Dialog ────────────────────────────────
//   Widget _buildSOSDialog() {
//     return WillPopScope(
//       onWillPop: () async => false,
//       child: Dialog(
//         backgroundColor: Colors.transparent,
//         child: Container(
//           padding: const EdgeInsets.all(28),
//           decoration: BoxDecoration(
//             color: AppColors.sosRed,
//             borderRadius: BorderRadius.circular(24),
//           ),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//
//               // Pulsing icon
//               const Icon(
//                 Icons.warning_amber_rounded,
//                 color: Colors.white,
//                 size: 60,
//               ),
//
//               const SizedBox(height: 16),
//
//               Text(
//                 'SOS ACTIVATED!',
//                 style: GoogleFonts.poppins(
//                   fontSize: 22,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.white,
//                   letterSpacing: 2,
//                 ),
//               ),
//
//               const SizedBox(height: 8),
//
//               Text(
//                 'Alerting your guardian circle...',
//                 style: GoogleFonts.poppins(
//                   fontSize: 13,
//                   color: Colors.white70,
//                 ),
//                 textAlign: TextAlign.center,
//               ),
//
//               const SizedBox(height: 24),
//
//               // Status indicators
//               _buildSOSStatus('📍 Location captured', true),
//               const SizedBox(height: 8),
//               _buildSOSStatus('📲 Notifying guardians...', false),
//               const SizedBox(height: 8),
//               _buildSOSStatus('📱 Sending SMS alerts...', false),
//
//               const SizedBox(height: 28),
//
//               // Cancel Button
//               SizedBox(
//                 width: double.infinity,
//                 height: 50,
//                 child: OutlinedButton(
//                   onPressed: () {
//                     setState(() => _isSosActive = false);
//                     Navigator.pop(context);
//                   },
//                   style: OutlinedButton.styleFrom(
//                     foregroundColor: Colors.white,
//                     side: const BorderSide(color: Colors.white, width: 2),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(14),
//                     ),
//                   ),
//                   child: Text(
//                     'Cancel SOS',
//                     style: GoogleFonts.poppins(
//                       fontSize: 15,
//                       fontWeight: FontWeight.w600,
//                       color: Colors.white,
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   // ─── SOS Status Row ───────────────────────────────────
//   Widget _buildSOSStatus(String text, bool isDone) {
//     return Row(
//       children: [
//         Container(
//           width: 22,
//           height: 22,
//           decoration: BoxDecoration(
//             color: isDone
//                 ? Colors.white
//                 : Colors.white.withOpacity(0.3),
//             shape: BoxShape.circle,
//           ),
//           child: Icon(
//             isDone ? Icons.check : Icons.access_time,
//             size: 14,
//             color: isDone ? AppColors.sosRed : Colors.white,
//           ),
//         ),
//         const SizedBox(width: 10),
//         Text(
//           text,
//           style: GoogleFonts.poppins(
//             fontSize: 13,
//             color: Colors.white,
//             fontWeight: isDone ? FontWeight.w600 : FontWeight.normal,
//           ),
//         ),
//       ],
//     );
//   }
//
//   // ─── Quick Action Button ──────────────────────────────
//   Widget _buildQuickAction({
//     required IconData icon,
//     required String label,
//     required Color color,
//     required VoidCallback onTap,
//   }) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Column(
//         children: [
//           Container(
//             width: 62,
//             height: 62,
//             decoration: BoxDecoration(
//               color: color.withOpacity(0.12),
//               shape: BoxShape.circle,
//               border: Border.all(
//                 color: color.withOpacity(0.3),
//                 width: 1.5,
//               ),
//             ),
//             child: Icon(
//               icon,
//               color: color,
//               size: 28,
//             ),
//           ),
//           const SizedBox(height: 8),
//           Text(
//             label,
//             style: GoogleFonts.poppins(
//               fontSize: 11,
//               fontWeight: FontWeight.w500,
//               color: AppColors.darkGrey,
//             ),
//             textAlign: TextAlign.center,
//           ),
//         ],
//       ),
//     );
//   }
//
//   // ─── Safety Status Card ───────────────────────────────
//   Widget _buildStatusCard() {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//       decoration: BoxDecoration(
//         color: Colors.white.withOpacity(0.15),
//         borderRadius: BorderRadius.circular(16),
//         border: Border.all(
//           color: Colors.white.withOpacity(0.3),
//           width: 1,
//         ),
//       ),
//       child: Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Container(
//             width: 10,
//             height: 10,
//             decoration: const BoxDecoration(
//               color: Color(0xFF69F0AE),
//               shape: BoxShape.circle,
//             ),
//           ),
//           const SizedBox(width: 8),
//           Text(
//             'Sentinel is Active',
//             style: GoogleFonts.poppins(
//               fontSize: 12,
//               fontWeight: FontWeight.w500,
//               color: Colors.white,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final user = ref.watch(userProvider);
//     final userName = user?.name ?? 'User';
//     final firstName = userName.split(' ').first;
//
//     return WillPopScope(
//       onWillPop: _onWillPop,
//       child: Scaffold(
//         backgroundColor: AppColors.lightGrey,
//         body: Column(
//           children: [
//
//             // ─── Top Purple Header ────────────────────
//             Container(
//               width: double.infinity,
//               decoration: const BoxDecoration(
//                 gradient: AppColors.purpleGradient,
//                 borderRadius: BorderRadius.only(
//                   bottomLeft: Radius.circular(36),
//                   bottomRight: Radius.circular(36),
//                 ),
//               ),
//               child: SafeArea(
//                 child: Padding(
//                   padding: const EdgeInsets.fromLTRB(20, 16, 20, 30),
//                   child: Column(
//                     children: [
//
//                       // ── Top Row: Greeting + Profile ──
//                       FadeInDown(
//                         duration: const Duration(milliseconds: 600),
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//
//                             // Greeting
//                             Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Text(
//                                   'Hello, $firstName 👋',
//                                   style: GoogleFonts.poppins(
//                                     fontSize: 22,
//                                     fontWeight: FontWeight.bold,
//                                     color: Colors.white,
//                                   ),
//                                 ),
//                                 Text(
//                                   'Stay safe today',
//                                   style: GoogleFonts.poppins(
//                                     fontSize: 13,
//                                     color: Colors.white70,
//                                   ),
//                                 ),
//                               ],
//                             ),
//
//                             // Profile Avatar
//                             GestureDetector(
//                               onTap: () {},
//                               child: Container(
//                                 width: 46,
//                                 height: 46,
//                                 decoration: BoxDecoration(
//                                   color: Colors.white.withOpacity(0.2),
//                                   shape: BoxShape.circle,
//                                   border: Border.all(
//                                     color: Colors.white.withOpacity(0.5),
//                                     width: 2,
//                                   ),
//                                 ),
//                                 child: Center(
//                                   child: Text(
//                                     firstName.isNotEmpty
//                                         ? firstName[0].toUpperCase()
//                                         : 'U',
//                                     style: GoogleFonts.poppins(
//                                       fontSize: 18,
//                                       fontWeight: FontWeight.bold,
//                                       color: Colors.white,
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//
//                       const SizedBox(height: 20),
//
//                       // ── Status Badge ─────────────────
//                       FadeInUp(
//                         duration: const Duration(milliseconds: 600),
//                         delay: const Duration(milliseconds: 200),
//                         child: _buildStatusCard(),
//                       ),
//
//                       const SizedBox(height: 28),
//
//                       // ── BIG SOS BUTTON ───────────────
//                       FadeInUp(
//                         duration: const Duration(milliseconds: 700),
//                         delay: const Duration(milliseconds: 300),
//                         child: GestureDetector(
//                           onLongPress: _startSOSCountdown,
//                           child: Stack(
//                             alignment: Alignment.center,
//                             children: [
//
//                               // Outer pulse ring 1
//                               AnimatedBuilder(
//                                 animation: _pulseAnimation,
//                                 builder: (context, child) {
//                                   return Transform.scale(
//                                     scale: _pulseAnimation.value * 1.25,
//                                     child: Container(
//                                       width: 150,
//                                       height: 150,
//                                       decoration: BoxDecoration(
//                                         shape: BoxShape.circle,
//                                         color: AppColors.sosRed
//                                             .withOpacity(0.1),
//                                       ),
//                                     ),
//                                   );
//                                 },
//                               ),
//
//                               // Outer pulse ring 2
//                               AnimatedBuilder(
//                                 animation: _pulseAnimation,
//                                 builder: (context, child) {
//                                   return Transform.scale(
//                                     scale: _pulseAnimation.value * 1.12,
//                                     child: Container(
//                                       width: 150,
//                                       height: 150,
//                                       decoration: BoxDecoration(
//                                         shape: BoxShape.circle,
//                                         color: AppColors.sosRed
//                                             .withOpacity(0.18),
//                                       ),
//                                     ),
//                                   );
//                                 },
//                               ),
//
//                               // Main SOS Button
//                               Container(
//                                 width: 150,
//                                 height: 150,
//                                 decoration: BoxDecoration(
//                                   shape: BoxShape.circle,
//                                   color: AppColors.sosRed,
//                                   boxShadow: [
//                                     BoxShadow(
//                                       color: AppColors.sosRed.withOpacity(0.5),
//                                       blurRadius: 20,
//                                       spreadRadius: 2,
//                                     ),
//                                   ],
//                                 ),
//                                 child: Column(
//                                   mainAxisAlignment: MainAxisAlignment.center,
//                                   children: [
//                                     const Icon(
//                                       Icons.warning_amber_rounded,
//                                       color: Colors.white,
//                                       size: 40,
//                                     ),
//                                     const SizedBox(height: 4),
//                                     Text(
//                                       'SOS',
//                                       style: GoogleFonts.poppins(
//                                         fontSize: 26,
//                                         fontWeight: FontWeight.bold,
//                                         color: Colors.white,
//                                         letterSpacing: 4,
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),
//
//                       const SizedBox(height: 12),
//
//                       // Hold to activate text
//                       FadeInUp(
//                         duration: const Duration(milliseconds: 600),
//                         delay: const Duration(milliseconds: 400),
//                         child: Text(
//                           'Hold to activate SOS',
//                           style: GoogleFonts.poppins(
//                             fontSize: 12,
//                             color: Colors.white60,
//                             letterSpacing: 0.5,
//                           ),
//                         ),
//                       ),
//
//                       const SizedBox(height: 24),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//
//             // ─── Quick Actions Row ────────────────────
//             Expanded(
//               child: SingleChildScrollView(
//                 padding: const EdgeInsets.all(20),
//                 child: Column(
//                   children: [
//
//                     const SizedBox(height: 8),
//
//                     // Quick Actions Title
//                     FadeInLeft(
//                       duration: const Duration(milliseconds: 600),
//                       child: Align(
//                         alignment: Alignment.centerLeft,
//                         child: Text(
//                           'Quick Actions',
//                           style: GoogleFonts.poppins(
//                             fontSize: 16,
//                             fontWeight: FontWeight.bold,
//                             color: AppColors.darkGrey,
//                           ),
//                         ),
//                       ),
//                     ),
//
//                     const SizedBox(height: 16),
//
//                     // 4 Quick Action Buttons
//                     FadeInUp(
//                       duration: const Duration(milliseconds: 600),
//                       delay: const Duration(milliseconds: 200),
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//
//                           // Fake Call
//                           _buildQuickAction(
//                             icon: Icons.phone_in_talk_rounded,
//                             label: 'Fake\nCall',
//                             color: AppColors.deepPurple,
//                             onTap: () {
//                               Navigator.push(
//                                 context,
//                                 MaterialPageRoute(
//                                   builder: (context) =>
//                                   const FakeCallScreen(),
//                                 ),
//                               );
//                             },
//                           ),
//
//                           // Safe Places
//                           _buildQuickAction(
//                             icon: Icons.location_on_rounded,
//                             label: 'Safe\nPlaces',
//                             color: AppColors.successGreen,
//                             onTap: () {
//                               Navigator.push(
//                                 context,
//                                 MaterialPageRoute(
//                                   builder: (context) =>
//                                   const SafePlacesScreen(),
//                                 ),
//                               );
//                             },
//                           ),
//
//                           // Guardians
//                           _buildQuickAction(
//                             icon: Icons.people_rounded,
//                             label: 'Guardian\nCircle',
//                             color: AppColors.warningAmber,
//                             onTap: () {
//                               Navigator.push(
//                                 context,
//                                 MaterialPageRoute(
//                                   builder: (context) =>
//                                   const GuardianCircleScreen(),
//                                 ),
//                               );
//                             },
//                           ),
//
//                           // Helplines
//                           _buildQuickAction(
//                             icon: Icons.call_rounded,
//                             label: 'Help\nlines',
//                             color: AppColors.sosRed,
//                             onTap: () {
//                               Navigator.push(
//                                 context,
//                                 MaterialPageRoute(
//                                   builder: (context) =>
//                                   const HelplinesScreen(),
//                                 ),
//                               );
//                             },
//                           ),
//                         ],
//                       ),
//                     ),
//
//                     const SizedBox(height: 28),
//
//                     // ─── Safety Tips Card ─────────────
//                     FadeInUp(
//                       duration: const Duration(milliseconds: 600),
//                       delay: const Duration(milliseconds: 300),
//                       child: Container(
//                         width: double.infinity,
//                         padding: const EdgeInsets.all(20),
//                         decoration: BoxDecoration(
//                           gradient: const LinearGradient(
//                             colors: [
//                               Color(0xFF4A148C),
//                               Color(0xFF7B1FA2),
//                             ],
//                           ),
//                           borderRadius: BorderRadius.circular(20),
//                           boxShadow: [
//                             BoxShadow(
//                               color: AppColors.deepPurple.withOpacity(0.3),
//                               blurRadius: 12,
//                               offset: const Offset(0, 4),
//                             ),
//                           ],
//                         ),
//                         child: Row(
//                           children: [
//                             Container(
//                               width: 48,
//                               height: 48,
//                               decoration: BoxDecoration(
//                                 color: Colors.white.withOpacity(0.2),
//                                 borderRadius: BorderRadius.circular(14),
//                               ),
//                               child: const Icon(
//                                 Icons.tips_and_updates_rounded,
//                                 color: Colors.white,
//                                 size: 26,
//                               ),
//                             ),
//                             const SizedBox(width: 16),
//                             Expanded(
//                               child: Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Text(
//                                     'Safety Tip',
//                                     style: GoogleFonts.poppins(
//                                       fontSize: 13,
//                                       fontWeight: FontWeight.bold,
//                                       color: Colors.white,
//                                     ),
//                                   ),
//                                   const SizedBox(height: 4),
//                                   Text(
//                                     'Always share your live location with a trusted guardian when traveling alone at night.',
//                                     style: GoogleFonts.poppins(
//                                       fontSize: 11,
//                                       color: Colors.white70,
//                                       height: 1.4,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//
//                     const SizedBox(height: 20),
//
//                     // ─── Share Location Card ──────────
//                 // ─── Share Location Card ──────────────────────────────
//                     FadeInUp(
//                       duration: const Duration(milliseconds: 600),
//                       delay: const Duration(milliseconds: 400),
//                       child: GestureDetector(
//                         onTap: () {
//                           Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                             builder: (context) => const LiveLocationScreen(),
//                           ),
//                         );
//                       },
//                       child: Container(
//                         width: double.infinity,
//                         padding: const EdgeInsets.all(20),
//                         decoration: BoxDecoration(
//                           color: Colors.white,
//                           borderRadius: BorderRadius.circular(20),
//                           boxShadow: [
//                             BoxShadow(
//                               color: AppColors.deepPurple.withOpacity(0.08),
//                               blurRadius: 12,
//                               offset: const Offset(0, 4),
//                             ),
//                           ],
//                         ),
//                         child: Row(
//                           children: [
//
//                           // Icon
//                             Container(
//                               width: 52,
//                               height: 52,
//                               decoration: BoxDecoration(
//                                 color: AppColors.successGreen.withOpacity(0.12),
//                                 borderRadius: BorderRadius.circular(16),
//                               ),
//                               child: const Icon(
//                                 Icons.share_location_rounded,
//                                 color: AppColors.successGreen,
//                                 size: 28,
//                               ),
//                             ),
//
//                             const SizedBox(width: 16),
//
//                           // Text
//                             Expanded(
//                               child: Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Text(
//                                     'Share Live Location',
//                                       style: GoogleFonts.poppins(
//                                       fontSize: 14,
//                                       fontWeight: FontWeight.bold,
//                                       color: AppColors.darkGrey,
//                                     ),
//                                   ),
//                                   Text(
//                                     'Let guardians track you in real time',
//                                     style: GoogleFonts.poppins(
//                                       fontSize: 11,
//                                       color: AppColors.mediumGrey,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//
//                           // Arrow
//                             const Icon(
//                               Icons.arrow_forward_ios_rounded,
//                               size: 16,
//                               color: AppColors.mediumGrey,
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ),
//
//
//         // ─── Bottom Navigation Bar ────────────────────
//                   bottomNavigationBar: Container(
//                     decoration: BoxDecoration(
//                       color: Colors.white,
//                       boxShadow: [
//                         BoxShadow(
//                           color: Colors.black.withOpacity(0.08),
//                           blurRadius: 20,
//                           offset: const Offset(0, -5),
//                         ),
//                       ],
//                       borderRadius: const BorderRadius.only(
//                         topLeft: Radius.circular(24),
//                         topRight: Radius.circular(24),
//                       ),
//                     ),
//                     child: ClipRRect(
//                       borderRadius: const BorderRadius.only(
//                         topLeft: Radius.circular(24),
//                         topRight: Radius.circular(24),
//                       ),
//                       child: BottomNavigationBar(
//                         currentIndex: _currentIndex,
//                         onTap: (index) {
//                           setState(() => _currentIndex = index);
//                           // Navigation will be added as we build each screen
//                         },
//                         type: BottomNavigationBarType.fixed,
//                         backgroundColor: Colors.white,
//                         selectedItemColor: AppColors.deepPurple,
//                         unselectedItemColor: AppColors.mediumGrey,
//                         selectedLabelStyle: GoogleFonts.poppins(
//                           fontSize: 11,
//                           fontWeight: FontWeight.w600,
//                         ),
//                         unselectedLabelStyle: GoogleFonts.poppins(
//                           fontSize: 11,
//                         ),
//                         elevation: 0,
//                         items: const [
//                           BottomNavigationBarItem(
//                             icon: Icon(Icons.home_rounded),
//                             label: 'Home',
//                           ),
//                           BottomNavigationBarItem(
//                             icon: Icon(Icons.map_rounded),
//                             label: 'Map',
//                           ),
//                           BottomNavigationBarItem(
//                             icon: Icon(Icons.chat_bubble_outline_rounded),
//                             label: 'Legal',
//                           ),
//                           BottomNavigationBarItem(
//                             icon: Icon(Icons.person_outline_rounded),
//                             label: 'Profile',
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }




// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:animate_do/animate_do.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:sentinel/presentation/screens/live_location_screen.dart';
// import 'package:sentinel/presentation/screens/sos_active_screen.dart';
// import '../../../core/constants/app_colors.dart';
// import '../../../providers/user_provider.dart';
// import '../../data/services/sos_service.dart';
// import 'guardian_circle_screen.dart';
// import 'fake_call_screen.dart';
// import 'helplines_screen.dart';
// import 'safe_places_screen.dart';
// import 'package:sensors_plus/sensors_plus.dart';
//
// class HomeScreen extends ConsumerStatefulWidget {
//   const HomeScreen({super.key});
//
//   @override
//   ConsumerState<HomeScreen> createState() => _HomeScreenState();
// }
//
// class _HomeScreenState extends ConsumerState<HomeScreen>
//     with SingleTickerProviderStateMixin {
//
//   int _currentIndex = 0;
//   late AnimationController _pulseController;
//   late Animation<double> _pulseAnimation;
//   bool _isSosActive = false;
//   int _countdownValue = 3;
//   bool _isCountingDown = false;
//   StreamSubscription? _shakeSubscription;
//   DateTime? _lastShakeTime;
//   int _shakeCount = 0;
//   bool _isSosScreenActive = false;
//
//   @override
//   void initState() {
//     super.initState();
//
//     _pulseController = AnimationController(
//       vsync: this,
//       duration: const Duration(seconds: 1),
//     )..repeat(reverse: true);
//
//     _pulseAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(
//       CurvedAnimation(
//         parent: _pulseController,
//         curve: Curves.easeInOut,
//       ),
//     );
//
//     WidgetsBinding.instance.addPostFrameCallback((_) async {
//       await ref.read(userProvider.notifier).loadUser();
//     });
//
//     _setupShakeDetection();
//   }
//
//   @override
//   void dispose() {
//     _pulseController.dispose();
//     _shakeSubscription?.cancel();
//     super.dispose();
//   }
//
//   void _setupShakeDetection() {
//     _shakeSubscription = accelerometerEventStream().listen((event) {
//       double acceleration =
//           (event.x.abs() + event.y.abs() + event.z.abs()) - 9.8;
//
//       if (acceleration > 20) {
//         final now = DateTime.now();
//
//         if (_lastShakeTime == null ||
//             now.difference(_lastShakeTime!) >
//                 const Duration(seconds: 3)) {
//           _shakeCount = 0;
//         }
//
//         _lastShakeTime = now;
//         _shakeCount++;
//
//         if (_shakeCount >= 3) {
//           _shakeCount = 0;
//           if (!_isSosScreenActive && !_isCountingDown) {
//             _triggerSOS(triggerType: 'shake');
//           }
//         }
//       }
//     });
//   }
//
//   // ─── Exit Dialog ──────────────────────────────────────
//   Future<bool> _onWillPop() async {
//     final shouldExit = await showDialog<bool>(
//       context: context,
//       builder: (context) => AlertDialog(
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(20),
//         ),
//         title: Row(
//           children: [
//             Container(
//               width: 40,
//               height: 40,
//               decoration: BoxDecoration(
//                 color: AppColors.sosRed.withOpacity(0.1),
//                 shape: BoxShape.circle,
//               ),
//               child: const Icon(
//                 Icons.exit_to_app_rounded,
//                 color: AppColors.sosRed,
//                 size: 22,
//               ),
//             ),
//             const SizedBox(width: 12),
//             Text(
//               'Exit Sentinel?',
//               style: GoogleFonts.poppins(
//                 fontSize: 18,
//                 fontWeight: FontWeight.bold,
//                 color: AppColors.darkGrey,
//               ),
//             ),
//           ],
//         ),
//         content: Text(
//           'Are you sure you want to exit? Your guardian protection will be disabled.',
//           style: GoogleFonts.poppins(
//             fontSize: 13,
//             color: AppColors.mediumGrey,
//             height: 1.5,
//           ),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context, false),
//             child: Text(
//               'Stay',
//               style: GoogleFonts.poppins(
//                 fontSize: 14,
//                 fontWeight: FontWeight.w600,
//                 color: AppColors.deepPurple,
//               ),
//             ),
//           ),
//           ElevatedButton(
//             onPressed: () {
//               Navigator.pop(context, true);
//               SystemNavigator.pop();
//             },
//             style: ElevatedButton.styleFrom(
//               backgroundColor: AppColors.sosRed,
//               foregroundColor: Colors.white,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(10),
//               ),
//             ),
//             child: Text(
//               'Exit',
//               style: GoogleFonts.poppins(
//                 fontSize: 14,
//                 fontWeight: FontWeight.w600,
//               ),
//             ),
//           ),
//           const SizedBox(width: 4),
//         ],
//       ),
//     );
//     return shouldExit ?? false;
//   }
//
//   // ─── SOS Countdown ────────────────────────────────────
//   void _startSOSCountdown() {
//     if (_isSosScreenActive || _isCountingDown) return;
//     setState(() {
//       _isCountingDown = true;
//       _countdownValue = 3;
//     });
//
//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       barrierColor: Colors.black87,
//       builder: (ctx) => _SOSCountdownDialog(
//         onCancel: () {
//           setState(() {
//             _isCountingDown = false;
//             _countdownValue = 3;
//           });
//           Navigator.of(ctx).pop();
//         },
//       ),
//     );
//   }
//
//   // ─── Actual SOS Trigger ───────────────────────────────
//   Future<void> _triggerSOS({String triggerType = 'manual'}) async {
//     if (_isSosScreenActive) return;
//     setState(() => _isSosScreenActive = true);
//
//     if (Navigator.canPop(context)) {
//       Navigator.of(context).pop();
//     }
//
//     setState(() => _isCountingDown = false);
//
//     if (!mounted) return;
//
//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       barrierColor: Colors.black54,
//       builder: (ctx) => WillPopScope(
//         onWillPop: () async => false,
//         child: Center(
//           child: Container(
//             padding: const EdgeInsets.all(28),
//             decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.circular(16),
//             ),
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 const CircularProgressIndicator(
//                   color: AppColors.deepPurple,
//                 ),
//                 const SizedBox(height: 16),
//                 Text(
//                   'Sending SOS...',
//                   style: GoogleFonts.poppins(
//                     fontSize: 14,
//                     fontWeight: FontWeight.w600,
//                     color: AppColors.darkGrey,
//                   ),
//                 ),
//                 const SizedBox(height: 8),
//                 Text(
//                   'Alerting your guardians',
//                   style: GoogleFonts.poppins(
//                     fontSize: 12,
//                     color: AppColors.mediumGrey,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//
//     Map<String, dynamic> result = {};
//
//     try {
//       result = await SosService.triggerSOS(
//         triggerType: triggerType,
//       ).timeout(
//         const Duration(seconds: 20),
//         onTimeout: () => {
//           'success': false,
//           'message': 'Request timed out.'
//         },
//       );
//     } catch (e) {
//       result = {
//         'success': false,
//         'message': 'Error: ${e.toString()}'
//       };
//     }
//
//     if (mounted && Navigator.canPop(context)) {
//       Navigator.of(context).pop();
//     }
//
//     if (!mounted) return;
//
//     if (result['success'] == true) {
//       setState(() => _isSosScreenActive = true);
//       await Navigator.push(
//         context,
//         MaterialPageRoute(
//           builder: (context) => SosActiveScreen(sosData: result),
//         ),
//       );
//       if (mounted) setState(() => _isSosScreenActive = false);
//     } else {
//       setState(() => _isSosScreenActive = false);
//       _showSOSError(result['message'] ?? 'SOS failed. Try again.');
//     }
//   }
//
//   // ─── Show SOS Error ───────────────────────────────────
//   void _showSOSError(String message) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Row(
//           children: [
//             const Icon(Icons.error_outline, color: Colors.white, size: 20),
//             const SizedBox(width: 10),
//             Expanded(
//               child: Text(
//                 message,
//                 style: GoogleFonts.poppins(color: Colors.white),
//               ),
//             ),
//           ],
//         ),
//         backgroundColor: AppColors.sosRed,
//         behavior: SnackBarBehavior.floating,
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(10),
//         ),
//       ),
//     );
//   }
//
//   // ─── SOS Status Row ───────────────────────────────────
//   Widget _buildSOSStatus(String text, bool isDone) {
//     return Row(
//       children: [
//         Container(
//           width: 22,
//           height: 22,
//           decoration: BoxDecoration(
//             color: isDone ? Colors.white : Colors.white.withOpacity(0.3),
//             shape: BoxShape.circle,
//           ),
//           child: Icon(
//             isDone ? Icons.check : Icons.access_time,
//             size: 14,
//             color: isDone ? AppColors.sosRed : Colors.white,
//           ),
//         ),
//         const SizedBox(width: 10),
//         Text(
//           text,
//           style: GoogleFonts.poppins(
//             fontSize: 13,
//             color: Colors.white,
//             fontWeight: isDone ? FontWeight.w600 : FontWeight.normal,
//           ),
//         ),
//       ],
//     );
//   }
//
//   // ─── Quick Action Button ──────────────────────────────
//   Widget _buildQuickAction({
//     required IconData icon,
//     required String label,
//     required Color color,
//     required VoidCallback onTap,
//   }) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Column(
//         children: [
//           Container(
//             width: 62,
//             height: 62,
//             decoration: BoxDecoration(
//               color: color.withOpacity(0.12),
//               shape: BoxShape.circle,
//               border: Border.all(
//                 color: color.withOpacity(0.3),
//                 width: 1.5,
//               ),
//             ),
//             child: Icon(icon, color: color, size: 28),
//           ),
//           const SizedBox(height: 8),
//           Text(
//             label,
//             style: GoogleFonts.poppins(
//               fontSize: 11,
//               fontWeight: FontWeight.w500,
//               color: AppColors.darkGrey,
//             ),
//             textAlign: TextAlign.center,
//           ),
//         ],
//       ),
//     );
//   }
//
//   // ─── Safety Status Card ───────────────────────────────
//   Widget _buildStatusCard() {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//       decoration: BoxDecoration(
//         color: Colors.white.withOpacity(0.15),
//         borderRadius: BorderRadius.circular(16),
//         border: Border.all(
//           color: Colors.white.withOpacity(0.3),
//           width: 1,
//         ),
//       ),
//       child: Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Container(
//             width: 10,
//             height: 10,
//             decoration: const BoxDecoration(
//               color: Color(0xFF69F0AE),
//               shape: BoxShape.circle,
//             ),
//           ),
//           const SizedBox(width: 8),
//           Text(
//             'Sentinel is Active',
//             style: GoogleFonts.poppins(
//               fontSize: 12,
//               fontWeight: FontWeight.w500,
//               color: Colors.white,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final user = ref.watch(userProvider);
//     final userName = user?.name ?? 'User';
//     final firstName = userName.split(' ').first;
//
//     return WillPopScope(
//       onWillPop: _onWillPop,
//       child: Scaffold(
//         backgroundColor: AppColors.lightGrey,
//         body: Column(
//           children: [
//
//             // ─── Top Purple Header ────────────────────
//             Container(
//               width: double.infinity,
//               decoration: const BoxDecoration(
//                 gradient: AppColors.purpleGradient,
//                 borderRadius: BorderRadius.only(
//                   bottomLeft: Radius.circular(36),
//                   bottomRight: Radius.circular(36),
//                 ),
//               ),
//               child: SafeArea(
//                 child: Padding(
//                   padding: const EdgeInsets.fromLTRB(20, 16, 20, 30),
//                   child: Column(
//                     children: [
//
//                       // ── Top Row: Greeting + Profile ──
//                       FadeInDown(
//                         duration: const Duration(milliseconds: 600),
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Text(
//                                   'Hello, $firstName 👋',
//                                   style: GoogleFonts.poppins(
//                                     fontSize: 22,
//                                     fontWeight: FontWeight.bold,
//                                     color: Colors.white,
//                                   ),
//                                 ),
//                                 Text(
//                                   'Stay safe today',
//                                   style: GoogleFonts.poppins(
//                                     fontSize: 13,
//                                     color: Colors.white70,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                             GestureDetector(
//                               onTap: () {},
//                               child: Container(
//                                 width: 46,
//                                 height: 46,
//                                 decoration: BoxDecoration(
//                                   color: Colors.white.withOpacity(0.2),
//                                   shape: BoxShape.circle,
//                                   border: Border.all(
//                                     color: Colors.white.withOpacity(0.5),
//                                     width: 2,
//                                   ),
//                                 ),
//                                 child: Center(
//                                   child: Text(
//                                     firstName.isNotEmpty
//                                         ? firstName[0].toUpperCase()
//                                         : 'U',
//                                     style: GoogleFonts.poppins(
//                                       fontSize: 18,
//                                       fontWeight: FontWeight.bold,
//                                       color: Colors.white,
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//
//                       const SizedBox(height: 20),
//
//                       // ── Status Badge ─────────────────
//                       FadeInUp(
//                         duration: const Duration(milliseconds: 600),
//                         delay: const Duration(milliseconds: 200),
//                         child: _buildStatusCard(),
//                       ),
//
//                       const SizedBox(height: 28),
//
//                       // ── BIG SOS BUTTON ───────────────
//                       FadeInUp(
//                         duration: const Duration(milliseconds: 700),
//                         delay: const Duration(milliseconds: 300),
//                         child: GestureDetector(
//                           onLongPress: _startSOSCountdown,
//                           child: Stack(
//                             alignment: Alignment.center,
//                             children: [
//                               AnimatedBuilder(
//                                 animation: _pulseAnimation,
//                                 builder: (context, child) {
//                                   return Transform.scale(
//                                     scale: _pulseAnimation.value * 1.25,
//                                     child: Container(
//                                       width: 150,
//                                       height: 150,
//                                       decoration: BoxDecoration(
//                                         shape: BoxShape.circle,
//                                         color: AppColors.sosRed.withOpacity(0.1),
//                                       ),
//                                     ),
//                                   );
//                                 },
//                               ),
//                               AnimatedBuilder(
//                                 animation: _pulseAnimation,
//                                 builder: (context, child) {
//                                   return Transform.scale(
//                                     scale: _pulseAnimation.value * 1.12,
//                                     child: Container(
//                                       width: 150,
//                                       height: 150,
//                                       decoration: BoxDecoration(
//                                         shape: BoxShape.circle,
//                                         color: AppColors.sosRed.withOpacity(0.18),
//                                       ),
//                                     ),
//                                   );
//                                 },
//                               ),
//                               Container(
//                                 width: 150,
//                                 height: 150,
//                                 decoration: BoxDecoration(
//                                   shape: BoxShape.circle,
//                                   color: AppColors.sosRed,
//                                   boxShadow: [
//                                     BoxShadow(
//                                       color: AppColors.sosRed.withOpacity(0.5),
//                                       blurRadius: 20,
//                                       spreadRadius: 2,
//                                     ),
//                                   ],
//                                 ),
//                                 child: Column(
//                                   mainAxisAlignment: MainAxisAlignment.center,
//                                   children: [
//                                     const Icon(
//                                       Icons.warning_amber_rounded,
//                                       color: Colors.white,
//                                       size: 40,
//                                     ),
//                                     const SizedBox(height: 4),
//                                     Text(
//                                       'SOS',
//                                       style: GoogleFonts.poppins(
//                                         fontSize: 26,
//                                         fontWeight: FontWeight.bold,
//                                         color: Colors.white,
//                                         letterSpacing: 4,
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),
//
//                       const SizedBox(height: 12),
//
//                       FadeInUp(
//                         duration: const Duration(milliseconds: 600),
//                         delay: const Duration(milliseconds: 400),
//                         child: Text(
//                           'Hold to activate SOS',
//                           style: GoogleFonts.poppins(
//                             fontSize: 12,
//                             color: Colors.white60,
//                             letterSpacing: 0.5,
//                           ),
//                         ),
//                       ),
//
//                       const SizedBox(height: 24),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//
//             // ─── Quick Actions Row ────────────────────
//             Expanded(
//               child: SingleChildScrollView(
//                 padding: const EdgeInsets.all(20),
//                 child: Column(
//                   children: [
//
//                     const SizedBox(height: 8),
//
//                     FadeInLeft(
//                       duration: const Duration(milliseconds: 600),
//                       child: Align(
//                         alignment: Alignment.centerLeft,
//                         child: Text(
//                           'Quick Actions',
//                           style: GoogleFonts.poppins(
//                             fontSize: 16,
//                             fontWeight: FontWeight.bold,
//                             color: AppColors.darkGrey,
//                           ),
//                         ),
//                       ),
//                     ),
//
//                     const SizedBox(height: 16),
//
//                     FadeInUp(
//                       duration: const Duration(milliseconds: 600),
//                       delay: const Duration(milliseconds: 200),
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           _buildQuickAction(
//                             icon: Icons.phone_in_talk_rounded,
//                             label: 'Fake\nCall',
//                             color: AppColors.deepPurple,
//                             onTap: () {
//                               Navigator.push(
//                                 context,
//                                 MaterialPageRoute(
//                                   builder: (context) => const FakeCallScreen(),
//                                 ),
//                               );
//                             },
//                           ),
//                           _buildQuickAction(
//                             icon: Icons.location_on_rounded,
//                             label: 'Safe\nPlaces',
//                             color: AppColors.successGreen,
//                             onTap: () {
//                               Navigator.push(
//                                 context,
//                                 MaterialPageRoute(
//                                   builder: (context) => const SafePlacesScreen(),
//                                 ),
//                               );
//                             },
//                           ),
//                           _buildQuickAction(
//                             icon: Icons.people_rounded,
//                             label: 'Guardian\nCircle',
//                             color: AppColors.warningAmber,
//                             onTap: () {
//                               Navigator.push(
//                                 context,
//                                 MaterialPageRoute(
//                                   builder: (context) =>
//                                   const GuardianCircleScreen(),
//                                 ),
//                               );
//                             },
//                           ),
//                           _buildQuickAction(
//                             icon: Icons.call_rounded,
//                             label: 'Help\nlines',
//                             color: AppColors.sosRed,
//                             onTap: () {
//                               Navigator.push(
//                                 context,
//                                 MaterialPageRoute(
//                                   builder: (context) => const HelplinesScreen(),
//                                 ),
//                               );
//                             },
//                           ),
//                         ],
//                       ),
//                     ),
//
//                     const SizedBox(height: 28),
//
//                     // ─── Safety Tips Card ─────────────
//                     FadeInUp(
//                       duration: const Duration(milliseconds: 600),
//                       delay: const Duration(milliseconds: 300),
//                       child: Container(
//                         width: double.infinity,
//                         padding: const EdgeInsets.all(20),
//                         decoration: BoxDecoration(
//                           gradient: const LinearGradient(
//                             colors: [
//                               Color(0xFF4A148C),
//                               Color(0xFF7B1FA2),
//                             ],
//                           ),
//                           borderRadius: BorderRadius.circular(20),
//                           boxShadow: [
//                             BoxShadow(
//                               color: AppColors.deepPurple.withOpacity(0.3),
//                               blurRadius: 12,
//                               offset: const Offset(0, 4),
//                             ),
//                           ],
//                         ),
//                         child: Row(
//                           children: [
//                             Container(
//                               width: 48,
//                               height: 48,
//                               decoration: BoxDecoration(
//                                 color: Colors.white.withOpacity(0.2),
//                                 borderRadius: BorderRadius.circular(14),
//                               ),
//                               child: const Icon(
//                                 Icons.tips_and_updates_rounded,
//                                 color: Colors.white,
//                                 size: 26,
//                               ),
//                             ),
//                             const SizedBox(width: 16),
//                             Expanded(
//                               child: Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Text(
//                                     'Safety Tip',
//                                     style: GoogleFonts.poppins(
//                                       fontSize: 13,
//                                       fontWeight: FontWeight.bold,
//                                       color: Colors.white,
//                                     ),
//                                   ),
//                                   const SizedBox(height: 4),
//                                   Text(
//                                     'Always share your live location with a trusted guardian when traveling alone at night.',
//                                     style: GoogleFonts.poppins(
//                                       fontSize: 11,
//                                       color: Colors.white70,
//                                       height: 1.4,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//
//                     const SizedBox(height: 20),
//
//                     // ─── Share Location Card ──────────
//                     FadeInUp(
//                       duration: const Duration(milliseconds: 600),
//                       delay: const Duration(milliseconds: 400),
//                       child: GestureDetector(
//                         onTap: () {
//                           Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                               builder: (context) => const LiveLocationScreen(),
//                             ),
//                           );
//                         },
//                         child: Container(
//                           width: double.infinity,
//                           padding: const EdgeInsets.all(20),
//                           decoration: BoxDecoration(
//                             color: Colors.white,
//                             borderRadius: BorderRadius.circular(20),
//                             boxShadow: [
//                               BoxShadow(
//                                 color: AppColors.deepPurple.withOpacity(0.08),
//                                 blurRadius: 12,
//                                 offset: const Offset(0, 4),
//                               ),
//                             ],
//                           ),
//                           child: Row(
//                             children: [
//                               Container(
//                                 width: 52,
//                                 height: 52,
//                                 decoration: BoxDecoration(
//                                   color: AppColors.successGreen.withOpacity(0.12),
//                                   borderRadius: BorderRadius.circular(16),
//                                 ),
//                                 child: const Icon(
//                                   Icons.share_location_rounded,
//                                   color: AppColors.successGreen,
//                                   size: 28,
//                                 ),
//                               ),
//                               const SizedBox(width: 16),
//                               Expanded(
//                                 child: Column(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: [
//                                     Text(
//                                       'Share Live Location',
//                                       style: GoogleFonts.poppins(
//                                         fontSize: 14,
//                                         fontWeight: FontWeight.bold,
//                                         color: AppColors.darkGrey,
//                                       ),
//                                     ),
//                                     Text(
//                                       'Let guardians track you in real time',
//                                       style: GoogleFonts.poppins(
//                                         fontSize: 11,
//                                         color: AppColors.mediumGrey,
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                               const Icon(
//                                 Icons.arrow_forward_ios_rounded,
//                                 size: 16,
//                                 color: AppColors.mediumGrey,
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),
//                     ),
//
//                     const SizedBox(height: 100),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//
//         // ─── Bottom Navigation Bar ────────────────────
//         bottomNavigationBar: Container(
//           decoration: BoxDecoration(
//             color: Colors.white,
//             boxShadow: [
//               BoxShadow(
//                 color: Colors.black.withOpacity(0.08),
//                 blurRadius: 20,
//                 offset: const Offset(0, -5),
//               ),
//             ],
//             borderRadius: const BorderRadius.only(
//               topLeft: Radius.circular(24),
//               topRight: Radius.circular(24),
//             ),
//           ),
//           child: ClipRRect(
//             borderRadius: const BorderRadius.only(
//               topLeft: Radius.circular(24),
//               topRight: Radius.circular(24),
//             ),
//             child: BottomNavigationBar(
//               currentIndex: _currentIndex,
//               onTap: (index) {
//                 setState(() => _currentIndex = index);
//                 switch (index) {
//                   case 0:
//                     break;
//                   case 1:
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (context) => const LiveLocationScreen(),
//                       ),
//                     );
//                     break;
//                   case 2:
//                     break;
//                   case 3:
//                     break;
//                 }
//               },
//               type: BottomNavigationBarType.fixed,
//               backgroundColor: Colors.white,
//               selectedItemColor: AppColors.deepPurple,
//               unselectedItemColor: AppColors.mediumGrey,
//               selectedLabelStyle: GoogleFonts.poppins(
//                 fontSize: 11,
//                 fontWeight: FontWeight.w600,
//               ),
//               unselectedLabelStyle: GoogleFonts.poppins(
//                 fontSize: 11,
//               ),
//               elevation: 0,
//               items: const [
//                 BottomNavigationBarItem(
//                   icon: Icon(Icons.home_rounded),
//                   label: 'Home',
//                 ),
//                 BottomNavigationBarItem(
//                   icon: Icon(Icons.map_rounded),
//                   label: 'Map',
//                 ),
//                 BottomNavigationBarItem(
//                   icon: Icon(Icons.chat_bubble_outline_rounded),
//                   label: 'Legal',
//                 ),
//                 BottomNavigationBarItem(
//                   icon: Icon(Icons.person_outline_rounded),
//                   label: 'Profile',
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
//
// // // ─── SOS Countdown Dialog Widget ─────────────────────────
// // class _SOSCountdownDialog extends StatefulWidget {
// //   final VoidCallback onCancel;
// //
// //   const _SOSCountdownDialog({required this.onCancel});
// //
// //   @override
// //   State<_SOSCountdownDialog> createState() => _SOSCountdownDialogState();
// // }
// //
// // class _SOSCountdownDialogState extends State<_SOSCountdownDialog> {
// //   int _count = 3;
// //
// //   @override
// //   void initState() {
// //     super.initState();
// //     _startCount();
// //   }
// //
// //   void _startCount() async {
// //     for (int i = 3; i >= 1; i--) {
// //       if (!mounted) return;
// //       setState(() => _count = i);
// //       await Future.delayed(const Duration(seconds: 1));
// //     }
// //
// //     if (!mounted) return;
// //
// //     Navigator.of(context).pop();
// //
// //     final homeState =
// //     context.findAncestorStateOfType<_HomeScreenState>();
// //     homeState?._triggerSOS();
// //   }
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return WillPopScope(
// //       onWillPop: () async => false,
// //       child: Dialog(
// //         backgroundColor: Colors.transparent,
// //         child: Container(
// //           padding: const EdgeInsets.all(32),
// //           decoration: BoxDecoration(
// //             color: AppColors.sosRed,
// //             borderRadius: BorderRadius.circular(24),
// //           ),
// //           child: Column(
// //             mainAxisSize: MainAxisSize.min,
// //             children: [
// //               Text(
// //                 'SOS in',
// //                 style: GoogleFonts.poppins(
// //                   fontSize: 16,
// //                   color: Colors.white70,
// //                 ),
// //               ),
// //               const SizedBox(height: 8),
// //               Text(
// //                 '$_count',
// //                 style: GoogleFonts.poppins(
// //                   fontSize: 80,
// //                   fontWeight: FontWeight.bold,
// //                   color: Colors.white,
// //                 ),
// //               ),
// //               const SizedBox(height: 8),
// //               Text(
// //                 'Hold tight...',
// //                 style: GoogleFonts.poppins(
// //                   fontSize: 14,
// //                   color: Colors.white70,
// //                 ),
// //               ),
// //               const SizedBox(height: 24),
// //               SizedBox(
// //                 width: double.infinity,
// //                 height: 48,
// //                 child: OutlinedButton(
// //                   onPressed: widget.onCancel,
// //                   style: OutlinedButton.styleFrom(
// //                     foregroundColor: Colors.white,
// //                     side: const BorderSide(
// //                       color: Colors.white,
// //                       width: 2,
// //                     ),
// //                     shape: RoundedRectangleBorder(
// //                       borderRadius: BorderRadius.circular(12),
// //                     ),
// //                   ),
// //                   child: Text(
// //                     'Cancel',
// //                     style: GoogleFonts.poppins(
// //                       fontSize: 15,
// //                       fontWeight: FontWeight.w600,
// //                       color: Colors.white,
// //                     ),
// //                   ),
// //                 ),
// //               ),
// //             ],
// //           ),
// //         ),
// //       ),
// //     );
// //   }
// // }




import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sentinel/presentation/screens/live_location_screen.dart';
import 'package:sentinel/presentation/screens/sos_active_screen.dart';
import '../../../core/constants/app_colors.dart';
import '../../../providers/user_provider.dart';
import '../../data/services/sos_service.dart';
import 'guardian_circle_screen.dart';
import 'fake_call_screen.dart';
import 'helplines_screen.dart';
import 'safe_places_screen.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'legal_chatbot_screen.dart';
import '../../../data/services/voice_sos_service.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with SingleTickerProviderStateMixin {

  // Bottom nav index
  int _currentIndex = 0;

  // SOS pulse animation controller
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  // SOS active state
  bool _isSosActive = false;

  // Shake Detection Variables
  int _countdownValue = 3;
  bool _isCountingDown = false;
  StreamSubscription? _shakeSubscription;
  DateTime? _lastShakeTime;
  int _shakeCount = 0;
  bool _isSosScreenActive = false;
  //bool _isVoiceListening = false;

  @override
  void initState() {
    super.initState();

    // Setup pulse animation
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: Curves.easeInOut,
      ),
    );

    // Load user data
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await ref.read(userProvider.notifier).loadUser();
    });

    // Setup Shake Detection
    _setupShakeDetection();

    // Start Voice SOS Detection
    // _startVoiceDetection();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _shakeSubscription?.cancel();
    // VoiceSosService.stopListening();
    super.dispose();
  }

  void _setupShakeDetection() {
    _shakeSubscription = accelerometerEventStream().listen((event) {
      double acceleration =
          (event.x.abs() + event.y.abs() + event.z.abs()) - 9.8;

      if (acceleration > 20) {
        final now = DateTime.now();

        if (_lastShakeTime == null ||
            now.difference(_lastShakeTime!) >
                const Duration(seconds: 3)) {
          _shakeCount = 0;
        }

        _lastShakeTime = now;
        _shakeCount++;

        if (_shakeCount >= 3) {
          _shakeCount = 0;
          if (!_isSosScreenActive && !_isCountingDown) {
            _triggerSOS(triggerType: 'shake');
          }
        }
      }
    });
  }

  // ─── Exit Dialog ──────────────────────────────────────
  Future<bool> _onWillPop() async {
    final shouldExit = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.sosRed.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.exit_to_app_rounded,
                color: AppColors.sosRed,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Exit Sentinel?',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.darkGrey,
              ),
            ),
          ],
        ),
        content: Text(
          'Are you sure you want to exit? Your guardian protection will be disabled.',
          style: GoogleFonts.poppins(
            fontSize: 13,
            color: AppColors.mediumGrey,
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Stay',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.deepPurple,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context, true);
              SystemNavigator.pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.sosRed,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(
              'Exit',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 4),
        ],
      ),
    );
    return shouldExit ?? false;
  }

  // ─── SOS Countdown and Trigger ────────────────────────
  void _startSOSCountdown() {
    if (_isCountingDown) return;
    setState(() {
      _isCountingDown = true;
      _countdownValue = 3;
    });

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _buildCountdownDialog(),
    );
  }

  Widget _buildCountdownDialog() {
    return StatefulBuilder(
      builder: (context, setDialogState) {
        Future.doWhile(() async {
          await Future.delayed(const Duration(seconds: 1));
          if (!mounted) return false;
          if (_countdownValue > 1) {
            setState(() => _countdownValue--);
            setDialogState(() {});
            return true;
          } else {
            Navigator.pop(context);
            setState(() => _isCountingDown = false);
            _triggerSOS();
            return false;
          }
        });

        return WillPopScope(
          onWillPop: () async => false,
          child: Dialog(
            backgroundColor: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: AppColors.sosRed,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'SOS in',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '$_countdownValue',
                    style: GoogleFonts.poppins(
                      fontSize: 72,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: OutlinedButton(
                      onPressed: () {
                        setState(() {
                          _isCountingDown = false;
                          _countdownValue = 3;
                        });
                        Navigator.pop(context);
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(
                            color: Colors.white, width: 2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Cancel',
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ─── Actual SOS Trigger ───────────────────────────────
  Future<void> _triggerSOS({String triggerType = 'manual'}) async {
    if (_isSosScreenActive) return;
    setState(() => _isSosScreenActive = true);

    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black54,
      builder: (context) => Center(
        child: Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(
                color: AppColors.deepPurple,
              ),
              const SizedBox(height: 16),
              Text(
                'Sending SOS...',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.darkGrey,
                ),
              ),
            ],
          ),
        ),
      ),
    );

    try {
      final result = await SosService.triggerSOS(
        triggerType: triggerType,
      ).timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          return {
            'success': false,
            'message': 'Request timed out. Check your connection.'
          };
        },
      );

      if (!mounted) return;
      Navigator.pop(context);

      if (result['success'] == true) {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SosActiveScreen(sosData: result),
          ),
        );
        if (mounted) setState(() => _isSosScreenActive = false);
      } else {
        setState(() => _isSosScreenActive = false);
        _showSOSError(result['message'] ?? 'SOS failed.');
      }
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context);
      setState(() => _isSosScreenActive = false);
      _showSOSError('Something went wrong. Try again.');
    }
  }

  // ─── Show SOS Error ───────────────────────────────────
  void _showSOSError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline,
                color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: GoogleFonts.poppins(color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.sosRed,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  // ─── SOS Active Dialog ────────────────────────────────
  Widget _buildSOSDialog() {
    return WillPopScope(
      onWillPop: () async => false,
      child: Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: AppColors.sosRed,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.warning_amber_rounded,
                color: Colors.white,
                size: 60,
              ),
              const SizedBox(height: 16),
              Text(
                'SOS ACTIVATED!',
                style: GoogleFonts.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Alerting your guardian circle...',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: Colors.white70,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              _buildSOSStatus('📍 Location captured', true),
              const SizedBox(height: 8),
              _buildSOSStatus('📲 Notifying guardians...', false),
              const SizedBox(height: 8),
              _buildSOSStatus('📱 Sending SMS alerts...', false),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton(
                  onPressed: () {
                    setState(() => _isSosActive = false);
                    Navigator.pop(context);
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(
                        color: Colors.white, width: 2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    'Cancel SOS',
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── SOS Status Row ───────────────────────────────────
  Widget _buildSOSStatus(String text, bool isDone) {
    return Row(
      children: [
        Container(
          width: 22,
          height: 22,
          decoration: BoxDecoration(
            color: isDone
                ? Colors.white
                : Colors.white.withOpacity(0.3),
            shape: BoxShape.circle,
          ),
          child: Icon(
            isDone ? Icons.check : Icons.access_time,
            size: 14,
            color: isDone ? AppColors.sosRed : Colors.white,
          ),
        ),
        const SizedBox(width: 10),
        Text(
          text,
          style: GoogleFonts.poppins(
            fontSize: 13,
            color: Colors.white,
            fontWeight:
            isDone ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  // ─── Quick Action Button ──────────────────────────────
  Widget _buildQuickAction({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 62,
            height: 62,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              shape: BoxShape.circle,
              border: Border.all(
                color: color.withOpacity(0.3),
                width: 1.5,
              ),
            ),
            child: Icon(
              icon,
              color: color,
              size: 28,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: AppColors.darkGrey,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // ─── Safety Status Card ───────────────────────────────
  Widget _buildStatusCard() {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: const BoxDecoration(
              color: Color(0xFF69F0AE),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            'Sentinel is Active',
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
          // // ✅ Voice indicator
          // if (_isVoiceListening) ...[
          //   const SizedBox(width: 10),
          //   const Icon(
          //     Icons.mic_rounded,
          //     color: Color(0xFF69F0AE),
          //     size: 14,
          //   ),
          //   const SizedBox(width: 4),
          //   Text(
          //     'Voice ON',
          //     style: GoogleFonts.poppins(
          //       fontSize: 11,
          //       fontWeight: FontWeight.w600,
          //       color: const Color(0xFF69F0AE),
          //     ),
          //   ),
          // ],
        ],
      ),
    );
  }

  // ─── Start Voice Detection ────────────────────────────
  // Future<void> _startVoiceDetection() async {
  //   final started = await VoiceSosService.startListening(
  //     onDistress: (String keyword) {
  //       if (!mounted) return;
  //
  //       // Don't trigger if SOS already active
  //       if (_isSosScreenActive || _isCountingDown) return;
  //
  //       print('🚨 Voice SOS: $keyword detected!');
  //
  //       // Show notification
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(
  //           content: Row(
  //             children: [
  //               const Icon(Icons.mic_rounded,
  //                   color: Colors.white, size: 18),
  //               const SizedBox(width: 8),
  //               Expanded(
  //                 child: Text(
  //                   'Voice detected: "$keyword" — SOS starting...',
  //                   style: GoogleFonts.poppins(
  //                     color: Colors.white,
  //                     fontSize: 12,
  //                   ),
  //                 ),
  //               ),
  //             ],
  //           ),
  //           backgroundColor: AppColors.sosRed,
  //           duration: const Duration(seconds: 2),
  //           behavior: SnackBarBehavior.floating,
  //           shape: RoundedRectangleBorder(
  //             borderRadius: BorderRadius.circular(10),
  //           ),
  //         ),
  //       );
  //
  //       // Start SOS countdown after 1 second
  //       Future.delayed(const Duration(seconds: 1), () {
  //         if (mounted && !_isSosScreenActive) {
  //           _startSOSCountdown();
  //         }
  //       });
  //     },
  //   );
  //
  //   if (mounted) {
  //     setState(() => _isVoiceListening = started);
  //     print(started
  //         ? '✅ Voice SOS active'
  //         : '❌ Voice SOS not started');
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider);
    final userName = user?.name ?? 'User';
    final firstName = userName.split(' ').first;

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: AppColors.lightGrey,
        body: Column(
          children: [

            // ─── Top Purple Header ────────────────────
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
                  padding:
                  const EdgeInsets.fromLTRB(20, 16, 20, 30),
                  child: Column(
                    children: [

                      // ── Top Row: Greeting + Profile ──
                      FadeInDown(
                        duration:
                        const Duration(milliseconds: 600),
                        child: Row(
                          mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Hello, $firstName 👋',
                                  style: GoogleFonts.poppins(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                Text(
                                  'Stay safe today',
                                  style: GoogleFonts.poppins(
                                    fontSize: 13,
                                    color: Colors.white70,
                                  ),
                                ),
                              ],
                            ),
                            GestureDetector(
                              onTap: () {},
                              child: Container(
                                width: 46,
                                height: 46,
                                decoration: BoxDecoration(
                                  color:
                                  Colors.white.withOpacity(0.2),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white
                                        .withOpacity(0.5),
                                    width: 2,
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    firstName.isNotEmpty
                                        ? firstName[0].toUpperCase()
                                        : 'U',
                                    style: GoogleFonts.poppins(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // ── Status Badge ─────────────────
                      FadeInUp(
                        duration:
                        const Duration(milliseconds: 600),
                        delay:
                        const Duration(milliseconds: 200),
                        child: _buildStatusCard(),
                      ),

                      const SizedBox(height: 28),

                      // ── BIG SOS BUTTON ───────────────
                      FadeInUp(
                        duration:
                        const Duration(milliseconds: 700),
                        delay:
                        const Duration(milliseconds: 300),
                        child: GestureDetector(
                          onLongPress: _startSOSCountdown,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              AnimatedBuilder(
                                animation: _pulseAnimation,
                                builder: (context, child) {
                                  return Transform.scale(
                                    scale:
                                    _pulseAnimation.value *
                                        1.25,
                                    child: Container(
                                      width: 150,
                                      height: 150,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: AppColors.sosRed
                                            .withOpacity(0.1),
                                      ),
                                    ),
                                  );
                                },
                              ),
                              AnimatedBuilder(
                                animation: _pulseAnimation,
                                builder: (context, child) {
                                  return Transform.scale(
                                    scale:
                                    _pulseAnimation.value *
                                        1.12,
                                    child: Container(
                                      width: 150,
                                      height: 150,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: AppColors.sosRed
                                            .withOpacity(0.18),
                                      ),
                                    ),
                                  );
                                },
                              ),
                              Container(
                                width: 150,
                                height: 150,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.sosRed,
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.sosRed
                                          .withOpacity(0.5),
                                      blurRadius: 20,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                                child: Column(
                                  mainAxisAlignment:
                                  MainAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      Icons.warning_amber_rounded,
                                      color: Colors.white,
                                      size: 40,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'SOS',
                                      style: GoogleFonts.poppins(
                                        fontSize: 26,
                                        fontWeight:
                                        FontWeight.bold,
                                        color: Colors.white,
                                        letterSpacing: 4,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      FadeInUp(
                        duration:
                        const Duration(milliseconds: 600),
                        delay:
                        const Duration(milliseconds: 400),
                        child: Text(
                          'Hold to activate SOS',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.white60,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),

            // ─── Quick Actions Row ────────────────────
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [

                    const SizedBox(height: 8),

                    FadeInLeft(
                      duration:
                      const Duration(milliseconds: 600),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Quick Actions',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.darkGrey,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    FadeInUp(
                      duration:
                      const Duration(milliseconds: 600),
                      delay:
                      const Duration(milliseconds: 200),
                      child: Row(
                        mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                        children: [
                          _buildQuickAction(
                            icon: Icons.phone_in_talk_rounded,
                            label: 'Fake\nCall',
                            color: AppColors.deepPurple,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                  const FakeCallScreen(),
                                ),
                              );
                            },
                          ),
                          _buildQuickAction(
                            icon: Icons.location_on_rounded,
                            label: 'Safe\nPlaces',
                            color: AppColors.successGreen,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                  const SafePlacesScreen(),
                                ),
                              );
                            },
                          ),
                          _buildQuickAction(
                            icon: Icons.people_rounded,
                            label: 'Guardian\nCircle',
                            color: AppColors.warningAmber,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                  const GuardianCircleScreen(),
                                ),
                              );
                            },
                          ),
                          _buildQuickAction(
                            icon: Icons.call_rounded,
                            label: 'Help\nlines',
                            color: AppColors.sosRed,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                  const HelplinesScreen(),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 28),

                    // ─── Safety Tips Card ─────────────
                    FadeInUp(
                      duration:
                      const Duration(milliseconds: 600),
                      delay:
                      const Duration(milliseconds: 300),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFF4A148C),
                              Color(0xFF7B1FA2),
                            ],
                          ),
                          borderRadius:
                          BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.deepPurple
                                  .withOpacity(0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: Colors.white
                                    .withOpacity(0.2),
                                borderRadius:
                                BorderRadius.circular(14),
                              ),
                              child: const Icon(
                                Icons.tips_and_updates_rounded,
                                color: Colors.white,
                                size: 26,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Safety Tip',
                                    style: GoogleFonts.poppins(
                                      fontSize: 13,
                                      fontWeight:
                                      FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Always share your live location with a trusted guardian when traveling alone at night.',
                                    style: GoogleFonts.poppins(
                                      fontSize: 11,
                                      color: Colors.white70,
                                      height: 1.4,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // ─── Share Location Card ──────────
                    // ✅ CHANGE 1: Added GestureDetector
                    FadeInUp(
                      duration:
                      const Duration(milliseconds: 600),
                      delay:
                      const Duration(milliseconds: 400),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                              const LiveLocationScreen(),
                            ),
                          );
                        },
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius:
                            BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.deepPurple
                                    .withOpacity(0.08),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 52,
                                height: 52,
                                decoration: BoxDecoration(
                                  color: AppColors.successGreen
                                      .withOpacity(0.12),
                                  borderRadius:
                                  BorderRadius.circular(16),
                                ),
                                child: const Icon(
                                  Icons.share_location_rounded,
                                  color: AppColors.successGreen,
                                  size: 28,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                  CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Share Live Location',
                                      style:
                                      GoogleFonts.poppins(
                                        fontSize: 14,
                                        fontWeight:
                                        FontWeight.bold,
                                        color:
                                        AppColors.darkGrey,
                                      ),
                                    ),
                                    Text(
                                      'Let guardians track you in real time',
                                      style:
                                      GoogleFonts.poppins(
                                        fontSize: 11,
                                        color: AppColors
                                            .mediumGrey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(
                                Icons.arrow_forward_ios_rounded,
                                size: 16,
                                color: AppColors.mediumGrey,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ],
        ),

        // ─── Bottom Navigation Bar ────────────────────
        // ✅ CHANGE 2: Map tab navigates to LiveLocationScreen
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 20,
                offset: const Offset(0, -5),
              ),
            ],
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          child: ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
            child: BottomNavigationBar(
              currentIndex: _currentIndex,
              onTap: (index) {
                setState(() => _currentIndex = index);
                switch (index) {
                  case 0:
                    break;
                  case 1:
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                        const LiveLocationScreen(),
                      ),
                    );
                    break;
                  case 2:
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                        const LegalChatbotScreen(),
                      ),
                    );
                    break;
                    break;
                  case 3:
                  // Profile — Coming Day 14
                    break;
                }
              },
              type: BottomNavigationBarType.fixed,
              backgroundColor: Colors.white,
              selectedItemColor: AppColors.deepPurple,
              unselectedItemColor: AppColors.mediumGrey,
              selectedLabelStyle: GoogleFonts.poppins(
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
              unselectedLabelStyle: GoogleFonts.poppins(
                fontSize: 11,
              ),
              elevation: 0,
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home_rounded),
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.map_rounded),
                  label: 'Map',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.auto_awesome_rounded),
                  label: 'AI Chat',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person_outline_rounded),
                  label: 'Profile',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}





