import 'dart:convert';

import 'package:aplicacion_ventas/core/utils/failure.dart';
import 'package:aplicacion_ventas/data/models/user_model.dart';
import 'package:http/http.dart' as http;

/// Handles authentication requests against the remote API.
class AuthRemoteDataSource {
  AuthRemoteDataSource({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;
  final String _baseUrl = '192.168.1.3:7177';

  /// Performs the login request flow and returns the authenticated user.
  Future<UserModel> login({required String rut, required String password}) async {
    try {
      final prefijoResponse = await _client.get(Uri.http(_baseUrl, '/api/Login/$rut'));
      final prefijoDecoded = jsonDecode(prefijoResponse.body) as Map<String, dynamic>;
      final items = prefijoDecoded['items'];
      if (prefijoDecoded['code'] != 200 || items is! List || items.isEmpty) {
        throw UserFailure('Credenciales inválidas');
      }

      final user = UserModel.fromJson(items.first as Map<String, dynamic>);
      final passResponse = await _client.get(
        Uri.http(_baseUrl, 'api/Login/${user.prefijo}/iniciar-sesion/$rut/$password'),
      );
      final passDecoded = jsonDecode(passResponse.body) as Map<String, dynamic>;
      if (passDecoded['code'] != 200) {
        throw UserFailure('Credenciales inválidas');
      }

      return user;
    } on UserFailure {
      rethrow;
    } catch (error) {
      throw UserFailure('No fue posible iniciar sesión', cause: error);
    }
  }
}

/// Specific failure for authentication operations.
class UserFailure extends Failure {
  UserFailure(super.message, {super.cause});
}
