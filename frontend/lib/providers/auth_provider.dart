import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  String? _accessToken;
  bool _isLoading = false;

  String? get accessToken => _accessToken;
  bool get isLoading => _isLoading;

  Future<void> login() async {
    _isLoading = true;
    notifyListeners();

    final authService = AuthService(); // AuthService 인스턴스 생성
    _accessToken = await authService.login(); // 인스턴스를 통해 login 메서드 호출

    _isLoading = false;
    notifyListeners();
  }
}
