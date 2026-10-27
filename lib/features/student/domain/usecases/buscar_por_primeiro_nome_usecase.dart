import '../../../../core/result/result.dart';
import '../entities/student.dart';
import '../repositories/student_repository.dart';

class BuscarPorPrimeiroNomeUseCase {
  final StudentRepository _repository;

  BuscarPorPrimeiroNomeUseCase(this._repository);

  Future<Result<Student?>> call(String primeiroNome, String curso, int turma) {
    return _repository.buscarPorPrimeiroNome(primeiroNome, curso, turma);
  }
}