import '../../../../core/result/result.dart';
import '../repositories/avaliacao_repository.dart';
import '../../../student/domain/entities/student.dart';
import '../../../student/domain/repositories/student_repository.dart';

class CalcularRankingPessoalUseCase {
  final AvaliacaoRepository _avaliacaoRepository;
  final StudentRepository _studentRepository;

  CalcularRankingPessoalUseCase(
    this._avaliacaoRepository,
    this._studentRepository,
  );

  Future<Result<List<Student>>> call(String avaliadorUid) async {
    final avaliacoesResult =
        await _avaliacaoRepository.buscarPorUsuario(avaliadorUid);

    return avaliacoesResult.when(
      onSuccess: (avaliacoes) async {
        final studentsResult = await _studentRepository.getAll();

        return studentsResult.when(
          onSuccess: (students) {
            // Para cada pessoa que o usuario avaliou, substitui os
            // criteriaScores pelos da avaliacao real e calcula o total.
            final ranked = <Student>[];

            for (final avaliacao in avaliacoes) {
              final student = students.firstWhere(
                (s) => s.id == avaliacao.pessoaId,
                orElse: () => Student(
                  id: avaliacao.pessoaId,
                  name: 'Desconhecido',
                  nickname: '',
                  course: Course.info,
                  classYear: 2024,
                  birthDate: DateTime(2000),
                  criteriaScores: avaliacao.notas,
                ),
              );

              ranked.add(Student(
                id: student.id,
                name: student.name,
                nickname: student.nickname,
                course: student.course,
                classYear: student.classYear,
                birthDate: student.birthDate,
                criteriaScores: avaliacao.notas,
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