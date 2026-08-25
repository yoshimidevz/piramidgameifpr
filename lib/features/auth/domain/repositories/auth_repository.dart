import '../../../../core/result/result.dart';
import '../entities/auth_token.dart';

abstract class AuthRepository {
  Future<Result<AuthToken>> login(String email, String password);
  Future<Result<AuthToken>> register(String name, String email, String password);
  Future<Result<void>> logout();
  Future<bool> isLoggedIn();
}