// import 'package:dio/dio.dart';
// import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// import '../../core/constants/api_constants.dart';
//
// class ApiService {
//   static final Dio _dio = Dio(
//     BaseOptions(
//       connectTimeout: const Duration(seconds: 10),
//       receiveTimeout: const Duration(seconds: 10),
//       headers: {'Content-Type': 'application/json'},
//     ),
//   );
//
//   static const _storage = FlutterSecureStorage();
//
//   // ─── Save Token ──────────────────────────────────────
//   static Future<void> saveToken(String token) async {
//     await _storage.write(key: 'auth_token', value: token);
//   }
//
//   // ─── Get Token ───────────────────────────────────────
//   static Future<String?> getToken() async {
//     return await _storage.read(key: 'auth_token');
//   }
//
//   // ─── Delete Token ────────────────────────────────────
//   static Future<void> deleteToken() async {
//     await _storage.delete(key: 'auth_token');
//   }
//
//   // ─── Register User ───────────────────────────────────
//   static Future<Map<String, dynamic>> registerUser({
//     required String name,
//     required String phone,
//     String? fcmToken,
//   }) async {
//     try {
//       final response = await _dio.post(
//         ApiConstants.register,
//         data: {
//           'name': name,
//           'phone': phone,
//           'fcm_token': fcmToken ?? '',
//         },
//       );
//
//       // Save token to secure storage
//       if (response.data['token'] != null) {
//         await saveToken(response.data['token']);
//       }
//
//       return response.data;
//
//     } on DioException catch (e) {
//       if (e.response != null) {
//         return e.response!.data;
//       }
//       return {
//         'success': false,
//         'message': 'Cannot connect to server. Check your connection.'
//       };
//     }
//   }
// }



import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../core/constants/api_constants.dart';

