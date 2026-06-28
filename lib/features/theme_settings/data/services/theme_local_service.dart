import '../../../../core/result/result.dart';

abstract class ThemeLocalService {
  Future<Result<String?>> getThemeMode();
  Future<Result<void>> saveThemeMode(String mode);
}