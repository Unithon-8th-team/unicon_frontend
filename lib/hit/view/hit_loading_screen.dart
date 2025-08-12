import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:ui'; // 블러 효과를 위해 추가
import 'package:shared_preferences/shared_preferences.dart';
import 'hit_screen.dart';
import '../../home/view/home_screen.dart'; // 홈스크린 경로 추가

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


// --- ✨ 재사용 가능 로딩 위젯 (UI 수정됨) ---
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
              // ✨ 핵심 수정: 자막 위치를 캐릭터 머리 위로 조정
              Positioned(
                bottom: 185, // 캐릭터 높이(80) + 캐릭터 bottom(100) + 여백(5)
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

class _HitLoadingScreenState extends State<HitLoadingScreen> with TickerProviderStateMixin {
  late AnimationController _modalController;
  late Animation<double> _modalAnimation;
  
  double _dragOffset = 0.0;
  bool _isAppLoading = true;
  bool _showModal = false;
  int _currentMainPage = 0;
  bool _isPremiumMember = false;
  String? _selectedCharacter;

  @override
  void initState() {
    super.initState();
    _checkPremiumMembership();
    _modalController = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _modalAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(CurvedAnimation(parent: _modalController, curve: Curves.easeOutBack));
  }

  void _checkPremiumMembership() async {
    final prefs = await SharedPreferences.getInstance();
    _isPremiumMember = prefs.getBool('is_premium_member') ?? true;
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

  void _goToPage(int page) {
    setState(() {
      _currentMainPage = page;
    });
  }
  
  void _startHitGame() {
    if (context.mounted) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HitScreen(selectedCharacter: _selectedCharacter)));
    }
  }

  @override
  void dispose() {
    _modalController.dispose();
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
        final modalH = screenH * 0.95;
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
    switch (_currentMainPage) {
      case 0:
        return Container(key: const ValueKey<int>(0), child: _buildMembershipPage());
      case 1:
        return Container(key: const ValueKey<int>(1), child: _buildCharacterSelectionPage());
      case 2:
        return Container(key: const ValueKey<int>(2), child: _buildPromptPage());
      case 3:
        return Container(key: const ValueKey<int>(3), child: CharacterCustomizationFlow(onExit: () => _goToPage(0)));
      default:
        return Container(key: const ValueKey<int>(0), child: _buildMembershipPage());
    }
  }

  Widget _buildMembershipPage() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(),
          _buildOptionButton(
            title: '기본',
            subtitle: '기본 버전',
            color: Colors.lightBlue.shade300,
            onTap: () => _goToPage(1),
          ),
          const SizedBox(height: 30),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('프리미엄 멤버십 전용', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.orange.shade400)),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: _buildPremiumOptionButton(text: '프롬프트 입력하기', onTap: () => _goToPage(2))),
                  const SizedBox(width: 12),
                  Expanded(child: _buildPremiumOptionButton(text: '나만의 커스터마이징 하기', onTap: () => _goToPage(3))),
                ],
              ),
            ],
          ),
          const Spacer(flex: 2),
        ],
      ),
    );
  }

  Widget _buildCharacterSelectionPage() {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 40, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('어떤 캐릭터를 원하시나요?', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
                  const SizedBox(height: 24),
                  _buildCharacterCategory(title: '교수님', characters: [{'id': 'pro_m', 'image': 'assets/images/pro_m.png', 'name': '남성 교수님'}, {'id': 'pro_f', 'image': 'assets/images/pro_f.png', 'name': '여성 교수님'}]),
                  const SizedBox(height: 20),
                  _buildCharacterCategory(title: '팀플 조원', characters: [{'id': 'stu_m', 'image': 'assets/images/stu_m.png', 'name': '남성 학생'}, {'id': 'stu_f', 'image': 'assets/images/stu_f.png', 'name': '여성 학생'}]),
                  const SizedBox(height: 20),
                  _buildCharacterCategory(title: '직장 상사', characters: [{'id': 'com_m', 'image': 'assets/images/com_m.png', 'name': '남성 상사'}, {'id': 'com_f', 'image': 'assets/images/com_f.png', 'name': '여성 상사'}]),
                ],
              ),
            ),
          ),
        ),
         Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _goToPage(0),
                  style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16), side: BorderSide(color: Colors.blue.shade400)),
                  child: const Text('이전', style: TextStyle(color: Colors.blue, fontSize: 16, fontWeight: FontWeight.w600)),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: _selectedCharacter != null ? _startHitGame : null,
                  style: ElevatedButton.styleFrom(backgroundColor: _selectedCharacter != null ? Colors.blue : Colors.grey.shade600, padding: const EdgeInsets.symmetric(vertical: 16)),
                  child: Text('때려줄게 시작!', style: TextStyle(color: _selectedCharacter != null ? Colors.white : Colors.grey.shade400, fontSize: 16, fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  Widget _buildPromptPage() {
    return PromptPage(
      onExit: () => _goToPage(0),
      onComplete: (Map<String, String?> generatedParts) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => FinalConfirmationPage(
              selectedParts: generatedParts,
              onRedo: () => Navigator.of(context).pop(),
              onConfirm: () {
                 Navigator.of(context).pushReplacement(
                   MaterialPageRoute(builder: (_) => SuccessPage(selectedParts: generatedParts))
                 );
              },
            ),
          ),
        );
      },
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
                      Image.asset(character['image']!, width: 60, height: 60, fit: BoxFit.contain, errorBuilder: (c,e,s) => Container(height: 60, color: Colors.grey.shade700)),
                      const SizedBox(height: 8),
                      Text(character['name']!, style: TextStyle(fontSize: 12, color: isSelected ? Colors.blue.shade300 : Colors.grey.shade300, fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal), textAlign: TextAlign.center),
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

  Widget _buildOptionButton({required String title, required String subtitle, required Color color, required VoidCallback onTap}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: color)),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: onTap,
          child: GestureDetector(
            onVerticalDragStart: (_) {},
            child: Container(
              width: double.infinity,
              height: 50,
              decoration: BoxDecoration(color: const Color(0xFF2A2A2A), borderRadius: BorderRadius.circular(8)),
              child: Center(child: Text(subtitle, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500))),
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildPremiumOptionButton({required String text, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: GestureDetector(
        onVerticalDragStart: (_) {},
        child: Container(
          height: 50,
          decoration: BoxDecoration(color: const Color(0xFF2A2A2A), borderRadius: BorderRadius.circular(8)),
          child: Center(child: Text(text, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500), textAlign: TextAlign.center)),
        ),
      ),
    );
  }
}

