import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/injection_container.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(22, 18, 22, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppColors.green,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.menu_book_rounded, color: Colors.white, size: 28),
              ),
              const SizedBox(height: 16),
              Text(
                'Sobre o PiramidGame',
                style: AppTextStyles.sora(
                  fontSize: 24, fontWeight: FontWeight.w800, letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'O PiramidGame é um projeto didático desenvolvido para o '
                'IFPR – Campus Paranaguá. A ideia é transformar a convivência '
                'escolar em um ranking divertido de popularidade, onde cada '
                'estudante recebe uma pontuação de aura construída de forma '
                'coletiva e bem-humorada.',
                style: AppTextStyles.jakarta(
                  fontSize: 14, fontWeight: FontWeight.w500, height: 1.5,
                  color: theme.colorScheme.onSurface.withOpacity(.75),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'A proposta é puramente educativa: praticar conceitos de '
                'interface, armazenamento de dados e lógica de pontuação '
                'enquanto a turma se diverte elegendo suas lendas.',
                style: AppTextStyles.jakarta(
                  fontSize: 14, fontWeight: FontWeight.w500, height: 1.5,
                  color: theme.colorScheme.onSurface.withOpacity(.75),
                ),
              ),
              const SizedBox(height: 20),
              _InfoCard(
                icon: Icons.calculate_rounded,
                iconColor: AppColors.green,
                title: 'A matemática da pontuação',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RichText(
                      text: TextSpan(
                        style: AppTextStyles.jakarta(
                          fontSize: 13.5, fontWeight: FontWeight.w500,
                          color: theme.colorScheme.onSurface.withOpacity(.75),
                          height: 1.5,
                        ),
                        children: const [
                          TextSpan(text: 'São '),
                          TextSpan(text: '15 critérios', style: TextStyle(fontWeight: FontWeight.w800)),
                          TextSpan(text: ', cada um avaliado de '),
                          TextSpan(text: '1 a 5 estrelas', style: TextStyle(fontWeight: FontWeight.w800)),
                          TextSpan(text: '. A soma define o Nível Lenda do estudante.'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: AppColors.green.withOpacity(.08),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _ScoreBadge(value: '15', label: 'MÍNIMO'),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 14),
                            child: Icon(Icons.arrow_forward_rounded, size: 18),
                          ),
                          _ScoreBadge(value: '75', label: 'MÁXIMO'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              _InfoCard(
                icon: Icons.dark_mode_rounded,
                iconColor: AppColors.gold,
                title: 'Tema claro e escuro',
                child: Text(
                  'Use o botão no topo da tela para alternar entre os '
                  'temas claro e escuro, a qualquer momento.',
                  style: AppTextStyles.jakarta(
                    fontSize: 13.5, fontWeight: FontWeight.w500, height: 1.5,
                    color: theme.colorScheme.onSurface.withOpacity(.75),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    await InjectionContainer.instance.authViewModel.logout();
                    if (context.mounted) context.go('/login');
                  },
                  icon: const Icon(Icons.logout_rounded, color: AppColors.red),
                  label: Text(
                    'Sair da conta',
                    style: AppTextStyles.jakarta(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.red,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.red),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final Widget child;

  const _InfoCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border.all(color: theme.dividerColor),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: AppTextStyles.jakarta(fontSize: 15, fontWeight: FontWeight.w800),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}

class _ScoreBadge extends StatelessWidget {
  final String value;
  final String label;

  const _ScoreBadge({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: AppTextStyles.sora(
          fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.green,
        )),
        Text(label, style: AppTextStyles.jakarta(
          fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 0.5,
          color: AppColors.green.withOpacity(.7),
        )),
      ],
    );
  }
}