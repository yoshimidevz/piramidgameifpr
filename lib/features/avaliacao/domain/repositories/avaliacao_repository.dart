import '../../../../core/result/result.dart';
import '../entities/avaliacao.dart';

abstract class AvaliacaoRepository {
  // Salva ou atualiza a avaliacao do usuario para uma pessoa
  Future<Result<void>> salvar(Avaliacao avaliacao);

  // Busca a avaliacao do usuario logado para uma pessoa especifica
  Future<Result<Avaliacao?>> buscarPorUsuarioEPessoa(
      String avaliadorUid, String pessoaId);

  // Busca todas as avaliacoes feitas pelo usuario logado
  Future<Result<List<Avaliacao>>> buscarPorUsuario(String avaliadorUid);

  // Busca todas as avaliacoes de uma pessoa (de todos os usuarios)
  Future<Result<List<Avaliacao>>> buscarPorPessoa(String pessoaId);

  // Busca todas as avaliacoes (para ranking global)
  Future<Result<List<Avaliacao>>> buscarTodas();
}