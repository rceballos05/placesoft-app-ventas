import 'dart:convert';

import 'package:aplicacion_ventas/core/errors/failure.dart';
import 'package:aplicacion_ventas/core/utils/result.dart';
import 'package:aplicacion_ventas/data/models/user_model.dart';
import 'package:aplicacion_ventas/domain/entities/user.dart';
import 'package:aplicacion_ventas/domain/repositories/auth_repository.dart';
import 'package:http/http.dart' as http;

/// Default implementation of [AuthRepository] relying on the remote API.
class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;
  final String _baseUrl = '192.168.1.3:7177';

  @override
  Future<Result<User>> login({required String rut, required String password}) async {
    try {
      final prefijoResponse = await _client.get(Uri.http(_baseUrl, '/api/Login/$rut'));
      final decoded = jsonDecode(prefijoResponse.body) as Map<String, dynamic>;
      if (decoded['code'] != 200 || (decoded['items'] as List).isEmpty) {
        return FailureResult(UserFailure('Credenciales inválidas'));
      }
      final user = UserModel.fromJson(decoded['items'][0] as Map<String, dynamic>);
      final passResponse = await _client.get(
        Uri.http(_baseUrl, 'api/Login/${user.prefijo}/iniciar-sesion/$rut/$password'),
      );
      final passDecoded = jsonDecode(passResponse.body) as Map<String, dynamic>;
      if (passDecoded['code'] != 200) {
        return FailureResult(UserFailure('Credenciales inválidas'));
      }
      return Success<User>(user);
    } catch (error) {
      return FailureResult(UserFailure('No fue posible iniciar sesión', cause: error));
    }
  }
}

/// Specific failure for authentication operations.
class UserFailure extends Failure {
  UserFailure(super.message, {super.cause});
}
