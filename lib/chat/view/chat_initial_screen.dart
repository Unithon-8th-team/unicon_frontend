import 'package:flutter/material.dart';
import 'chat_screen.dart';

class ChatInitialScreen extends StatefulWidget {
  const ChatInitialScreen({super.key});

  @override
  State<ChatInitialScreen> createState() => _ChatInitialScreenState();
}

class _ChatInitialScreenState extends State<ChatInitialScreen> {
  int _angerLevel = 2; // 화나는 정도 (0~4)
  int _expressionLevel = 2; // 화내는 정도 (0~4)
  bool _showSecondSlider = false; // 두 번째 슬라이더 표시 여부

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 배경 이미지
          Positioned.fill(
            child: Image.asset(
              'assets/images/day_background.png',
              fit: BoxFit.cover,
            ),
          ),
          // 어두운 오버레이
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.6),
            ),
          ),
          // 콘텐츠
          SafeArea(
            child: Column(
              children: [
                const Spacer(),
                
                // 설정 컨테이너
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        '지금 얼마나 화가나?',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 30),
                      // 첫 번째 토글 (화나는 정도)
                      _buildSlider(
                        value: _angerLevel,
                        onChanged: (value) {
                          setState(() {
                            _angerLevel = value;
                          });
                        },
                      ),
                      const SizedBox(height: 10),
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '매우 조금',
                            style: TextStyle(color: Colors.white70, fontSize: 12),
                          ),
                          Text(
                            '매우 많이',
                            style: TextStyle(color: Colors.white70, fontSize: 12),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                // 두 번째 토글 (화내는 정도) - 조건부 표시
                if (_showSecondSlider) ...[
                  const SizedBox(height: 20),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          '내가 얼만큼 화내줄까?',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 30),
                        _buildSlider(
                          value: _expressionLevel,
                          onChanged: (value) {
                            setState(() {
                              _expressionLevel = value;
                            });
                          },
                        ),
                        const SizedBox(height: 10),
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '매우 조금',
                              style: TextStyle(color: Colors.white70, fontSize: 12),
                            ),
                            Text(
                              '매우 많이',
                              style: TextStyle(color: Colors.white70, fontSize: 12),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
                
                const SizedBox(height: 20),
                
                // X 버튼과 선택완료 버튼
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Row(
                    children: [
                      // X 버튼
                      GestureDetector(
                        onTap: () {
                          Navigator.pushReplacementNamed(context, '/home');
                        },
                        child: Container(
                          width: 50,
                          height: 50,
                          decoration: const BoxDecoration(
                            color: Color(0xFFD9D9D9),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close,
                            color: Colors.black,
                            size: 24,
                          ),
                        ),
                      ),
                      const SizedBox(width: 15),
                      // 선택완료 버튼
                      Expanded(
                        child: SizedBox(
                          height: 50,
                          child: ElevatedButton(
                            onPressed: () {
                              if (!_showSecondSlider) {
                                setState(() {
                                  _showSecondSlider = true;
                                });
                              } else {
                                Navigator.pushReplacementNamed(context, '/chat/room');
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFD9D9D9),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25),
                              ),
                            ),
                            child: const Text(
                              '선택완료',
                              style: TextStyle(
                                color: Colors.black87,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
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

  Widget _buildSlider({
    required int value,
    required Function(int) onChanged,
  }) {
    return Container(
      height: 50,
      margin: const EdgeInsets.symmetric(horizontal: 10),
      child: Stack(
        children: [
          // 배경 트랙
          Center(
            child: Container(
              height: 34,
              decoration: BoxDecoration(
                color: const Color(0xB2636363),
                borderRadius: BorderRadius.circular(17),
              ),
            ),
          ),
          // 불 이모티콘 슬라이더
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 34.0,
              activeTrackColor: Colors.transparent,
              inactiveTrackColor: Colors.transparent,
              thumbShape: const _FireThumbShape(touchRadius: 20.0),
              overlayColor: Colors.transparent,
              overlayShape: SliderComponentShape.noOverlay,
            ),
            child: Slider(
              value: value.toDouble(),
              min: 0,
              max: 4,
              divisions: 4,
              onChanged: (sliderValue) {
                onChanged(sliderValue.round());
              },
            ),
          ),
          // 5개의 작은 점
          Positioned(
            left: 10,
            right: 10,
            top: 8,
            bottom: 8,
            child: IgnorePointer(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final stepWidth = constraints.maxWidth / 4;
                  return Stack(
                    children: List.generate(5, (index) {
                      return Positioned(
                        left: index * stepWidth - 4,
                        top: constraints.maxHeight / 2 - 4,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                        ),
                      );
                    }),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FireThumbShape extends SliderComponentShape {
  final double touchRadius;
  
  const _FireThumbShape({this.touchRadius = 15.0});
  
  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) {
    return const Size(24, 24);
  }

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {
    final textPainter = TextPainter(
      text: const TextSpan(
        text: '🔥',
        style: TextStyle(fontSize: 35),
      ),
      textDirection: textDirection,
    )..layout();
    
    textPainter.paint(
      context.canvas,
      Offset(
        center.dx - textPainter.width / 2,
        center.dy - textPainter.height / 2,
      ),
    );
  }
  
  @override
  bool hitTest(Offset position, Offset center, {TextDirection? textDirection}) {
    return (position - center).distance <= touchRadius;
  }
}
