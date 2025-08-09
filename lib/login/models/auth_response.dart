class AuthResponse {
  final String accessToken;
  final String refreshToken;
  final User user;

  AuthResponse({
    required this.accessToken,
    required this.refreshToken,
    required this.user,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      accessToken: json['accessToken'],
      refreshToken: json['refreshToken'],
      user: User.fromJson(json['user']),
    );
  }
}

class User {
  final String id;
  final String email;
  final String nickname;
  final int coin;
  final int dailyConversationCount;

  User({
    required this.id,
    required this.email,
    required this.nickname,
    required this.coin,
    required this.dailyConversationCount,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      email: json['email'],
      nickname: json['nickname'],
      coin: json['coin'],
      dailyConversationCount: json['dailyConversationCount'],
    );
  }
}
