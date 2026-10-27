import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/splash/presentation/screens/splash_screen.dart';
import '../../features/student/presentation/screens/home/home_screen.dart';
import '../../features/student/presentation/screens/ranking/ranking_screen.dart';
import '../../features/student/presentation/screens/student_form/student_form_screen.dart';
import '../../features/student/presentation/screens/student_detail/student_detail_screen.dart';
import '../../features/about/presentation/screens/about_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/avaliacao/presentation/screens/avaliacao_screen.dart';
import '../../features/auth/presentation/screens/completar_perfil_screen.dart';
import '../../features/perfil/presentation/screens/perfil_screen.dart';
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
      GoRoute(
        path: '/completar-perfil',
        builder: (context, state) => const CompletarPerfilScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return AppShell(navigationShell: navigationShell);
        },
        branches: [
          // Aba 0: Inicio
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/inicio',
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),
                    // Aba 1: Ranking
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/ranking',
                builder: (context, state) => const RankingScreen(),
                routes: [
                  GoRoute(
                    path: 'aluno/:id',
                    builder: (context, state) {
                      final id = state.pathParameters['id']!;
                      return StudentDetailScreen(studentId: id);
                    },
                    routes: [
                      GoRoute(
                        path: 'avaliar',
                        builder: (context, state) {
                          final id = state.pathParameters['id']!;
                          return AvaliacaoScreen(pessoaId: id);
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          // Aba 2: Cadastrar
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
          // Aba 3: Perfil
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/perfil',
                builder: (context, state) => const PerfilScreen(),
                routes: [
                  // Detalhes de aluno acessiveis a partir do perfil
                  GoRoute(
                    path: 'aluno/:id',
                    builder: (context, state) {
                      final id = state.pathParameters['id']!;
                      return StudentDetailScreen(studentId: id);
                    },
                    routes: [
                      GoRoute(
                        path: 'avaliar',
                        builder: (context, state) {
                          final id = state.pathParameters['id']!;
                          return AvaliacaoScreen(pessoaId: id);
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          // Aba 4: Sobre
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