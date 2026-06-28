import 'package:shared_preferences/shared_preferences.dart';
import '../result/result.dart';

class LocalStorageHelper {
  Future<Result<String?>> getString(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return Result.success(prefs.getString(key));
    } catch (e) {
      return Result.failure(
        Failure('Não foi possível ler os dados salvos', exception: e),
      );
    }
  }

  Future<Result<void>> setString(String key, String value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(key, value);
      return const Result.success(null);
    } catch (e) {
      return Result.failure(
        Failure('Não foi possível salvar os dados', exception: e),
      );
    }
  }

  Future<Result<void>> remove(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(key);
      return const Result.success(null);
    } catch (e) {
      return Result.failure(
        Failure('Não foi possível remover os dados', exception: e),
      );
    }
  }
}