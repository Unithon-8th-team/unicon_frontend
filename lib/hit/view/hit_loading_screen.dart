import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:ui';
import 'package:shared_preferences/shared_preferences.dart';
import 'hit_screen.dart';
import '../../home/view/home_screen.dart';
import '../../my/premium/premium.dart';

// --- 데이터 모델 ---
const List<Map<String, dynamic>> customizationStepsData = [
  {'key': 'clothes', 'title': '옷', 'prefix': 'clothes_', 'count': 10, 'isOptional': false},
  {'key': 'eyes', 'title': '눈', 'prefix': 'eyes_', 'count': 10, 'isOptional': false},
  {'key': 'nose', 'title': '코', 'prefix': 'nose_', 'count': 5, 'isOptional': false},
  {'key': 'mouth', 'title': '입', 'prefix': 'mouse_', 'count': 6, 'isOptional': false},
  {'key': 'eyebrow', 'title': '눈썹', 'prefix': 'eyebrow_', 'count': 3, 'isOptional': false},
  {'key': 'hair', 'title': '머리카락', 'prefix': 'hair_', 'count': 20, 'isOptional': false},
  {'key': 'beard', 'title': '수염', 'prefix': 'beard_', 'count': 4, 'isOptional': true},
  {'key': 'accessories', 'title': '악세사리', 'prefix': 'accessories_', 'count': 10, 'isOptional': true},
];

// --- 재사용 가능 로딩 위젯 ---
class CustomLoadingWidget extends StatefulWidget {
  final Duration duration;
  final VoidCallback onLoadingComplete;

  const CustomLoadingWidget({
    super.key,
    required this.duration,
    required this.onLoadingComplete,
  });

  @override
  State<CustomLoadingWidget> createState() => _CustomLoadingWidgetState();
}

class _CustomLoadingWidgetState extends State<CustomLoadingWidget> with TickerProviderStateMixin {
  late AnimationController _progressController;
  late AnimationController _characterController;
  late Animation<double> _progressAnimation;
  late Animation<double> _characterAnimation;

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(vsync: this, duration: widget.duration);
    _characterController = AnimationController(vsync: this, duration: widget.duration);

    _progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _progressController, curve: Curves.easeInOut));
    _characterAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _characterController, curve: Curves.easeInOut));

    _startLoadingAnimation();
  }

  void _startLoadingAnimation() {
    _progressController.forward();
    _characterController.forward();
    Timer(widget.duration, widget.onLoadingComplete);
  }

  @override
  void dispose() {
    _progressController.dispose();
    _characterController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AnimatedBuilder(
        animation: Listenable.merge([_progressAnimation, _characterAnimation]),
        builder: (context, child) {
          return Stack(
            children: [
              // Progress Bar at the bottom
              Positioned(
                bottom: 100,
                left: 30,
                right: 30,
                child: Container(
                  height: 8,
                  decoration: BoxDecoration(color: Colors.grey.shade400, borderRadius: BorderRadius.circular(4)),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      width: (MediaQuery.of(context).size.width - 60) * _progressAnimation.value,
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4)),
                    ),
                  ),
                ),
              ),
              // 자막 위치를 캐릭터 머리 위로 조정
              Positioned(
                bottom: 185,
                width: MediaQuery.of(context).size.width,
                child: const Column(
                  children: [
                    Text(
                      '내가 스트레스 풀릴때 까지 때려줄께',
                      style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 8),
                    Text(
                      '조금만 기다려',
                      style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              // Character animation
              Positioned(
                left: _characterAnimation.value * (MediaQuery.of(context).size.width - 80),
                bottom: 100,
                child: Image.asset('assets/images/hit_loding.png', width: 80, height: 80, fit: BoxFit.contain),
              ),
            ],
          );
        },
      ),
    );
  }
}

// --- 메인 로딩 스크린 ---
class HitLoadingScreen extends StatefulWidget {
  const HitLoadingScreen({super.key});

  @override
  State<HitLoadingScreen> createState() => _HitLoadingScreenState();
}

