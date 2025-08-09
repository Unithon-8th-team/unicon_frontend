class ChatService {
  // 자동 답장 메시지 목록
  static const List<String> _autoReplies = [
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
    '아 진짜 그런 놈들은 왜 그럴까?',
    '완전 공감해! 나도 화가 나네!',
    '그 상황에서 참은 거 대단해! 화내도 돼!',
    '정말 이해 안 되는 행동이네! 계속 말해봐!',
    '그런 일 겪으면 스트레스 엄청 받겠다!',
  ];

  // 메시지에 대한 자동 답장 생성
  static Future<String> getAutoReply(String userMessage, int messageCount) async {
    // 실제 API 호출을 시뮬레이션하기 위한 지연
    int delayMs = 1000 + (messageCount % 3) * 500;
    await Future.delayed(Duration(milliseconds: delayMs));
    
    // 사용자 메시지에 따른 간단한 키워드 기반 응답
    String lowerMessage = userMessage.toLowerCase();
    
    if (lowerMessage.contains('화나') || lowerMessage.contains('짜증') || lowerMessage.contains('빡쳐')) {
      return _getRandomReply([
        '그래! 화내자! 무슨 일이야?',
        '정말 짜증나겠다! 다 털어놔!',
        '와 진짜 빡치겠네! 어떻게 된 거야?',
      ]);
    } else if (lowerMessage.contains('직장') || lowerMessage.contains('회사') || lowerMessage.contains('상사')) {
      return _getRandomReply([
        '직장 스트레스 진짜 힘들지! 어떤 일이야?',
        '회사에서 무슨 일 있었어? 말해봐!',
        '상사 때문에 고생하는구나! 정말 속상하겠다!',
      ]);
    } else if (lowerMessage.contains('친구') || lowerMessage.contains('사람')) {
      return _getRandomReply([
        '사람 관계가 제일 어려워! 어떤 상황이야?',
        '친구 때문에 힘든 일 있었구나! 말해봐!',
        '그런 사람들 진짜 이해 안 돼! 계속 털어놔!',
      ]);
    } else if (lowerMessage.contains('슬프') || lowerMessage.contains('우울')) {
      return _getRandomReply([
        '많이 속상했구나... 화내도 괜찮아!',
        '슬플 때는 화내는 것도 방법이야! 어떤 일이야?',
        '우울할 때 나한테 화내도 돼! 들어줄게!',
      ]);
    } else {
      // 기본 응답에서 랜덤 선택
      return _autoReplies[messageCount % _autoReplies.length];
    }
  }

  // 주어진 리스트에서 랜덤 응답 선택
  static String _getRandomReply(List<String> replies) {
    return replies[DateTime.now().millisecondsSinceEpoch % replies.length];
  }
}
