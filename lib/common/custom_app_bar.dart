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
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: '홈'),
        BottomNavigationBarItem(icon: Icon(Icons.chat), label: '채팅'),
        BottomNavigationBarItem(icon: Icon(Icons.pets), label: '맞아줄개'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'MY'),
      ],
      currentIndex: currentIndex,
      selectedItemColor: Colors.deepPurple,
      onTap: onTap,
      type: BottomNavigationBarType.fixed,
    );
  }
}
