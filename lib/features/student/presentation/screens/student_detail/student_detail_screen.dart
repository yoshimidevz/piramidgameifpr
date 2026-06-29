import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:signals/signals_flutter.dart';
import '../../../../../core/di/injection_container.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../domain/entities/popularity_criteria.dart';
import '../../../domain/entities/student.dart';
import '../../../domain/entities/student_tier.dart';
import '../../widgets/aura_radar_chart.dart';
import '../../viewmodels/student_detail_viewmodel.dart';

class StudentDetailScreen extends StatelessWidget {
  final String? studentId;

  const StudentDetailScreen({super.key, required this.studentId});

   @override
  Widget build(BuildContext context) {

    if (studentId == null) {
      return const Scaffold(
        body: Center(child: Text('Nenhum aluno selecionado ainda')),
      );
    }

    final viewModel = InjectionContainer.instance.studentDetailViewModel;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      viewModel.loadStudent(studentId!);
    });

    return Scaffold(
      body: SafeArea(
        child: Watch((context) {
          final student = viewModel.student.value;
          final isLoading = viewModel.isLoading.value;

         if (isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (student == null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.person_off_rounded, size: 56, color: AppColors.gold.withOpacity(.6)),
                    const SizedBox(height: 16),
                    Text(
                      'Aluno não encontrado',
                      style: AppTextStyles.sora(fontSize: 18, fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Esse aluno pode ter sido removido. Veja o ranking para escolher outro.',
                      style: AppTextStyles.jakarta(
                        fontSize: 13.5, fontWeight: FontWeight.w500,
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(.6),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => context.go('/ranking'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.green,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Ver Ranking'),
                    ),
                  ],
                ),
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(22, 18, 22, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      onPressed: () => _confirmDelete(context, viewModel, student),
                      icon: const Icon(Icons.delete_outline_rounded),
                      style: IconButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.surface,
                        side: BorderSide(color: Theme.of(context).dividerColor),
                        foregroundColor: AppColors.red,
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: () => context.go('/cadastro/editar/${student.id}'),
                      icon: const Icon(Icons.edit_rounded),
                      style: IconButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.surface,
                        side: BorderSide(color: Theme.of(context).dividerColor),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                _StudentHeader(student: student),
                const SizedBox(height: 18),
                _ScoreCard(student: student),
                const SizedBox(height: 22),
                Text(
                  'MAPA DE AURA',
                  style: AppTextStyles.jakarta(
                    fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1.2,
                    color: AppColors.green,
                  ),
                ),
                const SizedBox(height: 10),
                _AuraRadarCard(student: student),
                const SizedBox(height: 22),
                Text(
                  'NOTAS POR CRITÉRIO',
                  style: AppTextStyles.jakarta(
                    fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1.2,
                    color: AppColors.green,
                  ),
                ),
                const SizedBox(height: 10),
                ...CriteriaType.values.map((criteria) {
                  return _CriteriaScoreRow(
                    criteria: criteria,
                    score: student.criteriaScores[criteria] ?? 0,
                  );
                }),
              ],
            ),
          );
        }),
      ),
    );
  }
}

Future<void> _confirmDelete(
  BuildContext context,
  StudentDetailViewModel viewModel,
  Student student,
) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        title: const Text('Remover aluno'),
        content: Text(
          'Tem certeza que deseja remover "${student.name}" do ranking? '
          'Essa ação não pode ser desfeita.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.red),
            child: const Text('Remover'),
          ),
        ],
      );
    },
  );

  if (confirmed != true) return;

  await viewModel.deleteCommand.execute(student.id);

  if (!context.mounted) return;

  final state = viewModel.deleteCommand.state.value;

  if (state.isSuccess) {
    await InjectionContainer.instance.rankingViewModel.refresh();
    if (context.mounted) context.go('/ranking');
  } else if (state.isError) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${state.error}'),
        backgroundColor: AppColors.red,
      ),
    );
  }
}

class _StudentHeader extends StatelessWidget {
  final Student student;

  const _StudentHeader({required this.student});

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

    return Row(
      children: [
        CircleAvatar(
          radius: 28,
          backgroundColor: _avatarColor(),
          child: Text(
            _initials(),
            style: AppTextStyles.sora(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.white),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                student.name,
                style: AppTextStyles.sora(fontSize: 19, fontWeight: FontWeight.w800),
                overflow: TextOverflow.ellipsis,
              ),
              if (student.nickname.isNotEmpty)
                Text(
                  '"${student.nickname}"',
                  style: AppTextStyles.jakarta(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.green),
                ),
              Text(
                '${student.course.label} · ${student.classYear} · '
                '${student.birthDate.day.toString().padLeft(2, '0')}/'
                '${student.birthDate.month.toString().padLeft(2, '0')}/'
                '${student.birthDate.year}',
                style: AppTextStyles.jakarta(
                  fontSize: 12, fontWeight: FontWeight.w500,
                  color: theme.colorScheme.onSurface.withOpacity(.55),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ScoreCard extends StatelessWidget {
  final Student student;

  const _ScoreCard({required this.student});

  @override
  Widget build(BuildContext context) {
    final tier = StudentTierInfo.fromScore(student.totalScore);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: const LinearGradient(
          begin: Alignment.topLeft, end: Alignment.bottomRight,
          colors: [AppColors.green, AppColors.greenDeep],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'PONTUAÇÃO TOTAL',
            style: AppTextStyles.jakarta(
              fontSize: 11.5, fontWeight: FontWeight.w700, letterSpacing: 1,
              color: Colors.white.withOpacity(.85),
            ),
          ),
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '${student.totalScore.toInt()}',
                style: AppTextStyles.sora(fontSize: 40, fontWeight: FontWeight.w800, color: Colors.white),
              ),
              Text(
                ' / 75',
                style: AppTextStyles.jakarta(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white.withOpacity(.7)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(.18),
              borderRadius: BorderRadius.circular(99),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.military_tech_rounded, size: 16, color: AppColors.gold),
                const SizedBox(width: 6),
                Text(
                  'Nível ${tier.label}',
                  style: AppTextStyles.jakarta(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CriteriaScoreRow extends StatelessWidget {
  final CriteriaType criteria;
  final double score;

  const _CriteriaScoreRow({required this.criteria, required this.score});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              criteria.label,
              style: AppTextStyles.jakarta(fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ),
          Row(
            children: List.generate(5, (index) {
              final isFilled = (index + 1) <= score;
              return Icon(
                isFilled ? Icons.star_rounded : Icons.star_outline_rounded,
                size: 18,
                color: isFilled ? AppColors.gold : theme.colorScheme.onSurface.withOpacity(.25),
              );
            }),
          ),
          const SizedBox(width: 6),
          SizedBox(
            width: 14,
            child: Text(
              score.toInt().toString(),
              textAlign: TextAlign.right,
              style: AppTextStyles.jakarta(fontSize: 13, fontWeight: FontWeight.w700, color: theme.colorScheme.onSurface.withOpacity(.6)),
            ),
          ),
        ],
      ),
    );
  }
}

class _AuraRadarCard extends StatelessWidget {
  final Student student;

  const _AuraRadarCard({required this.student});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border.all(color: theme.dividerColor),
        borderRadius: BorderRadius.circular(20),
      ),
      child: AuraRadarChart(scores: student.criteriaScores),
    );
  }
}