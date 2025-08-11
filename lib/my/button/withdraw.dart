import 'package:flutter/material.dart';

class WithdrawScreen extends StatefulWidget {
  const WithdrawScreen({super.key});

  @override
  State<WithdrawScreen> createState() => _WithdrawScreenState();
}

class _WithdrawScreenState extends State<WithdrawScreen> {
  bool _isAgreed = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text(
          '회원 탈퇴',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '정말 탈퇴하시겠어요?',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                fontFamily: 'Pretendard',
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              '탈퇴 시 모든 데이터는 복구할 수 없습니다.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.black54,
                fontFamily: 'Pretendard',
              ),
            ),
            const SizedBox(height: 32),
            _buildWarningPoint(
              '지금 탈퇴하시면, 현재까지 대화했던 내용이 모두 사라집니다.',
            ),
            const SizedBox(height: 16),
            _buildWarningPoint(
              '지금 탈퇴하시면, 맞춤형 대화가 복구되지 않아요.',
            ),
            const SizedBox(height: 40),
            Row(
              children: [
                Checkbox(
                  value: _isAgreed,
                  onChanged: (bool? value) {
                    setState(() {
                      _isAgreed = value ?? false;
                    });
                  },
                  activeColor: const Color(0xFFED3D3D),
                ),
                const Expanded(
                  child: Text(
                    '회원 탈퇴 유의사항을 확인하였으며, 이에 동의합니다.',
                    style: TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isAgreed
                  ? () {
                      // TODO: 회원탈퇴 로직 구현
                      Navigator.of(context).popUntil((route) => route.isFirst);
                    }
                  : null, // 동의하지 않으면 버튼 비활성화
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFED3D3D),
                disabledBackgroundColor: Colors.grey,
                minimumSize: const Size(double.infinity, 50),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                '회원 탈퇴하기',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 주의사항 항목을 만드는 위젯
  Widget _buildWarningPoint(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 4.0, right: 8.0),
          child: Icon(Icons.warning_amber_rounded,
              color: Colors.redAccent, size: 18),
        ),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 16,
              fontFamily: 'Pretendard',
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }
}
