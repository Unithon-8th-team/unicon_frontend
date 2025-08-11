import 'package:flutter/material.dart';
import '../view/hit_loading_screen.dart';
import '../view/hit_screen.dart';

class HitNavigationService {
  static Future<void> navigateToHitScreen(BuildContext context) async {
    // 로딩 화면으로 이동
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const HitLoadingScreen(),
      ),
    );
    
    // 로딩 완료 후 hit screen으로 이동
    if (context.mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const HitScreen(),
        ),
      );
    }
  }
}
