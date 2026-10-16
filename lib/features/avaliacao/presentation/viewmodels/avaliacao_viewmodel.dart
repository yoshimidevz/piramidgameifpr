import 'package:signals/signals.dart';
import '../../../../core/result/result.dart';
import '../../domain/entities/avaliacao.dart';
import '../../facade/avaliacao_facade.dart';
import '../../../student/domain/entities/popularity_criteria.dart';

class AvaliacaoViewModel {
  final AvaliacaoFacade _facade;

  AvaliacaoViewModel(this._facade);

  // Notas atuais sendo editadas (15 criterios)
  final Map<CriteriaType, Signal<double>> notas = {
    for (final c in CriteriaType.values) c: signal(0.0),
  };

  final isLoading = signal<bool>(false);
  final avaliacaoExistente = signal<Avaliacao?>(null);

  // Carrega avaliacao existente do usuario para essa pessoa (se houver)
  Future<void> carregarAvaliacao(
      String avaliadorUid, String pessoaId) async {
    isLoading.value = true;

    final result = await _facade.buscar(avaliadorUid, pessoaId);

    result.when(
      onSuccess: (avaliacao) {
        avaliacaoExistente.value = avaliacao;
        if (avaliacao != null) {
          // Pre-preenche as notas com a avaliacao existente
          for (final entry in avaliacao.notas.entries) {
            notas[entry.key]?.value = entry.value;
          }
        } else {
          _resetNotas();
        }
      },
      onFailure: (_) => _resetNotas(),
    );

    isLoading.value = false;
  }

  Future<Result<void>> salvar(
      String avaliadorUid, String pessoaId) async {
    final notasMap = <CriteriaType, double>{};
    for (final entry in notas.entries) {
      notasMap[entry.key] = entry.value.value;
    }

    final total = notasMap.values.fold(0.0, (sum, v) => sum + v);

    final avaliacao = Avaliacao(
      id: '${avaliadorUid}_$pessoaId',
      avaliadorUid: avaliadorUid,
      pessoaId: pessoaId,
      notas: notasMap,
      pontuacaoTotal: total,
      dataAvaliacao: DateTime.now(),
    );

    return _facade.salvar(avaliacao);
  }

  void setNota(CriteriaType criteria, double valor) {
    notas[criteria]?.value = valor;
  }

  void _resetNotas() {
    for (final s in notas.values) {
      s.value = 0.0;
    }
    avaliacaoExistente.value = null;
  }

  double get totalAtual =>
      notas.values.fold(0.0, (sum, s) => sum + s.value);

  bool get todasAvaliadas =>
      notas.values.every((s) => s.value >= 1.0);

  void dispose() {
    for (final s in notas.values) {
      s.dispose();
    }
    isLoading.dispose();
    avaliacaoExistente.dispose();
  }
}