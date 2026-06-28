import '../../../../core/result/result.dart';
import '../entities/student.dart';
import '../repositories/student_repository.dart';
import 'student_validator.dart';

class UpdateStudentUseCase {
  final StudentRepository _repository;
  final StudentValidator _validator;

  UpdateStudentUseCase(this._repository, {StudentValidator? validator})
      : _validator = validator ?? StudentValidator();

  Future<Result<void>> call(Student student) async {
    final validationError = _validator.validate(student);
    if (validationError != null) {
      return Result.failure(validationError);
    }

    return _repository.update(student);
  }
}