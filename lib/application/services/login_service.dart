import 'dart:async';
import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:io';

import 'package:aplicacion_ventas/application/services/sync_service.dart';
import 'package:aplicacion_ventas/core/utils/failure.dart';
import 'package:aplicacion_ventas/core/utils/result.dart';
import 'package:aplicacion_ventas/data/datasources/remote/sync_remote_datasource.dart';
import 'package:aplicacion_ventas/domain/entities/user.dart';
import 'package:aplicacion_ventas/utils/rut_utils.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

/// Result of a successful login operation.
class LoginResult {
  const LoginResult({
    required this.user,
    required this.databaseAssetPath,
    required this.isOfflineMode,
  });

  /// Authenticated user information.
  final User user;

  /// Local path to the database associated to the company prefix.
  final String? databaseAssetPath;

  /// Indicates if the login was performed offline.
  final bool isOfflineMode;
}

class _CachedCredentials {
  const _CachedCredentials({required this.prefix, required this.passwordHash});

  final String prefix;
  final String passwordHash;
}

class _RutData {
  const _RutData({
    required this.clean,
    required this.formatted,
    required this.database,
  });

  final String clean;
  final String formatted;
  final String database;

  String get cacheKey => clean.toLowerCase();
}

/// Handles all the authentication workflow including offline fallbacks.
class LoginService {
  LoginService({http.Client? httpClient, Connectivity? connectivity})
      : _httpClient = httpClient ?? http.Client(),
        _connectivity = connectivity ?? Connectivity();

  final http.Client _httpClient;
  final Connectivity _connectivity;

  static const _cachePrefix = 'login_cache';
  static const _baseUrl = '45.236.164.152:80';
  static const _httpTimeout = Duration(seconds: 15);

  LoginResult? _lastLoginResult;
  Failure? _lastFailure;
  User? _onlineUserCache;
  User? _offlineUserCache;

  /// Attempts to authenticate the user using either the remote API or local cache.
  Future<Result<LoginResult>> authenticate(
      {required String rut, required String password}) async {
    _lastLoginResult = null;
    _lastFailure = null;
    _onlineUserCache = null;
    _offlineUserCache = null;

    developer.log('Iniciando autenticación', name: 'LoginService');

    try {
      final success = await iniciarSesion(rut, password);
      if (success && _lastLoginResult != null) {
        return Success<LoginResult>(_lastLoginResult!);
      }
      return FailureResult<LoginResult>(
          _lastFailure ?? Failure('No fue posible iniciar sesión'));
    } on Failure catch (failure, stackTrace) {
      developer.log('Fallo en autenticación',
          name: 'LoginService', error: failure, stackTrace: stackTrace);
      return FailureResult<LoginResult>(failure);
    } catch (error, stackTrace) {
      developer.log('Error inesperado durante login',
          name: 'LoginService', error: error, stackTrace: stackTrace);
      return FailureResult<LoginResult>(
          Failure('No fue posible iniciar sesión', cause: error));
    }
  }

