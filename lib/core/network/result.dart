sealed class Result<F, T> {
  const Result();
  bool get isOk => this is Ok<F, T>;
  bool get isErr => this is Err<F, T>;
  R fold<R>(R Function(F failure) onError, R Function(T value) onOk) {
    return switch (this) {
      Ok<F, T>(:final value) => onOk(value),
      Err<F, T>(:final failure) => onError(failure),
    };
  }

  Result<F, R> map<R>(R Function(T value) transform) {
    return switch (this) {
      Ok<F, T>(:final value) => Ok(transform(value)),
      Err<F, T>(:final failure) => Err(failure),
    };
  }

  T? get valueOrNull => switch (this) {
    Ok<F, T>(:final value) => value,
    Err<F, T>() => null,
  };
  F? get failureOrNull => switch (this) {
    Ok<F, T>() => null,
    Err<F, T>(:final failure) => failure,
  };
}

final class Ok<F, T> extends Result<F, T> {
  final T value;
  const Ok(this.value);
}

final class Err<F, T> extends Result<F, T> {
  final F failure;
  const Err(this.failure);
}
