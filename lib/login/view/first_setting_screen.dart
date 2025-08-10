import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../home/view/home_screen.dart';

class FirstSettingScreen extends StatefulWidget {
  const FirstSettingScreen({super.key});

  @override
  State<FirstSettingScreen> createState() => _FirstSettingScreenState();
}

class _FirstSettingScreenState extends State<FirstSettingScreen>
    with TickerProviderStateMixin {
  int _currentStep = 0;
  final int _totalSteps = 5;
  
  // 입력 데이터
  DateTime _selectedDate = DateTime.now();
  String _selectedGender = ''; // 초기 선택 상태 없음
  String _userName = '';
  String _selectedPersonality = '활발한';
  String _selectedHobby = '게임';
  
  // 애니메이션을 위한 변수들
  late AnimationController _progressController;
  late Animation<double> _progressAnimation;
  double _currentProgress = 0.0;
  
  // 컨트롤러
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _personalityController = TextEditingController();
  final TextEditingController _hobbyController = TextEditingController();

  // 각 단계별 이미지
  final List<String> _stepImages = [
    'assets/images/0level.png',
    'assets/images/1level.png',
    'assets/images/2level.png',
    'assets/images/3level.png',
    'assets/images/4level.png',
  ];

  // 각 단계별 제목
  final List<String> _stepTitles = [
    '당신의 스트레스를 부셔줄 화내줄깨가 탄생을 기다리고 있어요.',
    '비슷한 나이대에게 잘 맞는 대화를 하기위해 생년월일을 알려주세요.',
    '비슷한 성별에게 잘 맞는 대화를 하기 위해 성별을 알려주세요.',
    '제가 부를 당신의 이름을 알려주세요.',
    '저와 함께 스트레스 부셔봐요!!!!',
  ];

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeInOut,
    ));
    
    _progressAnimation.addListener(() {
      setState(() {
        _currentProgress = _progressAnimation.value;
      });
    });
    
    // 초기 진행률 설정
    _updateProgress();
  }

  @override
  void dispose() {
    _progressController.dispose();
    super.dispose();
  }

  void _updateProgress() {
    // 현재 단계에 따라 시작값과 끝값 설정
    double startValue = 0.0;
    double endValue = 0.0;
    
    switch (_currentStep) {
      case 0: // 첫 번째 화면
        startValue = 0.0;
        endValue = 0.0;
        break;
      case 1: // 두 번째 화면: 0부터 1까지
        startValue = 0.0;
        endValue = 0.33;
        break;
      case 2: // 세 번째 화면: 1부터 2까지
        startValue = 0.33;
        endValue = 0.67;
        break;
      case 3: // 네 번째 화면: 2부터 3까지
        startValue = 0.67;
        endValue = 1.0;
        break;
      case 4: // 다섯 번째 화면
        startValue = 1.0;
        endValue = 1.0;
        break;
    }
    
    // 애니메이션 범위 설정
    _progressAnimation = Tween<double>(
      begin: startValue,
      end: endValue,
    ).animate(CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeInOut,
    ));
    
    // 애니메이션 시작
    _progressController.reset();
    _progressController.forward();
  }

  void _nextStep() {
    if (_currentStep < _totalSteps - 1) {
      setState(() {
        _currentStep++;
      });
      _updateProgress(); // 진행률 애니메이션 시작
    } else {
      _completeSetup();
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
      _updateProgress(); // 진행률 애니메이션 시작
    }
  }

  Future<void> _completeSetup() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // 사용자 설정 데이터 저장
      await prefs.setString('user_birth_date', _selectedDate.toIso8601String());
      await prefs.setString('user_gender', _selectedGender);
      await prefs.setString('user_name', _userName);
      await prefs.setString('user_personality', _selectedPersonality);
      await prefs.setString('user_hobby', _selectedHobby);
      await prefs.setBool('first_setup_completed', true);
      
      print('✅ 초기 설정 완료');
      
      // 홈 화면으로 이동
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()),
        );
      }
    } catch (e) {
      print('❌ 초기 설정 저장 실패: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('설정 저장에 실패했습니다: $e')),
      );
    }
  }

  Widget _buildProgressIndicator() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // 좌측 뒤로가기 버튼 (첫 번째 화면에서는 숨김)
            if (_currentStep > 0)
              GestureDetector(
                onTap: () {
                  print('🔄 뒤로가기 버튼 터치됨: 현재 단계 $_currentStep');
                  _previousStep();
                },
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
            // 첫 번째 화면에서는 빈 공간으로 대체
            if (_currentStep == 0)
              const SizedBox(width: 40),
            // 중앙 진행률 바 (3등분)
            Expanded(
              child: Container(
                height: 6,
                margin: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(3),
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: _currentProgress, // 애니메이션된 진행률 사용
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
              ),
            ),
            // 우측 진행 텍스트 (3등분)
            Text(
              '${_getCurrentStep()}/3', // 3등분으로 표시
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 3등분 진행률 계산 (0, 1, 2, 3)
  double _getProgressValue() {
    switch (_currentStep) {
      case 0: return 0.0;    // 0/3
      case 1: return 0.33;   // 1/3
      case 2: return 0.67;   // 2/3
      case 3: return 1.0;    // 3/3
      case 4: return 1.0;    // 3/3 (마지막 단계)
      default: return 0.0;
    }
  }

  // 3등분 단계 표시 (1, 2, 3)
  int _getCurrentStep() {
    switch (_currentStep) {
      case 0: return 1; // 첫 번째 화면
      case 1: return 1; // 두 번째 화면 (생년월일)
      case 2: return 2; // 세 번째 화면 (성별)
      case 3: return 3; // 네 번째 화면 (이름) - 3/3으로 수정
      case 4: return 3; // 다섯 번째 화면 (마지막)
      default: return 1;
    }
  }

  Widget _buildStepContent() {
    switch (_currentStep) {
      case 0:
        return _buildWelcomeStep();
      case 1:
        return _buildBirthDateStep();
      case 2:
        return _buildGenderStep();
      case 3:
        return _buildNameStep();
      case 4:
        return _buildFinalStep();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildWelcomeStep() {
    return const SizedBox.shrink(); // 첫 번째 화면에서는 텍스트를 메인 레이아웃에서 처리
  }

  Widget _buildBirthDateStep() {
    return Column(
      children: [
        // 이미지 밑에 년/월/일 선택 토글
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // 년도 선택
              Column(
                children: [
                  const Text(
                    '년',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 120,
                    width: 80,
                    child: ListWheelScrollView(
                      itemExtent: 40,
                      diameterRatio: 1.5,
                      physics: const FixedExtentScrollPhysics(),
                      onSelectedItemChanged: (index) {
                        HapticFeedback.selectionClick();
                        setState(() {
                          _selectedDate = DateTime(
                            DateTime.now().year - 40 + index,
                            _selectedDate.month,
                            _selectedDate.day,
                          );
                        });
                      },
                      children: List.generate(80, (index) {
                        final year = DateTime.now().year - 40 + index;
                        return Center(
                          child: Text(
                            year.toString(),
                            style: TextStyle(
                              color: year == _selectedDate.year 
                                ? Colors.yellow 
                                : Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                ],
              ),
              // 월 선택
              Column(
                children: [
                  const Text(
                    '월',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 120,
                    width: 80,
                    child: ListWheelScrollView(
                      itemExtent: 40,
                      diameterRatio: 1.5,
                      physics: const FixedExtentScrollPhysics(),
                      onSelectedItemChanged: (index) {
                        HapticFeedback.selectionClick();
                        setState(() {
                          _selectedDate = DateTime(
                            _selectedDate.year,
                            index + 1,
                            _selectedDate.day,
                          );
                        });
                      },
                      children: List.generate(12, (index) {
                        final month = index + 1;
                        return Center(
                          child: Text(
                            month.toString().padLeft(2, '0'),
                            style: TextStyle(
                              color: month == _selectedDate.month 
                                ? Colors.yellow 
                                : Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                ],
              ),
              // 일 선택
              Column(
                children: [
                  const Text(
                    '일',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 120,
                    width: 80,
                    child: ListWheelScrollView(
                      itemExtent: 40,
                      diameterRatio: 1.5,
                      physics: const FixedExtentScrollPhysics(),
                      onSelectedItemChanged: (index) {
                        HapticFeedback.selectionClick();
                        setState(() {
                          _selectedDate = DateTime(
                            _selectedDate.year,
                            _selectedDate.month,
                            index + 1,
                          );
                        });
                      },
                      children: List.generate(31, (index) {
                        final day = index + 1;
                        return Center(
                          child: Text(
                            day.toString().padLeft(2, '0'),
                            style: TextStyle(
                              color: day == _selectedDate.day 
                                ? Colors.yellow 
                                : Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildGenderStep() {
    return Column(
      children: [
        // 상단 여백 제거 - 뒤로가기 버튼과 겹치지 않도록
        Text(
          _stepTitles[_currentStep],
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),
        Column(
          children: [
            _buildGenderButton('남자', 'male'),
            const SizedBox(height: 20),
            _buildGenderButton('여자', 'female'),
            const SizedBox(height: 20),
            _buildGenderButton('기타', 'other'),
          ],
        ),
      ],
    );
  }

  // 가로로 배치된 성별 선택 버튼 (하단용)
  Widget _buildGenderButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildGenderButton('남자', 'male'),
        _buildGenderButton('여자', 'female'),
        _buildGenderButton('기타', 'other'),
      ],
    );
  }

  Widget _buildGenderButton(String label, String value) {
    final isSelected = _selectedGender == label; // value 대신 label로 비교
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedGender = label; // value 대신 label로 저장
        });
      },
      child: Container(
        width: 80,
        height: 45,
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(7.5),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.black : Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNameStep() {
    return Column(
      children: [
        Container(
          width: 280,
          // 줄인 세로 길이 적용
          height: 45,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.white.withOpacity(0.3)),
          ),
          alignment: Alignment.center,
          child: TextField(
            controller: _nameController,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
            decoration: InputDecoration(
              hintText: '당신의 이름은?',
              hintStyle: TextStyle(
                color: Colors.white.withOpacity(0.6),
                fontSize: 16,
              ),
              border: InputBorder.none,
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 8, // 기존 15에서 줄임
              ),
              suffixIcon: _nameController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear, color: Colors.white),
                    onPressed: () {
                      _nameController.clear();
                      setState(() {});
                    },
                  )
                : null,
            ),
            onChanged: (value) {
              setState(() {
                _userName = value;
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFinalStep() {
    return Column(
      children: [
        const SizedBox(height: 40),
        Text(
          _stepTitles[_currentStep],
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildNextButton() {
    final isLastStep = _currentStep == _totalSteps - 1;
    final canProceed = _canProceedToNext();
    
    return Positioned(
      bottom: 50,
      right: 30,
      child: GestureDetector(
        onTap: canProceed ? _nextStep : null,
        child: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: canProceed ? Colors.white : Colors.white.withOpacity(0.3),
            shape: BoxShape.circle,
            boxShadow: canProceed ? [
              BoxShadow(
                color: Colors.white.withOpacity(0.3),
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ] : null,
          ),
          child: Icon(
            isLastStep ? Icons.check : Icons.arrow_forward,
            color: canProceed ? Colors.black : Colors.white.withOpacity(0.5),
            size: 30,
          ),
        ),
      ),
    );
  }

  bool _canProceedToNext() {
    switch (_currentStep) {
      case 0: // 환영 단계
        return true;
      case 1: // 생년월일
        return _selectedDate != DateTime.now();
      case 2: // 성별
        return _selectedGender.isNotEmpty;
      case 3: // 이름
        return _userName.trim().isNotEmpty;
      case 4: // 마지막 단계
        return true;
      default:
        return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false, // 키보드가 올라와도 레이아웃 변경 방지
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/new_bg.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // 진행률 표시 (첫 번째 화면에서는 숨김)
              if (_currentStep > 0) _buildProgressIndicator(),
              
              // 배경 이미지
              Positioned.fill(
                child: Align(
                  alignment: Alignment.topCenter,
                  child: Container(
                    margin: const EdgeInsets.only(top: 130), // 원하는 만큼 위로 올리기 (값 조정 가능)
                    width: 350,
                    height: 350,
                    child: Image.asset(
                      _stepImages[_currentStep],
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
              
              // 중앙 콘텐츠
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const SizedBox(height: 100), // 상단 여백 추가
                    // 첫 번째 화면일 때는 텍스트를 먼저 표시
                    if (_currentStep == 0) ...[
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 30),
                        child: Text(
                          _stepTitles[_currentStep],
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            height: 1.4,
                          ),
                          textAlign: TextAlign.left,
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                    
                    // 두 번째 화면일 때는 텍스트를 먼저 표시
                    if (_currentStep == 1) ...[
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 30),
                        child: Text(
                          _stepTitles[_currentStep],
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            height: 1.4,
                          ),
                          textAlign: TextAlign.left,
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                    
                    // 세 번째 화면일 때는 텍스트를 먼저 표시
                    if (_currentStep == 2) ...[
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 30),
                        child: Text(
                          _stepTitles[_currentStep],
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            height: 1.4,
                          ),
                          textAlign: TextAlign.left,
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                    
                    // 네 번째 화면일 때는 텍스트를 먼저 표시
                    if (_currentStep == 3) ...[
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 30),
                        child: Text(
                          _stepTitles[_currentStep],
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            height: 1.4,
                          ),
                          textAlign: TextAlign.left,
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                    
                    // 첫 번째, 두 번째, 세 번째, 네 번째 화면이 아닐 때 콘텐츠 표시
                    if (_currentStep > 3) ...[
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 30),
                        child: _buildStepContent(),
                      ),
                    ],
                  ],
                ),
              ),
              
              // 두 번째 화면의 생년월일 토글 (하단에 배치)
              if (_currentStep == 1)
                Positioned(
                  bottom: 130, // 다음 버튼 위에 배치
                  left: 0,
                  right: 0,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    child: _buildBirthDateStep(),
                  ),
                ),
              
              // 세 번째 화면의 성별 선택 버튼 (화면 중간 아래에 배치)
              if (_currentStep == 2)
                Positioned(
                  top: MediaQuery.of(context).size.height * 0.6, // 화면 높이의 60% 위치
                  left: 0,
                  right: 0,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    child: _buildGenderButtons(),
                  ),
                ),
              
              // 네 번째 화면의 이름 입력 박스 (화면 하단에 배치)
              if (_currentStep == 3)
                Positioned(
                  bottom: 286, // 다음 버튼 위에 배치
                  left: 0,
                  right: 0,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    child: _buildNameStep(),
                  ),
                ),
              
              // 다음 버튼
              _buildNextButton(),
              
            ],
          ),
        ),
      ),
    );
  }
}
