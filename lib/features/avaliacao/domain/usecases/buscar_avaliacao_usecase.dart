import '../../../../core/result/result.dart';
import '../entities/avaliacao.dart';
import '../repositories/avaliacao_repository.dart';

class BuscarAvaliacaoUseCase {
  final AvaliacaoRepository _repository;

  BuscarAvaliacaoUseCase(this._repository);

  Future<Result<Avaliacao?>> call(String avaliadorUid, String pessoaId) {
    return _repository.buscarPorUsuarioEPessoa(avaliadorUid, pessoaId);
  }
}