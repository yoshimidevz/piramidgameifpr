import '../../../../core/result/result.dart';
import '../entities/app_theme_mode.dart';

abstract class ThemeRepository {
  Future<Result<AppThemeMode>> getThemeMode();
  Future<Result<void>> saveThemeMode(AppThemeMode mode);
}