import 'package:flutter/material.dart';
import 'dart:async'; // RefactoredScreen의 Timer를 위해 필요
import 'package:flutter_svg/flutter_svg.dart'; // RefactoredScreen의 SvgPicture를 위해 필요

// 공동 작업자의 다른 화면들 (경로는 실제 프로젝트 구조에 맞게 확인해주세요)
import '../../chat/view/chat_screen.dart';
import '../../my/view/my_screen.dart';
import '../../hit/view/hit_screen.dart';
// import '../../common/custom_app_bar.dart'; // CustomAppBar는 현재 코드에서 사용되지 않아 주석 처리

// --- 사용자가 만든 화면 ---
class RefactoredScreen extends StatefulWidget {
  const RefactoredScreen({super.key});

  @override
  State<RefactoredScreen> createState() => _RefactoredScreenState();
}

class _RefactoredScreenState extends State<RefactoredScreen> {
  int userCoins = 200;
  String backgroundImagePath = 'assets/images/day.png';
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _updateBackground();
    _timer = Timer.periodic(const Duration(minutes: 1), (timer) {
      _updateBackground();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _updateBackground() {
    final now = DateTime.now();
    final currentHour = now.hour;
    String newImagePath;

    if (currentHour >= 6 && currentHour < 18) {
      newImagePath = 'assets/images/day.png';
    } else {
      newImagePath = 'assets/images/night.png';
    }

    if (backgroundImagePath != newImagePath) {
      setState(() {
        backgroundImagePath = newImagePath;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Scaffold를 제거하고 내부 컨텐츠만 반환하도록 수정합니다.
    // HomeScreen의 Scaffold가 이미 전체 화면 구조를 제공하기 때문입니다.
    return SafeArea(
      child: Center(
        child: AspectRatio(
          aspectRatio: 412 / 917,
          child: Stack(
            children: [
              // 1. 배경 이미지
              Positioned.fill(
                child: Image.asset(
                  backgroundImagePath,
                  fit: BoxFit.cover,
                ),
              ),

              // 2. 코인 UI
              Positioned(
                top: 50,
                left: 12,
                child: Container(
                  width: 100,
                  height: 43,
                  decoration: BoxDecoration(
                    color: const Color(0x4CD9D9D9),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        top: 9,
                        left: 15,
                        child: SvgPicture.asset(
                          'assets/icons/coin.svg',
                          width: 24,
                          height: 24,
                        ),
                      ),
                      Positioned(
                        top: 5,
                        left: 45,
                        child: Text(
                          userCoins.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontFamily: 'Pretendard',
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // 3. 알림 UI
              Positioned(
                top: 50,
                right: 16,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: 43,
                      height: 43,
                      padding: const EdgeInsets.all(10),
                      decoration: const BoxDecoration(
                        color: Color(0x4CD9D9D9),
                        shape: BoxShape.circle,
                      ),
                      child: SvgPicture.asset('assets/icons/notification.svg'),
                    ),
                    Positioned(
                      top: 2,
                      right: 2,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Color(0xFFFE4E4D),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // 4. 캐릭터 이미지
              Positioned(
                top: 325,
                left: 0,
                right: 0,
                child: Align(
                  alignment: Alignment.center,
                  child: Image.asset(
                    'assets/images/character.png',
                    width: 172,
                    height: 239,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


// --- 공동 작업자가 만든 홈 스크린 (수정됨) ---
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  // --- [수정 포인트] ---
  // 첫 번째 페이지를 RefactoredScreen()으로 교체했습니다.
  static final List<Widget> _pages = <Widget>[
    const RefactoredScreen(), // 사용자가 만든 화면으로 교체
    const ChatScreen(),
    const HitScreen(),
    const MyScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // RefactoredScreen에서 배경색을 관리하므로 Scaffold의 배경색은 제거하거나 투명으로 설정합니다.
      backgroundColor: const Color(0xFF0F0F0F),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: '홈',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: '채팅',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: '히트',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: '마이',
          ),
        ],
      ),
    );
  }
}