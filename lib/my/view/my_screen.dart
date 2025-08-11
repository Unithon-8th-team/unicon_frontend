import 'package:flutter/material.dart';

// 페이지 이동을 위한 import
import '../premium/premium.dart';
import '../button/account.dart';
import '../button/logout.dart';
import '../button/withdraw.dart';
import '../button/profile.dart'; // 프로필 수정 화면 import

class MyScreen extends StatefulWidget {
  const MyScreen({super.key});

  @override
  State<MyScreen> createState() => _MyScreenState();
}

class _MyScreenState extends State<MyScreen> {
  // 프로필 수정 버튼 오버레이의 표시 여부를 관리하는 상태
  bool _isEditOverlayVisible = false;
  // 오버레이가 나타날 위치를 저장하는 상태
  Offset _overlayPosition = Offset.zero;
  // 닉네임을 관리하는 상태 변수. 기본값 설정.
  String _nickname = '유니톤';


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Stack(
        children: [
          // 1. 기본 UI (배경, 프로필 정보, 메뉴 등)
          _buildMainContent(),

          // 2. 프로필 수정 버튼을 눌렀을 때 나타나는 오버레이
          if (_isEditOverlayVisible) _buildEditOverlay(),
        ],
      ),
    );
  }

  /// 화면의 주요 콘텐츠를 빌드하는 위젯
  Widget _buildMainContent() {
    return Stack(
      children: [
        _buildBackgroundImage(),
        SafeArea(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 120),
                _buildCharacterImage(),
                const SizedBox(height: 16),
                // 닉네임을 상태 변수로 변경
                Text(_nickname, style: const TextStyle(color: Colors.black, fontSize: 20, fontFamily: 'Pretendard', fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                const Text('cloud020300@gmail.com', style: TextStyle(color: Colors.black54, fontSize: 16, fontFamily: 'Pretendard', fontWeight: FontWeight.w500)),
                const SizedBox(height: 32),
                _buildMenuList(context),
                _buildAdBanner(context),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// 프로필 수정 오버레이를 빌드하는 위젯
  Widget _buildEditOverlay() {
    return Stack(
      children: [
        // 반투명 배경 (오버레이 바깥을 누르면 닫힘)
        GestureDetector(
          onTap: () {
            setState(() {
              _isEditOverlayVisible = false;
            });
          },
          child: Container(
            color: Colors.transparent, // 전체 화면의 탭을 감지하되 색상은 투명
          ),
        ),
        // 프로필 수정 버튼 이미지와 상호작용 영역 (클릭한 위치에 표시)
        Positioned(
          top: _overlayPosition.dy,
          left: _overlayPosition.dx,
          child: SizedBox(
            width: 200, // profileeditbutton.png의 가로 크기에 맞게 조절
            height: 100, // profileeditbutton.png의 세로 크기에 맞게 조절
            child: Stack(
              children: [
                // 실제 버튼 이미지
                Image.asset('assets/icons/profileeditbutton.png'),
                // 상단 50% 탭 영역 (오버레이 닫기)
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  height: 50, // 높이의 50%
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _isEditOverlayVisible = false;
                      });
                    },
                  ),
                ),
                // 하단 50% 탭 영역 (프로필 수정 페이지로 이동)
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  height: 50, // 높이의 50%
                  child: GestureDetector(
                    onTap: () async { // 비동기 처리
                      setState(() {
                        _isEditOverlayVisible = false; // 오버레이 닫기
                      });
                      // ProfileScreen으로 이동하고, 결과를 받음
                      final newNickname = await Navigator.push<String>(
                        context,
                        MaterialPageRoute(builder: (context) => ProfileScreen(currentNickname: _nickname)),
                      );

                      // 결과가 null이 아니고 비어있지 않다면 닉네임 업데이트
                      if (newNickname != null && newNickname.isNotEmpty) {
                        setState(() {
                          _nickname = newNickname;
                        });
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// 화면 배경 이미지를 빌드합니다.
  Widget _buildBackgroundImage() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Image.asset(
        'assets/images/day_background_semi.png',
        width: double.infinity,
        height: 250,
        fit: BoxFit.cover,
      ),
    );
  }

  /// 캐릭터 이미지와 수정 버튼을 빌드합니다.
  Widget _buildCharacterImage() {
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            border: Border.all(color: Colors.grey.shade300, width: 2),
            image: const DecorationImage(
              image: AssetImage('assets/images/character_4.png'),
              fit: BoxFit.contain,
            ),
          ),
        ),
        // 수정 버튼 (아이콘에서 이미지로 변경 및 탭 기능 추가)
        GestureDetector(
          // onTap 대신 onTapDown을 사용하여 탭 위치를 정확히 얻음
          onTapDown: (details) {
            setState(() {
              // 클릭된 위치를 상태에 저장
              _overlayPosition = details.globalPosition;
              _isEditOverlayVisible = true;
            });
          },
          child: SizedBox(
            width: 38,
            height: 38,
            // 이미지 경로 수정
            child: Image.asset('assets/icons/profileedit.png'),
          ),
        ),
      ],
    );
  }

  /// 설정 메뉴 리스트를 빌드합니다.
  Widget _buildMenuList(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        children: [
          _buildMenuListItem(context, title: '구독 서비스', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const PremiumScreen()))),
          _buildMenuListItem(context, title: '계정 정보', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AccountScreen()))),
          _buildMenuListItem(context, title: '로그아웃', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const LogoutScreen()))),
          _buildMenuListItem(context, title: '회원탈퇴', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const WithdrawScreen()))),
        ],
      ),
    );
  }

  /// 각 메뉴 항목을 생성하는 위젯입니다.
  Widget _buildMenuListItem(BuildContext context, {required String title, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(width: 1, color: Colors.grey.shade300)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: const TextStyle(color: Colors.black, fontSize: 18, fontFamily: 'Pretendard', fontWeight: FontWeight.w500)),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  /// 광고 배너 위젯
  Widget _buildAdBanner(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const PremiumScreen()),
        );
      },
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24.0, 20.0, 24.0, 30.0),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10.0),
          child: Image.asset(
            'assets/images/adv.png',
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}
