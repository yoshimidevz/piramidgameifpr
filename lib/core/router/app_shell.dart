import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../di/injection_container.dart';

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
      body: navigationShell,
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