  /// Executes the authentication workflow with online and offline fallbacks.
  Future<bool> iniciarSesion(String rut, String pass) async {
    _lastLoginResult = null;
    _lastFailure = null;
    _onlineUserCache = null;
    _offlineUserCache = null;
    caja = '';
    descuento = 0;
    nombreUsuario = '';

    final trimmedPassword = pass.trim();
    if (trimmedPassword.isEmpty) {
      _lastFailure = Failure('La contraseña es obligatoria');
      return false;
    }

    late final _RutData rutData;
    try {
      rutData = _normalizeRut(rut);
    } on Failure catch (failure) {
      _lastFailure = failure;
      return false;
    }

    developer.log('RUT normalizado: ${rutData.formatted}',
        name: 'LoginService');

    final connectivityResult = await _connectivity.checkConnectivity();
    final hasInternet = connectivityResult != ConnectivityResult.none;
    developer.log('Conectividad detectada: $connectivityResult',
        name: 'LoginService');

    String? prefijo;
    if (hasInternet) {
      try {
        prefijo = await obtenerPrefijo(rutData.database);
      } on Failure catch (failure) {
        _lastFailure = failure;
      } catch (error, stackTrace) {
        developer.log('Error obteniendo prefijo remoto',
            name: 'LoginService', error: error, stackTrace: stackTrace);
        _lastFailure =
            Failure('Error al obtener prefijo del servidor', cause: error);
      }
    }

    if (prefijo != null) {
      try {
        final onlineOk =
            await loginOnline(prefijo, rutData.database, trimmedPassword);
        if (onlineOk) {
          await asegurarBaseLocal(prefijo);
          final databasePath = await _resolveLocalDatabase(prefijo);
          final user = _onlineUserCache ??
              User(
                  rut: rutData.database,
                  prefijo: prefijo,
                  caja: caja,
                  maxDcto: descuento,
                  nombre: "");
          _lastLoginResult = LoginResult(
            user: user,
            databaseAssetPath: databasePath,
            isOfflineMode: false,
          );
          await _persistCredentials(
            rut: rutData.cacheKey,
            prefix: user.prefijo,
            passwordHash: _hashPassword(trimmedPassword),
          );
          return true;
        }
      } on Failure catch (failure) {
        developer.log('Fallo en login online',
            name: 'LoginService', error: failure);
        _lastFailure = failure;
      } catch (error, stackTrace) {
        developer.log('Error inesperado en login online',
            name: 'LoginService', error: error, stackTrace: stackTrace);
        _lastFailure = Failure('No fue posible validar credenciales en línea',
            cause: error);
      }
    }

    developer.log('Intentando autenticación offline', name: 'LoginService');
    final offlineOk = await loginOffline(rutData.database, trimmedPassword);
    if (offlineOk) {
      final user = _offlineUserCache;
      if (user == null) {
        _lastFailure = Failure('Modo offline no disponible');
        return false;
      }
      try {
        await asegurarBaseLocal(user.prefijo);
      } on Failure catch (failure) {
        _lastFailure = failure;
        return false;
      }
      final databasePath = await _resolveLocalDatabase(user.prefijo);
      _lastLoginResult = LoginResult(
        user: user,
        databaseAssetPath: databasePath,
        isOfflineMode: true,
      );
      return true;
    }

    _lastFailure ??= Failure('Credenciales inválidas');
    return false;
  }

  String caja = "";
  double descuento = 0;
  String nombreUsuario = "";

  /// Retrieves the company prefix associated to the provided [rut].
  Future<String?> obtenerPrefijo(String rut) async {
    final rutData = _normalizeRut(rut);
    final uri = Uri.http(_baseUrl, '/api/Login/${rutData.database}');

    try {
      developer.log('Solicitando prefijo remoto', name: 'LoginService');
      final response = await _httpClient.get(uri).timeout(_httpTimeout);
      if (response.statusCode != 200) {
        throw Failure('Error al consultar prefijo (${response.statusCode})');
      }
      final decoded = jsonDecode(response.body) as Map<String, dynamic>;
      if (decoded['code'] != 200) {
        return null;
      }
      final items = decoded['items'];
      if (items is! List || items.isEmpty) {
        return null;
      }
      final data = items.first as Map<String, dynamic>;
      final prefijo = _stringFromValue(data['prefijo'])?.trim();
      caja = _stringFromValue(data['caja']) ??
          _stringFromValue(data['caja_doc']) ??
          "";
      descuento = _doubleFromValue(
        data['maxDctoProducto'] ?? data['max_dcto'] ?? data['descuento'],
        fallback: 0,
      );
      nombreUsuario = _stringFromValue(data['nombre']) ??
          _stringFromValue(data['nombreUsuario']) ??
          nombreUsuario;
      if (prefijo == null || prefijo.isEmpty) {
        throw Failure('Respuesta inválida del servidor');
      }
      return prefijo;
    } on SocketException catch (error) {
      developer.log('Sin conexión al obtener prefijo',
          name: 'LoginService', error: error);
      throw Failure('No hay conexión a internet', cause: error);
    } on TimeoutException catch (error) {
      developer.log('Timeout al obtener prefijo',
          name: 'LoginService', error: error);
      throw Failure('Tiempo de espera agotado al obtener prefijo',
          cause: error);
    } on FormatException catch (error) {
      developer.log('Formato inválido al obtener prefijo',
          name: 'LoginService', error: error);
      throw Failure('Respuesta inválida del servidor', cause: error);
    }
  }

