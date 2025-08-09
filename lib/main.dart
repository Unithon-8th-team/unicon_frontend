import 'package:flutter/material.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'login/view/login_screen.dart';
import 'home/view/home_screen.dart';
import 'chat/view/chat_screen.dart';
import 'chat/view/chat_initial_screen.dart';
import 'shop/view/shop_screen.dart';

void main() {
  // 카카오 SDK 초기화
  KakaoSdk.init(
    nativeAppKey: '833e3e7d3339dd6dd65e8f61447d97f2', // Android/iOS용
    javaScriptAppKey: '4b1909a2acd5542075d9a7ac26814516', // Web용
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Unicon App',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
      ),
      initialRoute: '/',
      onGenerateRoute: (settings) {
        Widget page;
        switch (settings.name) {
          case '/':
            page = const LoginScreen();
            break;
          case '/home':
            page = const HomeScreen();
            break;
          case '/chat':
            page = const ChatInitialScreen();
            break;
          case '/chat/room':
            page = const ChatScreen();
            break;
          case '/shop':
            page = const ShopScreen();
            break;
          default:
            page = const LoginScreen();
        }
        
        // 애니메이션 없는 페이지 전환
        return PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionDuration: Duration.zero,
          reverseTransitionDuration: Duration.zero,
        );
      },
    );
  }
}
