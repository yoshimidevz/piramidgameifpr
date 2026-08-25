import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/result/result.dart';
import '../../domain/entities/auth_token.dart';
import '../../domain/repositories/auth_repository.dart';
import '../services/auth_service.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthService _service;

  AuthRepositoryImpl(this._service);

  @override
  Future<Result<AuthToken>> login(String email, String password) async {
    final result = await _service.login(email, password);
    return result.when(
      onSuccess: (model) async {
        await _saveToken(model.token);
        return Result.success(model.toEntity());
      },
      onFailure: (failure) => Result.failure(failure),
    );
  }

  @override
  Future<Result<AuthToken>> register(
      String name, String email, String password) async {
    final result = await _service.register(name, email, password);
    return result.when(
      onSuccess: (model) async {
        await _saveToken(model.token);
        return Result.success(model.toEntity());
      },
      onFailure: (failure) => Result.failure(failure),
    );
  }

  @override
  Future<Result<void>> logout() async {
    final result = await _service.logout();
    await _clearToken();
    return result;
  }

  @override
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token') != null;
  }

  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  Future<void> _clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }
}