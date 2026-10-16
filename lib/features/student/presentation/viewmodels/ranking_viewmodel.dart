import 'package:signals/signals.dart';
import '../../../../core/command/command.dart';
import '../../../../core/result/result.dart';
import '../../domain/entities/student.dart';
import '../../../avaliacao/facade/avaliacao_facade.dart';

class RankingViewModel {
  final AvaliacaoFacade _avaliacaoFacade;

  RankingViewModel(this._avaliacaoFacade) {
    loadRankingCommand = Command0<List<Student>>(_loadRanking);
  }

  late final Command0<List<Student>> loadRankingCommand;

  final students = signal<List<Student>>([]);

  Future<void> refresh() => loadRankingCommand.execute();

  Future<Result<List<Student>>> _loadRanking() async {
    final result = await _avaliacaoFacade.rankingGlobal();

    result.when(
      onSuccess: (rankedStudents) {
        students.value = rankedStudents;
      },
      onFailure: (_) {},
    );

    return result;
  }

  void dispose() {
    students.dispose();
  }
}