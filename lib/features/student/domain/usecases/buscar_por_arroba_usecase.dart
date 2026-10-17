import '../../../../core/result/result.dart';
import '../entities/student.dart';
import '../repositories/student_repository.dart';

class BuscarPorArrobaUseCase {
  final StudentRepository _repository;

  BuscarPorArrobaUseCase(this._repository);

  Future<Result<Student?>> call(String arroba) {
    return _repository.buscarPorArroba(arroba);
  }
}