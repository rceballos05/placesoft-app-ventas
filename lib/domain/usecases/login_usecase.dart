import 'package:aplicacion_ventas/core/utils/result.dart';
import 'package:aplicacion_ventas/domain/entities/user.dart';
import 'package:aplicacion_ventas/domain/entities/contracts/auth_repository.dart';

/// Use case that orchestrates the login flow.
class LoginUseCase {
  const LoginUseCase(this._repository);

  final AuthRepository _repository;

  /// Executes the login process for the provided credentials.
  Future<Result<User>> call(String rut, String password) {
    return _repository.login(rut: rut, password: password);
  }
}
