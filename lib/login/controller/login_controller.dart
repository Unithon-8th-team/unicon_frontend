import 'package:flutter/material.dart';
import '../service/kakao_login_service.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';

class LoginController extends ChangeNotifier {
  final KakaoLoginService _kakaoLoginService = KakaoLoginService();
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  OAuthToken? _token;
  OAuthToken? get token => _token;

  Future<bool> loginWithKakao() async {
    _isLoading = true;
    notifyListeners();
    final result = await _kakaoLoginService.login();
    _isLoading = false;
    if (result != null) {
      _token = result;
      notifyListeners();
      return true;
    }
    notifyListeners();
    return false;
  }
}
