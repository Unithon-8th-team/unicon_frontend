import 'package:flutter/material.dart';
import '../service/chat_service.dart';
import 'chat_initial_screen.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with TickerProviderStateMixin {
  final TextEditingController _messageController = TextEditingController();
  List<Map<String, dynamic>> _messages = [];
  bool _isAiTyping = false; // AI가 답장하고 있는지 여부
  late AnimationController _typingAnimationController;
  final ChatService _chatService = ChatService();
  
  // 오늘 날짜를 한국어 형식으로 가져오기
  String get todayDate {
    final now = DateTime.now();
    return '${now.year}년 ${now.month}월 ${now.day}일';
  }
  
  @override
  void initState() {
    super.initState();
    // 빈 메시지 리스트로 시작
    _messages = [];
    
    // 타이핑 애니메이션 컨트롤러 초기화
    _typingAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
  }

  void _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    String userMessage = _messageController.text.trim();
    
    setState(() {
      // 사용자 메시지 추가
      _messages.add({
        'message': userMessage,
        'isUser': true,
        'hasProfileImage': false,
        'timestamp': DateTime.now(),
      });
      // AI가 타이핑 중임을 표시
      _isAiTyping = true;
    });

    _messageController.clear();

    // AI 채팅 서비스로 메시지 전송
    try {
      final response = await _chatService.sendMessage(
        message: userMessage,
        userAnger: 3, // 기본값, 나중에 사용자 설정에서 가져올 수 있음
        aiAnger: 3,  // 기본값, 나중에 AI 설정에서 가져올 수 있음
      );
      
      if (mounted) {
        setState(() {
          String aiReply;
          
          // 에러 응답인지 확인
          if (_chatService.isErrorResponse(response)) {
            aiReply = response['fallbackReply'] ?? '죄송합니다. 응답을 생성할 수 없습니다.';
          } else {
            aiReply = response['reply'] ?? '죄송합니다. 응답을 생성할 수 없습니다.';
          }
          
          _messages.add({
            'message': aiReply,
            'isUser': false,
            'hasProfileImage': true,
            'timestamp': DateTime.now(),
          });
          // AI 타이핑 완료
          _isAiTyping = false;
        });
      }
    } catch (e) {
      print('Error getting AI reply: $e');
      if (mounted) {
        setState(() {
          _isAiTyping = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _typingAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 검은색 배경
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF000000),
                  Color(0xFF2D1B1B),
                  Color(0xFF000000),
                ],
              ),
            ),
          ),
          // 배경 불꽃 효과 (Ellipse) - 화면 전체를 채우도록 수정
          Positioned.fill(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final screenWidth = MediaQuery.of(context).size.width;
                final screenHeight = MediaQuery.of(context).size.height;
                return Stack(
                  children: [
                    // Ellipse 배경 - 화면 전체를 덮도록 수정
                    Center(
                      child: Opacity(
                        opacity: 0.8,
                        child: Image.asset(
                          'assets/images/Ellipse 202.png',
                          width: screenWidth * 2.0,
                          height: screenWidth * 2.0,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    // 중앙 큰 불꽃 - 화면 정 중앙에 배치
                    Center(
                      child: Image.asset(
                        'assets/images/fire_img.png',
                        width: screenWidth * 0.8,
                        height: screenWidth * 0.8,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          // 콘텐츠
          SafeArea(
          child: Column(
            children: [
              // 상단 바 (뒤로가기 버튼과 포인트)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // 뒤로가기 버튼
                    GestureDetector(
                      onTap: () {
                        // ChatInitialScreen으로 이동
                        Navigator.pushReplacement(
                          context,
                          PageRouteBuilder(
                            pageBuilder: (context, animation, secondaryAnimation) => const ChatInitialScreen(),
                            transitionsBuilder: (context, animation, secondaryAnimation, child) {
                              return child; // 애니메이션 없음
                            },
                          ),
                        );
                      },
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Icon(
                          Icons.arrow_back,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                    // Points display
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          Text('5', style: TextStyle(color: Colors.white, fontSize: 16)),
                          Icon(Icons.add, color: Colors.orange, size: 20),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              Expanded(
                child: ListView(
                  reverse: true, // 아래에서부터 시작해서 위로 쌓이도록 설정
                  padding: const EdgeInsets.all(16),
                  children: [
                    // AI 타이핑 인디케이터 (가장 아래 = 최신 위치)
                    if (_isAiTyping)
                      Column(
                        children: [
                          const SizedBox(height: 8),
                          _buildTypingIndicator(),
                        ],
                      ),
                    // 채팅 메시지들 (reverse되므로 순서를 뒤집어야 함)
                    ..._messages.reversed.map((messageData) {
                      return Column(
                        children: [
                          const SizedBox(height: 8),
                          _buildChatMessage(
                            messageData['message'],
                            isUser: messageData['isUser'],
                            hasProfileImage: messageData['hasProfileImage'],
                          ),
                        ],
                      );
                    }).toList(),
                    // 날짜 표시 (메시지가 있을 때만 표시)
                    if (_messages.isNotEmpty)
                      Center(
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 20),
                          child: Row(
                            children: [
                              // 왼쪽 선
                              Expanded(
                                child: Container(
                                  height: 1,
                                  color: Colors.white70,
                                ),
                              ),
                              // 날짜 텍스트
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                child: Text(
                                  todayDate,
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                              // 오른쪽 선
                              Expanded(
                                child: Container(
                                  height: 1,
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              
              // Message input
              Container(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.image, color: Colors.white70),
                      onPressed: () {
                        // Handle image upload
                      },
                    ),
                    Expanded(
                      child: TextField(
                        controller: _messageController,
                        style: const TextStyle(color: Colors.white),
                        onSubmitted: (_) => _sendMessage(),
                        decoration: InputDecoration(
                          hintText: '메시지 입력하기',
                          hintStyle: TextStyle(color: Colors.white70),
                          filled: true,
                          fillColor: Colors.black45,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.send, color: Colors.orange),
                      onPressed: _sendMessage,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        ],
      ),
    );
  }

  Widget _buildChatMessage(String message, {required bool isUser, required bool hasProfileImage}) {
    return Padding(
      padding: EdgeInsets.only(
        left: isUser ? 0 : 0,
        right: isUser ? 10 : 0, // 사용자 메시지는 오른쪽에서 10픽셀 떨어뜨림
      ),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser && hasProfileImage) ...[
            SizedBox(
              width: 36,
              height: 36,
              child: Stack(
                children: [
                  // 배경 이미지
                  Container(
                    width: 36,
                    height: 36,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        image: AssetImage('assets/images/profile_bg.png'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  // 프로필 이미지 (중앙에 배치, 4픽셀 아래로 내림)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          image: DecorationImage(
                            image: AssetImage('assets/images/profile_1.png'),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.7, // 화면 너비의 70%로 제한
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6), // 사용자와 AI 동일한 배경색
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  message,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ),
          if (!isUser) const SizedBox(width: 50),
        ],
      ),
    );
  }

  // AI 타이핑 인디케이터 위젯
  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // AI 프로필 이미지 (채팅 메시지와 동일)
          SizedBox(
            width: 36,
            height: 36,
            child: Stack(
              children: [
                // 배경 이미지
                Container(
                  width: 36,
                  height: 36,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      image: AssetImage('assets/images/propil_bg.png'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                // 프로필 이미지 (중앙에 배치)
                Center(
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        image: AssetImage('assets/images/propil_1.png'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // 타이핑 애니메이션 버블
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.6),
              borderRadius: BorderRadius.circular(12),
            ),
            child: AnimatedBuilder(
              animation: _typingAnimationController,
              builder: (context, child) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(3, (index) {
                    final delay = index * 0.33;
                    final animationValue = (_typingAnimationController.value - delay) % 1.0;
                    final opacity = animationValue < 0.5 
                        ? (animationValue * 2).clamp(0.3, 1.0)
                        : ((1.0 - animationValue) * 2).clamp(0.3, 1.0);
                    
                    return Container(
                      width: 8,
                      height: 8,
                      margin: EdgeInsets.only(right: index < 2 ? 4 : 0),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(opacity),
                        shape: BoxShape.circle,
                      ),
                    );
                  }),
                );
              },
            ),
          ),
          const SizedBox(width: 50),
        ],
      ),
    );
  }
}
