import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:dio/dio.dart';

// 웹뷰 관련 import
import 'package:webview_flutter/webview_flutter.dart';

class OAuthWebViewScreen extends StatefulWidget {
  final String initialUrl;
  final Function(String accessToken, String refreshToken) onSuccess;
  final Function(String errorMessage) onFailure;

  const OAuthWebViewScreen({
    super.key,
    required this.initialUrl,
    required this.onSuccess,
    required this.onFailure,
  });

  @override
  State<OAuthWebViewScreen> createState() => _OAuthWebViewScreenState();
}

class _OAuthWebViewScreenState extends State<OAuthWebViewScreen> {
  late WebViewController _controller;
  bool _isLoading = true;
  bool _handled = false; // 중복 처리 방지

  @override
  void initState() {
    super.initState();
    
    // 웹뷰 컨트롤러 초기화
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            setState(() {
              _isLoading = true;
            });
            print('🌐 페이지 로딩 시작: $url');
          },
          onPageFinished: (String url) {
            setState(() {
              _isLoading = false;
            });
            print('✅ 페이지 로딩 완료: $url');
            _checkOAuthCallback(url);
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.initialUrl));
  }

    void _checkOAuthCallback(String url) {
    if (_handled) return; // 이미 처리했으면 재실행 방지
    
    if (url.contains('/auth/kakao/callback')) {
      print('✅ 카카오 OAuth 콜백 감지됨!');
      _extractTokensFromPage();
    }
  }

  void _extractTokensFromPage() async {
    try {
      final raw = await _controller.runJavaScriptReturningResult(r'''
        (function() {
          var pre = document.querySelector('pre');
          var text = pre ? (pre.textContent || pre.innerText || '') 
                         : (document.body ? (document.body.innerText || '') : '');
          return JSON.stringify(text);
        })();
      ''');

      final bodyText = jsonDecode(raw as String) as String;
      if (bodyText.isEmpty) throw Exception('빈 콜백 응답');

      final start = bodyText.indexOf('{');
      final end = bodyText.lastIndexOf('}');
      if (start < 0 || end < 0 || end <= start) {
        throw Exception('JSON 범위를 찾지 못함');
      }
      final jsonSlice = bodyText.substring(start, end + 1);
      
      // 이스케이프된 문자 디코딩
      final decodedJson = jsonSlice
          .replaceAll('\\"', '"')
          .replaceAll('\\/', '/')
          .replaceAll('\\\\', '\\');

      print('🔍 파싱할 JSON: ${decodedJson.substring(0, 100)}...');

      final jsonData = json.decode(decodedJson);
      final accessToken = jsonData['token'] ?? jsonData['accessToken'];
      final refreshToken = jsonData['refreshToken'];

      if (accessToken is String && refreshToken is String) {
        _handled = true;                  // ✅ 중복 방지
        print('✅ 토큰 추출 성공: ${accessToken.substring(0, 20)}...');
        widget.onSuccess(accessToken, refreshToken);
        return;
      }
      throw Exception('토큰 필드 누락');
    } catch (e) {
      if (!_handled) {
        _handled = true;                  // 실패도 한 번만
        print('❌ 토큰 추출 실패: $e');
        widget.onFailure('콜백 파싱 실패: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('카카오 로그인'),
        backgroundColor: Colors.yellow,
        foregroundColor: Colors.black,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              _controller.reload();
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}
