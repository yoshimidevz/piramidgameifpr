import '../../../../core/result/result.dart';
import '../../domain/entities/student.dart';
import '../../domain/repositories/student_repository.dart';
import '../../data/models/student_model.dart';
import '../../data/services/student_local_service.dart';

class StudentRepositoryImpl implements StudentRepository {
  final StudentLocalService _service;

  StudentRepositoryImpl(this._service);

  @override
  Future<Result<List<Student>>> getAll() async {
    final result = await _service.getAll();
    return result.when(
      onSuccess: (students) => Result.success(students),
      onFailure: (failure) => Result.failure(failure),
    );
  }

  @override
  Future<Result<Student>> getById(String id) async {
    final result = await _service.getAll();

    return result.when(
      onSuccess: (students) {
        final student = students.where((s) => s.id == id).firstOrNull;

        if (student == null) {
          return Result.failure(Failure('Aluno não encontrado'));
        }

        return Result.success(student);
      },
      onFailure: (failure) => Result.failure(failure),
    );
  }

  @override
  Future<Result<void>> create(Student student) async {
    final result = await _service.getAll();

    return result.when(
      onSuccess: (students) async {
        final updated = [...students, StudentModel.fromEntity(student)];
        return _service.saveAll(updated);
      },
      onFailure: (failure) async => Result.failure(failure),
    );
  }

  @override
  Future<Result<void>> update(Student student) async {
    final result = await _service.getAll();

    return result.when(
      onSuccess: (students) async {
        final index = students.indexWhere((s) => s.id == student.id);

        if (index == -1) {
          return Result.failure(Failure('Aluno não encontrado para alterar'));
        }

        final updated = [...students];
        updated[index] = StudentModel.fromEntity(student);

        return _service.saveAll(updated);
      },
      onFailure: (failure) async => Result.failure(failure),
    );
  }

  @override
  Future<Result<void>> delete(String id) async {
    final result = await _service.getAll();

    return result.when(
      onSuccess: (students) async {
        final exists = students.any((s) => s.id == id);

        if (!exists) {
          return Result.failure(Failure('Aluno não encontrado para remover'));
        }

        final updated = students.where((s) => s.id != id).toList();
        return _service.saveAll(updated);
      },
      onFailure: (failure) async => Result.failure(failure),
    );
  }
}