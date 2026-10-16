import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:signals/signals_flutter.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/app_scroll_behavior.dart';
import 'core/router/app_router.dart';
import 'core/di/injection_container.dart';
import 'core/network/api_client.dart';
import 'firebase_options.dart';
import 'features/theme_settings/domain/entities/app_theme_mode.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
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