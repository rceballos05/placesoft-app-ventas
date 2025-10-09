/// Base class for failures reported across repositories and services.
class Failure {
  Failure(this.message, {this.cause});

  /// Human readable failure message.
  final String message;

  /// Optional underlying exception.
  final Object? cause;

  @override
  String toString() => message;
}
