import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:signals/signals_flutter.dart';
import '../di/injection_container.dart';
import '../theme/app_colors.dart';
import '../../features/theme_settings/domain/entities/app_theme_mode.dart';

class AppShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const AppShell({super.key, required this.navigationShell});

  void _onTap(int index) {
    if (index == 1) {
      InjectionContainer.instance.rankingViewModel.refresh();
    }

    if (index == 2) {
      InjectionContainer.instance.studentFormViewModel.reset();
    }

    if (index == 3) {
      final currentStudent = InjectionContainer.instance.studentDetailViewModel.student.value;
      if (currentStudent != null) {
        InjectionContainer.instance.studentDetailViewModel.loadStudent(currentStudent.id);
      }
    }

    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          navigationShell,
          Positioned(
            top: 8,
            right: 16,
            child: SafeArea(
              child: _ThemeToggleButton(),
            ),
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: _onTap,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_rounded), label: 'Início'),
          NavigationDestination(icon: Icon(Icons.leaderboard_rounded), label: 'Ranking'),
          NavigationDestination(icon: Icon(Icons.add_circle_rounded), label: 'Cadastrar'),
          NavigationDestination(icon: Icon(Icons.account_circle_rounded), label: 'Aluno'),
          NavigationDestination(icon: Icon(Icons.info_rounded), label: 'Sobre'),
        ],
      ),
    );
  }
}

class _ThemeToggleButton extends StatelessWidget {
  const _ThemeToggleButton();

  @override
  Widget build(BuildContext context) {
    final viewModel = InjectionContainer.instance.themeViewModel;

    return Watch((context) {
      final isDark = viewModel.mode.value.isDark;

      return Container(
        decoration: BoxDecoration(
          color: AppColors.green.withOpacity(.12),
          borderRadius: BorderRadius.circular(99),
        ),
        child: IconButton(
          onPressed: viewModel.toggle,
          icon: Icon(
            isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
            color: AppColors.green,
          ),
        ),
      );
    });
  }
}