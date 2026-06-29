import 'package:signals/signals.dart';
import '../../../../core/command/command.dart';
import '../../../../core/result/result.dart';
import '../../domain/entities/student.dart';
import '../../facade/student_usecases_facade.dart';

class StudentDetailViewModel {
  final StudentUseCasesFacade _facade;

  StudentDetailViewModel(this._facade) {
    deleteCommand = Command1<void, String>(_delete);
  }

  final student = signal<Student?>(null);
  final isLoading = signal<bool>(false);

  late final Command1<void, String> deleteCommand;

  Future<void> loadStudent(String studentId) async {
    isLoading.value = true;

    final result = await _facade.getStudentById(studentId);

    result.when(
      onSuccess: (loadedStudent) {
        student.value = loadedStudent;
      },
      onFailure: (failure) {
        student.value = null;
      },
    );

    isLoading.value = false;
  }

  Future<Result<void>> _delete(String studentId) {
    return _facade.deleteStudent(studentId);
  }

  void dispose() {
    student.dispose();
    isLoading.dispose();
  }
}