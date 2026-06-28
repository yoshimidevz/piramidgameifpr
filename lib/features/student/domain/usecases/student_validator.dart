import '../entities/student.dart';
import '../entities/popularity_criteria.dart';
import '../../../../core/result/result.dart';

class StudentValidator {
  static const minClassYear = 2008;
  static const maxClassYear = 2026;

  // Retorna null se válido, ou uma Failure descrevendo o problema.
  Failure? validate(Student student) {
    if (student.name.trim().isEmpty) {
      return const Failure('O nome do aluno é obrigatório');
    }

    if (student.classYear < minClassYear || student.classYear > maxClassYear) {
      return Failure(
        'A turma/ano deve estar entre $minClassYear e $maxClassYear',
      );
    }

    if (student.criteriaScores.length != CriteriaType.values.length) {
      return const Failure('Todos os 15 critérios devem ser avaliados');
    }

    for (final entry in student.criteriaScores.entries) {
      if (entry.value < CriteriaScoreLimits.min ||
          entry.value > CriteriaScoreLimits.max) {
        return Failure(
          '${entry.key.label} deve ter nota entre '
          '${CriteriaScoreLimits.min} e ${CriteriaScoreLimits.max}',
        );
      }
    }

    return null;
  }
}