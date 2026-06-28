import 'package:signals/signals.dart';
import '../../../../core/command/command.dart';
import '../../../../core/result/result.dart';
import '../../domain/entities/student.dart';
import '../../facade/student_usecases_facade.dart';

class RankingViewModel {
  final StudentUseCasesFacade _facade;

  RankingViewModel(this._facade) {
    loadRankingCommand = Command0<List<Student>>(_loadRanking);
    // Carrega automaticamente ao instanciar a ViewModel.
    loadRankingCommand.execute();
  }

  late final Command0<List<Student>> loadRankingCommand;

  // Lista de alunos ja ordenada (Nivel Lenda decrescente).
  final students = signal<List<Student>>([]);

  // Chamado pelo pull-to-refresh.
  Future<void> refresh() => loadRankingCommand.execute();

  Future<Result<List<Student>>> _loadRanking() async {
    final result = await _facade.calculateRanking();

    result.when(
      onSuccess: (rankedStudents) {
        students.value = rankedStudents;
      },
      onFailure: (_) {
        // Mantem a lista anterior em tela; o erro fica disponivel
        // via loadRankingCommand.state.error para a UI exibir se quiser.
      },
    );

    return result;
  }

  void dispose() {
    students.dispose();
  }
}