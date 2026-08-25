import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/splash/presentation/screens/splash_screen.dart';
import '../../features/student/presentation/screens/home/home_screen.dart';
import '../../features/student/presentation/screens/ranking/ranking_screen.dart';
import '../../features/student/presentation/screens/student_form/student_form_screen.dart';
import '../../features/student/presentation/screens/student_detail/student_detail_screen.dart';
import '../../features/about/presentation/screens/about_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import 'app_shell.dart';

class AppRouter {
  static final GlobalKey<NavigatorState> _rootNavigatorKey =
      GlobalKey<NavigatorState>(debugLabel: 'root');

  static final GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return AppShell(navigationShell: navigationShell);
        },
        branches: [
          // Aba: Inicio
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/inicio',
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),
          // Aba: Ranking
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/ranking',
                builder: (context, state) => const RankingScreen(),
              ),
            ],
          ),
          // Aba: Cadastro (criar) + editar como sub-rota
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/cadastro',
                builder: (context, state) =>
                    const StudentFormScreen(studentId: null),
                routes: [
                  GoRoute(
                    path: 'editar/:id',
                    builder: (context, state) {
                      final id = state.pathParameters['id']!;
                      return StudentFormScreen(studentId: id);
                    },
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/aluno',
                builder: (context, state) => const StudentDetailScreen(studentId: null),
                routes: [
                  GoRoute(
                    path: ':id',
                    builder: (context, state) {
                      final id = state.pathParameters['id']!;
                      return StudentDetailScreen(studentId: id);
                    },
                  ),
                ],
              ),
            ],
          ),
          // Aba: Sobre
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/sobre',
                builder: (context, state) => const AboutScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}