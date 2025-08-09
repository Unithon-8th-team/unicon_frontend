import 'package:flutter/material.dart';
import '../../my/view/my_screen.dart';
import '../../hit/view/hit_screen.dart';
import '../../shop/view/shop_screen.dart';
import '../../common/custom_app_bar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 2; // 홈이 이제 인덱스 2이므로 기본값 변경

  static final List<Widget> _pages = <Widget>[
    const SizedBox.shrink(),   // 0: 채팅 (더미 - 실제로는 네비게이션으로 이동)
    const HitScreen(),          // 1: 때려줄게 (맞아줄개)
    const Center(child: Text('홈 화면', style: TextStyle(fontSize: 24))), // 2: 홈
    const SizedBox.shrink(),   // 3: 상점 (더미 - 실제로는 네비게이션으로 이동)
    const MyScreen(),           // 4: 마이
  ];

  void _onItemTapped(int index) {
    if (index == 0) { // 채팅 탭
      Navigator.pushNamed(context, '/chat');
    } else if (index == 3) { // 상점 탭
      Navigator.pushNamed(context, '/shop');
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: CustomBottomAppBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