  /// Validates the credentials against the remote API.
  Future<bool> loginOnline(String prefijo, String rut, String pass) async {
    final uri =
        Uri.http(_baseUrl, 'api/Login/$prefijo/iniciar-sesion/$rut/$pass');

    try {
      final response = await _httpClient.get(uri).timeout(_httpTimeout);
      if (response.statusCode != 200) {
        throw Failure('Error al validar credenciales (${response.statusCode})');
      }
      final decoded = jsonDecode(response.body) as Map<String, dynamic>;
      if (decoded['code'] != 200) {
        return false;
      }
      final items = decoded['items'];
      if (items is List && items.isNotEmpty) {
        final item = items.first as Map<String, dynamic>;
        final responseRut = (item['rut'] as String?) ?? rut;
        final normalizedRut = RutUtils.toDatabaseFormat(responseRut);
        final responsePrefix = (item['prefijo'] as String?) ?? prefijo;
        final responseNombre = _stringFromValue(item['nombre']) ??
            _stringFromValue(item['nombreUsuario']) ??
            nombreUsuario;
        final cajaRsp = _stringFromValue(item['caja']) ??
            _stringFromValue(item['caja_doc']) ??
            caja;
        final maxDcto = _doubleFromValue(
          item['maxDctoProducto'] ?? item['max_dcto'] ?? item['descuento'],
          fallback: descuento,
        );
        _onlineUserCache = User(
            rut: normalizedRut,
            prefijo: responsePrefix,
            caja: cajaRsp,
            maxDcto: maxDcto,
            nombre: responseNombre);
        await _updateLocalLoginDatabase(
          normalizedRut,
          responsePrefix,
          pass,
          caja: cajaRsp,
          maxDcto: maxDcto,
        );
      } else {
        final normalizedRut = RutUtils.toDatabaseFormat(rut);
        _onlineUserCache = User(
            rut: normalizedRut,
            prefijo: prefijo,
            caja: caja,
            maxDcto: descuento,
            nombre: nombreUsuario);
        await _updateLocalLoginDatabase(
          normalizedRut,
          prefijo,
          pass,
          caja: caja,
          maxDcto: descuento,
        );
      }
      developer.log('Login remoto exitoso para ${RutUtils.format(rut)}',
          name: 'LoginService');
      return true;
    } on SocketException catch (error) {
      developer.log('Sin conexión durante login online',
          name: 'LoginService', error: error);
      throw Failure('No hay conexión a internet', cause: error);
    } on TimeoutException catch (error) {
      developer.log('Timeout durante login online',
          name: 'LoginService', error: error);
      throw Failure('Tiempo de espera agotado durante login', cause: error);
    } on FormatException catch (error) {
      developer.log('Formato inválido en login online',
          name: 'LoginService', error: error);
      throw Failure('Respuesta inválida del servidor', cause: error);
    }
  }

  /// Attempts to authenticate the user using the local login database or cached credentials.
  Future<bool> loginOffline(String rut, String pass) async {
    try {
      final loginDbPath = await _prepareLoginDatabase();
      final db = await openDatabase(loginDbPath, readOnly: true);
      try {
        final results =
            await db.query('login', where: 'rut = ?', whereArgs: <Object>[rut]);
        if (results.isNotEmpty) {
          final row = results.first;
          final storedPassword = _stringFromValue(row['password']) ?? '';
          final prefix = _stringFromValue(row['prefijo']) ?? '';
          final caja = _stringFromValue(row['caja']) ?? '';
          final nombre = _stringFromValue(row['nombre']) ?? '';
          final dcto = _doubleFromValue(row['max_dcto']);
          final hashedIncoming = _hashPassword(pass);
          if (prefix.isNotEmpty &&
              (storedPassword == pass || storedPassword == hashedIncoming)) {
            _offlineUserCache = User(
                rut: rut,
                prefijo: prefix,
                caja: caja,
                maxDcto: dcto,
                nombre: nombre);
            return true;
          }
        }
      } finally {
        await db.close();
      }

      final cachedCredentials =
          await _loadCachedCredentials(_normalizeRut(rut).cacheKey);
      if (cachedCredentials == null) {
        developer.log('No se encontraron credenciales cacheadas para $rut',
            name: 'LoginService');
        return false;
      }
      final incomingHash = _hashPassword(pass);
      if (cachedCredentials.passwordHash != incomingHash) {
        developer.log('La contraseña cacheada no coincide',
            name: 'LoginService');
        return false;
      }
      _offlineUserCache = User(
          rut: rut,
          prefijo: cachedCredentials.prefix,
          caja: "",
          maxDcto: 0,
          nombre: "");
      return true;
    } on DatabaseException catch (error) {
      developer.log('Error accediendo a la base de login offline',
          name: 'LoginService', error: error);
      return false;
    } on Failure catch (failure) {
      developer.log('Fallo validando credenciales offline',
          name: 'LoginService', error: failure);
      _lastFailure = failure;
      return false;
    } catch (error, stackTrace) {
      developer.log('Error inesperado en login offline',
          name: 'LoginService', error: error, stackTrace: stackTrace);
      return false;
    }
  }

