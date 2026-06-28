import '../../../../core/result/result.dart';
import '../entities/student.dart';
import '../repositories/student_repository.dart';

class GetAllStudentsUseCase {
  final StudentRepository _repository;

  GetAllStudentsUseCase(this._repository);

  Future<Result<List<Student>>> call() {
    return _repository.getAll();
  }
}