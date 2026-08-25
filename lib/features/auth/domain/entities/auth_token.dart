class AuthToken {
  final String token;
  final int userId;
  final String userName;
  final String userEmail;

  const AuthToken({
    required this.token,
    required this.userId,
    required this.userName,
    required this.userEmail,
  });
}