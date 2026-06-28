import 'package:signals/signals.dart';
import '../../../../core/result/result.dart';
import '../../../../core/command/command.dart';
import '../../domain/entities/popularity_criteria.dart';
import '../../domain/entities/student.dart';
import '../../facade/student_usecases_facade.dart';

class StudentFormViewModel {
  final StudentUseCasesFacade _facade;

  // Id do aluno em edicao, ou null se for cadastro novo.
  final String? editingStudentId;

  StudentFormViewModel(this._facade, {this.editingStudentId}) {
    saveCommand = Command1<void, Student>(_save);
  }

  // Campos do formulario, reativos.
  final name = signal('');
  final nickname = signal('');
  final course = signal(Course.info);
  final classYear = signal(2024);
  final birthDate = signal<DateTime?>(null);

  final Map<CriteriaType, Signal<double>> criteriaScores = {
    for (final criteria in CriteriaType.values) criteria: signal(0.0),
  };

  late final Command1<void, Student> saveCommand;

  late final Computed<double> totalScore = computed(() {
    return criteriaScores.values.fold(0.0, (sum, s) => sum + s.value);
  });

  late final Computed<int> evaluatedCount = computed(() {
    return criteriaScores.values.where((s) => s.value >= 1).length;
  });

  late final Computed<bool> isComplete = computed(() {
    return evaluatedCount.value == CriteriaType.values.length;
  });

  void setCriteriaScore(CriteriaType criteria, double value) {
    criteriaScores[criteria]!.value = value;
  }

  Future<void> save() async {
    if (!isComplete.value) return;
    final student = Student(
      id: editingStudentId ?? '',
      name: name.value,
      nickname: nickname.value,
      course: course.value,
      classYear: classYear.value,
      birthDate: birthDate.value ?? DateTime.now(),
      criteriaScores: {
        for (final entry in criteriaScores.entries) entry.key: entry.value.value,
      },
    );

    await saveCommand.execute(student);
  }

  Future<Result<void>> _save(Student student) {
    if (editingStudentId != null) {
      return _facade.updateStudent(student);
    }
    return _facade.createStudent(student);
  }

  void dispose() {
    for (final s in criteriaScores.values) {
      s.dispose();
    }
    name.dispose();
    nickname.dispose();
    course.dispose();
    classYear.dispose();
    birthDate.dispose();
    totalScore.dispose();
    evaluatedCount.dispose();
    isComplete.dispose();
  }
}