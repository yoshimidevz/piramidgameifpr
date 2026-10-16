import 'package:signals/signals.dart';
import '../../../../core/command/command.dart';
import '../../../../core/result/result.dart';
import '../../../student/domain/entities/student.dart';
import '../../facade/avaliacao_facade.dart';

class RankingPessoalViewModel {
  final AvaliacaoFacade _facade;

  RankingPessoalViewModel(this._facade) {
    loadCommand = Command0<List<Student>>(_load);
  }

  late final Command0<List<Student>> loadCommand;
  final students = signal<List<Student>>([]);

  Future<void> refresh(String avaliadorUid) async {
    await _load(avaliadorUid: avaliadorUid);
  }

  Future<Result<List<Student>>> _load({String? avaliadorUid}) async {
    if (avaliadorUid == null) return const Result.success([]);

    final result = await _facade.rankingPessoal(avaliadorUid);
    result.when(
      onSuccess: (ranked) => students.value = ranked,
      onFailure: (_) {},
    );
    return result;
  }

  void dispose() {
    students.dispose();
  }
}