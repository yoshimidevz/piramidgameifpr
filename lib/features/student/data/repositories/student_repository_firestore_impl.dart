import '../../../../core/result/result.dart';
import '../../domain/entities/student.dart';
import '../../domain/repositories/student_repository.dart';
import '../services/firestore_student_service.dart';

class StudentRepositoryFirestoreImpl implements StudentRepository {
  final FirestoreStudentService _service;

  StudentRepositoryFirestoreImpl(this._service);

  @override
  Future<Result<List<Student>>> getAll() => _service.getAll();

  @override
  Future<Result<Student>> getById(String id) => _service.getById(id);

  @override
  Future<Result<void>> create(Student student) => _service.create(student);

  @override
  Future<Result<void>> update(Student student) => _service.update(student);

  @override
  Future<Result<void>> delete(String id) => _service.delete(id);

  @override
  Future<Result<Student?>> buscarPorArroba(String arroba) => _service.buscarPorArroba(arroba);
  
}