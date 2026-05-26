// import 'dart:async';
// import 'package:flutter/services.dart';
//
// class VoiceSosService {
//
//   static const MethodChannel _channel =
//   MethodChannel('sentinel/voice_sos');
//
//   static bool _isListening = false;
//   static Function(String keyword)? onDistressDetected;
//
//   static bool get isListening => _isListening;
//
//   static const List<String> _distressKeywords = [
//     'help', 'bachao', 'leave me',
//     'chodo', 'madad karo', 'save me',
//     'help me', 'bachao mujhe',
//   ];
//
//   // ─── Start Listening ───────────────────────────────────
//   static Future<bool> startListening({
//     required Function(String keyword) onDistress,
//   }) async {
//     try {
//       onDistressDetected = onDistress;
//       _isListening = true;
//
//       // Set up method call handler from Android
//       _channel.setMethodCallHandler((call) async {
//         if (call.method == 'onSpeechResult') {
//           final String text =
//           (call.arguments as String).toLowerCase();
//           print('🎤 Heard: $text');
//
//           // Check for distress keywords
//           for (final keyword in _distressKeywords) {
//             if (text.contains(keyword)) {
//               print('🚨 Distress keyword: $keyword');
//               onDistressDetected?.call(keyword);
//               break;
//             }
//           }
//         }
//       });
//
//       // Start Android speech recognition
//       final result = await _channel.invokeMethod(
//           'startListening');
//       print('✅ Voice SOS started: $result');
//       return true;
//
//     } catch (e) {
//       print('❌ Voice SOS error: $e');
//       _isListening = false;
//       return false;
//     }
//   }
//
//   // ─── Stop Listening ────────────────────────────────────
//   static Future<void> stopListening() async {
//     _isListening = false;
//     try {
//       await _channel.invokeMethod('stopListening');
//     } catch (e) {
//       print('Stop error: $e');
//     }
//     print('🎤 Voice SOS stopped');
//   }
//
//   static void dispose() {
//     stopListening();
//   }
// }