import '../../../core/result/result.dart';
import '../domain/entities/auth_token.dart';
import '../domain/repositories/auth_repository.dart';

class AuthFacade {
  final AuthRepository _repository;

  AuthFacade(this._repository);

  Future<Result<AuthToken>> login(String email, String password) =>
      _repository.login(email, password);

  Future<Result<AuthToken>> register(String name, String email, String password) =>
      _repository.register(name, email, password);

  Future<Result<void>> logout() => _repository.logout();

  Future<bool> isLoggedIn() => _repository.isLoggedIn();
}