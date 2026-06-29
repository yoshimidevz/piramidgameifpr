import 'package:flutter/material.dart';
import 'package:signals/signals_flutter.dart';
import '../../../../../core/di/injection_container.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../domain/entities/student.dart';
import '../../../domain/entities/student_tier.dart';
import '../../viewmodels/ranking_viewmodel.dart';
import 'package:go_router/go_router.dart';

class RankingScreen extends StatefulWidget {
  const RankingScreen({super.key});

  @override
  State<RankingScreen> createState() => _RankingScreenState();
}

class _RankingScreenState extends State<RankingScreen> {
  RankingViewModel get _viewModel => InjectionContainer.instance.rankingViewModel;

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Watch((context) {
          final students = _viewModel.students.value;
          final isLoading = _viewModel.loadRankingCommand.state.value.isRunning;

          if (isLoading && students.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (students.isEmpty) {
            return _EmptyRankingState(
              onCadastrarTap: () => context.go('/cadastro'),            );
          }

          return RefreshIndicator(
            onRefresh: _viewModel.refresh,
            child: CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(22, 16, 22, 0),
                  sliver: SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Ranking Geral',
                          style: AppTextStyles.sora(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'As maiores lendas do campus',
                          style: AppTextStyles.jakarta(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withOpacity(.6),
                          ),
                        ),
                        const SizedBox(height: 24),
                        if (students.length >= 3) _Podium(students: students),
                        if (students.length >= 3) const SizedBox(height: 24),
                        const SizedBox(height: 24),
                        Text(
                          'CLASSIFICAÇÃO',
                          style: AppTextStyles.jakarta(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.2,
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withOpacity(.55),
                          ),
                        ),
                        const SizedBox(height: 10),
                      ],
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(22, 0, 22, 20),
                  sliver: SliverList.builder(
                    itemCount: students.length >= 3
                        ? students.length - 3
                        : students.length,
                    itemBuilder: (context, index) {
                      final hasPodium = students.length >= 3;
                      final position = hasPodium ? index + 4 : index + 1;
                      final student = hasPodium ? students[index + 3] : students[index];
                      return _RankingListItem(
                        position: position,
                        student: student,
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}

class _EmptyRankingState extends StatelessWidget {
  final VoidCallback onCadastrarTap;

  const _EmptyRankingState({required this.onCadastrarTap});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.emoji_events_outlined,
                size: 64, color: AppColors.gold.withOpacity(.6)),
            const SizedBox(height: 16),
            Text(
              'O pódio está esperando',
              style: AppTextStyles.sora(fontSize: 19, fontWeight: FontWeight.w800),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              'Cadastre o primeiro aluno para começar o ranking de popularidade.',
              style: AppTextStyles.jakarta(
                fontSize: 13.5,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(.6),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: onCadastrarTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              child: const Text('Cadastrar primeiro aluno'),
            ),
          ],
        ),
      ),
    );
  }
}

// Pódio com os 3 primeiros colocados (1o no centro, com coroa).
class _Podium extends StatelessWidget {
  final List<Student> students;

  const _Podium({required this.students});

  @override
  Widget build(BuildContext context) {
    final first = students[0];
    final second = students[1];
    final third = students[2];

    return SizedBox(
      height: 210,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(child: _PodiumBlock(position: 2, height: 70)),
              Expanded(child: _PodiumBlock(position: 1, height: 96)),
              Expanded(child: _PodiumBlock(position: 3, height: 56)),
            ],
          ),
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(child: _PodiumAvatar(student: second, position: 2)),
                Expanded(child: _PodiumAvatar(student: first, position: 1)),
                Expanded(child: _PodiumAvatar(student: third, position: 3)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PodiumAvatar extends StatelessWidget {
  final Student student;
  final int position;

  const _PodiumAvatar({required this.student, required this.position});

  Color _avatarColor() {
    final colors = [
      AppColors.green,
      AppColors.greenDeep,
      const Color(0xFFD6457F),
      const Color(0xFF8B5CF6),
      const Color(0xFF3B82F6),
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
    final size = position == 1 ? 72.0 : 56.0;

    return GestureDetector(
      onTap: () => context.go('/aluno/${student.id}'),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
        if (position == 1)
          const Icon(Icons.emoji_events_rounded, color: AppColors.gold, size: 26),
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _avatarColor(),
            border: position == 1
                ? Border.all(color: AppColors.gold, width: 3)
                : null,
          ),
          alignment: Alignment.center,
          child: Text(
            _initials(),
            style: AppTextStyles.sora(
              fontSize: position == 1 ? 22 : 18,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          student.nickname.isNotEmpty ? student.nickname : student.name,
          style: AppTextStyles.jakarta(fontSize: 12.5, fontWeight: FontWeight.w700),
          overflow: TextOverflow.ellipsis,
        ),
        Text(
          '${student.totalScore.toInt()}',
          style: AppTextStyles.jakarta(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: AppColors.green,
          ),
        ),
      ],
    ),
  );
  }
}

class _PodiumBlock extends StatelessWidget {
  final int position;
  final double height;

  const _PodiumBlock({required this.position, required this.height});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isFirst = position == 1;

    return Container(
      height: height,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: isFirst ? AppColors.green : theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
        border: isFirst ? null : Border.all(color: theme.dividerColor),
      ),
      alignment: Alignment.center,
      child: Text(
        '$position',
        style: AppTextStyles.sora(
          fontSize: 28,
          fontWeight: FontWeight.w800,
          color: isFirst ? Colors.white : theme.colorScheme.onSurface.withOpacity(.3),
        ),
      ),
    );
  }
}

// Linha da lista, a partir do 4o lugar.
class _RankingListItem extends StatelessWidget {
  final int position;
  final Student student;

  const _RankingListItem({required this.position, required this.student});
  Color _avatarColor() {
    final colors = [
      AppColors.green,
      AppColors.greenDeep,
      const Color(0xFFD6457F),
      const Color(0xFF8B5CF6),
      const Color(0xFF3B82F6),
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
              width: 24,
              child: Text(
                '$position',
                style: AppTextStyles.jakarta(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.onSurface.withOpacity(.5),
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
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
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
                    style: AppTextStyles.jakarta(fontSize: 14.5, fontWeight: FontWeight.w700),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    '${student.course.label} · ${student.classYear}',
                    style: AppTextStyles.jakarta(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
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
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.green,
                  ),
                ),
                Text(
                  'NÍVEL ${tier.label.toUpperCase()}',
                  style: AppTextStyles.jakarta(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.4,
                    color: AppColors.gold,
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