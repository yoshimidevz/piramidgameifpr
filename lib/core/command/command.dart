import 'package:signals/signals.dart';
import '../result/result.dart';
import 'command_state.dart';

// Command sem parâmetro de entrada. Ex: carregar lista de alunos.
class Command0<T> {
  final Future<Result<T>> Function() _action;

  // Signal exposto pra UI observar (loading, erro, etc.)
  final state = signal(const CommandState());

  Command0(this._action);

  Future<void> execute() async {
    if (state.value.isRunning) return; // evita clique duplicado

    state.value = state.value.copyWith(status: CommandStatus.running);

    final result = await _action();

    result.when(
      onSuccess: (_) {
        state.value = state.value.copyWith(status: CommandStatus.success);
      },
      onFailure: (failure) {
        state.value = state.value.copyWith(
          status: CommandStatus.error,
          error: failure,
        );
      },
    );
  }
}

// Command com 1 parâmetro de entrada. Ex: salvar um Student.
class Command1<T, P> {
  final Future<Result<T>> Function(P param) _action;

  final state = signal(const CommandState());

  Command1(this._action);

  Future<void> execute(P param) async {
    if (state.value.isRunning) return;

    state.value = state.value.copyWith(status: CommandStatus.running);

    final result = await _action(param);

    result.when(
      onSuccess: (_) {
        state.value = state.value.copyWith(status: CommandStatus.success);
      },
      onFailure: (failure) {
        state.value = state.value.copyWith(
          status: CommandStatus.error,
          error: failure,
        );
      },
    );
  }
}