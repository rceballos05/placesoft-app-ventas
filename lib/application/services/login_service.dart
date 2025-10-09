import 'dart:convert';
import 'dart:developer' as developer;

import 'package:aplicacion_ventas/core/utils/failure.dart';
import 'package:aplicacion_ventas/core/utils/result.dart';
import 'package:aplicacion_ventas/data/datasources/remote/auth_remote_datasource.dart';
import 'package:aplicacion_ventas/domain/entities/user.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';

/// Result of a successful login operation.
class LoginResult {
  const LoginResult({
    required this.user,
    required this.databaseAssetPath,
    required this.isOfflineMode,
  });

  /// Authenticated user information.
  final User user;

  /// Asset path to the database associated to the company prefix.
  final String? databaseAssetPath;

  /// Indicates if the login was performed offline.
  final bool isOfflineMode;
}

class _CachedCredentials {
  const _CachedCredentials({required this.prefix, required this.passwordHash});

  final String prefix;
  final String passwordHash;
}

/// Handles all the authentication workflow including offline fallbacks.
class LoginService {
  LoginService({
    required AuthRemoteDataSource remoteDataSource,
    Connectivity? connectivity,
  })  : _remoteDataSource = remoteDataSource,
        _connectivity = connectivity ?? Connectivity();

  final AuthRemoteDataSource _remoteDataSource;
  final Connectivity _connectivity;

  static const _cachePrefix = 'login_cache';

  /// Attempts to authenticate the user using either the remote API or local cache.
  Future<Result<LoginResult>> authenticate({required String rut, required String password}) async {
    developer.log('Iniciando autenticación', name: 'LoginService');
    final normalizedRut = rut.trim().toLowerCase();
    final normalizedPassword = password.trim();

    if (normalizedRut.isEmpty) {
      return FailureResult<LoginResult>(Failure('El RUT es obligatorio'));
    }
    if (normalizedPassword.isEmpty) {
      return FailureResult<LoginResult>(Failure('La contraseña es obligatoria'));
    }

    try {
      final connectivityResult = await _connectivity.checkConnectivity();
      final hasInternet = connectivityResult != ConnectivityResult.none;
      developer.log('Conectividad detectada: $connectivityResult', name: 'LoginService');

      if (hasInternet) {
        final user = await _remoteDataSource.login(rut: normalizedRut, password: normalizedPassword);
        final databasePath = await _resolveLocalDatabase(user.prefijo);
        await _persistCredentials(
          rut: normalizedRut,
          prefix: user.prefijo,
          passwordHash: _hashPassword(normalizedPassword),
        );
        developer.log('Login remoto exitoso para ${user.rut}', name: 'LoginService');
        return Success<LoginResult>(
          LoginResult(
            user: user,
            databaseAssetPath: databasePath,
            isOfflineMode: false,
          ),
        );
      }

      developer.log('Intentando login offline', name: 'LoginService');
      final cachedCredentials = await _loadCachedCredentials(normalizedRut);
      if (cachedCredentials == null) {
        developer.log('No se encontraron credenciales en caché', name: 'LoginService');
        return FailureResult<LoginResult>(Failure('Modo offline no disponible'));
      }

      final incomingPasswordHash = _hashPassword(normalizedPassword);
      if (cachedCredentials.passwordHash != incomingPasswordHash) {
        developer.log('La contraseña cacheada no coincide', name: 'LoginService');
        return FailureResult<LoginResult>(Failure('Modo offline no disponible'));
      }

      final databasePath = await _resolveLocalDatabase(cachedCredentials.prefix);
      if (databasePath == null) {
        developer.log('No se encontró base de datos local para ${cachedCredentials.prefix}', name: 'LoginService');
        return FailureResult<LoginResult>(Failure('Modo offline no disponible'));
      }

      final offlineUser = User(rut: normalizedRut, prefijo: cachedCredentials.prefix);
      developer.log('Login offline exitoso para ${offlineUser.rut}', name: 'LoginService');
      return Success<LoginResult>(
        LoginResult(
          user: offlineUser,
          databaseAssetPath: databasePath,
          isOfflineMode: true,
        ),
      );
    } on Failure catch (failure, stackTrace) {
      developer.log('Fallo en autenticación', name: 'LoginService', error: failure, stackTrace: stackTrace);
      return FailureResult<LoginResult>(failure);
    } catch (error, stackTrace) {
      developer.log('Error inesperado durante login', name: 'LoginService', error: error, stackTrace: stackTrace);
      return FailureResult<LoginResult>(Failure('No fue posible iniciar sesión', cause: error));
    }
  }

  /// Retrieves the cached prefix for the provided [rut].
  Future<String?> getCachedPrefix(String rut) async {
    final credentials = await _loadCachedCredentials(rut.trim().toLowerCase());
    return credentials?.prefix;
  }

  Future<void> _persistCredentials({required String rut, required String prefix, required String passwordHash}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = _cacheKeyFor(rut.trim().toLowerCase());
      await prefs.setStringList(key, <String>[prefix, passwordHash]);
      developer.log('Credenciales guardadas localmente para $rut', name: 'LoginService');
    } catch (error, stackTrace) {
      developer.log('Error guardando credenciales', name: 'LoginService', error: error, stackTrace: stackTrace);
    }
  }

  Future<_CachedCredentials?> _loadCachedCredentials(String rut) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = _cacheKeyFor(rut);
      final cachedValues = prefs.getStringList(key);
      if (cachedValues == null || cachedValues.length != 2) {
        return null;
      }
      return _CachedCredentials(prefix: cachedValues.first, passwordHash: cachedValues.last);
    } catch (error, stackTrace) {
      developer.log('Error obteniendo credenciales cacheadas', name: 'LoginService', error: error, stackTrace: stackTrace);
      return null;
    }
  }

  Future<String?> _resolveLocalDatabase(String prefix) async {
    final normalizedPrefix = prefix.trim().toLowerCase();
    final candidates = <String>[
      'assets/databases/${normalizedPrefix}_local00.db',
      'assets/database/${normalizedPrefix}_local00.db',
      'assets/database/$normalizedPrefix/productos.db',
      'assets/database/$normalizedPrefix/clientes.db',
    ];

    for (final candidate in candidates) {
      try {
        await rootBundle.load(candidate);
        developer.log('Base de datos encontrada en $candidate', name: 'LoginService');
        return candidate;
      } on FlutterError {
        // Continue searching other paths silently.
      } catch (error, stackTrace) {
        developer.log('Error leyendo base local $candidate', name: 'LoginService', error: error, stackTrace: stackTrace);
      }
    }

    return null;
  }

  String _cacheKeyFor(String rut) => '$_cachePrefix:$rut';

  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }
}
