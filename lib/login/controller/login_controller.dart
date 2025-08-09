import 'package:flutter/material.dart';
import '../service/kakao_login_service.dart';
import '../models/auth_response.dart';

class LoginController extends ChangeNotifier {
  bool _isLoading = false;
  User? _user;
  String? _accessToken;

  bool get isLoading => _isLoading;
  User? get user => _user;
  String? get accessToken => _accessToken;
  bool get isLoggedIn => _accessToken != null;

  // 앱 시작 시 로그인 상태 확인
  Future<void> checkLoginStatus() async {
    _isLoading = true;
    notifyListeners();

    try {
      _accessToken = await KakaoLoginService.getAccessToken();
      _user = await KakaoLoginService.getUserInfo();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 카카오 로그인 (실제 API 연결)
  Future<bool> kakaoLogin(BuildContext context) async {
    _isLoading = true;
    notifyListeners();

    try {
      final success = await KakaoLoginService.login(context);
      if (success) {
        _accessToken = await KakaoLoginService.getAccessToken();
        _user = await KakaoLoginService.getUserInfo();
        return true;
      }
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 임시 로그인 (개발용)
  Future<bool> loginWithKakao() async {
    _isLoading = true;
    notifyListeners();

    try {
      final success = await KakaoLoginService.loginTemp();
      if (success) {
        _accessToken = await KakaoLoginService.getAccessToken();
        _user = await KakaoLoginService.getUserInfo();
        return true;
      }
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 로그아웃
  Future<void> logout() async {
    await KakaoLoginService.logout();
    _accessToken = null;
    _user = null;
    notifyListeners();
  }
}