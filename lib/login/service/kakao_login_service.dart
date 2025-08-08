import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';

class KakaoLoginService {
  Future<OAuthToken?> login() async {
    try {
      // 실제 카카오 로그인은 주석 처리
      /*
      OAuthToken token;
      if (await isKakaoTalkInstalled()) {
        token = await UserApi.instance.loginWithKakaoTalk();
      } else {
        token = await UserApi.instance.loginWithKakaoAccount();
      }
      return token;
      */
      
      // 임시 가짜 토큰 생성
      await Future.delayed(Duration(milliseconds: 500)); // 로그인 시뮬레이션
      
      // OAuthToken의 올바른 생성자 형식 사용
      final expiresAt = DateTime.now().add(Duration(seconds: 3600));
      return OAuthToken(
        "fake_access_token_12345",  // accessToken (positional)
        expiresAt,                  // expiresAt (positional)  
        "fake_refresh_token_67890", // refreshToken (positional)
        DateTime.now().add(Duration(days: 30)), // refreshTokenExpiresAt (positional)
        ["profile_nickname", "profile_image", "account_email"] // scope (positional)
      );
    } catch (e) {
      print('카카오 로그인 실패: $e');
      return null;
    }
  }
}
