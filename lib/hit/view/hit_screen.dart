import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/services.dart';
import '../../home/view/home_screen.dart';
import 'package:audioplayers/audioplayers.dart';

class HitScreen extends StatefulWidget {
  final String? selectedCharacter;
  
  const HitScreen({
    super.key,
    this.selectedCharacter,
  });

  @override
  State<HitScreen> createState() => _HitScreenState();
}

class _HitScreenState extends State<HitScreen> with TickerProviderStateMixin {
  final GlobalKey _characterStackKey = GlobalKey();

  // 탭 이펙트(리플)
  final List<_TapRipple> _ripples = [];

  // 효과음
  late final AudioPlayer _sfxPlayer;

  @override
  void initState() {
    super.initState();
    _sfxPlayer = AudioPlayer()..setReleaseMode(ReleaseMode.stop);
  }

  @override
  void dispose() {
    for (final r in _ripples) {
      r.controller.dispose();
    }
    _sfxPlayer.dispose();
    super.dispose();
  }

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
            onTap: () {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const HomeScreen()),
                (route) => false,
              );
            },
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
      child: SizedBox(
        width: 380,
        height: 380,
        child: Stack(
          key: _characterStackKey,
          clipBehavior: Clip.none,
          children: [
            // 탭 리플 이펙트들
            ..._ripples.map((r) => Positioned(
                  left: r.position.dx - r.size.value / 2,
                  top: r.position.dy - r.size.value / 2,
                  child: Opacity(
                    opacity: r.opacity.value,
                    child: Container(
                      width: r.size.value,
                      height: r.size.value,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.35),
                      ),
                    ),
                  ),
                )),

            // 캐릭터 이미지 (고정 위치)
            Center(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTapDown: (details) async {
                  // 정확한 좌표: Stack 기준의 로컬 좌표로 변환
                  final box = _characterStackKey.currentContext?.findRenderObject() as RenderBox?;
                  final local = box != null
                      ? box.globalToLocal(details.globalPosition)
                      : details.localPosition;
                  _spawnRipple(local);

                  // 햅틱 + 효과음
                  HapticFeedback.mediumImpact();
                  _playHitSfx();
                },
                child: ClipOval(
                  child: Image.asset(
                    _getCharacterImage(),
                    width: 380,
                    height: 380,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }


  String _getCharacterImage() {
    final key = (widget.selectedCharacter ?? 'pro_m').toLowerCase().trim();
    switch (key) {
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



  void _spawnRipple(Offset localPos) {
    // 리플 애니메이션: 0 → 140px, opacity 0.6 → 0.0, 250ms
    final controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    final size = Tween<double>(begin: 0, end: 140).animate(
      CurvedAnimation(parent: controller, curve: Curves.easeOutCubic),
    );
    final opacity = Tween<double>(begin: 0.6, end: 0.0).animate(
      CurvedAnimation(parent: controller, curve: Curves.easeOut),
    );

    final ripple = _TapRipple(
      position: localPos,
      controller: controller,
      size: size,
      opacity: opacity,
    );

    controller.addListener(() {
      setState(() {});
    });
    controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        controller.dispose();
        setState(() {
          _ripples.remove(ripple);
        });
      }
    });

    setState(() {
      _ripples.add(ripple);
    });

    controller.forward();
  }

  Future<void> _playHitSfx() async {
    try {
      await _sfxPlayer.stop();
      await _sfxPlayer.play(AssetSource('sfx/hit.mp3'));
    } catch (e) {
      // 무음 환경/미등록 에셋일 수 있으니 조용히 무시
    }
  }
}

class _TapRipple {
  _TapRipple({
    required this.position,
    required this.controller,
    required this.size,
    required this.opacity,
  });

  final Offset position;
  final AnimationController controller;
  final Animation<double> size;
  final Animation<double> opacity;
}