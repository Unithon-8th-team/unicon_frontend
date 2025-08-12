import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:provider/provider.dart';
import 'login/controller/login_controller.dart';
import 'login/view/login_screen.dart';
import 'home/view/home_screen.dart';
import 'login/view/first_setting_screen.dart';

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
              // 초기화되지 않았을 때 checkLoginStatus 호출
              WidgetsBinding.instance.addPostFrameCallback((_) {
                controller.checkLoginStatus();
              });
              return const Scaffold(body: Center(child: CircularProgressIndicator()));
            }
            
            // 로그인 상태에 따른 화면 분기
            if (controller.isLoggedIn) {
              // 로그인된 경우 초기 설정 완료 여부 확인
              return FutureBuilder<bool>(
                future: controller.isFirstSetupCompleted(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Scaffold(body: Center(child: CircularProgressIndicator()));
                  }
                  
                  final isFirstSetupCompleted = snapshot.data ?? false;
                  
                  if (isFirstSetupCompleted) {
                    // 초기 설정이 완료된 경우 홈 화면으로
                    return const HomeScreen();
                  } else {
                    // 초기 설정이 완료되지 않은 경우 초기 설정 화면으로
                    return const FirstSettingScreen();
                  }
                },
              );
            } else {
              // 로그인되지 않은 경우 로그인 화면
              return const LoginScreen();
            }
          },
        ),

      ),
    );
  }
}