import 'package:signals/signals.dart';
import '../../../../core/command/command.dart';
import '../../../../core/result/result.dart';
import '../../domain/entities/student.dart';
import '../../facade/student_usecases_facade.dart';
import '../../../avaliacao/facade/avaliacao_facade.dart';

class StudentDetailViewModel {
  final StudentUseCasesFacade _facade;
  final AvaliacaoFacade _avaliacaoFacade;

  StudentDetailViewModel(this._facade, this._avaliacaoFacade) {
    deleteCommand = Command1<void, String>(_delete);
  }

  final student = signal<Student?>(null);
  final isLoading = signal<bool>(false);

  late final Command1<void, String> deleteCommand;

  Future<void> loadStudent(String studentId, {String? avaliadorUid}) async {
    isLoading.value = true;

    final result = await _facade.getStudentById(studentId);

    await result.when(
      onSuccess: (loadedStudent) async {
        // Se tiver uid do usuario logado, busca as notas da avaliacao dele
        if (avaliadorUid != null) {
          final avaliacaoResult = await _avaliacaoFacade.buscar(
              avaliadorUid, studentId);

          avaliacaoResult.when(
            onSuccess: (avaliacao) {
              if (avaliacao != null) {
                // Substitui os criteriaScores pelas notas reais da avaliacao
                student.value = Student(
                  id: loadedStudent.id,
                  name: loadedStudent.name,
                  nickname: loadedStudent.nickname,
                  course: loadedStudent.course,
                  classYear: loadedStudent.classYear,
                  birthDate: loadedStudent.birthDate,
                  criteriaScores: avaliacao.notas,
                );
              } else {
                // Pessoa ainda nao avaliada pelo usuario
                student.value = loadedStudent;
              }
            },
            onFailure: (_) {
              student.value = loadedStudent;
            },
          );
        } else {
          student.value = loadedStudent;
        }
      },
      onFailure: (failure) async {
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