  Future<void> asegurarBaseLocal(String prefijo) async {
    final normalizedPrefix = prefijo.trim().toLowerCase();
    final databasesPath = await getDatabasesPath();
    final clientesPath =
        File(p.join(databasesPath, normalizedPrefix, 'clientes.db'));
    final productosPath =
        File(p.join(databasesPath, normalizedPrefix, 'productos.db'));

    // Si ya existen ambas bases, no hace falta copiar nada
    if (await clientesPath.exists() && await productosPath.exists()) {
      developer.log('Bases locales ya existen para $normalizedPrefix',
          name: 'LoginService');
      return;
    }

    developer.log('Bases locales no encontradas, iniciando descarga remota...',
        name: 'LoginService');

    // Descarga a través del SyncService (asumiendo que lo tienes accesible)
    final syncService = SyncService(
      remoteDataSource: SyncRemoteDataSource(),
      loginService: this,
    );

    await syncService.ensureInitialDataAvailable(
      status: InitialSyncStatus(
        downloadData: true,
        modoLocal: true,
        prefix: normalizedPrefix,
        alreadySynchronized: false,
        missingPrefix: false,
      ),
      onProgress: (progress) {
        developer.log(
          'Descargando ${progress.step} ${progress.progress * 100}%',
          name: 'LoginService',
        );
      },
    );
  }

  /// Retrieves the cached prefix for the provided [rut].
  Future<String?> getCachedPrefix(String rut) async {
    try {
      final rutData = _normalizeRut(rut);
      final credentials = await _loadCachedCredentials(rutData.cacheKey);
      return credentials?.prefix;
    } on Failure {
      return null;
    }
  }

  /// Clears any in-memory cached login information.
  Future<void> logout({bool clearPersistedCredentials = false}) async {
    developer.log('Cerrando sesión y limpiando caches', name: 'LoginService');
    _lastLoginResult = null;
    _lastFailure = null;
    _onlineUserCache = null;
    _offlineUserCache = null;
    caja = '';
    descuento = 0;
    nombreUsuario = '';

    if (!clearPersistedCredentials) {
      return;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final cachePrefix = _cacheKeyFor('');
      final keysToRemove =
          prefs.getKeys().where((key) => key.startsWith(cachePrefix)).toList();
      for (final key in keysToRemove) {
        await prefs.remove(key);
      }
      developer.log(
          'Credenciales persistidas eliminadas (${keysToRemove.length})',
          name: 'LoginService');
    } catch (error, stackTrace) {
      developer.log('Error limpiando credenciales persistidas',
          name: 'LoginService', error: error, stackTrace: stackTrace);
    }
  }

