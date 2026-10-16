import '../../../student/domain/entities/popularity_criteria.dart';

class Avaliacao {
  final String id;
  final String avaliadorUid;
  final String pessoaId;
  final Map<CriteriaType, double> notas;
  final double pontuacaoTotal;
  final DateTime dataAvaliacao;

  const Avaliacao({
    required this.id,
    required this.avaliadorUid,
    required this.pessoaId,
    required this.notas,
    required this.pontuacaoTotal,
    required this.dataAvaliacao,
  });
}