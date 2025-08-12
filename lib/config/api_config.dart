class ApiConfig {
  // 환경별 API URL 설정
  static const String _baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:3000', // 에뮬레이터 기본값
  );

  // API 엔드포인트
  static const String kakaoAuth = '/auth/kakao';
  static const String userProfile = '/users';
  static const String aiChat = '/ai'; // /ai/:userId/chat 형태로 사용
  static const String aiGenerateImage = '/ai'; // /ai/:userId/generate-image-code 형태로 사용
  static const String shopItems = '/shop/items';
  static const String shopPurchase = '/shop/purchase';
  static const String userInventory = '/shop/users';
  static const String purchaseVerify = '/purchase/verify';
  static const String notifications = '/notifications';
  static const String unreadNotifications = '/notifications/unread-count';

  // 전체 URL 가져오기
  static String get baseUrl => _baseUrl;
  
  // 특정 엔드포인트의 전체 URL 가져오기
  static String getUrl(String endpoint) => '$_baseUrl$endpoint';
}
