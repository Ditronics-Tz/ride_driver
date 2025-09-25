import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants.dart';

class TokenStorage {
  TokenStorage._();
  static final TokenStorage instance = TokenStorage._();

  static const _secure = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );

  Future<void> saveTokens({
    required String access,
    required String refresh,
  }) async {
    await _secure.write(key: StorageKeys.accessToken, value: access);
    await _secure.write(key: StorageKeys.refreshToken, value: refresh);
  }

  Future<String?> get accessToken async {
    final token = await _secure.read(key: StorageKeys.accessToken);
    if (token != null) return token;

    // Legacy migration: fallback to shared preferences once
    final prefs = await SharedPreferences.getInstance();
    final legacy = prefs.getString(StorageKeys.accessToken);
    if (legacy != null) {
      await _secure.write(key: StorageKeys.accessToken, value: legacy);
      await prefs.remove(StorageKeys.accessToken);
    }
    return legacy;
  }

  Future<String?> get refreshToken async {
    final token = await _secure.read(key: StorageKeys.refreshToken);
    if (token != null) return token;

    final prefs = await SharedPreferences.getInstance();
    final legacy = prefs.getString(StorageKeys.refreshToken);
    if (legacy != null) {
      await _secure.write(key: StorageKeys.refreshToken, value: legacy);
      await prefs.remove(StorageKeys.refreshToken);
    }
    return legacy;
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(StorageKeys.accessToken);
    await prefs.remove(StorageKeys.refreshToken);
    await prefs.remove(StorageKeys.user);
    await _secure.delete(key: StorageKeys.accessToken);
    await _secure.delete(key: StorageKeys.refreshToken);
  }

  Future<void> saveUserJson(Map<String, dynamic> user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(StorageKeys.user, jsonEncode(user));
  }

  Future<Map<String, dynamic>?> get user async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(StorageKeys.user);
    if (raw == null) return null;
    try {
      return jsonDecode(raw) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }
}