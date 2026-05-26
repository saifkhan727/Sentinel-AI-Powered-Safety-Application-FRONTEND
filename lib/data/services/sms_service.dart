import 'package:android_intent_plus/android_intent.dart';
import 'package:android_intent_plus/flag.dart';
import 'package:geolocator/geolocator.dart';

class SmsService {

  // ─── Get Location Link ────────────────────────────────
  static Future<String> _getLocationLink() async {
    try {
      bool serviceEnabled =
      await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return 'Location unavailable';

      LocationPermission permission =
      await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission =
        await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return 'Location unavailable';
        }
      }

      final position =
      await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 8),
      );

      return 'https://maps.google.com/?q=${position.latitude},${position.longitude}';
    } catch (e) {
      print('Location error: $e');
      return 'Location unavailable';
    }
  }

  // ─── Format Phone Number ──────────────────────────────
  static String _formatPhone(String phone) {
    String cleaned =
    phone.replaceAll(RegExp(r'[\s\-()]'), '');
    if (!cleaned.startsWith('+')) {
      if (cleaned.startsWith('91')) {
        cleaned = '+$cleaned';
      } else {
        cleaned = '+91$cleaned';
      }
    }
    return cleaned;
  }

  // ─── Send SOS SMS ─────────────────────────────────────
  static Future<Map<String, dynamic>> sendSOSSms({
    required List<Map<String, dynamic>> guardians,
    required String userName,
    required String userPhone,
  }) async {
    try {
      // Get location
      final locationLink = await _getLocationLink();

      // Build SOS message
      final message =
          '🚨 EMERGENCY ALERT - SENTINEL\n\n'
          '$userName needs immediate help!\n\n'
          '📍 Live Location:\n'
          '$locationLink\n\n'
          '📞 Their number: $userPhone\n\n'
          'Please call them or go to their location immediately.\n\n'
          '- Sent via Sentinel Safety App';

      // Get all guardian phone numbers
      final List<String> phones = guardians
          .map((g) {
        final phone =
            g['contact_phone'] as String? ??
                g['phone'] as String? ?? '';
        return _formatPhone(phone);
      })
          .where((p) => p.isNotEmpty)
          .toList();

      if (phones.isEmpty) {
        return {
          'success': false,
          'message': 'No guardian numbers found',
        };
      }

      print(
          '📤 Sending SOS SMS to ${phones.length} guardians...');

      // Send SMS to each guardian
      for (final phone in phones) {
        try {
          final intent = AndroidIntent(
            action: 'android.intent.action.SENDTO',
            data: 'smsto:$phone',
            arguments: {
              'sms_body': message,
              'exit_on_sent': true,
            },
            flags: [Flag.FLAG_ACTIVITY_NEW_TASK],
          );
          await intent.launch();

          print('✅ SMS intent launched for $phone');

          // Small delay between each SMS
          await Future.delayed(
              const Duration(milliseconds: 500));

        } catch (e) {
          print('❌ SMS failed for $phone: $e');
        }
      }

      return {
        'success': true,
        'message':
        'SMS sent to ${phones.length} guardians',
        'locationLink': locationLink,
      };

    } catch (e) {
      print('❌ SOS SMS error: $e');
      return {
        'success': false,
        'message': 'SMS failed: $e',
      };
    }
  }

  // ─── Send Safe SMS ────────────────────────────────────
  static Future<void> sendSafeSms({
    required List<Map<String, dynamic>> guardians,
    required String userName,
  }) async {
    try {
      final message =
          '✅ SAFE ALERT - SENTINEL\n\n'
          '$userName is now SAFE!\n\n'
          'The emergency SOS has been cancelled.\n'
          '$userName has confirmed they are safe.\n\n'
          'Thank you for your concern.\n'
          '- Sentinel Safety App';

      final List<String> phones = guardians
          .map((g) {
        final phone =
            g['contact_phone'] as String? ??
                g['phone'] as String? ?? '';
        return _formatPhone(phone);
      })
          .where((p) => p.isNotEmpty)
          .toList();

      if (phones.isEmpty) return;

      for (final phone in phones) {
        try {
          final intent = AndroidIntent(
            action: 'android.intent.action.SENDTO',
            data: 'smsto:$phone',
            arguments: {
              'sms_body': message,
              'exit_on_sent': true,
            },
            flags: [Flag.FLAG_ACTIVITY_NEW_TASK],
          );
          await intent.launch();

          await Future.delayed(
              const Duration(milliseconds: 500));

          print('✅ Safe SMS sent to $phone');
        } catch (e) {
          print('❌ Safe SMS failed for $phone: $e');
        }
      }
    } catch (e) {
      print('❌ Safe SMS error: $e');
    }
  }
}