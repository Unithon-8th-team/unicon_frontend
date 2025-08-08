import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import '../controller/login_controller.dart';
import '../../home/view/home_screen.dart';

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
                        final success = await controller.loginWithKakao();
                        if (success) {
                          // 로그인 성공 시 홈 화면으로 이동
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(builder: (context) => const HomeScreen()),
                          );
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
