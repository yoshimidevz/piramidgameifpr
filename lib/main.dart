import 'package:flutter/material.dart';
import 'package:signals/signals_flutter.dart';
import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';
import 'core/di/injection_container.dart';
import '../../features/theme_settings/domain/entities/app_theme_mode.dart';
import 'core/theme/app_scroll_behavior.dart';
import 'core/network/api_client.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  ApiClient.instance.init();
  await InjectionContainer.instance.init();
  runApp(const PiramidGameApp());
}

class PiramidGameApp extends StatelessWidget {
  const PiramidGameApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Watch((context) {
  final themeMode = InjectionContainer.instance.themeViewModel.mode.value;

  return MaterialApp.router(
    debugShowCheckedModeBanner: false,
    title: 'PiramidGame',
    theme: AppTheme.light,
    darkTheme: AppTheme.dark,
    themeMode: themeMode.isDark ? ThemeMode.dark : ThemeMode.light,
    scrollBehavior: AppScrollBehavior(),
    routerConfig: AppRouter.router,
  );
    });
  }
}