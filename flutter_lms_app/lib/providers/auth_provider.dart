import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthProvider with ChangeNotifier {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  String? _token;

  String? get token => _token;

  bool get isAuthenticated => _token != null;

  Future<void> login(String email, String password) async {
    // Implement login logic with Dio
    // For now, placeholder
    _token = 'dummy_token';
    await _storage.write(key: 'token', value: _token);
    notifyListeners();
  }

  Future<void> register(String name, String email, String password) async {
    // Implement register logic
    notifyListeners();
  }

  Future<void> googleLogin() async {
    // Implement Google login
    notifyListeners();
  }

  Future<void> logout() async {
    _token = null;
    await _storage.delete(key: 'token');
    notifyListeners();
  }

  Future<void> loadToken() async {
    _token = await _storage.read(key: 'token');
    notifyListeners();
  }
}