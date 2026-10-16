import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/result/result.dart';
import '../../domain/entities/auth_token.dart';
import '../../domain/repositories/auth_repository.dart';
import '../services/auth_service.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthService _service;

  AuthRepositoryImpl(this._service);

  @override
  Future<Result<AuthToken>> login(String email, String password) async {
    final result = await _service.loginWithEmail(email, password);
    return result.when(
      onSuccess: (user) => Result.success(_toToken(user)),
      onFailure: (failure) => Result.failure(failure),
    );
  }

  @override
  Future<Result<AuthToken>> register(
      String name, String email, String password) async {
    final result = await _service.registerWithEmail(name, email, password);
    return result.when(
      onSuccess: (user) => Result.success(_toToken(user)),
      onFailure: (failure) => Result.failure(failure),
    );
  }

  @override
  Future<Result<AuthToken>> loginWithGoogle() async {
    final result = await _service.loginWithGoogle();
    return result.when(
      onSuccess: (user) => Result.success(_toToken(user)),
      onFailure: (failure) => Result.failure(failure),
    );
  }

  @override
  Future<Result<void>> logout() async {
    await _service.logout();
    return const Result.success(null);
  }

  @override
  Future<bool> isLoggedIn() async {
    return _service.isLoggedIn;
  }

  @override
  AuthToken? getCurrentUser() {
    final user = _service.currentUser;
    if (user == null) return null;
    return _toToken(user);
  }

  AuthToken _toToken(User user) {
    return AuthToken(
      uid: user.uid,
      name: user.displayName ?? user.email?.split('@').first ?? 'Usuário',
      email: user.email ?? '',
      photoUrl: user.photoURL,
    );
  }
}