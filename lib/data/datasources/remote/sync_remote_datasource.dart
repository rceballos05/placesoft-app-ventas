import 'dart:async';
import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:aplicacion_ventas/core/utils/failure.dart';
import 'package:http/http.dart' as http;

/// Remote response describing whether the initial offline databases should be downloaded.
class RemoteInitialSyncStatus {
  const RemoteInitialSyncStatus({
    required this.downloadData,
    required this.modoLocal,
    required this.prefix,
  });

  /// Indicates if the server requests a fresh download of the offline data.
  final bool downloadData;

  /// Indicates if the offline mode is enabled for the current prefix.
  final bool modoLocal;

  /// Prefix resolved by the server.
  final String prefix;
}

/// Handles synchronization tasks with offline databases and remote APIs.
class SyncRemoteDataSource {
  SyncRemoteDataSource({http.Client? client})
      : _client = client ?? http.Client();

  final http.Client _client;

  static const String _baseUrl = '45.236.164.152:80';
  static const Duration _requestTimeout = Duration(seconds: 30);

  /// Downloads data required for offline usage.
  Future<void> downloadCatalog({required String prefix}) async {
    try {
      developer.log('Descargando catálogo para $prefix',
          name: 'SyncRemoteDataSource');
      await Future<void>.delayed(const Duration(milliseconds: 300));
    } catch (error, stackTrace) {
      developer.log('Error al descargar catálogo',
          name: 'SyncRemoteDataSource', error: error, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Synchronizes pending changes captured offline.
  Future<void> syncLocalSales({required String prefix}) async {
    try {
      developer.log('Sincronizando ventas locales de $prefix',
          name: 'SyncRemoteDataSource');
      await Future<void>.delayed(const Duration(milliseconds: 300));
    } catch (error, stackTrace) {
      developer.log('Error al sincronizar ventas',
          name: 'SyncRemoteDataSource', error: error, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Retrieves the synchronization status for the provided [prefix].
  Future<RemoteInitialSyncStatus> fetchInitialSyncStatus(
      {required String prefix}) async {
    final normalizedPrefix = prefix.trim().toLowerCase();
    final uri =
        Uri.http(_baseUrl, '/api/Sincronizacion/estado/$normalizedPrefix');
    developer.log(
        'Consultando estado de sincronización inicial para $normalizedPrefix',
        name: 'SyncRemoteDataSource');

    try {
      final response = await _client.get(uri).timeout(_requestTimeout);
      if (response.statusCode != HttpStatus.ok) {
        throw Failure(
            'Error al consultar estado de sincronización (${response.statusCode})');
      }

      final Map<String, dynamic> body =
          jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      final downloadData = _parseBool(body['download_data']);
      final modoLocal = _parseBool(body['modo_local']);
      final serverPrefix = (body['prefijo'] as String?)?.trim().toLowerCase();

      return RemoteInitialSyncStatus(
        downloadData: downloadData,
        modoLocal: modoLocal,
        prefix: (serverPrefix != null && serverPrefix.isNotEmpty)
            ? serverPrefix
            : normalizedPrefix,
      );
    } on TimeoutException {
      throw Failure(
          'Tiempo de espera agotado al consultar estado de sincronización');
    } on SocketException {
      throw Failure('No fue posible conectar con el servidor');
    } on FormatException catch (error, stackTrace) {
      developer.log('Formato inválido al consultar estado',
          name: 'SyncRemoteDataSource', error: error, stackTrace: stackTrace);
      throw Failure('Respuesta inválida al consultar estado de sincronización',
          cause: error);
    } catch (error, stackTrace) {
      developer.log('Error consultando estado inicial',
          name: 'SyncRemoteDataSource', error: error, stackTrace: stackTrace);
      if (error is Failure) {
        rethrow;
      }
      throw Failure('Error al consultar estado de sincronización',
          cause: error);
    }
  }

  /// Downloads the clients database for the provided [prefix].
  Future<void> downloadClientsDatabase({required String prefix}) async {
    final normalizedPrefix = prefix.trim().toLowerCase();
    final uri = Uri.http(
        _baseUrl, '/api/Sincronizacion/export-clientes/$normalizedPrefix');

    developer.log('Descargando base de datos de clientes desde ${uri.path}',
        name: 'SyncRemoteDataSource');

    try {
      final response = await _client.get(uri).timeout(_requestTimeout);
      if (response.statusCode != HttpStatus.ok) {
        throw Failure(
            'Error al descargar clientes.db (${response.statusCode}). Vuelva a intentar.');
      }

      final bytes = response.bodyBytes;
      if (bytes.isEmpty) {
        throw Failure('El archivo clientes.db recibido está vacío');
      }

      // Guardar el archivo usando el método nuevo
      await _saveDownloadedDatabase('clientes.db', bytes, normalizedPrefix);

      developer.log(
          '✅ clientes.db guardado correctamente para $normalizedPrefix',
          name: 'SyncRemoteDataSource');
    } on TimeoutException {
      throw Failure('Tiempo de espera agotado al descargar clientes.db');
    } on SocketException {
      throw Failure('No hay conexión para descargar clientes.db');
    } catch (error, stackTrace) {
      developer.log('Error descargando clientes.db',
          name: 'SyncRemoteDataSource', error: error, stackTrace: stackTrace);
      if (error is Failure) rethrow;
      throw Failure('Error al descargar clientes.db', cause: error);
    }
  }

  /// Downloads the products database for the provided [prefix].
  Future<void> downloadProductsDatabase({required String prefix}) async {
    final normalizedPrefix = prefix.trim().toLowerCase();
    final uri = Uri.http(
        _baseUrl, '/api/Sincronizacion/export-productos/$normalizedPrefix');

    developer.log('Descargando base de datos de productos desde ${uri.path}',
        name: 'SyncRemoteDataSource');

    try {
      final response = await _client.get(uri).timeout(_requestTimeout);
      if (response.statusCode != HttpStatus.ok) {
        throw Failure(
            'Error al descargar productos.db (${response.statusCode}). Vuelva a intentar.');
      }

      final bytes = response.bodyBytes;
      if (bytes.isEmpty) {
        throw Failure('El archivo productos.db recibido está vacío');
      }

      // Guardar el archivo usando el método nuevo
      await _saveDownloadedDatabase('productos.db', bytes, normalizedPrefix);

      developer.log(
          '✅ productos.db guardado correctamente para $normalizedPrefix',
          name: 'SyncRemoteDataSource');
    } on TimeoutException {
      throw Failure('Tiempo de espera agotado al descargar productos.db');
    } on SocketException {
      throw Failure('No hay conexión para descargar productos.db');
    } catch (error, stackTrace) {
      developer.log('Error descargando productos.db',
          name: 'SyncRemoteDataSource', error: error, stackTrace: stackTrace);
      if (error is Failure) rethrow;
      throw Failure('Error al descargar productos.db', cause: error);
    }
  }

  Future<List<int>> _downloadDatabase({
    required Uri uri,
    required String databaseName,
  }) async {
    developer.log('Descargando base de datos $databaseName desde ${uri.path}',
        name: 'SyncRemoteDataSource');
    try {
      final response = await _client.get(uri).timeout(_requestTimeout);
      if (response.statusCode != HttpStatus.ok) {
        throw Failure(
            'Error al descargar $databaseName (${response.statusCode}). Vuelva a intentar.');
      }

      final bytes = response.bodyBytes;
      if (bytes.isEmpty) {
        throw Failure('El archivo $databaseName.db recibido está vacío');
      }
      return bytes;
    } on TimeoutException {
      throw Failure('Tiempo de espera agotado al descargar $databaseName');
    } on SocketException {
      throw Failure('No hay conexión para descargar $databaseName');
    } catch (error, stackTrace) {
      developer.log('Error descargando $databaseName',
          name: 'SyncRemoteDataSource', error: error, stackTrace: stackTrace);
      if (error is Failure) {
        rethrow;
      }
      throw Failure('Error al descargar $databaseName', cause: error);
    }
  }

  bool _parseBool(dynamic value) {
    if (value is bool) {
      return value;
    }
    if (value is num) {
      return value != 0;
    }
    if (value is String) {
      final normalized = value.toLowerCase();
      return normalized == '1' || normalized == 'true' || normalized == 'si';
    }
    return false;
  }

  Future<void> _saveDownloadedDatabase(
    String fileName,
    List<int> bytes,
    String prefijo,
  ) async {
    final normalizedPrefix = prefijo.trim().toLowerCase();
    final databasesPath = await getDatabasesPath();
    developer.log('Descargando ${fileName} (${bytes.length} bytes)...',
        name: 'SyncRemoteDataSource');

    // Crear carpeta del prefijo si no existe
    final prefixDir = Directory(p.join(databasesPath, normalizedPrefix));
    if (!await prefixDir.exists()) {
      await prefixDir.create(recursive: true);
    }

    // Ruta destino: /databases/<prefijo>/<archivo>
    final destinationPath = p.join(prefixDir.path, fileName);
    final file = File(destinationPath);
    await file.writeAsBytes(bytes, flush: true);

    // Limpieza opcional: borrar copias viejas de /app_flutter
    try {
      final docs = await getApplicationDocumentsDirectory();
      final oldFile = File(p.join(docs.path, fileName));
      if (await oldFile.exists()) {
        await oldFile.delete();
      }
    } catch (_) {}

    developer.log('📦 Base de datos guardada en: $destinationPath',
        name: 'SyncRemoteDataSource');
  }
}
