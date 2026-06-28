import '../../../core/result/result.dart';
import '../domain/entities/app_theme_mode.dart';
import '../domain/usecases/get_theme_mode_usecase.dart';
import '../domain/usecases/toggle_theme_usecase.dart';

class ThemeUseCasesFacade {
  final GetThemeModeUseCase _getThemeMode;
  final ToggleThemeUseCase _toggleTheme;

  ThemeUseCasesFacade({
    required GetThemeModeUseCase getThemeMode,
    required ToggleThemeUseCase toggleTheme,
  })  : _getThemeMode = getThemeMode,
        _toggleTheme = toggleTheme;

  Future<Result<AppThemeMode>> getThemeMode() {
    return _getThemeMode();
  }

  Future<Result<AppThemeMode>> toggleTheme(AppThemeMode currentMode) {
    return _toggleTheme(currentMode);
  }
}