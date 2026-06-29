import 'package:signals/signals.dart';
import '../../../../core/command/command.dart';
import '../../domain/entities/student.dart';
import '../../facade/student_usecases_facade.dart';
import '../../../../core/result/result.dart';

class StudentDetailViewModel {
  final StudentUseCasesFacade _facade;
  final String studentId;

  StudentDetailViewModel(this._facade, {required this.studentId}) {
    loadCommand = Command0<Student>(_load);
    loadCommand.execute();
  }

  late final Command0<Student> loadCommand;

  final student = signal<Student?>(null);

  Future<Result<Student>> _load() async {
    final result = await _facade.getStudentById(studentId);

    result.when(
      onSuccess: (loadedStudent) => student.value = loadedStudent,
      onFailure: (_) {},
    );

    return result;
  }

  void dispose() {
    student.dispose();
  }
}