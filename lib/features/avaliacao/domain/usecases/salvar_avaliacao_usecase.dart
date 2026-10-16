import '../../../../core/result/result.dart';
import '../entities/avaliacao.dart';
import '../repositories/avaliacao_repository.dart';

class SalvarAvaliacaoUseCase {
  final AvaliacaoRepository _repository;

  SalvarAvaliacaoUseCase(this._repository);

  Future<Result<void>> call(Avaliacao avaliacao) {
    return _repository.salvar(avaliacao);
  }
}