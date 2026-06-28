enum AppThemeMode { light, dark }

extension AppThemeModeX on AppThemeMode {
  bool get isDark => this == AppThemeMode.dark;
}