  Future<void> _persistCredentials(
      {required String rut,
      required String prefix,
      required String passwordHash}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = _cacheKeyFor(rut);
      await prefs.setStringList(key, <String>[prefix, passwordHash]);
      developer.log('Credenciales guardadas localmente para $rut',
          name: 'LoginService');
    } catch (error, stackTrace) {
      developer.log('Error guardando credenciales',
          name: 'LoginService', error: error, stackTrace: stackTrace);
    }
  }

  Future<_CachedCredentials?> _loadCachedCredentials(String rutKey) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = _cacheKeyFor(rutKey);
      final cachedValues = prefs.getStringList(key);
      if (cachedValues == null || cachedValues.length != 2) {
        return null;
      }
      return _CachedCredentials(
          prefix: cachedValues.first, passwordHash: cachedValues.last);
    } catch (error, stackTrace) {
      developer.log('Error obteniendo credenciales cacheadas',
          name: 'LoginService', error: error, stackTrace: stackTrace);
      return null;
    }
  }

  Future<String?> _resolveLocalDatabase(String prefix) async {
    final normalizedPrefix = prefix.trim().toLowerCase();
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final databasesPath = await getDatabasesPath();
    final candidates = <String>[
      p.join(documentsDirectory.path, 'clientes.db'),
      p.join(documentsDirectory.path, 'productos.db'),
      p.join(databasesPath, normalizedPrefix, 'clientes.db'),
      p.join(databasesPath, normalizedPrefix, 'productos.db'),
      p.join(databasesPath, '${normalizedPrefix}_local00.db'),
    ];

    for (final candidate in candidates) {
      final file = File(candidate);
      if (await file.exists()) {
        return candidate;
      }
    }
    return null;
  }

  Future<String> _prepareLoginDatabase() async {
    final databasesPath = await getDatabasesPath();
    final destination = p.join(databasesPath, 'login.db');
    await _copyAssetIfNeeded('assets/database/login.db', destination,
        required: true);
    return destination;
  }

  Future<void> _updateLocalLoginDatabase(
      String rut, String prefijo, String password,
      {required String caja, required double maxDcto}) async {
    final loginDbPath = await _prepareLoginDatabase();
    final db = await openDatabase(loginDbPath);
    try {
      await db.insert(
        'login',
        <String, Object?>{
          'rut': rut,
          'password': _hashPassword(password),
          'prefijo': prefijo,
          'caja': caja,
          'url_imagen': '',
          'max_dcto': maxDcto,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (error, stackTrace) {
      developer.log('Error actualizando base de login local',
          name: 'LoginService', error: error, stackTrace: stackTrace);
    } finally {
      await db.close();
    }
  }

  Future<bool> _copyAssetIfNeeded(String assetPath, String destinationPath,
      {bool required = false}) async {
    final file = File(destinationPath);
    if (await file.exists()) {
      return true;
    }

    try {
      final byteData = await rootBundle.load(assetPath);
      await file.parent.create(recursive: true);
      final buffer = byteData.buffer;
      await file.writeAsBytes(
          buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes),
          flush: true);
      developer.log('Base copiada desde asset $assetPath a $destinationPath',
          name: 'LoginService');
      return true;
    } on FlutterError catch (error, stackTrace) {
      developer.log('Asset no encontrado $assetPath',
          name: 'LoginService', error: error, stackTrace: stackTrace);
      if (required) {
        throw Failure('Modo offline no disponible', cause: error);
      }
      return false;
    } catch (error, stackTrace) {
      developer.log('Error copiando asset $assetPath',
          name: 'LoginService', error: error, stackTrace: stackTrace);
      if (required) {
        throw Failure('Error preparando base de datos local', cause: error);
      }
      return false;
    }
  }

  _RutData _normalizeRut(String rut) {
    final cleaned = RutUtils.clean(rut);
    if (cleaned.length < 2) {
      throw Failure('El RUT ingresado no es válido.');
    }
    if (!RutUtils.isValid(cleaned)) {
      throw Failure('El RUT ingresado no es válido.');
    }
    final formatted = RutUtils.format(cleaned);
    final database = RutUtils.toDatabaseFormat(cleaned);
    return _RutData(clean: cleaned, formatted: formatted, database: database);
  }

  String _cacheKeyFor(String rut) => '$_cachePrefix:$rut';

  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  String? _stringFromValue(dynamic value) {
    if (value == null) {
      return null;
    }
    if (value is String) {
      final trimmed = value.trim();
      if (trimmed.isEmpty) {
        return null;
      }
      return trimmed;
    }
    if (value is num || value is bool) {
      return value.toString();
    }
    return null;
  }

  double _doubleFromValue(dynamic value, {double fallback = 0}) {
    if (value is num) {
      return value.toDouble();
    }
    if (value is String) {
      final parsed = double.tryParse(value);
      if (parsed != null) {
        return parsed;
      }
    }
    return fallback;
  }
}
