import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:provider/provider.dart';
import 'login/controller/login_controller.dart';
import 'login/view/login_screen.dart';
import 'home/view/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  

  
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
    return ChangeNotifierProvider(
      create: (context) {
        final controller = LoginController();
        // checkLoginStatus() 호출하지 않음 - 자동 로그인 방지
        return controller;
      },
      child: MaterialApp(
        title: 'Unicon App',
        theme: ThemeData(
          primarySwatch: Colors.deepPurple,
          fontFamily: 'Pretendard',
        ),
        debugShowCheckedModeBanner: false,
        home: Consumer<LoginController>(
          builder: (context, controller, child) {
            print('🔄 Consumer: isLoggedIn=${controller.isLoggedIn}, isInitialized=${controller.isInitialized}');
            if (!controller.isInitialized) {
              return const Scaffold(body: Center(child: CircularProgressIndicator()));
            }
            // 무조건 로그인 화면부터 시작 (자동 로그인 방지)
            return const LoginScreen();
          },
        ),
      ),
    );
  }
}