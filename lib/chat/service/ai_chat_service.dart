import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../config/api_config.dart';

class AiChatService {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: ApiConfig.baseUrl,
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 30),
  ));

  // AI 채팅 요청
  Future<Map<String, dynamic>> sendMessage({
    required String message,
    required int userAnger,
    required int aiAnger,
  }) async {
    try {
      print('🤖 AI 채팅 요청: $message (사용자 분노: $userAnger, AI 분노: $aiAnger)');
      print('🌐 요청 URL: ${ApiConfig.baseUrl}${ApiConfig.aiChat}');
      
      // 액세스 토큰 가져오기
      final accessToken = await _getAccessToken();
      if (accessToken == null) {
        throw Exception('액세스 토큰이 없습니다. 로그인이 필요합니다.');
      }

      print('🔑 액세스 토큰: ${accessToken.substring(0, 20)}...');

      final response = await _dio.post(
        ApiConfig.aiChat,
        data: {
          'message': message,
          'userAnger': userAnger,
          'aiAnger': aiAnger,
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $accessToken',
            'Content-Type': 'application/json',
          },
        ),
      );

      print('✅ AI 채팅 응답 성공: ${response.data}');
      return response.data;
    } on DioException catch (e) {
      print('❌ AI 채팅 API 오류: ${e.message}');
      
      if (e.response?.statusCode == 429) {
        // 무료 횟수 초과
        return {
          'error': 'FREE_CHAT_LIMIT_EXCEEDED',
          'message': '오늘의 무료 대화 횟수를 모두 사용했습니다. 코인을 사용하거나 구매해주세요.',
        };
      } else if (e.response?.statusCode == 401) {
        throw Exception('인증이 만료되었습니다. 다시 로그인해주세요.');
      } else {
        throw Exception('AI 채팅 서비스에 문제가 발생했습니다: ${e.message}');
      }
    } catch (e) {
      print('❌ AI 채팅 서비스 오류: $e');
      throw Exception('AI 채팅 서비스에 문제가 발생했습니다: $e');
    }
  }

  // 이미지 생성 요청
  Future<List<String>> generateImage(String description) async {
    try {
      print('🎨 이미지 생성 요청: $description');
      
      // 액세스 토큰 가져오기
      final accessToken = await _getAccessToken();
      if (accessToken == null) {
        throw Exception('액세스 토큰이 없습니다. 로그인이 필요합니다.');
      }

      final response = await _dio.post(
        ApiConfig.aiGenerateImage,
        data: {
          'description': description,
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $accessToken',
            'Content-Type': 'application/json',
          },
        ),
      );

      print('✅ 이미지 생성 성공: ${response.data}');
      final List<dynamic> imageUrls = response.data['imageUrls'];
      return imageUrls.cast<String>();
    } on DioException catch (e) {
      print('❌ 이미지 생성 API 오류: ${e.message}');
      throw Exception('이미지 생성에 실패했습니다: ${e.message}');
    } catch (e) {
      print('❌ 이미지 생성 서비스 오류: $e');
      throw Exception('이미지 생성에 실패했습니다: $e');
    }
  }

  // 액세스 토큰 가져오기
  Future<String?> _getAccessToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('access_token');
    } catch (e) {
      print('❌ 액세스 토큰 가져오기 실패: $e');
      return null;
    }
  }

  // 남은 무료 대화 횟수 확인 (응답에서 추출)
  int getRemainingFreeChats(Map<String, dynamic> response) {
    return response['remainingFreeChats'] ?? 0;
  }

  // 에러 응답인지 확인
  bool isErrorResponse(Map<String, dynamic> response) {
    return response.containsKey('error');
  }
}
