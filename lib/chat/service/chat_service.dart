import 'ai_chat_service.dart';

class ChatService {
  final AiChatService _aiChatService = AiChatService();

  // AI 채팅 서비스를 통한 메시지 전송
  Future<Map<String, dynamic>> sendMessage({
    required String message,
    required int userAnger,
    required int aiAnger,
  }) async {
    try {
      print('💬 AI 채팅 서비스로 메시지 전송: $message');
      
      final response = await _aiChatService.sendMessage(
        message: message,
        userAnger: userAnger,
        aiAnger: aiAnger,
      );

      // 에러 응답인지 확인
      if (_aiChatService.isErrorResponse(response)) {
        return response; // 에러 메시지 반환
      }

      // 성공 응답 처리
      final remainingChats = _aiChatService.getRemainingFreeChats(response);
      print('✅ AI 응답 성공. 남은 무료 대화: $remainingChats회');
      
      return response;
    } catch (e) {
      print('❌ AI 채팅 실패: $e');
      // 에러 발생 시 폴백 응답 반환
      return {
        'error': 'CHAT_ERROR',
        'message': 'AI 채팅에 문제가 발생했습니다. 잠시 후 다시 시도해주세요.',
        'fallbackReply': _getFallbackReply(message),
      };
    }
  }

  // 이미지 생성 요청
  Future<List<String>> generateImage(String description) async {
    try {
      print('🎨 이미지 생성 요청: $description');
      return await _aiChatService.generateImage(description);
    } catch (e) {
      print('❌ 이미지 생성 실패: $e');
      throw Exception('이미지 생성에 실패했습니다: $e');
    }
  }

  // 폴백 응답 (API 실패 시 사용)
  String _getFallbackReply(String userMessage) {
    final List<String> fallbackReplies = [
      '그래! 화내자! 무슨 일이야?',
      '정말 짜증나겠다! 다 털어놔!',
      '그 놈들 진짜 나쁘네! 계속 말해봐!',
      '화가 나는 게 당연해! 어떤 상황이었어?',
      '완전 이해해! 그럼 어떻게 해줄까?',
      '맞아맞아! 정말 열받네!',
      '그런 상황이면 나도 화났을 거야!',
      '진짜 속상했겠다! 더 말해줘!',
      '와 진짜 빡치겠네! 어떻게 된 거야?',
      '그런 일이 있었구나! 정말 화나겠다!',
    ];

    // 사용자 메시지에 따른 간단한 키워드 기반 응답
    String lowerMessage = userMessage.toLowerCase();
    
    if (lowerMessage.contains('화나') || lowerMessage.contains('짜증') || lowerMessage.contains('빡쳐')) {
      return '그래! 화내자! 무슨 일이야?';
    } else if (lowerMessage.contains('직장') || lowerMessage.contains('회사') || lowerMessage.contains('상사')) {
      return '직장 스트레스 진짜 힘들지! 어떤 일이야?';
    } else if (lowerMessage.contains('친구') || lowerMessage.contains('사람')) {
      return '사람 관계가 제일 어려워! 어떤 상황이야?';
    } else if (lowerMessage.contains('슬프') || lowerMessage.contains('우울')) {
      return '많이 속상했구나... 화내도 괜찮아!';
    } else {
      // 기본 응답에서 랜덤 선택
      return fallbackReplies[DateTime.now().millisecondsSinceEpoch % fallbackReplies.length];
    }
  }

  // 남은 무료 대화 횟수 확인
  int getRemainingFreeChats(Map<String, dynamic> response) {
    return _aiChatService.getRemainingFreeChats(response);
  }

  // 에러 응답인지 확인
  bool isErrorResponse(Map<String, dynamic> response) {
    return _aiChatService.isErrorResponse(response);
  }
}
