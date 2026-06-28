import '../../../../core/result/result.dart';
import '../models/student_model.dart';

abstract class StudentLocalService {
  Future<Result<List<StudentModel>>> getAll();
  Future<Result<void>> saveAll(List<StudentModel> students);
}