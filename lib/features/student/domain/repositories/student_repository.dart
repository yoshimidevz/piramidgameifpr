import '../../../../core/result/result.dart';
import '../entities/student.dart';

// Contrato que os Use Cases usam. Não conhece SharedPreferences,
// JSON ou StudentModel - só trabalha com a entidade pura Student.
abstract class StudentRepository {
  Future<Result<List<Student>>> getAll();
  Future<Result<Student>> getById(String id);
  Future<Result<void>> create(Student student);
  Future<Result<void>> update(Student student);
  Future<Result<void>> delete(String id);
}