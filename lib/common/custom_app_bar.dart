import 'package:flutter/material.dart';

class CustomBottomAppBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const CustomBottomAppBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      items: [
        // 0: 채팅
        BottomNavigationBarItem(
          icon: Image.asset(
            currentIndex == 0 ? 'assets/icons/chat_on.png' : 'assets/icons/chat_off.png',
            width: 75,
            height: 75,
          ),
          label: '',
        ),
        // 1: 때려줄게 (맞아줄개)
        BottomNavigationBarItem(
          icon: Image.asset(
            currentIndex == 1 ? 'assets/icons/hit_on.png' : 'assets/icons/hit_off.png',
            width: 75,
            height: 75,
          ),
          label: '',
        ),
        // 2: 홈
        BottomNavigationBarItem(
          icon: Image.asset(
            currentIndex == 2 ? 'assets/icons/home_on.png' : 'assets/icons/home_off.png',
            width: 75,
            height: 75,
          ),
          label: '',
        ),
        // 3: 상점
        BottomNavigationBarItem(
          icon: Image.asset(
            currentIndex == 3 ? 'assets/icons/shop_on.png' : 'assets/icons/shop_off.png',
            width: 75,
            height: 75,
          ),
          label: '',
        ),
        // 4: 마이
        BottomNavigationBarItem(
          icon: Image.asset(
            currentIndex == 4 ? 'assets/icons/my_on.png' : 'assets/icons/my_off.png',
            width: 75,
            height: 75,
          ),
          label: '',
        ),
      ],
      currentIndex: currentIndex,
      selectedItemColor: Colors.black,
      unselectedItemColor: Colors.grey,
      onTap: onTap,
      type: BottomNavigationBarType.fixed,
      backgroundColor: Colors.transparent,
      elevation: 0,
    );
  }
}
