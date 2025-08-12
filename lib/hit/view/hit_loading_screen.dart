import 'package:flutter/material.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'hit_screen.dart';

class HitLoadingScreen extends StatefulWidget {
  const HitLoadingScreen({super.key});

  @override
  State<HitLoadingScreen> createState() => _HitLoadingScreenState();
}

class _HitLoadingScreenState extends State<HitLoadingScreen>
    with TickerProviderStateMixin {
  late AnimationController _progressController;
  late AnimationController _characterController;
  late AnimationController _modalController;
  late Animation<double> _progressAnimation;
  late Animation<double> _characterAnimation;
  late Animation<double> _modalAnimation;
  PageController? _pageController;

  // 드래그 복원 애니메이션 컨트롤러
  late AnimationController _dragReboundController;
  late Animation<double> _dragReboundAnimation;
  double _dragOffset = 0.0; // 모달을 아래로 끌어내릴 때 사용할 오프셋

  double _progress = 0.0;
  bool _isLoading = true;
  bool _showModal = false;
  int _currentModalPage = 0; // 0: 멤버십, 1: 캐릭터 선택
  String? _selectedCharacter; // 선택된 캐릭터
  bool _isPremiumMember = false; // 프리미엄 멤버십 여부

  @override
  void initState() {
    super.initState();

    // 프리미엄 멤버십 상태 확인
    _checkPremiumMembership();

    // 진행률 애니메이션 컨트롤러
    _progressController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    // 캐릭터 이동 애니메이션 컨트롤러
    _characterController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    // 모달 창 애니메이션 컨트롤러
    _modalController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    // 드래그 복원 애니메이션 컨트롤러
    _dragReboundController = AnimationController(
      duration: const Duration(milliseconds: 180),
      vsync: this,
    );

    // 진행률 애니메이션 (0.0 -> 1.0)
    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeInOut,
    ));

    // 캐릭터 이동 애니메이션 (왼쪽 -> 오른쪽)
    _characterAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _characterController,
      curve: Curves.easeInOut,
    ));

    // 모달 창 애니메이션
    _modalAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _modalController,
      curve: Curves.easeOutBack,
    ));

    // 페이지 컨트롤러
    _pageController = PageController(initialPage: 0);

    // 애니메이션 리스너
    _progressAnimation.addListener(() {
      setState(() {
        _progress = _progressAnimation.value;
      });
    });

    // 로딩 시작
    _startLoading();
  }

  void _checkPremiumMembership() async {
    final prefs = await SharedPreferences.getInstance();
    _isPremiumMember = prefs.getBool('is_premium_member') ?? false;
  }

  void _startLoading() async {
    // 진행률과 캐릭터 애니메이션 동시 시작
    _progressController.forward();
    _characterController.forward();
    
    // 3초 후 로딩 완료
    Timer(const Duration(seconds: 3), () {
      setState(() {
        _isLoading = false;
        _showModal = true;
      });
      
      // 모달 창 애니메이션 시작
      _modalController.forward();
    });
  }

  void _nextModalPage() {
    print('🔄 다음 페이지로 이동 시도: 현재 $_currentModalPage');
    if (_currentModalPage < 1 && _pageController != null) {
      _pageController!.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      print('✅ 다음 페이지로 이동: $_currentModalPage');
    }
  }

  void _previousModalPage() {
    if (_currentModalPage > 0 && _pageController != null) {
      _pageController!.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _startHitGame() {
    if (context.mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => HitScreen(
            selectedCharacter: _selectedCharacter,
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    _progressController.dispose();
    _characterController.dispose();
    _modalController.dispose();
    _dragReboundController.dispose();
    _pageController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/hit_loding_bg.png'),
                fit: BoxFit.cover,
              ),
            ),
            child: Container(
              color: Colors.black.withOpacity(0.6), // 배경 어둡게 처리
              child: SafeArea(
                child: Column(
                  children: [          
                    // 중간 텍스트 메시지
                    Expanded(
                      flex: 1,
                      child: _buildMessageSection(),
                    ),
                    
                    // 하단 캐릭터와 진행바
                    Expanded(
                      flex: 2,
                      child: _buildBottomSection(),
                    ),
                    
                    // 하단 네비게이션바 공간
                    const SizedBox(height: 220),
                  ],
                ),
              ),
            ),
          ),
          
          // 모달 창
          _buildModal(),
        ],
      ),
    );
  }

  Widget _buildMessageSection() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '내가 스트레스 풀릴때 까지 때려줄께',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8),
          Text(
            '조금만 기다려',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildBottomSection() {
    return Stack(
      children: [
        // 진행바 (하단에 배치)
        Positioned(
          bottom: 0,
          left: 30,
          right: 30,
          child: Container(
            height: 8,
            decoration: BoxDecoration(
              color: Colors.grey.shade400,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Stack(
              children: [
                // 진행률 표시
                AnimatedBuilder(
                  animation: _progressAnimation,
                  builder: (context, child) {
                    return Container(
                      width: (MediaQuery.of(context).size.width - 60) * _progress,
                      height: 8,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
        
        // 캐릭터 (hit_loding.png 이미지 사용)
        AnimatedBuilder(
          animation: _characterAnimation,
          builder: (context, child) {
            return Positioned(
              left: _characterAnimation.value * (MediaQuery.of(context).size.width - 80),
              bottom: 20, // 진행바 위에 위치
              child: Image.asset(
                'assets/images/hit_loding.png',
                width: 80,
                height: 80,
                fit: BoxFit.contain,
              ),
            );
          },
        ),
      ],
    );
  }

  // 모달 창 위젯
  Widget _buildModal() {
    if (!_showModal) return const SizedBox.shrink();

    return AnimatedBuilder(
      animation: _modalAnimation,
      builder: (context, child) {
        final screenH = MediaQuery.of(context).size.height;
        final modalH = screenH * 0.7; // 모달 실제 높이
        return Positioned(
          // value: 1.0 → bottom = -modalH (아래로 숨김), value: 0.0 → bottom = 0 (바닥에 붙음)
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
      onVerticalDragUpdate: (details) {
        // 아래로 끌면 양수 delta → 오프셋 증가. 위로 끌면 감소하지만 0 미만으로는 방지
        setState(() {
          _dragOffset = (_dragOffset + details.delta.dy).clamp(0.0, modalH);
        });
      },
      onVerticalDragEnd: (details) async {
        // 일정 이상 내리면 닫기, 아니면 제자리로 복원
        final threshold = modalH * 0.25;
        if (_dragOffset > threshold) {
          // 닫기 애니메이션
          await _modalController.reverse();
          if (mounted) {
            setState(() {
              _showModal = false;
              _dragOffset = 0.0;
            });
          }
        } else {
          // 복원 애니메이션
          _dragReboundAnimation = Tween<double>(begin: _dragOffset, end: 0.0).animate(
            CurvedAnimation(parent: _dragReboundController, curve: Curves.easeOut),
          );
          _dragReboundController.removeListener(_reboundListener);
          _dragReboundController.addListener(_reboundListener);
          _dragReboundController.forward(from: 0.0);
        }
      },
      child: Container(
        height: modalH,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.9),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: _buildModalContents(),
      ),
    );
  }

  void _reboundListener() {
    setState(() {
      _dragOffset = _dragReboundAnimation.value;
    });
  }

  Widget _buildModalContents() {
    return Column(
      children: [
        // 모달 상단 핸들
        Container(
          margin: const EdgeInsets.only(top: 12),
          width: 40,
          height: 4,
          decoration: BoxDecoration(
            color: Colors.grey.shade300,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        // 페이지 인디케이터
        Container(
          margin: const EdgeInsets.symmetric(vertical: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: _currentModalPage == 0 ? Colors.blue : Colors.grey.shade300,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: _currentModalPage == 1 ? Colors.blue : Colors.grey.shade300,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
        ),
        // 페이지 내용
        Expanded(
          child: PageView(
            controller: _pageController ?? PageController(initialPage: 0),
            onPageChanged: (page) {
              setState(() {
                _currentModalPage = page;
              });
            },
            physics: const ClampingScrollPhysics(),
            children: [
              _buildMembershipPage(),
              _buildCharacterSelectionPage(),
            ],
          ),
        ),
        // 하단 버튼 (기존 그대로)
        Container(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              if (_currentModalPage > 0)
                Expanded(
                  child: OutlinedButton(
                    onPressed: _previousModalPage,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: BorderSide(color: Colors.blue.shade400),
                    ),
                    child: const Text(
                      '이전',
                      style: TextStyle(
                        color: Colors.blue,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              if (_currentModalPage > 0) const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: _currentModalPage == 0
                      ? _nextModalPage
                      : (_selectedCharacter != null ? _startHitGame : null),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _currentModalPage == 0 || _selectedCharacter != null
                        ? Colors.blue
                        : Colors.grey.shade600,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    _currentModalPage == 0 ? '다음' : '때려줄게 시작!',
                    style: TextStyle(
                      color: _currentModalPage == 0 || _selectedCharacter != null
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
    );
  }

  // 멤버십 가입 페이지
  Widget _buildMembershipPage() {
    if (_isPremiumMember) {
      // 프리미엄 멤버용 모달 (이미지 디자인과 동일)
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
                Icon(
                  Icons.arrow_back,
                  color: Colors.white70,
                  size: 24,
                ),
                // 중앙 진행바
                Container(
                  width: 100,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade600,
                    borderRadius: BorderRadius.circular(2),
                  ),
                  child: Container(
                    width: 50, // 진행률 표시
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                // 오른쪽 X 아이콘
                Icon(
                  Icons.close,
                  color: Colors.white70,
                  size: 24,
                ),
              ],
            ),
            
            const SizedBox(height: 30),
            
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
                Container(
                  width: double.infinity,
                  height: 50,
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
                      child: Container(
                        height: 50,
                        decoration: BoxDecoration(
                          color: const Color(0xFF2A2A2A),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Center(
                          child: Text(
                            '프롬프트 입력하기',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // 나만의 커스터마이징 하기 버튼
                    Expanded(
                      child: Container(
                        height: 50,
                        decoration: BoxDecoration(
                          color: const Color(0xFF2A2A2A),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Center(
                          child: Text(
                            '나만의 커스터마이징 하기',
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
              ],
            ),
            
            const Spacer(),
          ],
        ),
      );
    } else {
      // 무료 사용자용 모달 (기존 코드)
      return Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '프리미엄 멤버십 전용',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '더 많은 캐릭터 생성 옵션',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade300,
              ),
            ),
            const SizedBox(height: 32),
            
            // 여기에 멤버십 내용을 추가하세요
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.star,
                      size: 80,
                      color: Colors.amber.shade400,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      '프리미엄 멤버십으로\n더욱 확실하게 스트레스 풀어요 💰',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }
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
                {'id': 'pro_m', 'image': 'assets/images/pro_m.png', 'name': '남성 교수님'},
                {'id': 'pro_f', 'image': 'assets/images/pro_f.png', 'name': '여성 교수님'},
              ],
            ),
            
            const SizedBox(height: 20),
            
            // 팀플 조원 카테고리
            _buildCharacterCategory(
              title: '팀플 조원',
              characters: [
                {'id': 'stu_m', 'image': 'assets/images/stu_m.png', 'name': '남성 학생'},
                {'id': 'stu_f', 'image': 'assets/images/stu_f.png', 'name': '여성 학생'},
              ],
            ),
            
            const SizedBox(height: 20),
            
            // 직장 상사 카테고리
            _buildCharacterCategory(
              title: '직장 상사',
              characters: [
                {'id': 'com_m', 'image': 'assets/images/com_m.png', 'name': '남성 상사'},
                {'id': 'com_f', 'image': 'assets/images/com_f.png', 'name': '여성 상사'},
              ],
            ),
            
            // 하단 여백 추가
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // 캐릭터 카테고리 위젯
  Widget _buildCharacterCategory({
    required String title,
    required List<Map<String, String>> characters,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: characters.map((character) {
            final isSelected = _selectedCharacter == character['id'];
            return Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedCharacter = character['id'];
                  });
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isSelected 
                        ? Colors.blue.withOpacity(0.3)
                        : Colors.grey.shade800.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? Colors.blue : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: Column(
                    children: [
                      Image.asset(
                        character['image']!,
                        width: 60,
                        height: 60,
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        character['name']!,
                        style: TextStyle(
                          fontSize: 12,
                          color: isSelected ? Colors.blue.shade300 : Colors.grey.shade300,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                        ),
                        textAlign: TextAlign.center,
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

