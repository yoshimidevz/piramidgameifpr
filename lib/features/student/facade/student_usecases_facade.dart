import '../../../core/result/result.dart';
import '../domain/entities/student.dart';
import '../domain/usecases/create_student_usecase.dart';
import '../domain/usecases/update_student_usecase.dart';
import '../domain/usecases/delete_student_usecase.dart';
import '../domain/usecases/get_all_students_usecase.dart';
import '../domain/usecases/get_student_by_id_usecase.dart';
import '../domain/usecases/calculate_ranking_usecase.dart';

class StudentUseCasesFacade {
  final CreateStudentUseCase _createStudent;
  final UpdateStudentUseCase _updateStudent;
  final DeleteStudentUseCase _deleteStudent;
  final GetAllStudentsUseCase _getAllStudents;
  final GetStudentByIdUseCase _getStudentById;
  final CalculateRankingUseCase _calculateRanking;

  StudentUseCasesFacade({
    required CreateStudentUseCase createStudent,
    required UpdateStudentUseCase updateStudent,
    required DeleteStudentUseCase deleteStudent,
    required GetAllStudentsUseCase getAllStudents,
    required GetStudentByIdUseCase getStudentById,
    required CalculateRankingUseCase calculateRanking,
  })  : _createStudent = createStudent,
        _updateStudent = updateStudent,
        _deleteStudent = deleteStudent,
        _getAllStudents = getAllStudents,
        _getStudentById = getStudentById,
        _calculateRanking = calculateRanking;

  Future<Result<void>> createStudent(Student student) {
    return _createStudent(student);
  }

  Future<Result<void>> updateStudent(Student student) {
    return _updateStudent(student);
  }

  Future<Result<void>> deleteStudent(String id) {
    return _deleteStudent(id);
  }

  Future<Result<List<Student>>> getAllStudents() {
    return _getAllStudents();
  }

  Future<Result<Student>> getStudentById(String id) {
    return _getStudentById(id);
  }

  Future<Result<List<Student>>> calculateRanking() {
    return _calculateRanking();
  }
}