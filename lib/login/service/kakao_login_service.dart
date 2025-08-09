import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart' hide User;
import 'auth_api_service.dart';
import '../models/auth_response.dart';

class KakaoLoginService {
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userIdKey = 'user_id';
  static const String _userEmailKey = 'user_email';
  static const String _userNicknameKey = 'user_nickname';
  static const String _userCoinKey = 'user_coin';

  static final AuthApiService _authService = AuthApiService();

  // 카카오 SDK를 사용한 실제 로그인
  static Future<bool> login(BuildContext context) async {
    print('=== 카카오 SDK 로그인 시작 ===');
    try {
      // 1. 카카오 SDK로 로그인
      OAuthToken token;
      if (await isKakaoTalkInstalled()) {
        print('📱 카카오톡으로 로그인 시도');
        token = await UserApi.instance.loginWithKakaoTalk();
      } else {
        print('🌐 카카오 계정으로 로그인 시도');
        token = await UserApi.instance.loginWithKakaoAccount();
      }

      print('✅ 카카오 로그인 성공! 액세스 토큰: ${token.accessToken.substring(0, 20)}...');

      // 2. 카카오 사용자 정보 가져오기
      final kakaoUser = await UserApi.instance.me();
      print('👤 카카오 사용자 정보: ${kakaoUser.kakaoAccount?.profile?.nickname}');

      // 3. 백엔드에 카카오 토큰 전송하여 JWT 받기
      print('🔄 백엔드에 카카오 토큰 전송 중...');
      final authResponse = await _authService.verifyKakaoToken(token.accessToken);
      
      // 4. 받은 JWT와 사용자 정보 저장
      await _saveUserData(authResponse);
      print('✅ 실제 로그인 완료! 사용자: ${authResponse.user.nickname}');
      return true;

    } catch (error) {
      print('❌ 카카오 SDK 로그인 실패: $error');
      print('🔄 임시 로그인으로 폴백');
      final tempResult = await loginTemp();
      print('📱 임시 로그인 결과: $tempResult');
      return tempResult;
    }
  }

  // 사용자 데이터 저장
  static Future<void> _saveUserData(AuthResponse authResponse) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_accessTokenKey, authResponse.accessToken);
    await prefs.setString(_refreshTokenKey, authResponse.refreshToken);
    await prefs.setString(_userIdKey, authResponse.user.id);
    await prefs.setString(_userEmailKey, authResponse.user.email);
    await prefs.setString(_userNicknameKey, authResponse.user.nickname);
    await prefs.setInt(_userCoinKey, authResponse.user.coin);
  }

  // 저장된 액세스 토큰 가져오기
  static Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_accessTokenKey);
  }

  // 저장된 사용자 정보 가져오기
  static Future<User?> getUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getString(_userIdKey);
    final email = prefs.getString(_userEmailKey);
    final nickname = prefs.getString(_userNicknameKey);
    final coin = prefs.getInt(_userCoinKey);

    if (id != null && email != null && nickname != null && coin != null) {
      return User(
        id: id,
        email: email,
        nickname: nickname,
        coin: coin,
        dailyConversationCount: 0, // 기본값
      );
    }
    return null;
  }

  // 로그인 상태 확인
  static Future<bool> isLoggedIn() async {
    final token = await getAccessToken();
    return token != null;
  }

  // 로그아웃
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    print('로그아웃 성공');
  }

  // 임시 개발용 로그인 (실제 API 연결 전 테스트용)
  static Future<bool> loginTemp() async {
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      
      // 임시 사용자 데이터 생성
      final tempAuthResponse = AuthResponse(
        accessToken: 'temp_access_token_12345',
        refreshToken: 'temp_refresh_token_67890',
        user: User(
          id: 'temp_user_123',
          email: 'test@example.com',
          nickname: '테스트유저',
          coin: 30,
          dailyConversationCount: 0,
        ),
      );
      
      await _saveUserData(tempAuthResponse);
      return true;
    } catch (e) {
      print('임시 로그인 실패: $e');
      return false;
    }
  }
}