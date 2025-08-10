import 'package:flutter/material.dart';
import '../../my/premium/premium.dart'; 

class MyScreen extends StatelessWidget {
  const MyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Page'),
        backgroundColor: const Color(0xFF0F0F0F),
      ),
      body: Center(
        // 화면 중앙에 버튼을 추가합니다.
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFCA5655), // 버튼 배경색
            foregroundColor: Colors.white, // 버튼 텍스트색
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              fontFamily: 'Pretendard',
            ),
          ),
          // 버튼을 눌렀을 때의 동작
          onPressed: () {
            // PremiumMembershipScreen으로 화면을 이동시킵니다.
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const PremiumMembershipScreen()),
            );
          },
          child: const Text('프리미엄 구독 서비스 바로가기'),
        ),
      ),
    );
  }
}
