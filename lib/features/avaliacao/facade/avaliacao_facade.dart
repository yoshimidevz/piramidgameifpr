import '../../../core/result/result.dart';
import '../domain/entities/avaliacao.dart';
import '../domain/usecases/salvar_avaliacao_usecase.dart';
import '../domain/usecases/buscar_avaliacao_usecase.dart';
import '../domain/usecases/calcular_ranking_pessoal_usecase.dart';
import '../domain/usecases/calcular_ranking_global_usecase.dart';
import '../../student/domain/entities/student.dart';

class AvaliacaoFacade {
  final SalvarAvaliacaoUseCase _salvar;
  final BuscarAvaliacaoUseCase _buscar;
  final CalcularRankingPessoalUseCase _rankingPessoal;
  final CalcularRankingGlobalUseCase _rankingGlobal;

  AvaliacaoFacade({
    required SalvarAvaliacaoUseCase salvar,
    required BuscarAvaliacaoUseCase buscar,
    required CalcularRankingPessoalUseCase rankingPessoal,
    required CalcularRankingGlobalUseCase rankingGlobal,
  })  : _salvar = salvar,
        _buscar = buscar,
        _rankingPessoal = rankingPessoal,
        _rankingGlobal = rankingGlobal;

  Future<Result<void>> salvar(Avaliacao avaliacao) =>
      _salvar(avaliacao);

  Future<Result<Avaliacao?>> buscar(
          String avaliadorUid, String pessoaId) =>
      _buscar(avaliadorUid, pessoaId);

  Future<Result<List<Student>>> rankingPessoal(String avaliadorUid) =>
      _rankingPessoal(avaliadorUid);

  Future<Result<List<Student>>> rankingGlobal() => _rankingGlobal();
}