class _HitLoadingScreenState extends State<HitLoadingScreen>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  late AnimationController _modalController;
  late Animation<double> _modalAnimation;
  PageController? _pageController;
  
  double _dragOffset = 0.0;
  bool _isAppLoading = true;
  bool _showModal = false;
  int _currentModalPage = 0; // 0: 멤버십, 1: 캐릭터 선택
  String? _selectedCharacter; // 선택된 캐릭터
  bool _isPremiumMember = false; // 프리미엄 멤버십 여부
  bool _isExiting = false; // 홈으로 이동 중 중복 네비게이션 방지

  @override
  void initState() {
    super.initState();

    // WidgetsBindingObserver 등록
    WidgetsBinding.instance.addObserver(this);

    // 프리미엄 멤버십 상태 확인
    _checkPremiumMembership();
    _modalController = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _modalAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(CurvedAnimation(parent: _modalController, curve: Curves.easeOutBack));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 화면이 다시 표시될 때마다 프리미엄 멤버십 상태 확인
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkPremiumMembership();
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      // 앱이 다시 활성화될 때 프리미엄 상태 확인
      _checkPremiumMembership();
    }
  }

  void _checkPremiumMembership() async {
    final prefs = await SharedPreferences.getInstance();
    
    final isPremium = prefs.getBool('is_premium_member') ?? false;
    final expiryTime = prefs.getInt('membership_expiry') ?? 0;
    final now = DateTime.now().millisecondsSinceEpoch;
    
    // 만료된 프리미엄 멤버십 체크
    if (isPremium && expiryTime > 0 && now > expiryTime) {
      // 만료된 경우 프리미엄 상태 해제
      await prefs.setBool('is_premium_member', false);
      await prefs.remove('membership_type');
      await prefs.remove('membership_expiry');
      
      if (mounted) {
        setState(() {
          _isPremiumMember = false;
        });
      }
    } else if (isPremium != _isPremiumMember) {
      // 프리미엄 상태가 변경된 경우
      if (mounted) {
        setState(() {
          _isPremiumMember = isPremium;
        });
      }
    }
  }
  
  void _onLoadingComplete() {
    if (mounted) {
      setState(() {
        _isAppLoading = false;
        _showModal = true;
      });
      _modalController.forward();
    }
  }

  void _nextModalPage() {
    if (_currentModalPage < 1 && _pageController != null) {
      _pageController!.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() {
        _currentModalPage = 1;
      });
    }
  }

  void _previousModalPage() {
    if (_currentModalPage > 0 && _pageController != null) {
      _pageController!.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() {
        _currentModalPage = 0;
      });
    }
  }

  void _exitToHome() {
    if (_isExiting || !mounted) return;
    _isExiting = true;

    // 진행 중인 애니메이션 중지
    _modalController.stop();

    // 홈 화면으로 직접 이동하고 모든 스택 제거
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const HomeScreen()),
      (route) => false,
    );
  }

  Future<void> _startHitGame() async {
    if (_isExiting) return;
    if (_selectedCharacter == null) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selected_character', _selectedCharacter!);
    if (context.mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => HitScreen(
            selectedCharacter: _selectedCharacter,
          ),
        ),
        (route) => false,
      );
    }
  }

  @override
  void dispose() {
    _modalController.dispose();
    _pageController?.dispose();
    
    // WidgetsBindingObserver 해제
    WidgetsBinding.instance.removeObserver(this);
    
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(image: DecorationImage(image: AssetImage('assets/images/hit_loding_bg.png'), fit: BoxFit.cover)),
            child: Container(
              color: Colors.black.withOpacity(0.6),
            ),
          ),
          SafeArea(
            child: _isAppLoading
                ? CustomLoadingWidget(
                    duration: const Duration(seconds: 3),
                    onLoadingComplete: _onLoadingComplete,
                  )
                : const SizedBox.shrink(),
          ),
          if (_showModal && !_isAppLoading)
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
              child: Container(
                color: Colors.black.withOpacity(0.1),
              ),
            ),
          _buildModal(),
        ],
      ),
    );
  }

  Widget _buildModal() {
    if (!_showModal) return const SizedBox.shrink();
    return AnimatedBuilder(
      animation: _modalAnimation,
      builder: (context, child) {
        final screenH = MediaQuery.of(context).size.height;
        final modalH = screenH * 0.85;
        return Positioned(
          bottom: -modalH * _modalAnimation.value - _dragOffset,
          left: 0,
          right: 0,
          child: _buildDraggableModalContainer(modalH),
        );
      },
    );
  }

  Widget _buildDraggableModalContainer(double modalH) {
    return GestureDetector(
      onVerticalDragUpdate: (details) => setState(() => _dragOffset = (_dragOffset + details.delta.dy).clamp(0.0, modalH)),
      onVerticalDragEnd: (details) async {
        final threshold = modalH * 0.25;
        if (_dragOffset > threshold) {
          await _modalController.reverse();
          if (mounted) setState(() => _showModal = false);
        }
        setState(() => _dragOffset = 0);
      },
      child: Container(
        height: modalH,
        decoration: BoxDecoration(
          color: const Color(0xE6232323),
          borderRadius: const BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
        ),
        child: _buildModalContents(),
      ),
    );
  }

  Widget _buildModalContents() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      transitionBuilder: (Widget child, Animation<double> animation) {
        return FadeTransition(opacity: animation, child: child);
      },
      child: _getCurrentPageWidget(),
    );
  }

  Widget _getCurrentPageWidget() {
    switch (_currentModalPage) {
      case 0:
        return Container(key: const ValueKey<int>(0), child: _buildMembershipPage());
      case 1:
        return Container(key: const ValueKey<int>(1), child: _buildCharacterSelectionPage());
      default:
        return Container(key: const ValueKey<int>(0), child: _buildMembershipPage());
    }
  }

  // 멤버십 가입 페이지
  Widget _buildMembershipPage() {
    return _buildPremiumMemberModal();
  }

  // 프리미엄 멤버용 모달
  Widget _buildPremiumMemberModal() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 상단 네비게이션 바
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // 왼쪽 화살표 아이콘
              GestureDetector(
                onTap: _exitToHome,
                child: Icon(
                  Icons.arrow_back,
                  color: Colors.white70,
                  size: 24,
                ),
              ),
              
              // 오른쪽 X 아이콘
              GestureDetector(
                onTap: _exitToHome,
                child: Icon(
                  Icons.close,
                  color: Colors.white70,
                  size: 24,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 30),
          
          // 프리미엄 멤버십 전용 헤더 텍스트
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '캐릭터 생성 옵션',
                style: TextStyle(
                  fontSize: 24,
                  color: Colors.grey.shade300,
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
          
          // 기본 섹션
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '기본',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.lightBlue.shade300,
                ),
              ),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: () {
                  // 기본 버전 버튼을 눌렀을 때 캐릭터 선택 페이지로 이동
                  _nextModalPage();
                },
                child: Container(
                  width: double.infinity,
                  height: 80,
                  decoration: BoxDecoration(
                    color: const Color(0xFF2A2A2A),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Center(
                    child: Text(
                      '기본 버전',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 30),
          
          // 프리미엄 멤버십 전용 섹션
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '프리미엄 멤버십 전용',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.orange.shade400,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  // 프롬프트 입력하기 버튼
                  Expanded(
                    child: GestureDetector(
                      onTap: _isPremiumMember ? () {
                        // 프리미엄 사용자만 사용 가능
                        // TODO: 프롬프트 입력 기능 구현
                      } : () {
                        // 일반 사용자는 프리미엄 화면으로 이동
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const PremiumScreen(),
                          ),
                        );
                      },
                      child: Container(
                        height: 80,
                        decoration: BoxDecoration(
                          color: _isPremiumMember 
                              ? const Color(0xFF2A2A2A)
                              : Colors.grey.shade600,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Text(
                            '프롬프트 입력하기',
                            style: TextStyle(
                              color: _isPremiumMember 
                                  ? Colors.white
                                  : Colors.grey.shade400,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // 나만의 커스터마이징 하기 버튼
                  Expanded(
                    child: GestureDetector(
                      onTap: _isPremiumMember ? () {
                        // 프리미엄 사용자만 사용 가능
                        // TODO: 커스터마이징 기능 구현
                      } : () {
                        // 일반 사용자는 프리미엄 화면으로 이동
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const PremiumScreen(),
                          ),
                        );
                      },
                      child: Container(
                        height: 80,
                        decoration: BoxDecoration(
                          color: _isPremiumMember 
                              ? const Color(0xFF2A2A2A)
                              : Colors.grey.shade600,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Text(
                            '나만의 커스터마이징 하기',
                            style: TextStyle(
                              color: _isPremiumMember 
                                  ? Colors.white
                                  : Colors.grey.shade400,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          
          const Spacer(),
        ],
      ),
    );
  }

  // 캐릭터 선택 페이지
  Widget _buildCharacterSelectionPage() {
    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '어떤 캐릭터를 원하시나요?',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 24),
            
            // 교수님 카테고리
            _buildCharacterCategory(
              title: '교수님',
              characters: [
                {'id': 'pro_m', 'image': 'assets/images/pro_m.png'},
                {'id': 'pro_f', 'image': 'assets/images/pro_f.png'},
              ],
            ),
            
            const SizedBox(height: 20),
            
            // 팀플 조원 카테고리
            _buildCharacterCategory(
              title: '팀플 조원',
              characters: [
                {'id': 'stu_m', 'image': 'assets/images/stu_m.png'},
                {'id': 'stu_f', 'image': 'assets/images/stu_f.png'},
              ],
            ),
            
            const SizedBox(height: 20),
            
            // 직장 상사 카테고리
            _buildCharacterCategory(
              title: '직장 상사',
              characters: [
                {'id': 'com_m', 'image': 'assets/images/com_m.png'},
                {'id': 'com_f', 'image': 'assets/images/com_f.png'},
              ],
            ),
            
            // 하단 여백 추가
            const SizedBox(height: 20),
            
            // 하단 버튼
            Container(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _previousModalPage,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: BorderSide(color: Colors.blue.shade400),
                      ),
                      child: const Text(
                        '이전',
                        style: TextStyle(color: Colors.blue, fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _selectedCharacter != null ? _startHitGame : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _selectedCharacter != null
                            ? Colors.blue
                            : Colors.grey.shade600,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        '때려줄게 시작!',
                        style: TextStyle(
                          color: _selectedCharacter != null
                              ? Colors.white
                              : Colors.grey.shade400,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
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
    );
  }
  
  // --- Helper Widgets ---

  Widget _buildCharacterCategory({required String title, required List<Map<String, String>> characters}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white)),
        const SizedBox(height: 12),
        Row(
          children: characters.map((character) {
            final isSelected = _selectedCharacter == character['id'];
            return Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _selectedCharacter = character['id']),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.blue.withOpacity(0.3) : Colors.grey.shade800.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: isSelected ? Colors.blue : Colors.transparent, width: 2),
                  ),
                  child: Column(
                    children: [
                      Image.asset(
                        character['image']!,
                        width: 120,
                        height: 140,
                        fit: BoxFit.contain,
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
