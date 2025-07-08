import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:logto_dart_sdk/logto_dart_sdk.dart';
import 'package:http/http.dart' as http;

class AuthProvider extends ChangeNotifier {
  late final LogtoClient _logto;
  bool _isAuthenticated = false;
  String? _userName;

  static final LogtoConfig _logtoConfig = LogtoConfig(
    endpoint: dotenv.env['LOGTO_ENDPOINT']!,
    appId: dotenv.env['LOGTO_CLIENT_ID']!,
    // Optionally: scopes, resources
  );

  AuthProvider() {
    _logto = LogtoClient(
      config: _logtoConfig,
      httpClient: http.Client(),
    );
    _checkAuth();
  }

  bool get isAuthenticated => _isAuthenticated;
  String? get userName => _userName;

  Future<void> _checkAuth() async {
    _isAuthenticated = await _logto.isAuthenticated;
    if (_isAuthenticated) {
      final claims = await _logto.idTokenClaims;
      _userName = claims?.name ?? claims?.username;
    } else {
      _userName = null;
    }
    notifyListeners();
  }

  Future<void> signIn() async {
    final redirectUri = dotenv.env['LOGTO_REDIRECT_URI']!;
    await _logto.signIn(redirectUri);
    await _checkAuth();
  }

  Future<void> signOut() async {
    final redirectUri = dotenv.env['LOGTO_REDIRECT_URI']!;
    await _logto.signOut(redirectUri);
    _isAuthenticated = false;
    _userName = null;
    notifyListeners();
  }
}
