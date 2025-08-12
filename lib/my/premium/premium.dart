import 'package:flutter/material.dart';
import 'dart:ui'; // ImageFilter를 사용하기 위해 dart:ui를 import 합니다.
import 'package:shared_preferences/shared_preferences.dart';

// 페이지 이동을 위한 import
import 'servicelaw.dart';
import 'privatelaw.dart';

/// 프리미엄 멤버십 화면 전체를 구성하는 메인 위젯
class PremiumScreen extends StatefulWidget {
  const PremiumScreen({super.key});

  @override
  State<PremiumScreen> createState() =>
      _PremiumScreenState();
}

// 멤버십 종류를 나타내는 Enum
enum MembershipType { yearly, monthly }


class _PremiumScreenState extends State<PremiumScreen> {
  // 현재 선택된 멤버십 상태를 관리. 기본값은 월간.
  MembershipType _selectedMembership = MembershipType.monthly;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 1. 배경 이미지 (고정)
        Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/night_background.png'),
              fit: BoxFit.cover,
            ),
          ),
        ),
        // 2. character_3 이미지 (고정)
        Positioned(
          top: 510,
          left: 0,
          right: 0,
          child: Image.asset(
            'assets/images/character_3.png',
            width: 172,
            height: 239,
            fit: BoxFit.contain,
          ),
        ),
        // 3. 검은색 오버레이 (고정) - character_3 이미지 위에 위치
        Container(
          color: const Color.fromARGB(102, 12, 10, 10),
        ),
        // 4. 스크롤 가능한 콘텐츠를 담을 투명한 Scaffold
        Scaffold(
          backgroundColor: Colors.transparent, // 배경이 보이도록 투명하게 설정
          body: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 80),
                _buildHeader(),
                const SizedBox(height: 30),
                _buildMembershipOptions(), // 블러 효과가 추가된 멤버십 선택 위젯
                const SizedBox(height: 40),
                _buildBenefitsSection(),
                const SizedBox(height: 40),
                _buildFooter(),
                const SizedBox(height: 120), // 하단 버튼을 위한 여백
              ],
            ),
          ),
        ),
        // 5. x.png 버튼 (고정)
        _buildFixedAppBar(),
        // 6. 멤버십 가입 버튼 (고정)
        _buildPurchaseButton(),
      ],
    );
  }

  // x 버튼에 뒤로가기 기능 추가
  Widget _buildFixedAppBar() {
    return Positioned(
      top: 0,
      right: 16,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.only(top: 10.0),
          child: GestureDetector(
            onTap: () {
              Navigator.of(context).pop(false); // 명시적으로 취소 결과 전달
            },
            child: Image.asset(
              'assets/icons/x.png',
              width: 34,
              height: 34,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 20.0),
          child: Image.asset(
            'assets/icons/honorfire.png',
            width: 66,
            height: 66,
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          '프리미엄',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontSize: 36,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.72,
          ),
        ),
        const Padding(
          padding: EdgeInsets.only(bottom: 8.0),
          child: Text(
            '멤버십',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w400,
              letterSpacing: 0.48,
            ),
          ),
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/character_2.png',
              width: 37,
              height: 41,
            ),
            const SizedBox(width: 8),
            const Text(
              '내가 너 대신 화내줄게 스트레스 뿌셔!!!!',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.30,
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// [수정됨] 멤버십 선택 옵션 위젯 (블러 효과 추가)
  Widget _buildMembershipOptions() {
    // 각 옵션 버튼을 생성하는 내부 함수
    Widget buildOption({
      required bool isSelected,
      required String imagePath,
      required VoidCallback onTap,
    }) {
      return GestureDetector(
        onTap: onTap,
        // ClipRRect를 사용하여 블러 효과가 이미지의 둥근 모서리에 맞게 적용되도록 함
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12.0), // 이미지 에셋의 둥근 모서리 값과 일치시키는 것이 좋음
          child: Stack(
            children: [
              // BackdropFilter를 사용하여 배경에 블러 효과(sigma: 15)를 적용
              BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 15.0, sigmaY: 15.0),
                child: Container(color: Colors.transparent), // 자식 위젯이 필요하지만 투명하게 설정
              ),
              // 실제 'on/off' 이미지를 블러 효과 위에 표시
              Image.asset(imagePath),
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        children: [
          // 연간 멤버십 옵션
          buildOption(
            isSelected: _selectedMembership == MembershipType.yearly,
            imagePath: _selectedMembership == MembershipType.yearly
                ? 'assets/images/year_on.png'
                : 'assets/images/year_off.png',
            onTap: () {
              setState(() {
                _selectedMembership = MembershipType.yearly;
              });
            },
          ),
          const SizedBox(height: 10),
          // 월간 멤버십 옵션
          buildOption(
            isSelected: _selectedMembership == MembershipType.monthly,
            imagePath: _selectedMembership == MembershipType.monthly
                ? 'assets/images/month_on.png'
                : 'assets/images/month_off.png',
            onTap: () {
              setState(() {
                _selectedMembership = MembershipType.monthly;
              });
            },
          ),
        ],
      ),
    );
  }


  Widget _buildBenefitsSection() {
    return Column(
      children: [
        const Text(
          '더 자세한 내용을 확인하세요',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.48,
          ),
        ),
        const SizedBox(height: 8),
        Image.asset(
          'assets/icons/scroll.png',
          width: 52,
          height: 90,
        ),
        const SizedBox(height: 4),
        const Text(
          '스크롤',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.40,
          ),
        ),
        const SizedBox(height: 40),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              '프리미엄 멤버십 혜택',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.40,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            children: [
              _BenefitCard(
                number: '1',
                title: '무제한 대화, 이미지 업로드 오픈',
                description: '당신의 스트레스를 마음껏 표출해 보세요',
                content: SizedBox(
                  width: 250,
                  height: 300,
                  child: Stack(
                    children: [
                      Positioned(
                        top: -24,
                        left: -8,
                        child: Image.asset('assets/images/scroll_1.png'),
                      ),
                      Positioned(
                        top: 56,
                        left: 28,
                        child: Image.asset('assets/images/scroll_2.png'),
                      ),
                    ],
                  ),
                ),
              ),
              _BenefitCard(
                number: '2',
                title: '프리미엄 데이터',
                description:
                    '화내줄깨가 당신의 데이터를 학습하여 더욱 개인화된 대화가 가능해져요',
                content: Image.asset('assets/images/scroll_3.png'),
              ),
              _BenefitCard(
                number: '3',
                title: '26,000개의 캐릭터 조합',
                description: '스트레스를 유발하는 사람과 유사한 캐릭터를 제작해 보세요',
                content: Image.asset('assets/images/scroll_4.png'),
              ),
              _BenefitCard(
                number: '4',
                title: '리워드 2배!',
                description: '더 많은 불을 모아서 화내줄깨를 예쁘게 꾸며주세요',
                content: Image.asset('assets/images/scroll_5.png'),
              ),
              _BenefitCard(
                number: '5',
                title: '다양한 옷, 헤어스타일, 아이템',
                description: '당신의 꾸미기 능력을 마음껏 뽐내 보세요\n다양한 아이템을 골라보세요',
                content: Image.asset('assets/images/scroll_6.png'),
              ),
            ],
          ),
        )
      ],
    );
  }

  /// [수정됨] 이용약관 및 개인정보처리방침 네비게이션 기능 추가
  Widget _buildFooter() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '유의사항',
            style: TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            '0000계정을 통해 결제가 이루어집니다. 연간 멤버십의 가격은 연 19,000원으로 매년 자동으로 갱신되며, 언제든 취소할 수 있습니다.',
            style: TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 30),
          // 이용약관 버튼
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ServiceLawScreen()),
              );
            },
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '이용약관',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Icon(Icons.chevron_right, color: Colors.white, size: 20),
              ],
            ),
          ),
          const SizedBox(height: 8),
          // 개인정보처리방침 버튼
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const PrivateLawScreen()),
              );
            },
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '개인정보처리방침',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Icon(Icons.chevron_right, color: Colors.white, size: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 버튼 위치를 쉽게 조정할 수 있도록 Padding 추가
  Widget _buildPurchaseButton() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Padding(
        // 이 값을 조절하여 버튼의 하단 여백을 변경할 수 있습니다.
        padding: const EdgeInsets.only(bottom: 12.0, left: 16.0, right: 16.0),
        child: GestureDetector(
          onTap: () => _handleMembershipPurchase(),
          child: Image.asset(
            _selectedMembership == MembershipType.yearly
                ? 'assets/images/membership_year.png'
                : 'assets/images/membership_month.png',
          ),
        ),
      ),
    );
  }

  // 멤버십 가입 처리
  Future<void> _handleMembershipPurchase() async {
    final pageContext = context;
    try {
      // 로딩 표시
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const AlertDialog(
            backgroundColor: Color(0xFF2A2A2A),
            content: Row(
              children: [
                CircularProgressIndicator(color: Colors.orange),
                SizedBox(width: 20),
                Text(
                  '멤버십 가입 중...',
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
          );
        },
      );

      // 실제 결제 로직은 여기에 구현 (현재는 시뮬레이션)
      await Future.delayed(const Duration(seconds: 2));

      // SharedPreferences에 멤버십 정보 저장 (세션 프리미엄은 저장하지 않음)
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('membership_type', _selectedMembership.name);
      await prefs.setInt('membership_expiry', DateTime.now().add(
        _selectedMembership == MembershipType.yearly 
            ? const Duration(days: 365)
            : const Duration(days: 30)
      ).millisecondsSinceEpoch);

      // 로딩 다이얼로그 닫기
      if (mounted) {
        Navigator.of(context).pop();
      }

      // 성공 메시지 표시
      if (mounted) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              backgroundColor: const Color(0xFF2A2A2A),
              title: const Text(
                '멤버십 가입 완료!',
                style: TextStyle(color: Colors.white),
              ),
              content: Text(
                '${_selectedMembership == MembershipType.yearly ? '연간' : '월간'} 프리미엄 멤버십이 성공적으로 가입되었습니다!',
                style: const TextStyle(color: Colors.white70),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    // 1) 성공 다이얼로그 닫기 (현재 다이얼로그 컨텍스트)
                    Navigator.of(context).pop();
                    // 2) PremiumScreen 닫기 + 결과 true 전달 (페이지 컨텍스트 사용)
                    Navigator.of(pageContext).pop(true);
                  },
                  child: const Text(
                    '확인',
                    style: TextStyle(color: Colors.orange),
                  ),
                ),
              ],
            );
          },
        );
      }

      // 프리미엄 상태 변경을 알림 (세션 플래그만 상위로 전달, 영구 저장 안 함)
      if (mounted) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt('premium_status_changed', DateTime.now().millisecondsSinceEpoch);
      }
    } catch (e) {
      // 로딩 다이얼로그 닫기
      if (mounted) {
        Navigator.of(context).pop();
      }

      // 오류 메시지 표시
      if (mounted) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              backgroundColor: const Color(0xFF2A2A2A),
              title: const Text(
                '가입 실패',
                style: TextStyle(color: Colors.red),
              ),
              content: Text(
                '멤버십 가입 중 오류가 발생했습니다: $e',
                style: const TextStyle(color: Colors.white70),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text(
                    '확인',
                    style: TextStyle(color: Colors.orange),
                  ),
                ),
              ],
            );
          },
        );
      }
    }
  }
}

/// [수정 없음] 멤버십 혜택을 표시하는 재사용 가능한 카드 위젯 (블러 효과 15 적용됨)
class _BenefitCard extends StatelessWidget {
  final String number;
  final String title;
  final String description;
  final Widget content;

  const _BenefitCard({
    required this.number,
    required this.title,
    required this.description,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.transparent, // 기존 배경색 제거
        borderRadius: BorderRadius.circular(16),
      ),
      child: Stack(
        children: [
          // 블러 효과를 위한 BackdropFilter
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                child: Container(
                  color: const Color(0x663D3D3D), // 흐릿한 배경색
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(0), // 내부 Padding 유지
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0x4C505050),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    number,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
                const SizedBox(height: 23),
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  description,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 32),
                Center(child: content),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
