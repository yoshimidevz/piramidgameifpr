import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/di/injection_container.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../auth/domain/entities/usuario.dart';
import '../../../student/domain/entities/student.dart';
import '../../../student/domain/entities/student_tier.dart';

class PerfilScreen extends StatefulWidget {
  const PerfilScreen({super.key});

  @override
  State<PerfilScreen> createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> {
  Usuario? _usuario;
  Student? _pessoaNoRanking;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _carregar());
  }

  Future<void> _carregar() async {
    final uid = InjectionContainer.instance.authViewModel.currentUser.value?.uid;
    if (uid == null) return;

    final usuarioResult = await InjectionContainer.instance
        .firestoreUsuarioService.buscarPorUid(uid);

    final usuario = usuarioResult.when(
      onSuccess: (u) => u,
      onFailure: (_) => null,
    );

    Student? pessoa;
    if (usuario?.pessoaId != null) {
      final pessoaResult = await InjectionContainer.instance
          .studentFacade.getStudentById(usuario!.pessoaId!);
      pessoa = pessoaResult.when(
        onSuccess: (s) => s,
        onFailure: (_) => null,
      );

      // Busca a media das avaliacoes da pessoa no ranking global
      if (pessoa != null) {
        final rankingGlobal = InjectionContainer.instance.rankingViewModel.students.value;
        final pessoaNoRanking = rankingGlobal.where((s) => s.id == pessoa!.id).firstOrNull;
        if (pessoaNoRanking != null) pessoa = pessoaNoRanking;
      }
    }

    if (mounted) {
      setState(() {
        _usuario = usuario;
        _pessoaNoRanking = pessoa;
        _isLoading = false;
      });
    }
  }

  Color _avatarColor(String nome) {
    final colors = [
      AppColors.green, AppColors.greenDeep,
      const Color(0xFFD6457F), const Color(0xFF8B5CF6), const Color(0xFF3B82F6),
    ];
    return colors[nome.hashCode % colors.length];
  }

  String _initials(String nome) {
    final parts = nome.trim().split(' ');
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts[0].substring(0, 1).toUpperCase();
    return (parts[0].substring(0, 1) + parts[1].substring(0, 1)).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authUser = InjectionContainer.instance.authViewModel.currentUser.value;

    return Scaffold(
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: _carregar,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(22, 18, 22, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Meu Perfil',
                        style: AppTextStyles.sora(
                          fontSize: 26, fontWeight: FontWeight.w800, letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Avatar + info principal
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 36,
                            backgroundColor: _avatarColor(_usuario?.nome ?? authUser?.name ?? '?'),
                            backgroundImage: (_usuario?.fotoUrl ?? authUser?.photoUrl) != null
                                ? NetworkImage(_usuario?.fotoUrl ?? authUser!.photoUrl!)
                                : null,
                            child: (_usuario?.fotoUrl ?? authUser?.photoUrl) == null
                                ? Text(
                                    _initials(_usuario?.nome ?? authUser?.name ?? '?'),
                                    style: AppTextStyles.sora(
                                      fontSize: 22, fontWeight: FontWeight.w800, color: Colors.white,
                                    ),
                                  )
                                : null,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _usuario?.nome ?? authUser?.name ?? 'Usuário',
                                  style: AppTextStyles.sora(
                                    fontSize: 18, fontWeight: FontWeight.w800,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                if (_usuario?.arroba != null)
                                  Text(
                                    '@${_usuario!.arroba}',
                                    style: AppTextStyles.jakarta(
                                      fontSize: 13, fontWeight: FontWeight.w600,
                                      color: AppColors.green,
                                    ),
                                  ),
                                Text(
                                  authUser?.email ?? '',
                                  style: AppTextStyles.jakarta(
                                    fontSize: 12, fontWeight: FontWeight.w500,
                                    color: theme.colorScheme.onSurface.withOpacity(.55),
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // Card de posicao no ranking
                      if (_pessoaNoRanking != null) ...[
                        _RankingCard(pessoa: _pessoaNoRanking!),
                        const SizedBox(height: 14),
                      ] else ...[
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surface,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: theme.dividerColor),
                          ),
                          child: Column(
                            children: [
                              const Text('👻', style: TextStyle(fontSize: 32)),
                              const SizedBox(height: 8),
                              Text(
                                'Você ainda não está no ranking',
                                style: AppTextStyles.jakarta(
                                  fontSize: 14, fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Quando alguém te cadastrar e te avaliar, '
                                'sua pontuação vai aparecer aqui.',
                                style: AppTextStyles.jakarta(
                                  fontSize: 12.5, fontWeight: FontWeight.w500,
                                  color: theme.colorScheme.onSurface.withOpacity(.6),
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),
                      ],

                      // Info do curso/turma
                      if (_usuario != null)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surface,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: theme.dividerColor),
                          ),
                          child: Row(
                            children: [
                              _InfoChip(label: 'Curso', value: _usuario!.curso.toUpperCase()),
                              const SizedBox(width: 12),
                              _InfoChip(label: 'Turma', value: '${_usuario!.turma}'),
                            ],
                          ),
                        ),

                      const SizedBox(height: 20),

                      // Botao ver meu perfil no ranking
                      if (_pessoaNoRanking != null)
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: () => context.go('/perfil/aluno/${_pessoaNoRanking!.id}'),
                            icon: const Icon(Icons.leaderboard_rounded),
                            label: const Text('Ver meu perfil no ranking'),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              side: BorderSide(color: AppColors.green.withOpacity(.5)),
                              foregroundColor: AppColors.green,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}

class _RankingCard extends StatelessWidget {
  final Student pessoa;

  const _RankingCard({required this.pessoa});

  @override
  Widget build(BuildContext context) {
    final tier = StudentTierInfo.fromScore(pessoa.totalScore);
    final rankingGlobal = InjectionContainer.instance.rankingViewModel.students.value;
    final posicao = rankingGlobal.indexWhere((s) => s.id == pessoa.id);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.green, AppColors.greenDeep],
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'MEU NÍVEL LENDA',
                  style: AppTextStyles.jakarta(
                    fontSize: 11, fontWeight: FontWeight.w700,
                    letterSpacing: 1, color: Colors.white.withOpacity(.8),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${pessoa.totalScore.toInt()}',
                  style: AppTextStyles.sora(
                    fontSize: 42, fontWeight: FontWeight.w800, color: Colors.white,
                  ),
                ),
                Text(
                  'Nível ${tier.label}',
                  style: AppTextStyles.jakarta(
                    fontSize: 13, fontWeight: FontWeight.w700,
                    color: AppColors.gold,
                  ),
                ),
              ],
            ),
          ),
          if (posicao >= 0)
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '#${posicao + 1}',
                  style: AppTextStyles.sora(
                    fontSize: 36, fontWeight: FontWeight.w800, color: Colors.white,
                  ),
                ),
                Text(
                  'no ranking',
                  style: AppTextStyles.jakarta(
                    fontSize: 12, fontWeight: FontWeight.w600,
                    color: Colors.white.withOpacity(.7),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final String label;
  final String value;

  const _InfoChip({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.jakarta(
            fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 0.5,
            color: theme.colorScheme.onSurface.withOpacity(.5),
          ),
        ),
        Text(
          value,
          style: AppTextStyles.sora(fontSize: 16, fontWeight: FontWeight.w800),
        ),
      ],
    );
  }
}