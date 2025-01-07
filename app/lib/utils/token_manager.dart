// lib/utils/token_manager.dart

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenManager {
  static final _storage = FlutterSecureStorage();
  static const String _kTokenKey = "auth_token";
  static const String _kUserRoleKey = "user_role";

  /// Sauvegarde le token et le rôle dans le device
  static Future<void> saveToken(String token, String role) async {
    await _storage.write(key: _kTokenKey, value: token);
    await _storage.write(key: _kUserRoleKey, value: role);
  }

  /// Récupère le token
  static Future<String?> getToken() async {
    return await _storage.read(key: _kTokenKey);
  }

  /// Récupère le rôle
  static Future<String?> getUserRole() async {
    return await _storage.read(key: _kUserRoleKey);
  }

  /// Supprime le token et le rôle (logout)
  static Future<void> clearToken() async {
    await _storage.delete(key: _kTokenKey);
    await _storage.delete(key: _kUserRoleKey);
  }
}
