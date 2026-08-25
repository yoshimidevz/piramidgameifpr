import '../../domain/entities/auth_token.dart';

class AuthModel {
  final String token;
  final int userId;
  final String userName;
  final String userEmail;

  const AuthModel({
    required this.token,
    required this.userId,
    required this.userName,
    required this.userEmail,
  });

  factory AuthModel.fromJson(Map<String, dynamic> json) {
    return AuthModel(
      token: json['token'] as String,
      userId: json['user']['id'] as int,
      userName: json['user']['name'] as String,
      userEmail: json['user']['email'] as String,
    );
  }

  AuthToken toEntity() => AuthToken(
        token: token,
        userId: userId,
        userName: userName,
        userEmail: userEmail,
      );
}