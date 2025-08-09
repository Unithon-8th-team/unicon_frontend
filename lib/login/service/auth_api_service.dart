import 'package:dio/dio.dart';
import '../models/auth_response.dart';

class AuthApiService {
  static const String baseUrl = 'http://10.0.2.2:3000'; // 안드로이드 에뮬레이터용
  late final Dio _dio;

  AuthApiService() {
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
      },
    ));
  }

  /// 카카오 로그인 API 호출
  Future<AuthResponse> kakaoLogin() async {
    try {
      final response = await _dio.get('/auth/kakao');
      
      print('🔍 서버 응답 상태: ${response.statusCode}');
      print('🔍 서버 응답 데이터: ${response.data}');
      print('🔍 응답 타입: ${response.data.runtimeType}');
      
      if (response.statusCode == 200) {
        // 서버 응답이 JSON 객체가 아닐 경우를 대비한 처리
        if (response.data is Map<String, dynamic>) {
          final data = response.data as Map<String, dynamic>;
          
          // 에러 응답 체크
          if (data.containsKey('status') && data['status'] != null && data['status'] < 0) {
            throw Exception('서버 에러: ${data['title']} (status: ${data['status']})');
          }
          
          // 성공 응답인지 확인 (accessToken이 있는지 체크)
          if (data.containsKey('accessToken')) {
            return AuthResponse.fromJson(data);
          } else {
            throw Exception('로그인 응답에 필요한 정보가 없습니다: $data');
          }
        } else {
          throw Exception('서버 응답이 JSON 형태가 아닙니다: ${response.data}');
        }
      } else {
        throw Exception('로그인 실패: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        print('🔍 DioException 응답: ${e.response?.data}');
        throw Exception('로그인 실패: ${e.response?.statusCode} - ${e.response?.data}');
      } else {
        throw Exception('네트워크 오류: ${e.message}');
      }
    } catch (e) {
      print('🔍 일반 예외: $e');
      throw Exception('알 수 없는 오류: $e');
    }
  }

  /// 카카오 토큰을 백엔드로 전송하여 JWT 받기
  Future<AuthResponse> verifyKakaoToken(String kakaoAccessToken) async {
    try {
      print('🌐 요청 URL: $baseUrl/auth/kakao/verify');
      print('📤 카카오 토큰: ${kakaoAccessToken.substring(0, 20)}...');
      
      final response = await _dio.post('/auth/kakao/verify', data: {
        'kakaoAccessToken': kakaoAccessToken,
      });
      
      print('🔍 서버 응답 상태: ${response.statusCode}');
      print('🔍 서버 응답 데이터: ${response.data}');
      
      if (response.statusCode == 200) {
        if (response.data is Map<String, dynamic>) {
          final data = response.data as Map<String, dynamic>;
          
          // 에러 응답 체크
          if (data.containsKey('status') && data['status'] != null && data['status'] < 0) {
            throw Exception('서버 에러: ${data['title']} (status: ${data['status']})');
          }
          
          // JWT 토큰이 있는지 확인
          if (data.containsKey('accessToken') || data.containsKey('token')) {
            return AuthResponse.fromJson(data);
          } else {
            throw Exception('토큰 검증 응답에 필요한 정보가 없습니다: $data');
          }
        } else {
          throw Exception('서버 응답이 JSON 형태가 아닙니다: ${response.data}');
        }
      } else {
        throw Exception('토큰 검증 실패: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        print('🔍 DioException 응답: ${e.response?.data}');
        throw Exception('토큰 검증 실패: ${e.response?.statusCode} - ${e.response?.data}');
      } else {
        throw Exception('네트워크 오류: ${e.message}');
      }
    } catch (e) {
      print('🔍 일반 예외: $e');
      throw Exception('알 수 없는 오류: $e');
    }
  }

  /// 카카오 로그인 웹뷰 URL 생성 (사용 안 함)
  String getKakaoLoginUrl() {
    return '$baseUrl/auth/kakao';
  }
}
