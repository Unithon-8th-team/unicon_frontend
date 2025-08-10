import 'package:flutter/material.dart';
import 'chat_screen.dart';
import '../../home/view/home_screen.dart';

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
                    color: const Color(0x66636363), // #636363 with 40% opacity
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '지금 얼마나 화가나?',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.left,
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
                            style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w600),
                          ),
                          Text(
                            '매우 많이',
                            style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w600),
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
                      color: const Color(0x66636363), // #636363 with 40% opacity
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '내가 얼만큼 화내줄까?',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.left,
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
                            style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w600),
                          ),
                          Text(
                            '매우 많이',
                            style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w600),
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
                          // HomeScreen으로 이동
                          Navigator.pushReplacement(
                            context,
                            PageRouteBuilder(
                              pageBuilder: (context, animation, secondaryAnimation) => const HomeScreen(),
                              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                return child; // 애니메이션 없음
                              },
                            ),
                          );
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
                                // ChatScreen으로 직접 이동
                                Navigator.pushReplacement(
                                  context,
                                  PageRouteBuilder(
                                    pageBuilder: (context, animation, secondaryAnimation) => const ChatScreen(),
                                    transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                      return child; // 애니메이션 없음
                                    },
                                  ),
                                );
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
                                fontWeight: FontWeight.w600,
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
    const double trackHeight = 34.0;
    const double dotSize = 8.0; // 흰 점 크기
    const double hPad = 24.0;   // 좌우 내부 여백(끝 점이 잘리지 않도록)

    return Container(
      height: 50,
      margin: const EdgeInsets.symmetric(horizontal: 10),
      child: Stack(
        children: [
          // 배경 트랙
          Center(
            child: Container(
              height: trackHeight,
              decoration: BoxDecoration(
                color: const Color(0x80636363), // #636363 with 50% opacity
                borderRadius: BorderRadius.circular(trackHeight / 2),
              ),
            ),
          ),

          // 5개의 작은 점(끝이 잘리지 않도록 내부 여백을 두고 배치)
          Positioned.fill(
            child: IgnorePointer(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final totalWidth = constraints.maxWidth;
                  final usableWidth = totalWidth - (hPad * 2);
                  return Stack(
                    children: List.generate(5, (index) {
                      final dx = hPad + (usableWidth * (index / 4));
                      return Positioned(
                        left: dx - (dotSize / 2),
                        top: (constraints.maxHeight / 2) - (dotSize / 2),
                        child: Container(
                          width: dotSize,
                          height: dotSize,
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

          // 불 이모티콘 슬라이더(기본 트랙 페인팅 제거해서 잔상/하이라이트가 생기지 않도록 함)
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: trackHeight,
              // 기본 트랙 렌더링 제거 -> 우리가 그린 배경만 보이게
              trackShape: const _NoopTrackShape(),
              activeTrackColor: Colors.transparent,
              inactiveTrackColor: Colors.transparent,
              thumbShape: const _FireThumbShape(touchRadius: 25.0),
              overlayColor: Colors.transparent,
              overlayShape: SliderComponentShape.noOverlay,
              // 기본 눈금(회색 동그라미) 제거
              activeTickMarkColor: Colors.transparent,
              inactiveTickMarkColor: Colors.transparent,
              tickMarkShape: const RoundSliderTickMarkShape(tickMarkRadius: 0),
            ),
            child: Slider(
              value: value.toDouble(),
              min: 0,
              max: 4,
              divisions: 4,
              onChanged: (sliderValue) => onChanged(sliderValue.round()),
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
    // fire_img.png 이미지를 그리기 위한 ImageProvider
    final imageProvider = AssetImage('assets/images/fire_img.png');
    
    // 이미지 로드 및 그리기
    imageProvider.resolve(ImageConfiguration()).addListener(
      ImageStreamListener((ImageInfo info, bool _) {
        final paint = Paint();
        final rect = Rect.fromCenter(
          center: Offset(center.dx, center.dy - 5), // 위쪽으로 5픽셀 이동
          width: 45, // 너비를 45로 증가
          height: 45, // 높이를 45로 증가
        );
        
        context.canvas.drawImageRect(
          info.image,
          Rect.fromLTWH(0, 0, info.image.width.toDouble(), info.image.height.toDouble()),
          rect,
          paint,
        );
      }),
    );
  }
  
  @override
  bool hitTest(Offset position, Offset center, {TextDirection? textDirection}) {
    return (position - center).distance <= touchRadius;
  }
}

class _NoopTrackShape extends SliderTrackShape {
  const _NoopTrackShape();

  @override
  Rect getPreferredRect({
    required RenderBox parentBox,
    Offset offset = Offset.zero,
    required SliderThemeData sliderTheme,
    bool isEnabled = false,
    bool isDiscrete = false,
  }) {
    const double trackHeight = 34.0;
    final double trackLeft = offset.dx;
    final double trackTop = offset.dy + (parentBox.size.height - trackHeight) / 2;
    final double trackWidth = parentBox.size.width;
    return Rect.fromLTWH(trackLeft, trackTop, trackWidth, trackHeight);
  }

  @override
  void paint(
    PaintingContext context,
    Offset offset, {
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required Animation<double> enableAnimation,
    required Offset thumbCenter,
    bool isDiscrete = false,
    bool isEnabled = false,
    required TextDirection textDirection,
    Offset? secondaryOffset,
  }) {
    // 기본 트랙을 그리지 않음. (배경 트랙은 우리가 별도 컨테이너로 그림)
  }
}