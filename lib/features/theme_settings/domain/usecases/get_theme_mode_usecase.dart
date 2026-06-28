import '../../../../core/result/result.dart';
import '../entities/app_theme_mode.dart';
import '../repositories/theme_repository.dart';

class GetThemeModeUseCase {
  final ThemeRepository _repository;

  GetThemeModeUseCase(this._repository);

  Future<Result<AppThemeMode>> call() {
    return _repository.getThemeMode();
  }
}