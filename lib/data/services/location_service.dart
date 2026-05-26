import 'dart:async';
import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../core/constants/api_constants.dart';
import 'api_service.dart';

class LocationService {
  static WebSocketChannel? _channel;
  static StreamSubscription<Position>? _locationSubscription;
  static String? _currentSessionId;
  static bool _isSharing = false;

  static bool get isSharing => _isSharing;
  static String? get sessionId => _currentSessionId;

  // ─── Start Live Location Sharing ────────────────────────
  static Future<Map<String, dynamic>> startSharing({
    int durationMinutes = 60,
  }) async {
    try {
      // Get current location first
      final position = await _getCurrentPosition();
      if (position == null) {
        return {
          'success': false,
          'message': 'Could not get location. Check permissions.'
        };
      }

      // Start session on backend
      final result = await ApiService.startLocationSession(
        latitude: position.latitude,
        longitude: position.longitude,
        durationMinutes: durationMinutes,
      );

      if (result['success'] != true) {
        return result;
      }

      _currentSessionId = result['session']['id'];
      _isSharing = true;

      // Connect WebSocket
      await _connectWebSocket();

      // Start sending location updates every 5 seconds
      _startLocationUpdates(position);

      return {
        'success': true,
        'sessionId': _currentSessionId,
        'shareToken': result['session']['shareToken'],
      };

    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to start sharing: $e'
      };
    }
  }

  // ─── Stop Location Sharing ───────────────────────────────
  static Future<void> stopSharing() async {
    _isSharing = false;

    // Cancel location updates
    await _locationSubscription?.cancel();
    _locationSubscription = null;

    // Close WebSocket
    await _channel?.sink.close();
    _channel = null;

    // Stop session on backend
    if (_currentSessionId != null) {
      await ApiService.stopLocationSession(
        sessionId: _currentSessionId!,
      );
      _currentSessionId = null;
    }
  }

  // ─── Connect WebSocket ───────────────────────────────────
  static Future<void> _connectWebSocket() async {
    try {
      final storage = const FlutterSecureStorage();
      final userId = await storage.read(key: 'user_id');

      _channel = WebSocketChannel.connect(
        Uri.parse(ApiConstants.wsUrl),
      );

      // Register user connection
      _channel!.sink.add(jsonEncode({
        'type': 'register',
        'userId': userId,
      }));

      print('🔌 WebSocket connected');
    } catch (e) {
      print('❌ WebSocket error: $e');
    }
  }

  // ─── Start Location Updates ──────────────────────────────
  static void _startLocationUpdates(Position initialPosition) {
    _locationSubscription = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10, // Update every 10 meters
      ),
    ).listen((Position position) async {
      if (!_isSharing || _currentSessionId == null) return;

      // Send via WebSocket
      if (_channel != null) {
        _channel!.sink.add(jsonEncode({
          'type': 'location_update',
          'userId': await _getUserId(),
          'latitude': position.latitude,
          'longitude': position.longitude,
          'sessionId': _currentSessionId,
        }));
      }

      print('📍 Location updated: ${position.latitude}, ${position.longitude}');
    });
  }

  // ─── Get Current Position ────────────────────────────────
  static Future<Position?> _getCurrentPosition() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return null;

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return null;
      }

      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );
    } catch (e) {
      return null;
    }
  }

  // ─── Get User ID ─────────────────────────────────────────
  static Future<String?> _getUserId() async {
    const storage = FlutterSecureStorage();
    return await storage.read(key: 'user_id');
  }
}