import 'package:flutter/material.dart';
import 'dart:async'; // RefactoredScreen의 Timer를 위해 필요
import 'package:flutter_svg/flutter_svg.dart'; // RefactoredScreen의 SvgPicture를 위해 필요
import 'package:shared_preferences/shared_preferences.dart'; // 추가

// 공동 작업자의 다른 화면들 (경로는 실제 프로젝트 구조에 맞게 확인해주세요)
import '../../chat/view/chat_initial_screen.dart'; // ChatInitialScreen으로 변경
import '../../my/view/my_screen.dart';
import '../../hit/service/hit_navigation_service.dart';
import '../../hit/view/hit_loading_screen.dart';
import '../../shop/view/shop_screen.dart';
import '../../common/custom_app_bar.dart'; // CustomBottomAppBar import 추가

// --- [기능 추가] ntf.dart와 setting.dart를 import 합니다 ---
import 'ntf.dart'; // ntf.dart (Notification Screen)
import 'setting.dart'; // setting.dart (Settings Screen)


// --- 사용자가 만든 화면 ---
class RefactoredScreen extends StatefulWidget {
  const RefactoredScreen({super.key});

  @override
  State<RefactoredScreen> createState() => _RefactoredScreenState();
}

class _RefactoredScreenState extends State<RefactoredScreen> {
  int userCoins = 2000; // 기본값을 2000으로 설정
  String backgroundImagePath = 'assets/images/day_background.png';
  Timer? _timer;

  // 아이템 관련 상태 추가
  final Map<int, int> _appliedItems = {
    0: -1, // 헤어: 기본값 (적용 안됨)
    1: -1, // 옷: 기본값 (적용 안됨)
    2: -1, // 무기: 기본값 (적용 안됨)
  };

