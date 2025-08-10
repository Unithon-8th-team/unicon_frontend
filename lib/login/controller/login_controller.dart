import 'package:flutter/material.dart';
import '../service/kakao_login_service.dart';
import '../service/auth_api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginController extends ChangeNotifier {
  bool _isLoading = false;
  bool _isInitialized = false; // 초기화되지 않은 상태로 시작
  String? _accessToken;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  bool get isInitialized => _isInitialized;
  bool get isLoggedIn => _accessToken != null;
  String? get accessToken => _accessToken;
  String? get errorMessage => _errorMessage;

  final KakaoLoginService _kakaoService = KakaoLoginService();
  final AuthApiService _authService = AuthApiService();

  // 초기화 및 로그인 상태 확인
  Future<void> checkLoginStatus() async {
    if (_isInitialized) return;
    try {
      print('🔄 로그인 상태 확인 시작');

      // 🚨 개발 모드: 토큰 무시하고 항상 로그인되지 않은 상태로 시작
      // TODO: 프로덕션 배포 시 아래 주석을 해제하고 실제 토큰 확인 로직 사용
      // _accessToken = await _kakaoService.getAccessToken();
      // if (_accessToken != null) {
      //   print('✅ 저장된 토큰 발견');
      // } else {
      //   print('ℹ️ 저장된 토큰 없음');
      // }
      
      // 개발 중에는 항상 토큰이 없는 상태로 시작
      _accessToken = null;
      print('🔧 개발 모드: 토큰 무시하고 로그인 화면부터 시작');

      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      print('❌ 로그인 상태 확인 실패: $e');
      _errorMessage = '로그인 상태 확인에 실패했습니다: $e';
      _isInitialized = true;
      notifyListeners();
    }
  }

  // 카카오 로그인
  Future<bool> kakaoLogin(BuildContext context) async {
    if (_isLoading) return false;

    _setLoading(true);
    _clearError();

    try {
      print('🔄 카카오 로그인 시작');

      // KakaoLoginService에서 로그인 수행 (LoginController 인스턴스 전달)
      final ok = await _kakaoService.login(context, this);
      if (ok) {
        await updateLoginState();
        if (_accessToken != null) return true;
        _errorMessage = '토큰 저장/조회에 실패했습니다.'; 
        notifyListeners(); 
        return false;
      }
      _errorMessage = '카카오 로그인에 실패했습니다.'; 
      notifyListeners(); 
      return false;
    } catch (e) {
      print('❌ 카카오 로그인 중 오류: $e');
      _errorMessage = '로그인 중 오류가 발생했습니다: $e';
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // 로그인 상태 업데이트
  Future<void> updateLoginState() async {
    try {
      _accessToken = await _kakaoService.getAccessToken();
      
      if (_accessToken != null) {
        print('✅ 로그인 상태 업데이트 완료');
      } else {
        print('⚠️ 로그인 상태 업데이트 실패: 토큰이 없습니다');
      }
      
      notifyListeners();
    } catch (e) {
      print('❌ 로그인 상태 업데이트 실패: $e');
    }
  }

  // 토큰으로 직접 로그인 상태 업데이트
  Future<void> updateLoginStateWithTokens(String accessToken, String refreshToken) async {
    try {
      print('🔄 LoginController: 토큰으로 로그인 상태 업데이트 시작');
      print('  - 이전 토큰: ${_accessToken?.substring(0, 20) ?? '없음'}...');
      print('  - 새 토큰: ${accessToken.substring(0, 20)}...');
      
      _accessToken = accessToken;
      
      print('✅ LoginController: 토큰으로 로그인 상태 업데이트 완료');
      print('  - 현재 토큰: ${_accessToken?.substring(0, 20) ?? '없음'}...');
      print('  - isLoggedIn: $isLoggedIn');
      print('  - notifyListeners() 호출 예정...');
      
      // 상태 변화를 즉시 알림
      notifyListeners();
      
      print('✅ LoginController: notifyListeners() 호출 완료');
      
      // 추가로 상태 변화 확인 및 강제 리빌드
      await Future.delayed(const Duration(milliseconds: 100));
      print('🔍 상태 변화 후 확인: isLoggedIn = $isLoggedIn');
      
      // 상태가 제대로 변경되었는지 한 번 더 확인하고 필요시 재알림
      if (isLoggedIn) {
        print('✅ 로그인 상태 확인됨, 추가 알림 전송');
        notifyListeners();
      }
      
    } catch (e) {
      print('❌ LoginController: 토큰으로 로그인 상태 업데이트 실패: $e');
    }
  }

  // 로그아웃
  Future<void> logout() async {
    if (_isLoading) return;
    
    _setLoading(true);
    
    try {
      print('🔄 로그아웃 시작');
      
      // 백엔드 로그아웃 시도
      if (_accessToken != null) {
        try {
          await _authService.logout(_accessToken!);
          print('✅ 백엔드 로그아웃 완료');
        } catch (e) {
          print('⚠️ 백엔드 로그아웃 실패: $e');
        }
      }
      
      // 로컬 로그아웃
      await _kakaoService.logout();
      
      // 로컬 상태 초기화
      _accessToken = null;
      
      print('✅ 로그아웃 완료');
      notifyListeners();
      
    } catch (e) {
      print('❌ 로그아웃 중 오류: $e');
      _errorMessage = '로그아웃 중 오류가 발생했습니다: $e';
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  // 에러 메시지 초기화
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // 로딩 상태 설정
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // 에러 메시지 초기화 (내부용)
  void _clearError() {
    _errorMessage = null;
  }

  // 디버그 정보 출력
  Future<void> debugPrintInfo() async {
    print('🔍 LoginController 디버그 정보:');
    print('  - 로딩 중: $_isLoading');
    print('  - 초기화됨: $_isInitialized');
    print('  - 로그인됨: $isLoggedIn');
    print('  - 토큰: ${_accessToken?.substring(0, 20) ?? '없음'}...');
  }

  // 초기 설정 완료 여부 확인
  Future<bool> isFirstSetupCompleted() async {
    try {
      // 🚨 개발 모드: 초기 설정 완료 여부 무시하고 항상 false 반환
      // TODO: 프로덕션 배포 시 아래 주석을 해제하고 실제 설정 확인 로직 사용
      // final prefs = await SharedPreferences.getInstance();
      // return prefs.getBool('first_setup_completed') ?? false;
      
      // 개발 중에는 항상 초기 설정이 완료되지 않은 상태로 시작
      print('🔧 개발 모드: 초기 설정 완료 여부 무시하고 FirstSettingScreen 표시');
      return false;
    } catch (e) {
      print('❌ 초기 설정 완료 여부 확인 실패: $e');
      return false;
    }
  }
}