import '../../../../core/result/result.dart';
import '../entities/avaliacao.dart';
import '../repositories/avaliacao_repository.dart';

class BuscarAvaliacoesPorPessoaUseCase {
  final AvaliacaoRepository _repository;

  BuscarAvaliacoesPorPessoaUseCase(this._repository);

  Future<Result<List<Avaliacao>>> call(String pessoaId) {
    return _repository.buscarPorPessoa(pessoaId);
  }
}