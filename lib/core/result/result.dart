sealed class Result<T> {
  const Result();

  const factory Result.success(T value) = Success<T>;

  const factory Result.failure(Failure failure) = ResultFailure<T>;

  bool get isSuccess => this is Success<T>;

  bool get isFailure => this is ResultFailure<T>;

  // Trata os dois casos de uma vez, evita if/is espalhado
  R when<R>({
    required R Function(T value) onSuccess,
    required R Function(Failure failure) onFailure,
  }) {
    return switch (this) {
      Success<T>(value: final value) => onSuccess(value),
      ResultFailure<T>(failure: final failure) => onFailure(failure),
    };
  }

  T? get valueOrNull => switch (this) {
        Success<T>(value: final value) => value,
        ResultFailure<T>() => null,
      };

  Failure? get failureOrNull => switch (this) {
        Success<T>() => null,
        ResultFailure<T>(failure: final failure) => failure,
      };
}

final class Success<T> extends Result<T> {
  final T value;
  const Success(this.value);
}

final class ResultFailure<T> extends Result<T> {
  final Failure failure;
  const ResultFailure(this.failure);
}

// Mensagem amigável pra UI + exception original opcional pra debug
class Failure {
  final String message;
  final Object? exception;

  const Failure(this.message, {this.exception});

  @override
  String toString() => 'Failure: $message';
}