  // 구매한 아이템들 (카테고리별로 저장)
  final Map<int, List<int>> _purchasedItems = {
    0: [], // 헤어: 구매한 아이템 인덱스 리스트
    1: [], // 옷: 구매한 아이템 인덱스 리스트
    2: [], // 무기: 구매한 아이템 인덱스 리스트
  };

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 화면이 다시 표시될 때마다 최신 데이터 로드
    _loadAppliedItems();
    _loadCurrency();
  }

  @override
  void initState() {
    super.initState();
    _updateBackground();
    _loadAppliedItems(); // 아이템 정보 로드 추가
    _loadCurrency(); // 재화 정보 로드 추가
    _timer = Timer.periodic(const Duration(minutes: 1), (timer) {
      _updateBackground();
    });
  }

  // 착용된 아이템 정보 로드
  Future<void> _loadAppliedItems() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _appliedItems[0] = prefs.getInt('applied_hair') ?? -1;
      _appliedItems[1] = prefs.getInt('applied_clothes') ?? -1;
      _appliedItems[2] = prefs.getInt('applied_weapons') ?? -1;
      
      // 구매한 아이템 정보도 로드
      final purchasedHair = prefs.getStringList('purchased_hair')?.map((e) => int.tryParse(e) ?? -1).where((e) => e >= 0).toList() ?? [];
      final purchasedClothes = prefs.getStringList('purchased_clothes')?.map((e) => int.tryParse(e) ?? -1).where((e) => e >= 0).toList() ?? [];
      final purchasedWeapons = prefs.getStringList('purchased_weapons')?.map((e) => int.tryParse(e) ?? -1).where((e) => e >= 0).toList() ?? [];
      
      _purchasedItems[0] = purchasedHair;
      _purchasedItems[1] = purchasedClothes;
      _purchasedItems[2] = purchasedWeapons;
    });
  }

  // 재화 정보 로드
  Future<void> _loadCurrency() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userCoins = prefs.getInt('user_currency') ?? 2000;
    });
  }

  // 현재 적용된 아이템들로 캐릭터 이미지 생성
  Widget _buildCharacterWithItems() {
    // 카테고리별 아이템 데이터 (ShopScreen과 동일)
    final List<List<String>> _categoryItems = [
      // 헤어 아이템들
      [
        'assets/images/hair_1.png',
        'assets/images/hair_2.png',
        'assets/images/hair_3.png',
        'assets/images/hair_4.png',
        'assets/images/hair_5.png',
        'assets/images/hair_6.png',
      ],
      // 옷 아이템들
      [
        'assets/images/clothes_1.png',
        'assets/images/clothes_2.png',
        'assets/images/clothes_3.png',
        'assets/images/clothes_4.png',
        'assets/images/clothes_5.png',
        'assets/images/clothes_6.png',
      ],
    ];

    return Stack(
      alignment: Alignment.center,
      children: [
        // 기본 캐릭터
        Image.asset(
          'assets/images/character_1.png',
          width: 172,
          height: 239,
          fit: BoxFit.contain,
        ),
        // 헤어 아이템 (구매한 아이템 + 착용 중인 것만)
        if (_appliedItems[0] != null && _appliedItems[0]! >= 0 && _purchasedItems[0]!.contains(_appliedItems[0]!))
          Positioned(
            top: -52,
            left: -63,
            child: Image.asset(
              _categoryItems[0][_appliedItems[0]!],
              width: 280, // 홈 화면 캐릭터 크기에 맞춰 조정
              height: 280,
              fit: BoxFit.contain,
            ),
          ),
        // 옷 아이템 (구매한 아이템 + 착용 중인 것만)
        if (_appliedItems[1] != null && _appliedItems[1]! >= 0 && _purchasedItems[1]!.contains(_appliedItems[1]!))
          Positioned(
            top: -53,
            left: -85,
            child: Image.asset(
              _categoryItems[1][_appliedItems[1]!],
              width: 322, // 홈 화면 캐릭터 크기에 맞춰 조정
              height: 322,
              fit: BoxFit.contain,
            ),
          ),
      ],
    );
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

        // --- [수정] 3. 설정 및 알림 버튼 UI ---
        Positioned(
          top: MediaQuery.of(context).padding.top + 20, // SafeArea 고려
          right: 16,
          child: Row(
            children: [
              // 설정 버튼
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SettingScreen()),
                  );
                },
                child: Container(
                  width: 43,
                  height: 43,
                  decoration: const BoxDecoration(
                    color: Color(0x4CD9D9D9),
                    shape: BoxShape.circle,
                  ),
                  child: Image.asset('assets/icons/setting.png'),
                ),
              ),
              const SizedBox(width: 8), // 아이콘 사이 간격

              // 알림 버튼
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const NtfScreen()),
                  );
                },
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
            ],
          ),
        ),

        // 4. 캐릭터 이미지 - 기존 코드를 수정된 캐릭터로 교체
        Positioned(
          top: MediaQuery.of(context).size.height * 0.55, // 화면 높이의 55% 위치 (더 아래로)
          left: 0,
          right: 0,
          child: Align(
            alignment: Alignment.center,
            child: _buildCharacterWithItems(), // 수정된 캐릭터 사용
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
    
    // 상점 화면으로 이동할 때 홈 화면 데이터 새로고침
    if (index == 3) { // 상점 화면 인덱스
      // 홈 화면으로 돌아올 때 데이터를 새로고침하기 위해 타이머 설정
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted) {
          setState(() {}); // 화면 새로고침
        }
      });
    }
  }

  // 홈 화면으로 돌아가는 메서드
  void _onBackToHome() {
    setState(() {
      _selectedIndex = 2; // 홈 화면 인덱스
    });
    
    // 홈 화면으로 돌아올 때 아이템과 재화 정보 새로고침
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        setState(() {}); // 화면 새로고침
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // --- [수정 포인트] ---
    // CustomBottomAppBar의 순서에 맞춰서 수정: 채팅, 때려줄게, 홈, 상점, 마이
    final List<Widget> _pages = <Widget>[
      const ChatInitialScreen(), // 0: 채팅 (ChatScreen에서 ChatInitialScreen으로 변경)
      const HitLoadingScreen(),  // 1: 때려줄게 (로딩 화면으로 시작)
      RefactoredScreen(key: ValueKey(_selectedIndex)), // 2: 홈 (키 추가로 새로고침)
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