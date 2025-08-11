import 'package:flutter/material.dart';

// my_screen.dart와 닉네임 데이터를 주고받을 수 있도록 StatefulWidget으로 변경합니다.
class ProfileScreen extends StatefulWidget {
  // 이전 화면(MyScreen)에서 전달받은 현재 닉네임을 저장할 변수
  final String currentNickname;

  const ProfileScreen({
    super.key,
    required this.currentNickname,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // TextFormField의 텍스트를 제어하기 위한 컨트롤러
  late final TextEditingController _nicknameController;

  @override
  void initState() {
    super.initState();
    // 컨트롤러를 이전 화면에서 받아온 닉네임으로 초기화합니다.
    _nicknameController = TextEditingController(text: widget.currentNickname);
  }

  @override
  void dispose() {
    // 위젯이 화면에서 사라질 때 컨트롤러를 정리하여 메모리 누수를 방지합니다.
    _nicknameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text(
          '닉네임 변경',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              const Text(
                '닉네임',
                style: TextStyle(
                  color: Colors.black54,
                  fontSize: 18,
                  fontFamily: 'Pretendard',
                ),
              ),
              const SizedBox(height: 12),
              // 닉네임 입력을 위한 TextFormField
              TextFormField(
                controller: _nicknameController, // 컨트롤러 연결
                style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 18,
                  fontFamily: 'Pretendard',
                ),
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 12.0),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: const Color(0xFF595656).withOpacity(0.5),
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(
                      width: 1.5,
                      color: Color(0xFF595656),
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const Spacer(), // 버튼을 화면 하단으로 밀어냄
              // 변경하기 버튼
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    // 변경된 닉네임을 가지고 이전 화면으로 돌아갑니다.
                    Navigator.of(context).pop(_nicknameController.text);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF484747),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    '변경하기',
                    style: TextStyle(
                      fontSize: 18,
                      fontFamily: 'Pretendard',
                      fontWeight: FontWeight.w500,
                    ),
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
