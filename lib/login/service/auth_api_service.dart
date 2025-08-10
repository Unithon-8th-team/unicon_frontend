import 'package:dio/dio.dart';
import '../models/auth_response.dart';

class AuthApiService {
  static const String _baseUrl = 'http://10.0.2.2:3000';
  late final Dio _dio;

  AuthApiService() {
    _dio = Dio(BaseOptions(
      baseUrl: _baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ));
  }

  // 로그아웃
  Future<void> logout(String token) async {
    try {
      await _dio.post(
        '/auth/logout',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );
      print('✅ 로그아웃 성공');
    } catch (e) {
      print('❌ 로그아웃 실패: $e');
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
