import 'package:signals/signals.dart';
import '../../domain/entities/app_theme_mode.dart';
import '../../facade/theme_usecases_facade.dart';

class ThemeViewModel {
  final ThemeUseCasesFacade _facade;

  ThemeViewModel(this._facade) {
    _loadInitialTheme();
  }

  final mode = signal<AppThemeMode>(AppThemeMode.light);

  Future<void> _loadInitialTheme() async {
    final result = await _facade.getThemeMode();
    result.when(
      onSuccess: (loadedMode) => mode.value = loadedMode,
      onFailure: (_) {},
    );
  }

  Future<void> toggle() async {
    final result = await _facade.toggleTheme(mode.value);
    result.when(
      onSuccess: (newMode) => mode.value = newMode,
      onFailure: (_) {},
    );
  }

  void dispose() {
    mode.dispose();
  }
}