import 'package:signals/signals.dart';
import '../../../../core/command/command.dart';
import '../../../../core/result/result.dart';
import '../../domain/entities/auth_token.dart';
import '../../facade/auth_facade.dart';

class AuthViewModel {
  final AuthFacade _facade;

  AuthViewModel(this._facade);

  final currentUser = signal<AuthToken?>(null);
  final isLoggedIn = signal<bool>(false);

  Future<void> checkAuthStatus() async {
    final loggedIn = await _facade.isLoggedIn();
    isLoggedIn.value = loggedIn;
  }

  Future<Result<AuthToken>> login(String email, String password) async {
    final result = await _facade.login(email, password);
    result.when(
      onSuccess: (token) {
        currentUser.value = token;
        isLoggedIn.value = true;
      },
      onFailure: (_) {},
    );
    return result;
  }

  Future<Result<AuthToken>> register(
      String name, String email, String password) async {
    final result = await _facade.register(name, email, password);
    result.when(
      onSuccess: (token) {
        currentUser.value = token;
        isLoggedIn.value = true;
      },
      onFailure: (_) {},
    );
    return result;
  }

  Future<void> logout() async {
    await _facade.logout();
    currentUser.value = null;
    isLoggedIn.value = false;
  }

  void dispose() {
    currentUser.dispose();
    isLoggedIn.dispose();
  }
}