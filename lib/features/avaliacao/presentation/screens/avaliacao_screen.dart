import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:signals/signals_flutter.dart';
import '../../../../../core/di/injection_container.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../student/domain/entities/popularity_criteria.dart';

class AvaliacaoScreen extends StatefulWidget {
  final String pessoaId;

  const AvaliacaoScreen({super.key, required this.pessoaId});

  @override
  State<AvaliacaoScreen> createState() => _AvaliacaoScreenState();
}

class _AvaliacaoScreenState extends State<AvaliacaoScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final uid = InjectionContainer.instance.authViewModel.currentUser.value?.uid;
      if (uid != null) {
        InjectionContainer.instance.avaliacaoViewModel
            .carregarAvaliacao(uid, widget.pessoaId);
      }
    });
  }

  Future<void> _salvar() async {
    final uid = InjectionContainer.instance.authViewModel.currentUser.value?.uid;
    print('DEBUG SCREEN: _salvar chamado uid=$uid pessoaId=${widget.pessoaId}');
    print('DEBUG SCREEN: todasAvaliadas=${InjectionContainer.instance.avaliacaoViewModel.todasAvaliadas}');
    if (uid == null) return;

    final viewModel = InjectionContainer.instance.avaliacaoViewModel;

    if (!viewModel.todasAvaliadas) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Avalie todos os 15 critérios antes de salvar'),
          backgroundColor: AppColors.red,
        ),
      );
      return;
    }

    final result = await viewModel.salvar(uid, widget.pessoaId);

    if (!mounted) return;

    result.when(
      onSuccess: (_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Avaliação salva com sucesso!'),
            backgroundColor: AppColors.green,
          ),
        );
        context.pop();
      },
      onFailure: (failure) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(failure.message),
            backgroundColor: AppColors.red,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = InjectionContainer.instance.avaliacaoViewModel;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Avaliar Pessoa',
          style: AppTextStyles.sora(fontSize: 18, fontWeight: FontWeight.w800),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: Watch((context) {
        if (viewModel.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final isEdicao = viewModel.avaliacaoExistente.value != null;

        return Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(22, 12, 22, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (isEdicao)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: AppColors.green.withOpacity(.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'Você já avaliou esta pessoa. Altere as notas para atualizar.',
                          style: AppTextStyles.jakarta(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.green,
                          ),
                        ),
                      ),
                    Text(
                      'CRITÉRIOS DE POPULARIDADE',
                      style: AppTextStyles.jakarta(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.2,
                        color: AppColors.green,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...CriteriaType.values.map((criteria) {
                      return _CriteriaRow(
                        criteria: criteria,
                        scoreSignal: viewModel.notas[criteria]!,
                        onChanged: (valor) =>
                            viewModel.setNota(criteria, valor),
                      );
                    }),
                  ],
                ),
              ),
            ),
            // Painel inferior com total e botao salvar
            Watch((context) {
              final total = viewModel.totalAtual;
              final avaliados = viewModel.notas.values
                  .where((s) => s.value >= 1)
                  .length;

              return Container(
                padding: const EdgeInsets.fromLTRB(22, 16, 22, 24),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  border: Border(
                    top: BorderSide(
                        color: Theme.of(context).dividerColor),
                  ),
                ),
                child: Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${total.toInt()} / 75',
                          style: AppTextStyles.sora(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: AppColors.green,
                          ),
                        ),
                        Text(
                          '$avaliados/15 critérios',
                          style: AppTextStyles.jakarta(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withOpacity(.6),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: SizedBox(
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () {
                            print('DEBUG: botao salvar tocado');
                            _salvar();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.green,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          child: Text(
                            isEdicao
                                ? 'Salvar Alterações'
                                : 'Salvar Avaliação',
                            style: AppTextStyles.jakarta(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        );
      }),
    );
  }
}

class _CriteriaRow extends StatelessWidget {
  final CriteriaType criteria;
  final Signal<double> scoreSignal;
  final ValueChanged<double> onChanged;

  const _CriteriaRow({
    required this.criteria,
    required this.scoreSignal,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            criteria.label,
            style: AppTextStyles.jakarta(
                fontSize: 14, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Watch((context) {
            final score = scoreSignal.value;
            return Row(
              children: List.generate(5, (index) {
                final starValue = (index + 1).toDouble();
                final isFilled = score >= starValue;
                return GestureDetector(
                  onTap: () => onChanged(starValue),
                  child: Padding(
                    padding: const EdgeInsets.only(right: 4),
                    child: Icon(
                      isFilled
                          ? Icons.star_rounded
                          : Icons.star_outline_rounded,
                      size: 32,
                      color: isFilled
                          ? AppColors.gold
                          : Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withOpacity(.25),
                    ),
                  ),
                );
              }),
            );
          }),
        ],
      ),
    );
  }
}