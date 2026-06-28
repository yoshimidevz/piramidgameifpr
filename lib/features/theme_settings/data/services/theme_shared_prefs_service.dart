import '../../../../core/storage/local_storage_helper.dart';
import '../../../../core/result/result.dart';
import 'theme_local_service.dart';

class ThemeSharedPrefsService implements ThemeLocalService {
  static const _storageKey = 'theme_mode';

  final LocalStorageHelper _storage;

  ThemeSharedPrefsService(this._storage);

  @override
  Future<Result<String?>> getThemeMode() {
    return _storage.getString(_storageKey);
  }

  @override
  Future<Result<void>> saveThemeMode(String mode) {
    return _storage.setString(_storageKey, mode);
  }
}