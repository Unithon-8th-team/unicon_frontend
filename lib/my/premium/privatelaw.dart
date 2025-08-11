import 'package:flutter/material.dart';

class PrivateLawScreen extends StatelessWidget {
  const PrivateLawScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text(
          '개인정보처리방침',
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
화내줄깨 (이하 “회사”라 한다)은 「개인정보 보호법」에 따라 이용자의 개인정보를 보호하고 이와 관련한 고충을 신속하고 원활하게 처리할 수 있도록 하기 위하여 다음과 같이 개인정보 처리방침을 정하여 운영하고 있습니다.

제 1조 (개인정보의 수집 항목 및 목적과 보유 기간)

회사는 서비스 이용에 필요한 최소한의 개인정보를 수집합니다. 처리하고있는 개인정보는 다음의 수집•이용 목적 이외의 용도로 활용되지 않습니다.

① 회원가입 시 다음의 개인정보를 수집 이용합니다.

수집 목적
- (필수) : 회원 식별 및 관리, 서비스 이용 만족도 조사, 필수 고지•통지•안내, 업무의 회신, 서비스개선을 위한 분석, 부정행위 방지
- (선택) 마케팅, 프로모션 및 혜택 소식 알림

수집 항목
- 이름, 이메일 주소, 닉네임
- 이메일 회원가입 시 : 비밀번호
- 카카오로그인 연동 : 이메일 주소, 카카오 계정 식별값

... (이하 개인정보처리방침 내용) ...
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
