import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenManager {
  static final _storage = FlutterSecureStorage();
  static const String _kTokenKey = "auth_token";
  static const String _kUserRoleKey = "user_role";

  /// Save token and role
  static Future<void> saveToken(String token, String role) async {
    await _storage.write(key: _kTokenKey, value: token);
    await _storage.write(key: _kUserRoleKey, value: role);
  }

  /// Get token
  static Future<String?> getToken() async {
    return await _storage.read(key: _kTokenKey);
  }

  /// Get user role
  static Future<String?> getUserRole() async {
    return await _storage.read(key: _kUserRoleKey);
  }

  /// Check if user is logged in
  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null;
  }

  /// Clear token and role (logout)
  static Future<void> clearToken() async {
    await _storage.delete(key: _kTokenKey);
    await _storage.delete(key: _kUserRoleKey);
  }
}
