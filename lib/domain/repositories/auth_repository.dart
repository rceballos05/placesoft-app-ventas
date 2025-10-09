import 'package:aplicacion_ventas/core/utils/result.dart';
import 'package:aplicacion_ventas/domain/entities/user.dart';

/// Contract for authentication data sources.
abstract class AuthRepository {
  /// Attempts to log in using the provided credentials.
  Future<Result<User>> login({required String rut, required String password});
}
