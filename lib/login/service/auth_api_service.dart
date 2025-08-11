import 'package:dio/dio.dart';
import '../models/auth_response.dart';

class AuthApiService {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: 'http://10.0.2.2:3000',
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
  ));

  // 로그아웃
  Future<void> logout(String accessToken) async {
    try {
      await _dio.post('/auth/logout', 
        options: Options(
          headers: {'Authorization': 'Bearer $accessToken'},
        ),
      );
    } catch (e) {
      print('❌ 로그아웃 API 호출 실패: $e');
      rethrow;
    }
  }

  // 유저 프로필 초기 셋팅
  Future<Map<String, dynamic>> setUserProfile({
    required String accessToken,
    required String userId,
    required String nickname,
    required String birthDate,
    required String sex,
  }) async {
    try {
      print('🔍 API 요청 정보:');
      print('  - URL: /users/$userId/settings');
      print('  - Access Token: $accessToken'); // 전체 토큰 값 표시
      print('  - User ID: $userId');
      print('  - Nickname: $nickname');
      print('  - Birth Date: $birthDate');
      print('  - Sex: $sex');

      // FormData 생성
      final formData = FormData.fromMap({
        'nickname': nickname,
        'birthDate': birthDate,
        'sex': sex,
      });

      print('🔍 FormData 생성 완료');

      final response = await _dio.post(
        '/users/$userId/settings',
        data: formData,
        options: Options(
          headers: {
            'Authorization': 'Bearer $accessToken', // Authorization 헤더 추가
            'Content-Type': 'application/json',
          },
          validateStatus: (status) {
            print('🔍 응답 상태 코드: $status');
            return status! < 500; // 500 이상만 에러로 처리
          },
        ),
      );

      print('✅ 유저 프로필 초기 셋팅 성공: ${response.data}');
      return response.data;
    } catch (e) {
      print('❌ 유저 프로필 초기 셋팅 API 호출 실패: $e');
      
      // DioException인 경우 더 자세한 정보 출력
      if (e is DioException) {
        print('🔍 DioException 상세 정보:');
        print('  - Type: ${e.type}');
        print('  - Message: ${e.message}');
        print('  - Response: ${e.response?.data}');
        print('  - Status Code: ${e.response?.statusCode}');
        print('  - Headers: ${e.response?.headers}');
        
        // HTTP 상태 코드별 에러 메시지 개선
        if (e.response?.statusCode == 404) {
          throw Exception('사용자 ID $userId가 백엔드에 존재하지 않습니다. 카카오 로그인을 다시 시도해주세요.');
        } else if (e.response?.statusCode == 401) {
          throw Exception('인증이 만료되었습니다. 다시 로그인해주세요.');
        } else if (e.response?.statusCode == 403) {
          throw Exception('권한이 없습니다. 관리자에게 문의해주세요.');
        }
      }
      
      rethrow;
    }
  }

  // 토큰 갱신
  Future<AuthResponse> refreshToken(String refreshToken) async {
    try {
      final response = await _dio.post(
        '/auth/refresh',
        data: {'refreshToken': refreshToken},
      );

      if (response.statusCode == 200 && response.data != null) {
        return _processAuthResponse(response.data);
      } else {
        throw Exception('토큰 갱신 실패: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ 토큰 갱신 실패: $e');
      rethrow;
    }
  }

  // 사용자 정보 조회 (백엔드에 해당 엔드포인트가 없는 경우 주석 처리)
  // Future<Map<String, dynamic>> getUserInfo(String token) async {
  //   try {
  //     final response = await _dio.get(
  //       '/auth/me',
  //       options: Options(
  //         headers: {'Authorization': 'Bearer $token'},
  //       ),
  //     );

  //     if (response.statusCode == 200 && response.data != null) {
  //       print('✅ 사용자 정보 조회 성공: ${response.data}');
  //       return response.data;
  //     } else {
  //       throw Exception('사용자 정보 조회 실패: ${response.statusCode}');
  //       }
  //   } catch (e) {
  //     print('❌ 사용자 정보 조회 실패: $e');
  //     rethrow;
  //   }
  // }

  // 응답 데이터 처리
  AuthResponse _processAuthResponse(Map<String, dynamic> data) {
    final accessToken = data['token'] ?? data['accessToken'] ?? data['access_token'];
    final refreshToken = data['refreshToken'] ?? data['refreshToken'] ?? data['refresh_token'];

    if (accessToken != null && refreshToken != null) {
      return AuthResponse(
        accessToken: accessToken,
        refreshToken: refreshToken,
        user: null, // 사용자 정보는 별도로 처리
      );
    } else {
      throw Exception('토큰 정보가 올바르지 않습니다');
    }
  }
}
