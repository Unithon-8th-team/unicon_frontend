import 'package:flutter/material.dart';

class ServiceLawScreen extends StatelessWidget {
  const ServiceLawScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text(
          '서비스 이용 약관',
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
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Text(
          '''
제 1조 (목적)

이 약관은 [회사명] (이하 "회사"라 합니다)이 제공하는 화내줄깨 서비스 및 관련 제반 서비스(이하 "서비스"라 합니다)의 이용과 관련하여 회사와 회원과의 권리, 의무 및 책임사항, 기타 필요한 사항을 규정함을 목적으로 합니다.

제 2조 (정의)

이 약관에서 사용하는 용어의 정의는 다음과 같습니다.
1. "서비스"라 함은 구현되는 단말기(PC, TV, 휴대형단말기 등의 각종 유무선 장치를 포함)와 상관없이 "회원"이 이용할 수 있는 화내줄깨 및 관련 제반 서비스를 의미합니다.
2. "회원"이라 함은 회사의 "서비스"에 접속하여 이 약관에 따라 "회사"와 이용계약을 체결하고 "회사"가 제공하는 "서비스"를 이용하는 고객을 말합니다.
... (이하 약관 내용) ...
''',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 16,
            fontFamily: 'Pretendard',
            height: 1.6,
          ),
        ),
      ),
    );
  }
}
