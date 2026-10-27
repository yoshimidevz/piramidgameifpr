import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/result/result.dart';
import '../../domain/entities/avaliacao.dart';
import '../../../student/domain/entities/popularity_criteria.dart';

class FirestoreAvaliacaoService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference get _avaliacoes => _db.collection('avaliacoes');

    Future<Result<void>> salvar(Avaliacao avaliacao) async {
    try {
      print('DEBUG AVAL: salvando avaliacao pessoaId=${avaliacao.pessoaId} uid=${avaliacao.avaliadorUid} total=${avaliacao.pontuacaoTotal}');
      
      final existing = await _avaliacoes
          .where('avaliadorUid', isEqualTo: avaliacao.avaliadorUid)
          .where('pessoaId', isEqualTo: avaliacao.pessoaId)
          .limit(1)
          .get();

      final data = _toMap(avaliacao);
      print('DEBUG AVAL: data = $data');

      if (existing.docs.isNotEmpty) {
        await existing.docs.first.reference.update(data);
        print('DEBUG AVAL: atualizado');
      } else {
        await _avaliacoes.doc(avaliacao.id).set(data);
        print('DEBUG AVAL: criado');
      }

      return const Result.success(null);
    } catch (e) {
      print('DEBUG AVAL: ERRO = $e');
      return Result.failure(Failure('Erro ao salvar avaliação: $e'));
    }
  }

  Future<Result<Avaliacao?>> buscarPorUsuarioEPessoa(
      String avaliadorUid, String pessoaId) async {
    try {
      final snapshot = await _avaliacoes
          .where('avaliadorUid', isEqualTo: avaliadorUid)
          .where('pessoaId', isEqualTo: pessoaId)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) return const Result.success(null);
      return Result.success(_fromDoc(snapshot.docs.first));
    } catch (e) {
      return Result.failure(Failure('Erro ao buscar avaliação: $e'));
    }
  }

  Future<Result<List<Avaliacao>>> buscarPorUsuario(
      String avaliadorUid) async {
    try {
      final snapshot = await _avaliacoes
          .where('avaliadorUid', isEqualTo: avaliadorUid)
          .get();
      final list = snapshot.docs.map(_fromDoc).toList();
      return Result.success(list);
    } catch (e) {
      return Result.failure(Failure('Erro ao buscar avaliações: $e'));
    }
  }

  Future<Result<List<Avaliacao>>> buscarPorPessoa(String pessoaId) async {
    try {
      final snapshot = await _avaliacoes
          .where('pessoaId', isEqualTo: pessoaId)
          .get();
      final list = snapshot.docs.map(_fromDoc).toList();
      return Result.success(list);
    } catch (e) {
      return Result.failure(Failure('Erro ao buscar avaliações: $e'));
    }
  }

  Future<Result<List<Avaliacao>>> buscarTodas() async {
    try {
      final snapshot = await _avaliacoes.get();
      final list = snapshot.docs.map(_fromDoc).toList();
      return Result.success(list);
    } catch (e) {
      return Result.failure(Failure('Erro ao buscar avaliações: $e'));
    }
  }

  Map<String, dynamic> _toMap(Avaliacao avaliacao) {
    final notasMap = <String, dynamic>{};
    for (final entry in avaliacao.notas.entries) {
      notasMap[entry.key.name] = entry.value;
    }

    return {
      'avaliadorUid': avaliacao.avaliadorUid,
      'pessoaId': avaliacao.pessoaId,
      'pontuacaoTotal': avaliacao.pontuacaoTotal,
      'dataAvaliacao': avaliacao.dataAvaliacao.toIso8601String(),
      ...notasMap,
    };
  }

  Avaliacao _fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    final notas = <CriteriaType, double>{};
    for (final criteria in CriteriaType.values) {
      final value = data[criteria.name];
      notas[criteria] = (value as num?)?.toDouble() ?? 0.0;
    }

    return Avaliacao(
      id: doc.id,
      avaliadorUid: data['avaliadorUid'] as String,
      pessoaId: data['pessoaId'] as String,
      notas: notas,
      pontuacaoTotal: (data['pontuacaoTotal'] as num).toDouble(),
      dataAvaliacao: DateTime.parse(data['dataAvaliacao'] as String),
    );
  }
}