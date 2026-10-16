import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/result/result.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<Result<User>> loginWithEmail(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return Result.success(credential.user!);
    } on FirebaseAuthException catch (e) {
      return Result.failure(Failure(_friendlyError(e.code)));
    }
  }

  Future<Result<User>> registerWithEmail(
      String name, String email, String password) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await credential.user!.updateDisplayName(name);
      return Result.success(credential.user!);
    } on FirebaseAuthException catch (e) {
      return Result.failure(Failure(_friendlyError(e.code)));
    }
  }

    Future<Result<User>> loginWithGoogle() async {
    try {
      final provider = GoogleAuthProvider();
      final result = await _auth.signInWithPopup(provider);
      return Result.success(result.user!);
    } on FirebaseAuthException catch (e) {
      return Result.failure(Failure(_friendlyError(e.code)));
    } catch (e) {
      return Result.failure(Failure('Erro ao entrar com Google'));
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
  }

  User? get currentUser => _auth.currentUser;

  bool get isLoggedIn => _auth.currentUser != null;

  String _friendlyError(String code) {
    switch (code) {
      case 'user-not-found':
        return 'Usuário não encontrado';
      case 'wrong-password':
        return 'Senha incorreta';
      case 'email-already-in-use':
        return 'Email já cadastrado';
      case 'weak-password':
        return 'Senha muito fraca (mínimo 6 caracteres)';
      case 'invalid-email':
        return 'Email inválido';
      case 'invalid-credential':
        return 'Email ou senha incorretos';
      default:
        return 'Erro de autenticação: $code';
    }
  }
}