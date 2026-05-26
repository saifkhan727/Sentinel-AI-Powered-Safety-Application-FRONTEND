import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// ─── User Model ───────────────────────────────────────────
class UserModel {
  final String id;
  final String name;
  final String phone;
  final String? profilePhotoUrl;

  UserModel({
    required this.id,
    required this.name,
    required this.phone,
    this.profilePhotoUrl,
  });
}

// ─── User Notifier ────────────────────────────────────────
class UserNotifier extends StateNotifier<UserModel?> {
  UserNotifier() : super(null);

  static const _storage = FlutterSecureStorage();

  // Save user data to storage and state
  Future<void> setUser(UserModel user) async {
    await _storage.write(key: 'user_name', value: user.name);
    await _storage.write(key: 'user_phone', value: user.phone);
    await _storage.write(key: 'user_id', value: user.id);
    state = user;
  }

  // Load user from storage into state
  Future<void> loadUser() async {
    try {
      final name = await _storage.read(key: 'user_name');
      final phone = await _storage.read(key: 'user_phone');
      final id = await _storage.read(key: 'user_id');

      print('📦 Loading user — name: $name, phone: $phone, id: $id');

      if (name != null && name.isNotEmpty &&
          phone != null && id != null) {
        state = UserModel(
          id: id,
          name: name,
          phone: phone,
        );
        print('✅ User loaded: $name');
      } else {
        print('❌ No user data found in storage');
      }
    } catch (e) {
      print('❌ Error loading user: $e');
    }
  }

  // Clear user on logout
  Future<void> clearUser() async {
    await _storage.deleteAll();
    state = null;
  }
}

// ─── Provider ─────────────────────────────────────────────
final userProvider = StateNotifierProvider<UserNotifier, UserModel?>(
      (ref) => UserNotifier(),
);