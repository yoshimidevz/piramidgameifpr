import '../../../../core/result/result.dart';
import '../../domain/entities/app_theme_mode.dart';
import '../../domain/repositories/theme_repository.dart';
import '../services/theme_local_service.dart';
import '../../../../core/extensions/enum_extensions.dart';

class ThemeRepositoryImpl implements ThemeRepository {
  final ThemeLocalService _service;

  ThemeRepositoryImpl(this._service);

  @override
  Future<Result<AppThemeMode>> getThemeMode() async {
    final result = await _service.getThemeMode();

    return result.when(
      onSuccess: (modeString) {
        // Nenhum tema salvo ainda - usa claro como padrao.
        if (modeString == null) {
          return const Result.success(AppThemeMode.light);
        }

        final mode = AppThemeMode.values.byNameOrNull(modeString);
        return Result.success(mode ?? AppThemeMode.light);
      },
      onFailure: (failure) => Result.failure(failure),
    );
  }

  @override
  Future<Result<void>> saveThemeMode(AppThemeMode mode) {
    return _service.saveThemeMode(mode.name);
  }
}