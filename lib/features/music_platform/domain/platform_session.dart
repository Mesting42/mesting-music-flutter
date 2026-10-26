/// A music-platform identity is independent of the Mesting CloudBase session.
/// Credentials are serialized only into the platform's secure-storage entry.
class PlatformSession {
  const PlatformSession({
    required this.userId,
    required this.token,
    this.vipToken = '',
    this.nickname = '',
  });

  final String userId;
  final String token;
  final String vipToken;
  final String nickname;

  factory PlatformSession.fromJson(Map<String, dynamic> json) {
    final userId = '${json['userid'] ?? ''}';
    final token = '${json['token'] ?? ''}';
    if (userId.isEmpty || token.isEmpty) {
      throw const FormatException('音乐平台登录凭证不完整');
    }
    return PlatformSession(
      userId: userId,
      token: token,
      vipToken: '${json['vip_token'] ?? ''}',
      nickname: '${json['nickname'] ?? ''}',
    );
  }

  Map<String, dynamic> toJson() => {
    'userid': userId,
    'token': token,
    'vip_token': vipToken,
    'nickname': nickname,
  };
}
