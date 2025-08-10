class AuthResponse {
  final String accessToken;
  final String refreshToken;
  final User? user; // nullable로 변경

  AuthResponse({
    required this.accessToken,
    required this.refreshToken,
    this.user, // required 제거
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    try {
      // 필수 필드 검증
      if (json['accessToken'] == null && json['token'] == null) {
        throw Exception('accessToken 또는 token이 필요합니다');
      }
      if (json['refreshToken'] == null) {
        throw Exception('refreshToken이 필요합니다');
      }

      return AuthResponse(
        accessToken: json['accessToken'] ?? json['token'] ?? '',
        refreshToken: json['refreshToken'] ?? '',
        user: json['user'] != null ? User.fromJson(json['user']) : null, // null 체크 추가
      );
    } catch (e) {
      throw Exception('AuthResponse 파싱 실패: $e');
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'accessToken': accessToken,
      'refreshToken': refreshToken,
      'user': user?.toJson(), // null 체크 추가
    };
  }

  @override
  String toString() {
    return 'AuthResponse(accessToken: ${accessToken.substring(0, 10)}..., refreshToken: ${refreshToken.substring(0, 10)}..., user: $user)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AuthResponse &&
        other.accessToken == accessToken &&
        other.refreshToken == refreshToken &&
        other.user == user;
  }

  @override
  int get hashCode {
    return accessToken.hashCode ^ refreshToken.hashCode ^ user.hashCode;
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
    try {
      // 필수 필드 검증
      if (json['id'] == null) {
        throw Exception('사용자 ID가 필요합니다');
      }
      if (json['email'] == null) {
        throw Exception('사용자 이메일이 필요합니다');
      }
      if (json['nickname'] == null) {
        throw Exception('사용자 닉네임이 필요합니다');
      }

      return User(
        id: json['id'].toString(),
        email: json['email'].toString(),
        nickname: json['nickname'].toString(),
        coin: json['coin']?.toInt() ?? 0,
        dailyConversationCount: json['dailyConversationCount']?.toInt() ?? 0,
      );
    } catch (e) {
      throw Exception('User 파싱 실패: $e');
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'nickname': nickname,
      'coin': coin,
      'dailyConversationCount': dailyConversationCount,
    };
  }

  User copyWith({
    String? id,
    String? email,
    String? nickname,
    int? coin,
    int? dailyConversationCount,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      nickname: nickname ?? this.nickname,
      coin: coin ?? this.coin,
      dailyConversationCount: dailyConversationCount ?? this.dailyConversationCount,
    );
  }

  @override
  String toString() {
    return 'User(id: $id, email: $email, nickname: $nickname, coin: $coin, dailyConversationCount: $dailyConversationCount)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is User &&
        other.id == id &&
        other.email == email &&
        other.nickname == nickname &&
        other.coin == coin &&
        other.dailyConversationCount == dailyConversationCount;
  }

  @override
  int get hashCode {
    return id.hashCode ^ email.hashCode ^ nickname.hashCode ^ coin.hashCode ^ dailyConversationCount.hashCode;
  }
}
