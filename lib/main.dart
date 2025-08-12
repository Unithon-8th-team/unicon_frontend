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
            print(
                '🔄 Consumer: isLoggedIn=${controller.isLoggedIn}, isInitialized=${controller.isInitialized}');
            if (!controller.isInitialized) {
              // 초기화되지 않았을 때 checkLoginStatus 호출
              WidgetsBinding.instance.addPostFrameCallback((_) {
                controller.checkLoginStatus();
              });
              return const Scaffold(
                  body: Center(child: CircularProgressIndicator()));
            }

            // 로그인 상태에 따른 화면 분기
            if (controller.isLoggedIn) {
              // 로그인된 경우 초기 설정 완료 여부 확인
              return FutureBuilder<bool>(
                future: controller.isFirstSetupCompleted(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Scaffold(
                        body: Center(child: CircularProgressIndicator()));
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
              // [수정된 부분] 로그인되지 않은 경우, 기존 로그인 화면 위에 '둘러보기' 버튼을 추가합니다.
              return Stack(
                alignment: Alignment.center,
                children: [
                  // 기존 로그인 화면을 그대로 보여줍니다.
                  const LoginScreen(),

                  // 화면 하단에 위치할 '둘러보기' 버튼입니다.
                  Positioned(
                    bottom: 100, // 화면 하단에서의 높이
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[700], // 버튼 색상
                        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                      ),
                      onPressed: () {
                        // 버튼을 누르면 로그인 절차를 건너뛰고 홈 화면으로 바로 이동합니다.
                        // pushReplacement를 사용하여 뒤로가기 시 로그인 화면으로 돌아오지 않도록 합니다.
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(builder: (_) => const HomeScreen()),
                        );
                      },
                      child: const Text(
                        '로그인 없이 둘러보기',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              );
            }
          },
        ),

      ),
    );
  }
}
