import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:signals/signals_flutter.dart';
import '../../../../../core/di/injection_container.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../student/domain/entities/student.dart';
import '../../../student/domain/entities/student_tier.dart';

class RankingPessoalScreen extends StatefulWidget {
  const RankingPessoalScreen({super.key});

  @override
  State<RankingPessoalScreen> createState() => _RankingPessoalScreenState();
}

class _RankingPessoalScreenState extends State<RankingPessoalScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _refresh());
  }

  void _refresh() {
    final uid = InjectionContainer.instance.authViewModel.currentUser.value?.uid;
    if (uid != null) {
      InjectionContainer.instance.rankingPessoalViewModel.refresh(uid);
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = InjectionContainer.instance.rankingPessoalViewModel;

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 18, 22, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Ranking Pessoal',
                    style: AppTextStyles.sora(
                      fontSize: 26, fontWeight: FontWeight.w800, letterSpacing: -0.5,
                    ),
                  ),
                  Text(
                    'Baseado nas suas avaliações',
                    style: AppTextStyles.jakarta(
                      fontSize: 13, fontWeight: FontWeight.w600,
                      color: AppColors.green,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Watch((context) {
                final students = viewModel.students.value;
                final isLoading = viewModel.loadCommand.state.value.isRunning;

                if (isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (students.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.star_outline_rounded,
                              size: 56,
                              color: AppColors.gold.withOpacity(.5)),
                          const SizedBox(height: 16),
                          Text(
                            'Nenhuma avaliação ainda',
                            style: AppTextStyles.sora(
                              fontSize: 18, fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Avalie pessoas no ranking para ver seu ranking pessoal.',
                            style: AppTextStyles.jakarta(
                              fontSize: 13.5, fontWeight: FontWeight.w500,
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(.6),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async => _refresh(),
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(22, 0, 22, 20),
                    itemCount: students.length,
                    itemBuilder: (context, index) {
                      final student = students[index];
                      return _RankingPessoalItem(
                        position: index + 1,
                        student: student,
                      );
                    },
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

class _RankingPessoalItem extends StatelessWidget {
  final int position;
  final Student student;

  const _RankingPessoalItem({
    required this.position,
    required this.student,
  });

  Color _avatarColor() {
    final colors = [
      AppColors.green, AppColors.greenDeep,
      const Color(0xFFD6457F), const Color(0xFF8B5CF6), const Color(0xFF3B82F6),
    ];
    return colors[student.name.hashCode % colors.length];
  }

  String _initials() {
    final parts = student.name.trim().split(' ');
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts[0].substring(0, 1).toUpperCase();
    return (parts[0].substring(0, 1) + parts[1].substring(0, 1)).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tier = StudentTierInfo.fromScore(student.totalScore);

    return GestureDetector(
      onTap: () => context.go('/aluno/${student.id}'),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: theme.dividerColor),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 28,
              child: Text(
                '$position',
                style: AppTextStyles.sora(
                  fontSize: 16, fontWeight: FontWeight.w800,
                  color: position <= 3 ? AppColors.gold : theme.colorScheme.onSurface.withOpacity(.5),
                ),
              ),
            ),
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 18,
              backgroundColor: _avatarColor(),
              child: Text(
                _initials(),
                style: AppTextStyles.sora(
                  fontSize: 13, fontWeight: FontWeight.w800, color: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    student.name,
                    style: AppTextStyles.jakarta(
                      fontSize: 14.5, fontWeight: FontWeight.w700,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    '${student.course.label} · ${student.classYear}',
                    style: AppTextStyles.jakarta(
                      fontSize: 12, fontWeight: FontWeight.w500,
                      color: theme.colorScheme.onSurface.withOpacity(.55),
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${student.totalScore.toInt()}',
                  style: AppTextStyles.sora(
                    fontSize: 18, fontWeight: FontWeight.w800,
                    color: AppColors.green,
                  ),
                ),
                Text(
                  'NÍVEL ${tier.label.toUpperCase()}',
                  style: AppTextStyles.jakarta(
                    fontSize: 9.5, fontWeight: FontWeight.w700,
                    letterSpacing: 0.4, color: AppColors.gold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}