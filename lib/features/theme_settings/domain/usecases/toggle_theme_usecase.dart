import '../../../../core/result/result.dart';
import '../entities/app_theme_mode.dart';
import '../repositories/theme_repository.dart';

class ToggleThemeUseCase {
  final ThemeRepository _repository;

  ToggleThemeUseCase(this._repository);

  Future<Result<AppThemeMode>> call(AppThemeMode currentMode) async {
    final newMode = currentMode.isDark ? AppThemeMode.light : AppThemeMode.dark;

    final saveResult = await _repository.saveThemeMode(newMode);

    return saveResult.when(
      onSuccess: (_) => Result.success(newMode),
      onFailure: (failure) => Result.failure(failure),
    );
  }
}