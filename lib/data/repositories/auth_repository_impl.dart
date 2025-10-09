import 'package:aplicacion_ventas/core/utils/failure.dart';
import 'package:aplicacion_ventas/core/utils/result.dart';
import 'package:aplicacion_ventas/data/datasources/remote/auth_remote_datasource.dart';
import 'package:aplicacion_ventas/data/models/user_model.dart';
import 'package:aplicacion_ventas/domain/entities/user.dart';
import 'package:aplicacion_ventas/domain/entities/contracts/auth_repository.dart';

/// Default implementation of [AuthRepository] relying on the remote API.
class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({AuthRemoteDataSource? remoteDataSource})
      : _remoteDataSource = remoteDataSource ?? AuthRemoteDataSource();

  final AuthRemoteDataSource _remoteDataSource;

  @override
  Future<Result<User>> login({required String rut, required String password}) async {
    try {
      final UserModel user =
          await _remoteDataSource.login(rut: rut, password: password);
      return Success<User>(user);
    } on UserFailure catch (failure) {
      return FailureResult(failure);
    } catch (error) {
      return FailureResult(UserFailure('No fue posible iniciar sesión', cause: error));
    }
  }
}
