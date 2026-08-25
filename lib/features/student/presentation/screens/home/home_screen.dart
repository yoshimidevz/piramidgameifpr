import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:signals/signals_flutter.dart';
import '../../../../../core/di/injection_container.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../domain/entities/student.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final rankingViewModel = InjectionContainer.instance.rankingViewModel;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(22, 18, 22, 20),
          child: Watch((context) {
            final students = rankingViewModel.students.value;
            final isLoading = rankingViewModel.loadRankingCommand.state.value.isRunning;
            final hasStudents = students.isNotEmpty;
            final leader = hasStudents ? students.first : null;

            if (isLoading && students.isEmpty) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(40),
                  child: CircularProgressIndicator(),
                ),
              );
            }

            return Column(
              children: [
                Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(28),
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [AppColors.green, AppColors.greenDeep],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.green.withOpacity(.4),
                        blurRadius: 34,
                        offset: const Offset(0, 16),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.emoji_events_rounded,
                    size: 52,
                    color: AppColors.gold,
                  ),
                ),
                const SizedBox(height: 18),
                Text('PiramidGame', style: AppTextStyles.sora(
                  fontSize: 32, fontWeight: FontWeight.w800, letterSpacing: -0.8,
                )),
                const SizedBox(height: 4),
                Text(
                  'Ranking de Popularidade · IFPR Paranaguá',
                  style: AppTextStyles.jakarta(
                    fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.green,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 18),

                Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        value: '${students.length}',
                        label: 'Lendas no ranking',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StatCard(value: '15', label: 'Critérios de aura'),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                _LeaderCard(leader: leader),
                const SizedBox(height: 14),

                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton.icon(
                    onPressed: () => context.go('/ranking'),
                    icon: const Icon(Icons.leaderboard_rounded),
                    label: const Text('Ver Ranking Geral'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.red,
                      foregroundColor: Colors.white,
                      textStyle: AppTextStyles.jakarta(
                        fontSize: 15.5, fontWeight: FontWeight.w700,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                  ),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String value;
  final String label;

  const _StatCard({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border.all(color: theme.dividerColor),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value, style: AppTextStyles.sora(fontSize: 26, fontWeight: FontWeight.w800)),
          const SizedBox(height: 2),
          Text(
            label,
            style: AppTextStyles.jakarta(
              fontSize: 12, fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface.withOpacity(.6),
            ),
          ),
        ],
      ),
    );
  }
}

class _LeaderCard extends StatelessWidget {
  final Student? leader;

  const _LeaderCard({required this.leader});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.green, AppColors.greenDeep],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -10,
            bottom: -18,
            child: Icon(
              Icons.workspace_premium_rounded,
              size: 110,
              color: Colors.white.withOpacity(.13),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'LÍDER ATUAL',
                style: AppTextStyles.jakarta(
                  fontSize: 12, fontWeight: FontWeight.w700,
                  letterSpacing: .5, color: Colors.white.withOpacity(.85),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                leader == null ? 'Ninguém ainda' : leader!.name,
                style: AppTextStyles.sora(
                  fontSize: 22, fontWeight: FontWeight.w800, color: Colors.white,
                ),
              ),
              Text(
                leader == null
                    ? 'Cadastre o primeiro aluno'
                    : '${leader!.totalScore.toInt()} pontos · Nível Lenda',
                style: AppTextStyles.jakarta(
                  fontSize: 13, fontWeight: FontWeight.w600,
                  color: Colors.white.withOpacity(.9),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}