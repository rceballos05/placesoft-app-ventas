import 'package:aplicacion_ventas/core/errors/failure.dart';

/// Represents either a success or a failure when executing async operations.
sealed class Result<T> {
  const Result();

  R fold<R>({required R Function(Failure failure) failure, required R Function(T data) success});

  bool get isSuccess => this is Success<T>;
  bool get isFailure => this is FailureResult<T>;
}

/// Success state that wraps the resulting [data].
class Success<T> extends Result<T> {
  const Success(this.data);

  final T data;

  @override
  R fold<R>({required R Function(Failure failure) failure, required R Function(T data) success}) {
    return success(data);
  }
}

/// Failure state that wraps a [Failure] description.
class FailureResult<T> extends Result<T> {
  const FailureResult(this.error);

  final Failure error;

  @override
  R fold<R>({required R Function(Failure failure) failure, required R Function(T data) success}) {
    return failure(error);
  }
}
