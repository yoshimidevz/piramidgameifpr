import 'package:signals/signals.dart';
import '../../../../core/result/result.dart';
import '../../domain/entities/student.dart';
import '../../facade/student_usecases_facade.dart';

class StudentDetailViewModel {
  final StudentUseCasesFacade _facade;

  StudentDetailViewModel(this._facade);

  final student = signal<Student?>(null);
  final isLoading = signal<bool>(false);

  Future<void> loadStudent(String studentId) async {
    isLoading.value = true;

    final result = await _facade.getStudentById(studentId);

    result.when(
      onSuccess: (loadedStudent) => student.value = loadedStudent,
      onFailure: (_) {},
    );

    isLoading.value = false;
  }

  void dispose() {
    student.dispose();
    isLoading.dispose();
  }
}