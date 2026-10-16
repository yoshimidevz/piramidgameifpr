import '../../../../core/result/result.dart';
import '../../domain/entities/avaliacao.dart';
import '../../domain/repositories/avaliacao_repository.dart';
import '../services/firestore_avaliacao_service.dart';

class AvaliacaoRepositoryImpl implements AvaliacaoRepository {
  final FirestoreAvaliacaoService _service;

  AvaliacaoRepositoryImpl(this._service);

  @override
  Future<Result<void>> salvar(Avaliacao avaliacao) =>
      _service.salvar(avaliacao);

  @override
  Future<Result<Avaliacao?>> buscarPorUsuarioEPessoa(
          String avaliadorUid, String pessoaId) =>
      _service.buscarPorUsuarioEPessoa(avaliadorUid, pessoaId);

  @override
  Future<Result<List<Avaliacao>>> buscarPorUsuario(String avaliadorUid) =>
      _service.buscarPorUsuario(avaliadorUid);

  @override
  Future<Result<List<Avaliacao>>> buscarPorPessoa(String pessoaId) =>
      _service.buscarPorPessoa(pessoaId);

  @override
  Future<Result<List<Avaliacao>>> buscarTodas() =>
      _service.buscarTodas();
}