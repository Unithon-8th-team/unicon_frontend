import 'package:flutter/material.dart';

class HitScreen extends StatefulWidget {
  final String? selectedCharacter;
  
  const HitScreen({
    super.key,
    this.selectedCharacter,
  });

  @override
  State<HitScreen> createState() => _HitScreenState();
}

class _HitScreenState extends State<HitScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/login_bg.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // 상단 뒤로가기 버튼
              _buildTopSection(),
              
              // 중앙 캐릭터 영역
              Expanded(
                child: _buildCharacterSection(),
              ),
              
              // 하단 정보
              _buildBottomSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.arrow_back,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCharacterSection() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 선택된 캐릭터 이미지
          Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 3,
              ),
            ),
            child: ClipOval(
              child: Image.asset(
                _getCharacterImage(),
                width: 180,
                height: 180,
                fit: BoxFit.contain,
              ),
            ),
          ),
          
          const SizedBox(height: 30),
          
          // 캐릭터 이름
          Text(
            _getCharacterName(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const SizedBox(height: 10),
          
          // 설명 텍스트
          const Text(
            '이제 이 캐릭터를 때려서\n스트레스를 해소하세요!',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // 시작 버튼
          Container(
            width: double.infinity,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.withOpacity(0.3),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: const Center(
              child: Text(
                '게임 시작!',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 20),
          
          // 선택된 캐릭터 정보
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.person,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  '선택된 캐릭터: ${_getCharacterName()}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getCharacterImage() {
    switch (widget.selectedCharacter) {
      case 'pro_m':
        return 'assets/images/pro_m.png';
      case 'pro_f':
        return 'assets/images/pro_f.png';
      case 'stu_m':
        return 'assets/images/stu_m.png';
      case 'stu_f':
        return 'assets/images/stu_f.png';
      case 'com_m':
        return 'assets/images/com_m.png';
      case 'com_f':
        return 'assets/images/com_f.png';
      default:
        return 'assets/images/pro_m.png'; // 기본값
    }
  }

  String _getCharacterName() {
    switch (widget.selectedCharacter) {
      case 'pro_m':
        return '남성 교수님';
      case 'pro_f':
        return '여성 교수님';
      case 'stu_m':
        return '남성 학생';
      case 'stu_f':
        return '여성 학생';
      case 'com_m':
        return '남성 상사';
      case 'com_f':
        return '여성 상사';
      default:
        return '기본 캐릭터';
    }
  }
}