class ApiService {
  static final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {'Content-Type': 'application/json'},
    ),
  );

  static const _storage = FlutterSecureStorage();

  // ─── Save Token ───────────────────────────────────────
  static Future<void> saveToken(String token) async {
    await _storage.write(key: 'auth_token', value: token);
  }

  // ─── Get Token ────────────────────────────────────────
  static Future<String?> getToken() async {
    return await _storage.read(key: 'auth_token');
  }

  // ─── Delete Token ─────────────────────────────────────
  static Future<void> deleteToken() async {
    await _storage.delete(key: 'auth_token');
  }

  // ─── Get Auth Headers ─────────────────────────────────
  // Every protected API needs this header
  static Future<Map<String, String>> _getAuthHeaders() async {
    final token = await getToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // ─── Register User ────────────────────────────────────
  static Future<Map<String, dynamic>> registerUser({
    required String name,
    required String phone,
    String? fcmToken,
  }) async {
    try {
      final response = await _dio.post(
        ApiConstants.register,
        data: {
          'name': name,
          'phone': phone,
          'fcm_token': fcmToken ?? '',
        },
      );

      // Save token to secure storage
      if (response.data['token'] != null) {
        await saveToken(response.data['token']);
      }

      return response.data;

    } on DioException catch (e) {
      if (e.response != null) {
        return e.response!.data;
      }
      return {
        'success': false,
        'message': 'Cannot connect to server. Check your connection.'
      };
    }
  }

  // ─── Get Current User ─────────────────────────────────
  static Future<Map<String, dynamic>> getMe() async {
    try {
      final headers = await _getAuthHeaders();
      final response = await _dio.get(
        ApiConstants.getMe,
        options: Options(headers: headers),
      );
      return response.data;
    } on DioException catch (e) {
      if (e.response != null) return e.response!.data;
      return {
        'success': false,
        'message': 'Cannot connect to server.'
      };
    }
  }

  // ══════════════════════════════════════════════════════
  // GUARDIAN METHODS
  // ══════════════════════════════════════════════════════

  // ─── Get All Guardians ────────────────────────────────
  static Future<Map<String, dynamic>> getGuardians() async {
    try {
      final headers = await _getAuthHeaders();
      final response = await _dio.get(
        ApiConstants.guardians,
        options: Options(headers: headers),
      );
      return response.data;
    } on DioException catch (e) {
      if (e.response != null) return e.response!.data;
      return {
        'success': false,
        'message': 'Cannot connect to server.'
      };
    }
  }

  // ─── Add Guardian ─────────────────────────────────────
  static Future<Map<String, dynamic>> addGuardian({
    required String name,
    required String phone,
    required int priority,
  }) async {
    try {
      final headers = await _getAuthHeaders();
      final response = await _dio.post(
        ApiConstants.guardians,
        data: {
          'contact_name': name,
          'contact_phone': phone,
          'priority_order': priority,
        },
        options: Options(headers: headers),
      );
      return response.data;
    } on DioException catch (e) {
      if (e.response != null) return e.response!.data;
      return {
        'success': false,
        'message': 'Cannot connect to server.'
      };
    }
  }

  // ─── Update Guardian ──────────────────────────────────
  static Future<Map<String, dynamic>> updateGuardian({
    required String id,
    required String name,
    required String phone,
    required int priority,
  }) async {
    try {
      final headers = await _getAuthHeaders();
      final response = await _dio.put(
        '${ApiConstants.guardians}/$id',
        data: {
          'contact_name': name,
          'contact_phone': phone,
          'priority_order': priority,
        },
        options: Options(headers: headers),
      );
      return response.data;
    } on DioException catch (e) {
      if (e.response != null) return e.response!.data;
      return {
        'success': false,
        'message': 'Cannot connect to server.'
      };
    }
  }

  // ─── Delete Guardian ──────────────────────────────────
  static Future<Map<String, dynamic>> deleteGuardian(String id) async {
    try {
      final headers = await _getAuthHeaders();
      final response = await _dio.delete(
        '${ApiConstants.guardians}/$id',
        options: Options(headers: headers),
      );
      return response.data;
    } on DioException catch (e) {
      if (e.response != null) return e.response!.data;
      return {
        'success': false,
        'message': 'Cannot connect to server.'
      };
    }
  }

  // ══════════════════════════════════════════════════════
  // SOS METHODS
  // ══════════════════════════════════════════════════════

  // ─── Trigger SOS ──────────────────────────────────────
  static Future<Map<String, dynamic>> triggerSOS({
    required double latitude,
    required double longitude,
    String? address,
    String triggerType = 'manual',
    String? evidencePhotoUrl,
  }) async {
    try {
      final headers = await _getAuthHeaders();
      final response = await _dio.post(
        ApiConstants.sosTrigger,
        data: {
          'latitude': latitude,
          'longitude': longitude,
          'address': address ?? 'Unknown location',
          'trigger_type': triggerType,
          'evidence_photo_url': evidencePhotoUrl,
        },
        options: Options(headers: headers),
      );
      return response.data;
    } on DioException catch (e) {
      if (e.response != null) return e.response!.data;
      return {
        'success': false,
        'message': 'Cannot connect to server.'
      };
    }
  }

  // ─── Resolve SOS ──────────────────────────────────────
  static Future<Map<String, dynamic>> resolveSOS(String sosId) async {
    try {
      final headers = await _getAuthHeaders();
      final response = await _dio.put(
        '${ApiConstants.baseUrl}/sos/$sosId/resolve',
        options: Options(headers: headers),
      );
      return response.data;
    } on DioException catch (e) {
      if (e.response != null) return e.response!.data;
      return {
        'success': false,
        'message': 'Cannot connect to server.'
      };
    }
  }

  // Base URL helper
  static String get baseUrl => ApiConstants.baseUrl.replaceAll('/api', '');


  // ══════════════════════════════════════════════════════
  // LOCATION METHODS
  // ══════════════════════════════════════════════════════

  // ─── Start Location Session ──────────────────────────
  static Future<Map<String, dynamic>> startLocationSession({
    required double latitude,
    required double longitude,
    int durationMinutes = 60,
  }) async {
    try {
      final headers = await _getAuthHeaders();
      final response = await _dio.post(
        ApiConstants.locationStart,
        data: {
          'latitude': latitude,
          'longitude': longitude,
          'duration_minutes': durationMinutes,
        },
        options: Options(headers: headers),
      );
      return response.data;
    } on DioException catch (e) {
      if (e.response != null) return e.response!.data;
      return {'success': false, 'message': 'Cannot connect to server.'};
    }
  }

  // ─── Stop Location Session ────────────────────────────
  static Future<Map<String, dynamic>> stopLocationSession({
    required String sessionId,
  }) async {
    try {
      final headers = await _getAuthHeaders();
      final response = await _dio.post(
        ApiConstants.locationStop,
        data: {'sessionId': sessionId},
        options: Options(headers: headers),
      );
      return response.data;
    } on DioException catch (e) {
      if (e.response != null) return e.response!.data;
      return {'success': false, 'message': 'Cannot connect to server.'};
    }
  }

  // ─── Get Active Session ───────────────────────────────
  static Future<Map<String, dynamic>> getActiveSession() async {
    try {
      final headers = await _getAuthHeaders();
      final response = await _dio.get(
        ApiConstants.locationActive,
        options: Options(headers: headers),
      );
      return response.data;
    } on DioException catch (e) {
      if (e.response != null) return e.response!.data;
      return {'success': false, 'message': 'Cannot connect to server.'};
    }
  }

  // ─── Get Safe Places ──────────────────────────────────
  static Future<Map<String, dynamic>> getSafePlaces({
    required double latitude,
    required double longitude,
    String? type,
    int radius = 5000,
  }) async {
    try {
      final response = await _dio.get(
        ApiConstants.safePlaces,
        queryParameters: {
          'lat': latitude.toString(),
          'lng': longitude.toString(),
          if (type != null && type != 'all') 'type': type,
          'radius': radius.toString(),
        },
      );
      return response.data;
    } on DioException catch (e) {
      if (e.response != null) return e.response!.data;
      return {
        'success': false,
        'message': 'Cannot connect to server.'
      };
    }
  }
}