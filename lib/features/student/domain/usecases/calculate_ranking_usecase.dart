import '../../../../core/result/result.dart';
import '../entities/student.dart';
import '../repositories/student_repository.dart';

class CalculateRankingUseCase {
  final StudentRepository _repository;

  CalculateRankingUseCase(this._repository);

  Future<Result<List<Student>>> call() async {
    final result = await _repository.getAll();

    return result.when(
      onSuccess: (students) {
        final ranked = [...students];
        ranked.sort((a, b) => b.totalScore.compareTo(a.totalScore));
        return Result.success(ranked);
      },
      onFailure: (failure) => Result.failure(failure),
    );
  }
}