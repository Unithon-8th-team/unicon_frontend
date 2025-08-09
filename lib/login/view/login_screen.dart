import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import '../controller/login_controller.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => LoginController(),
      child: Consumer<LoginController>(
        builder: (context, controller, _) {
          return Scaffold(
            appBar: AppBar(title: const Text('카카오 로그인')),
            body: Center(
              child: controller.isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: () async {
                        // 실제 API 연결용 (웹에서는 임시 로그인, 모바일에서는 WebView)
                        final success = await controller.kakaoLogin(context);
                        
                        if (success) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('로그인 성공! 환영합니다, ${controller.user?.nickname ?? "사용자"}님!')),
                          );
                          Navigator.pushReplacementNamed(context, '/home');
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('카카오 로그인 실패')),
                          );
                        }
                      },
                      child: const Text('카카오로 로그인'),
                    ),
            ),
          );
        },
      ),
    );
  }
}
