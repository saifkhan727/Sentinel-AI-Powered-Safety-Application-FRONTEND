// import 'package:geolocator/geolocator.dart';
// import 'api_service.dart';
//
// class SosService {
//
//   // ─── Get Current Location ──────────────────────────────
//   static Future<Position?> getCurrentLocation() async {
//     try {
//       // Check if location services enabled
//       bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
//       if (!serviceEnabled) {
//         print('❌ Location services disabled');
//         return null;
//       }
//
//       // Check permissions
//       LocationPermission permission = await Geolocator.checkPermission();
//       if (permission == LocationPermission.denied) {
//         permission = await Geolocator.requestPermission();
//         if (permission == LocationPermission.denied) {
//           print('❌ Location permission denied');
//           return null;
//         }
//       }
//
//       if (permission == LocationPermission.deniedForever) {
//         print('❌ Location permission permanently denied');
//         return null;
//       }
//
//       // Get position
//       final position = await Geolocator.getCurrentPosition(
//         desiredAccuracy: LocationAccuracy.high,
//         timeLimit: const Duration(seconds: 10),
//       );
//
//       print('📍 Location: ${position.latitude}, ${position.longitude}');
//       return position;
//
//     } catch (e) {
//       print('❌ Location error: $e');
//       return null;
//     }
//   }
//
//   // ─── Trigger Full SOS ──────────────────────────────────
//   static Future<Map<String, dynamic>> triggerSOS({
//     String triggerType = 'manual',
//   }) async {
//     // Get location
//     final position = await getCurrentLocation();
//
//     double lat = 0.0;
//     double lng = 0.0;
//
//     if (position != null) {
//       lat = position.latitude;
//       lng = position.longitude;
//     }
//
//     // Call backend API
//     final result = await ApiService.triggerSOS(
//       latitude: lat,
//       longitude: lng,
//       triggerType: triggerType,
//     );
//
//     return result;
//   }
// }



// import 'package:geolocator/geolocator.dart';
// import 'api_service.dart';
//
// class SosService {
//
//   // ─── Get Current Location ──────────────────────────────
//   static Future<Position?> getCurrentLocation() async {
//     try {
//       bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
//       if (!serviceEnabled) {
//         print('❌ Location services disabled');
//         return null;
//       }
//
//       LocationPermission permission = await Geolocator.checkPermission();
//       if (permission == LocationPermission.denied) {
//         permission = await Geolocator.requestPermission();
//         if (permission == LocationPermission.denied) {
//           print('❌ Location permission denied');
//           return null;
//         }
//       }
//
//       if (permission == LocationPermission.deniedForever) {
//         print('❌ Location permanently denied');
//         return null;
//       }
//
//       // ✅ Added timeout so it doesn't hang
//       final position = await Geolocator.getCurrentPosition(
//         desiredAccuracy: LocationAccuracy.medium,
//         timeLimit: const Duration(seconds: 8),
//       );
//
//       print('📍 Got location: ${position.latitude}, ${position.longitude}');
//       return position;
//
//     } catch (e) {
//       print('❌ Location error: $e');
//       // Return last known location as fallback
//       try {
//         final lastPosition = await Geolocator.getLastKnownPosition();
//         if (lastPosition != null) {
//           print('📍 Using last known location');
//           return lastPosition;
//         }
//       } catch (_) {}
//       return null;
//     }
//   }
//
//   // ─── Trigger Full SOS ──────────────────────────────────
//   static Future<Map<String, dynamic>> triggerSOS({
//     String triggerType = 'manual',
//   }) async {
//
//     double lat = 0.0;
//     double lng = 0.0;
//
//     // Get location with timeout
//     try {
//       final position = await getCurrentLocation();
//       if (position != null) {
//         lat = position.latitude;
//         lng = position.longitude;
//       }
//     } catch (e) {
//       print('❌ Location failed — using 0,0: $e');
//     }
//
//     print('📤 Calling SOS API with lat: $lat, lng: $lng');
//
//     // Call backend API
//     final result = await ApiService.triggerSOS(
//       latitude: lat,
//       longitude: lng,
//       triggerType: triggerType,
//     );
//
//     print('📥 SOS API response: $result');
//     return result;
//   }
// }




import 'package:geolocator/geolocator.dart';
import 'api_service.dart';
import 'sms_service.dart';

class SosService {

  // ─── Get Current Location ──────────────────────────────
  static Future<Position?> getCurrentLocation() async {
    try {
      bool serviceEnabled =
      await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        print('❌ Location services disabled');
        return null;
      }

      LocationPermission permission =
      await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission =
        await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          print('❌ Location permission denied');
          return null;
        }
      }

      if (permission ==
          LocationPermission.deniedForever) {
        print('❌ Location permanently denied');
        return null;
      }

      final position =
      await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
        timeLimit: const Duration(seconds: 8),
      );

      print(
          '📍 Got location: ${position.latitude}, ${position.longitude}');
      return position;

    } catch (e) {
      print('❌ Location error: $e');
      try {
        final lastPosition =
        await Geolocator.getLastKnownPosition();
        if (lastPosition != null) {
          print('📍 Using last known location');
          return lastPosition;
        }
      } catch (_) {}
      return null;
    }
  }

  // ─── Trigger Full SOS ──────────────────────────────────
  static Future<Map<String, dynamic>> triggerSOS({
    String triggerType = 'manual',
  }) async {

    double lat = 0.0;
    double lng = 0.0;

    // Get location with timeout
    try {
      final position = await getCurrentLocation();
      if (position != null) {
        lat = position.latitude;
        lng = position.longitude;
      }
    } catch (e) {
      print('❌ Location failed — using 0,0: $e');
    }

    print(
        '📤 Calling SOS API with lat: $lat, lng: $lng');

    // Call backend API
    final result = await ApiService.triggerSOS(
      latitude: lat,
      longitude: lng,
      triggerType: triggerType,
    );

    print('📥 SOS API response: $result');

    // ✅ Send SMS from phone after API call
    if (result['success'] == true) {
      try {
        final guardians =
        result['guardians'] as List?;
        final userName =
        result['userName'] as String?;
        final userPhone =
        result['userPhone'] as String?;

        if (guardians != null &&
            guardians.isNotEmpty &&
            userName != null &&
            userPhone != null) {

          print(
              '📱 Sending SMS to ${guardians.length} guardians...');

          // Send SMS in background — don't await
          SmsService.sendSOSSms(
            guardians: guardians
                .map((g) =>
            g as Map<String, dynamic>)
                .toList(),
            userName: userName,
            userPhone: userPhone,
          ).then((smsResult) {
            print('📱 SMS result: $smsResult');
          }).catchError((e) {
            print('📱 SMS error: $e');
          });

        } else {
          print(
              '⚠️ Missing data for SMS — guardians: ${guardians?.length}, userName: $userName');
        }
      } catch (e) {
        print('❌ SMS sending failed: $e');
      }
    }

    return result;
  }
}
