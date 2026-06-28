import 'package:uuid/uuid.dart';
import '../../../../core/result/result.dart';
import '../entities/student.dart';
import '../repositories/student_repository.dart';
import 'student_validator.dart';

class CreateStudentUseCase {
  final StudentRepository _repository;
  final StudentValidator _validator;
  final Uuid _uuid;

  CreateStudentUseCase(
    this._repository, {
    StudentValidator? validator,
    Uuid? uuid,
  })  : _validator = validator ?? StudentValidator(),
        _uuid = uuid ?? const Uuid();

  Future<Result<void>> call(Student student) async {
    // Gera o id aqui - regra de negocio: todo aluno novo recebe um id unico.
    final newStudent = student.copyWith(id: _uuid.v4());

    final validationError = _validator.validate(newStudent);
    if (validationError != null) {
      return Result.failure(validationError);
    }

    return _repository.create(newStudent);
  }
}