// --- ✨ 새로운 프롬프트 페이지 위젯 ---
class PromptPage extends StatefulWidget {
  final VoidCallback onExit;
  final Function(Map<String, String?> generatedParts) onComplete;
  const PromptPage({super.key, required this.onExit, required this.onComplete});

  @override
  State<PromptPage> createState() => _PromptPageState();
}

class _PromptPageState extends State<PromptPage> {
  bool _isProcessing = false;

  void _startProcessing() {
    setState(() {
      _isProcessing = true;
    });
  }

  void _onProcessingComplete() {
    final Map<String, String?> dummyParts = {
      'clothes': 'clothes_01.png', 'hair': 'hair_15.png', 'eyes': 'eyes_03.png',
      'nose': 'nose_01.png', 'mouth': 'mouse_02.png', 'eyebrow': 'eyebrow_01.png',
    };
    widget.onComplete(dummyParts);
    if (mounted) {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isProcessing) {
      return CustomLoadingWidget(
        duration: const Duration(seconds: 3),
        onLoadingComplete: _onProcessingComplete,
      );
    }

    const pretendardFont = 'Pretendard';
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20), onPressed: widget.onExit),
                SizedBox(
                  width: 90, height: 6,
                  child: Stack(
                    children: [
                      Container(decoration: ShapeDecoration(color: const Color(0x7F858585), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(99)))),
                      Container(width: 45, decoration: ShapeDecoration(color: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(99)))),
                    ],
                  ),
                ),
                IconButton(icon: const Icon(Icons.close, color: Colors.white, size: 24), onPressed: widget.onExit),
              ],
            ),
            const Spacer(flex: 2),
            const Text('원하는 캐릭터의 모습을\n자유롭게 말씀해 주세요!', textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 24, fontFamily: pretendardFont, fontWeight: FontWeight.w600, height: 1.25)),
            const SizedBox(height: 40),
            Text('# 눈썹을 찡그린 남자 직장상사의 모습을 그려줘', style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 16, fontFamily: pretendardFont, fontWeight: FontWeight.w400)),
            const SizedBox(height: 16),
             GestureDetector(
              onVerticalDragStart: (_) {},
              child: TextField(
                style: const TextStyle(color: Colors.black, fontFamily: pretendardFont),
                decoration: InputDecoration(
                  hintText: '캐릭터 모습',
                  hintStyle: const TextStyle(color: Color(0xFF595959), fontFamily: pretendardFont),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(25), borderSide: BorderSide.none),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
                  suffixIcon: Padding(padding: const EdgeInsets.only(right: 8.0), child: IconButton(icon: const Icon(Icons.send, color: Colors.black54), onPressed: () {})),
                ),
              ),
            ),
            const Spacer(flex: 3),
            ElevatedButton(
              onPressed: _startProcessing,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, minimumSize: const Size(double.infinity, 50), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
              child: const Text('다음', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}


// --- ✨ 새로운 커스터마이징 플로우 위젯 ---
class CharacterCustomizationFlow extends StatefulWidget {
  final VoidCallback onExit;
  const CharacterCustomizationFlow({super.key, required this.onExit});

  @override
  State<CharacterCustomizationFlow> createState() => _CharacterCustomizationFlowState();
}

class _CharacterCustomizationFlowState extends State<CharacterCustomizationFlow> {
  int _currentStep = 0;
  bool _isCompleting = false;
  final Map<String, String?> _selectedParts = {
    'clothes': null, 'eyes': null, 'nose': null, 'mouth': null,
    'eyebrow': null, 'hair': null, 'beard': null, 'accessories': null,
  };

  bool get isNextButtonEnabled {
    final currentStepData = customizationStepsData[_currentStep];
    if (currentStepData['isOptional'] as bool) return true;
    return _selectedParts[currentStepData['key']] != null;
  }

  void _onNextStep() {
    if (_currentStep < customizationStepsData.length - 1) {
      setState(() => _currentStep++);
    } else {
      setState(() => _isCompleting = true);
    }
  }

  void _onCompletionLoadingEnd() {
    if (mounted) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => FinalConfirmationPage(
            selectedParts: _selectedParts,
            onRedo: () {
              Navigator.of(context).pop();
              setState(() {
                _currentStep = 0;
                _isCompleting = false;
                _selectedParts.updateAll((key, value) => null);
              });
            },
            onConfirm: () {
               Navigator.of(context).pushReplacement(
                 MaterialPageRoute(builder: (_) => SuccessPage(selectedParts: _selectedParts))
               );
            },
          ),
        ),
      ).then((_) {
        if (mounted) {
          setState(() {
            _isCompleting = false;
          });
        }
      });
    }
  }

  void _onPreviousStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    } else {
      widget.onExit();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isCompleting) {
      return CustomLoadingWidget(
        duration: const Duration(seconds: 3),
        onLoadingComplete: _onCompletionLoadingEnd,
      );
    }

    final currentStepData = customizationStepsData[_currentStep];
    final String title = currentStepData['title'];
    final String prefix = currentStepData['prefix'];
    final int count = currentStepData['count'];
    final String currentStepKey = currentStepData['key'];
    final double progressBarWidth = 200.0;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20), onPressed: _onPreviousStep),
                Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('${_currentStep + 1}', style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
                        Text('/${customizationStepsData.length}', style: TextStyle(color: Colors.grey.shade400, fontSize: 15)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Container(
                      width: progressBarWidth,
                      height: 6,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade800,
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeOut,
                          width: progressBarWidth * ((_currentStep + 1) / customizationStepsData.length),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                IconButton(icon: const Icon(Icons.close, color: Colors.white, size: 24), onPressed: widget.onExit),
              ],
            ),
          ),
          Expanded(
            flex: 3,
            child: Center(
              child: LayeredCharacter(selectedParts: _selectedParts),
            ),
          ),
          Expanded(
            flex: 4,
            child: Container(
              padding: const EdgeInsets.only(top: 20),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
              ),
              child: Column(
                children: [
                  Text(title, style: const TextStyle(color: Colors.black, fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  Expanded(
                    child: GridView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: count,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4, crossAxisSpacing: 10, mainAxisSpacing: 10),
                      itemBuilder: (context, index) {
                        final itemNumber = (index + 1).toString().padLeft(2, '0');
                        final fileName = '$prefix$itemNumber.png';
                        final isSelected = _selectedParts[currentStepKey] == fileName;

                        return GestureDetector(
                          onTap: () => setState(() => _selectedParts[currentStepKey] = fileName),
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: isSelected ? Colors.blue : Colors.grey.shade300, width: isSelected ? 3 : 1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.asset('assets/images/$fileName', fit: BoxFit.contain, errorBuilder: (c,e,s) => Container(color: Colors.grey.shade200, child: Center(child: Text(itemNumber, style: const TextStyle(color: Colors.black))))),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: ElevatedButton(
                      onPressed: isNextButtonEnabled ? _onNextStep : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isNextButtonEnabled ? Colors.blue : Colors.grey.shade700,
                        minimumSize: const Size(double.infinity, 50),
                      ),
                      child: Text(
                        _currentStep == customizationStepsData.length - 1 ? '완료' : '다음',
                        style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                      ),
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

// --- ✨ 새로운 펀치 효과가 적용된 캐릭터 위젯 ---
class LayeredCharacter extends StatefulWidget {
  final Map<String, String?> selectedParts;
  final double width;
  final Function(bool isPunching)? onPunch;

  const LayeredCharacter({
    super.key,
    required this.selectedParts,
    this.width = 250,
    this.onPunch,
  });

  @override
  State<LayeredCharacter> createState() => _LayeredCharacterState();
}

class _LayeredCharacterState extends State<LayeredCharacter> {
  bool _showPunch = false;

  void _triggerPunchEffect() {
    widget.onPunch?.call(true);
    setState(() => _showPunch = true);
    Timer(const Duration(milliseconds: 300), () {
      if (mounted) {
        setState(() => _showPunch = false);
        widget.onPunch?.call(false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _triggerPunchEffect,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Image.asset('assets/images/base_character.png', width: widget.width, errorBuilder: (c,e,s) => Container(width: widget.width * 0.8, height: widget.width * 1.4, color: Colors.grey, child: const Center(child: Text("Base")))),
          ..._buildLayers(),
          if (_showPunch)
            Image.asset('assets/images/punch.png', width: widget.width, errorBuilder: (c,e,s) => const SizedBox.shrink()),
        ],
      ),
    );
  }

  List<Widget> _buildLayers() {
    final List<Widget> layers = [];
    final layerOrder = ['clothes', 'eyes', 'nose', 'mouth', 'eyebrow', 'hair', 'beard', 'accessories'];
    for (var key in layerOrder) {
      final part = widget.selectedParts[key];
      if (part != null) {
        layers.add(Image.asset('assets/images/$part', width: widget.width, errorBuilder: (c, e, s) => const SizedBox.shrink()));
      }
    }
    return layers;
  }
}


// --- 최종 확인 페이지 ---
class FinalConfirmationPage extends StatefulWidget {
  final Map<String, String?> selectedParts;
  final VoidCallback onRedo;
  final VoidCallback onConfirm;

  const FinalConfirmationPage({super.key, required this.selectedParts, required this.onRedo, required this.onConfirm});

  @override
  State<FinalConfirmationPage> createState() => _FinalConfirmationPageState();
}

class _FinalConfirmationPageState extends State<FinalConfirmationPage> {
  bool _isPunching = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent, // 배경을 투명하게 하여 Stack 배경이 보이도록 함
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/images/punch_background.png',
            fit: BoxFit.cover,
            errorBuilder: (c,e,s) => Container(color: const Color(0xFF232323)), // 에러 시 기본 배경색
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 100),
                  const Text('생성된 캐릭터가\n마음에 드나요?', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w600)),
                  const Spacer(),
                  Center(
                    child: LayeredCharacter(
                      selectedParts: widget.selectedParts,
                      onPunch: (isPunching) => setState(() => _isPunching = isPunching),
                    ),
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: widget.onConfirm,
                          style: ElevatedButton.styleFrom(backgroundColor: const Color(0x7F7F8AFF), padding: const EdgeInsets.symmetric(vertical: 15), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100))),
                          child: const Text('네! 마음에 들어요', style: TextStyle(color: Colors.white, fontSize: 18)),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: widget.onRedo,
                          style: ElevatedButton.styleFrom(backgroundColor: const Color(0x7FFF5252), padding: const EdgeInsets.symmetric(vertical: 15), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100))),
                          child: const Text('다시 제작할래요', style: TextStyle(color: Colors.white, fontSize: 18)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// --- 최종 완료 페이지 ---
class SuccessPage extends StatefulWidget {
  final Map<String, String?> selectedParts;
  const SuccessPage({super.key, required this.selectedParts});

  @override
  State<SuccessPage> createState() => _SuccessPageState();
}

class _SuccessPageState extends State<SuccessPage> {
  bool _isPunching = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
       backgroundColor: Colors.transparent,
       body: Stack(
         fit: StackFit.expand,
         children: [
           Image.asset(
              'assets/images/punch_background.png',
              fit: BoxFit.cover,
              errorBuilder: (c,e,s) => Container(color: const Color(0xFF232323)),
            ),
           SafeArea(
             child: Column(
               mainAxisAlignment: MainAxisAlignment.center,
               children: [
                 const Spacer(flex: 2),
                 const Text("캐릭터 생성 완료!", style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                 const SizedBox(height: 40),
                 LayeredCharacter(
                   selectedParts: widget.selectedParts,
                   onPunch: (isPunching) => setState(() => _isPunching = isPunching),
                 ),
                 const Spacer(flex: 3),
                 Padding(
                   padding: const EdgeInsets.all(20.0),
                   child: ElevatedButton(
                     onPressed: () {
                       Navigator.of(context).pushAndRemoveUntil(
                         MaterialPageRoute(builder: (_) => const HomeScreen()),
                         (route) => false,
                       );
                     },
                     style: ElevatedButton.styleFrom(
                       backgroundColor: const Color(0x7F424242),
                       minimumSize: const Size(double.infinity, 50),
                       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                     ),
                     child: const Text('홈으로 돌아가기', style: TextStyle(color: Colors.white, fontSize: 20)),
                   ),
                 ),
               ],
             ),
           ),
         ],
       ),
    );
  }
}


// --- 기존 분리된 위젯들 ---
class _MessageSection extends StatelessWidget {
  const _MessageSection();
  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink(); // 로딩 위젯에서 직접 처리하므로 비워둡니다.
  }
}

class _BottomSection extends StatelessWidget {
  final Animation<double> progressAnimation;
  final Animation<double> characterAnimation;
  const _BottomSection({required this.progressAnimation, required this.characterAnimation});

  @override
  Widget build(BuildContext context) {
    // ✨ 핵심 수정: 로딩 UI 레이아웃 변경
    return AnimatedBuilder(
      animation: Listenable.merge([progressAnimation, characterAnimation]),
      builder: (context, child) {
        return Stack(
          children: [
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
                    width: (MediaQuery.of(context).size.width - 60) * progressAnimation.value,
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4)),
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 115,
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
            Positioned(
              left: characterAnimation.value * (MediaQuery.of(context).size.width - 80),
              bottom: 100,
              child: Image.asset('assets/images/hit_loding.png', width: 80, height: 80, fit: BoxFit.contain),
            ),
          ],
        );
      },
    );
  }
}