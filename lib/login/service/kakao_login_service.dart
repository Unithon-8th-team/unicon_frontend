import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:dio/dio.dart';
import '../controller/login_controller.dart';
import '../view/oauth_webview_screen.dart';

class KakaoLoginService {
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userIdKey = 'user_id';
  static const String _userEmailKey = 'user_email';
  static const String _userNicknameKey = 'user_nickname';
  static const String _userCoinKey = 'user_coin';
  static const String _userDailyConversationCountKey = 'user_daily_conversation_count';
  static const String _tokenExpiryKey = 'token_expiry';
  
  final Dio _dio = Dio(BaseOptions(
    baseUrl: 'http://10.0.2.2:3000',
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
  ));

  // 변경 전: Future<void> login(BuildContext context) async
  Future<bool> login(BuildContext context, LoginController loginController) async {
    try {
      print('=== 백엔드 API 기반 카카오 OAuth 로그인 시작 ===');

      final result = await Navigator.push<bool>(
        context,
        MaterialPageRoute(
          builder: (context) => OAuthWebViewScreen(
            initialUrl: 'http://10.0.2.2:3000/auth/kakao',
            onSuccess: (accessToken, refreshToken) async {
              print('🎉 OAuth 성공! 토큰: ${accessToken.substring(0, 20)}...');
              await _saveUserData(accessToken, refreshToken);

              // LoginController를 직접 사용하여 로그인 상태 업데이트
              await loginController.updateLoginStateWithTokens(accessToken, refreshToken);
              
              print('✅ 로그인 상태 업데이트 완료');
              
              // 단, pop은 여기서 수행
              Navigator.pop(context, true);
            },
            onFailure: (String errorMessage) {
              print('❌ OAuth 실패: $errorMessage');
              Navigator.pop(context, false);
            },
          ),
        ),
      );

      if (result == true) {
        print('✅ 웹뷰 OAuth 로그인 완료!');
        return true;
      }
      return false;
    } catch (e) {
      print('❌ 카카오 로그인 실패: $e');
      return false;
    }
  }
  // 백엔드에서 받은 토큰으로 사용자 데이터 저장
  Future<void> _saveUserData(String accessToken, String refreshToken) async {
    try {
      print('🔄 백엔드 토큰으로 사용자 데이터 저장 시작');
      
      // 백엔드에서 이미 토큰을 반환했으므로, 그대로 저장
      final prefs = await SharedPreferences.getInstance();
      
      // 백엔드 토큰 저장
      await prefs.setString(_accessTokenKey, accessToken);
      await prefs.setString(_refreshTokenKey, refreshToken);
      
      // 기본 사용자 정보 설정 (백엔드에서 사용자 정보를 별도로 제공하지 않음)
      await prefs.setString(_userIdKey, 'kakao_user');
      await prefs.setString(_userEmailKey, 'kakao@email.com');
      await prefs.setString(_userNicknameKey, '카카오 사용자');
      await prefs.setInt(_userCoinKey, 0);
      await prefs.setInt(_userDailyConversationCountKey, 0);
      
      // 토큰 만료 시간 설정 (기본 24시간)
      final expiryTime = DateTime.now().add(const Duration(hours: 24));
      await prefs.setString(_tokenExpiryKey, expiryTime.toIso8601String());
      
      print('💾 백엔드 토큰으로 사용자 데이터 저장 완료');
    } catch (e) {
      print('❌ 사용자 데이터 저장 실패: $e');
    }
  }

  // 저장된 토큰 가져오기
  Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_accessTokenKey);
  }

  // 로그아웃
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    print('✅ 로그아웃 완료');
  }
}