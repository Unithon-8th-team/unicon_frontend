import 'package:flutter/material.dart';
import 'dart:async'; // RefactoredScreen의 Timer를 위해 필요
import 'package:flutter_svg/flutter_svg.dart'; // RefactoredScreen의 SvgPicture를 위해 필요

// 공동 작업자의 다른 화면들 (경로는 실제 프로젝트 구조에 맞게 확인해주세요)
import '../../chat/view/chat_initial_screen.dart'; // ChatInitialScreen으로 변경
import '../../my/view/my_screen.dart';
import '../../hit/service/hit_navigation_service.dart';
import '../../hit/view/hit_loading_screen.dart';
import '../../shop/view/shop_screen.dart';
import '../../common/custom_app_bar.dart'; // CustomBottomAppBar import 추가

// --- 사용자가 만든 화면 ---
class RefactoredScreen extends StatefulWidget {
  const RefactoredScreen({super.key});

  @override
  State<RefactoredScreen> createState() => _RefactoredScreenState();
}

class _RefactoredScreenState extends State<RefactoredScreen> {
  int userCoins = 200;
  String backgroundImagePath = 'assets/images/day_background.png';
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
      newImagePath = 'assets/images/day_background.png';
    } else {
      newImagePath = 'assets/images/night_background.png';
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
    return Stack(
      children: [
        // 1. 배경 이미지 - 전체 화면을 채움
        Positioned.fill(
          child: Image.asset(
            backgroundImagePath,
            fit: BoxFit.cover,
          ),
        ),

        // 2. 코인 UI
        Positioned(
          top: MediaQuery.of(context).padding.top + 20, // SafeArea 고려
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
                      fontWeight: FontWeight.w600,
                      fontSize: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // 3. 알림 UI
        Positioned(
          top: MediaQuery.of(context).padding.top + 20, // SafeArea 고려
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

        // 4. 캐릭터 이미지 - 화면 중앙에 배치
        Positioned(
          top: MediaQuery.of(context).size.height * 0.55, // 화면 높이의 55% 위치 (더 아래로)
          left: 0,
          right: 0,
          child: Align(
            alignment: Alignment.center,
            child: Image.asset(
              'assets/images/character_1.png',
              width: 172,
              height: 239,
              fit: BoxFit.contain,
            ),
          ),
        ),
      ],
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
  int _selectedIndex = 2; // 홈이 중앙에 있으므로 2로 설정

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // 홈 화면으로 돌아가는 메서드
  void _onBackToHome() {
    setState(() {
      _selectedIndex = 2; // 홈 화면 인덱스
    });
  }

  @override
  Widget build(BuildContext context) {
    // --- [수정 포인트] ---
    // CustomBottomAppBar의 순서에 맞춰서 수정: 채팅, 때려줄게, 홈, 상점, 마이
    final List<Widget> _pages = <Widget>[
      const ChatInitialScreen(), // 0: 채팅 (ChatScreen에서 ChatInitialScreen으로 변경)
      const HitLoadingScreen(),  // 1: 때려줄게 (로딩 화면으로 시작)
      const RefactoredScreen(), // 2: 홈 (사용자가 만든 화면)
      ShopScreen(onBackToHome: _onBackToHome), // 3: 상점 (콜백 전달)
      const MyScreen(),   // 4: 마이
    ];

    return Scaffold(
      // 배경색을 투명하게 설정하여 RefactoredScreen의 배경이 보이도록 함
      backgroundColor: Colors.transparent,
      // extendBody을 true로 설정하여 배경이 하단 앱 바까지 확장되도록 함
      extendBody: true,
      // SafeArea를 제거하여 하단 앱 바까지 화면이 채워지도록 함
      body: _pages[_selectedIndex],
      // 홈 화면(인덱스 2), Hit 화면(인덱스 1), My 화면(인덱스 4)에서 앱 바 표시
      bottomNavigationBar: (_selectedIndex == 2 || _selectedIndex == 1 || _selectedIndex == 4)
          ? CustomBottomAppBar(
              currentIndex: _selectedIndex,
              onTap: _onItemTapped,
            )
          : null,
    );
  }
}
