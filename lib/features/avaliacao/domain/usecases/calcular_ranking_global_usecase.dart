import '../../../../core/result/result.dart';
import '../repositories/avaliacao_repository.dart';
import '../../../student/domain/entities/student.dart';
import '../../../student/domain/entities/popularity_criteria.dart';
import '../../../student/domain/repositories/student_repository.dart';

class CalcularRankingGlobalUseCase {
  final AvaliacaoRepository _avaliacaoRepository;
  final StudentRepository _studentRepository;

  CalcularRankingGlobalUseCase(
    this._avaliacaoRepository,
    this._studentRepository,
  );

  Future<Result<List<Student>>> call() async {
    final avaliacoesResult = await _avaliacaoRepository.buscarTodas();

    return avaliacoesResult.when(
      onSuccess: (avaliacoes) async {
        final studentsResult = await _studentRepository.getAll();

        return studentsResult.when(
          onSuccess: (students) {
            final ranked = <Student>[];

            for (final student in students) {
              // Pega todas as avaliacoes dessa pessoa
              final avaliacoesDaPessoa = avaliacoes
                  .where((a) => a.pessoaId == student.id)
                  .toList();

              if (avaliacoesDaPessoa.isEmpty) {
                // Pessoa sem nenhuma avaliacao ainda
                ranked.add(student);
                continue;
              }

              // Calcula a media de cada criterio entre todos os avaliadores
              final mediaCriterios = <CriteriaType, double>{};
              for (final criteria in CriteriaType.values) {
                final notas = avaliacoesDaPessoa
                    .map((a) => a.notas[criteria] ?? 0.0)
                    .toList();
                final media =
                    notas.reduce((a, b) => a + b) / notas.length;
                mediaCriterios[criteria] = media;
              }

              ranked.add(Student(
                id: student.id,
                name: student.name,
                nickname: student.nickname,
                course: student.course,
                classYear: student.classYear,
                birthDate: student.birthDate,
                criteriaScores: mediaCriterios,
              ));
            }

            // Ordena pelo totalScore decrescente
            ranked.sort((a, b) =>
                b.totalScore.compareTo(a.totalScore));

            return Result.success(ranked);
          },
          onFailure: (failure) => Result.failure(failure),
        );
      },
      onFailure: (failure) => Result.failure(failure),
    );
  }
}