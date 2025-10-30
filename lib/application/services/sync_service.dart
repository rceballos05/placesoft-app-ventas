import 'dart:async';
import 'dart:developer' as developer;
import 'dart:io';

import 'package:aplicacion_ventas/core/utils/failure.dart';
import 'package:aplicacion_ventas/core/utils/result.dart';
import 'package:aplicacion_ventas/data/datasources/remote/sync_remote_datasource.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'login_service.dart';

/// Represents the status of the initial synchronization requirement returned by the API.
class InitialSyncStatus {
  const InitialSyncStatus({
    required this.downloadData,
    required this.modoLocal,
    required this.prefix,
    required this.alreadySynchronized,
    required this.missingPrefix,
  });

  /// Indicates whether the server requests a database refresh.
  final bool downloadData;

  /// Indicates whether the offline mode is enabled remotely.
  final bool modoLocal;

  /// Prefix resolved either locally or by the server.
  final String prefix;

  /// Whether the device already has the offline databases in place.
  final bool alreadySynchronized;

  /// Whether the prefix is missing locally.
  final bool missingPrefix;

  /// True when the download should occur.
  bool get shouldDownload =>
      !alreadySynchronized && !missingPrefix && downloadData && modoLocal;
}

/// Stages emitted while downloading the initial databases.
enum InitialDownloadStep { clientes, productos, verificando, completado }

/// Progress information emitted during the initial download.
class InitialDownloadProgress {
  const InitialDownloadProgress({
    required this.step,
    required this.progress,
  });

  final InitialDownloadStep step;
  final double progress;
}

/// Coordinates synchronization tasks ensuring connectivity checks and error reporting.
class SyncService {
  SyncService({
    required SyncRemoteDataSource remoteDataSource,
    required LoginService loginService,
    Connectivity? connectivity,
    String defaultPrefix = 'crvictoria',
  })  : _remoteDataSource = remoteDataSource,
        _loginService = loginService,
        _connectivity = connectivity ?? Connectivity(),
        _defaultPrefix = defaultPrefix;

  final SyncRemoteDataSource _remoteDataSource;
  final LoginService _loginService;
  final Connectivity _connectivity;
  final String _defaultPrefix;

  static const _syncedFlagKey = 'db_sincronizada';
  static const _storedPrefixKey = 'db_prefijo';

  /// Public API used by the UI to trigger synchronization of pending sales.
  Future<void> sincronizarVentas({required String rut}) async {
    final normalizedRut = rut.trim();
    if (normalizedRut.isEmpty) {
      throw Failure('Debes ingresar un RUT para sincronizar');
    }

    final connectivityResult = await _connectivity.checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      throw Failure('No hay conexión a internet');
    }

    final prefix = await _obtenerPrefijoDesdeCache(normalizedRut);
    if (prefix == null) {
      throw Failure('Modo offline no disponible');
    }

    try {
      developer.log('Sincronizando ventas locales de $prefix', name: 'SyncService');
      await _remoteDataSource.syncLocalSales(prefix: prefix);
      await _loginService.asegurarBaseLocal(prefix);
    } on Failure {
      rethrow;
    } catch (error, stackTrace) {
      developer.log('Error durante la sincronización', name: 'SyncService', error: error, stackTrace: stackTrace);
      throw Failure('No fue posible sincronizar los datos', cause: error);
    }
  }

  /// Downloads catalog and supporting data required for offline mode.
  Future<void> descargarDatosActualizados({required String rut}) async {
    final normalizedRut = rut.trim();
    if (normalizedRut.isEmpty) {
      throw Failure('Debes ingresar un RUT para descargar datos');
    }

    final connectivityResult = await _connectivity.checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      throw Failure('No hay conexión a internet');
    }

    final prefix = await _obtenerPrefijoDesdeCache(normalizedRut);
    if (prefix == null) {
      throw Failure('Modo offline no disponible');
    }

    try {
      developer.log('Descargando información para $prefix', name: 'SyncService');
      await _remoteDataSource.downloadCatalog(prefix: prefix);
      await _loginService.asegurarBaseLocal(prefix);
    } on Failure {
      rethrow;
    } catch (error, stackTrace) {
      developer.log('Error durante la descarga', name: 'SyncService', error: error, stackTrace: stackTrace);
      throw Failure('Error al descargar información', cause: error);
    }
  }

  /// Retrieves whether the initial offline data should be downloaded.
  Future<InitialSyncStatus> getInitialDownloadStatus({String? prefixOverride}) async {
    final prefs = await SharedPreferences.getInstance();
    final alreadySynced = prefs.getBool(_syncedFlagKey) ?? false;

    final storedPrefix = prefixOverride ??
        prefs.getString(_storedPrefixKey) ??
        _defaultPrefix;

    if (storedPrefix.trim().isEmpty) {
      return InitialSyncStatus(
        downloadData: false,
        modoLocal: false,
        prefix: storedPrefix,
        alreadySynchronized: alreadySynced,
        missingPrefix: true,
      );
    }

    if (alreadySynced) {
      return InitialSyncStatus(
        downloadData: false,
        modoLocal: false,
        prefix: storedPrefix,
        alreadySynchronized: true,
        missingPrefix: false,
      );
    }

    final status = await _remoteDataSource.fetchInitialSyncStatus(prefix: storedPrefix);
    await prefs.setString(_storedPrefixKey, status.prefix);
    return InitialSyncStatus(
      downloadData: status.downloadData,
      modoLocal: status.modoLocal,
      prefix: status.prefix,
      alreadySynchronized: false,
      missingPrefix: false,
    );
  }

  /// Ensures the initial offline databases are available locally.
  Future<bool> ensureInitialDataAvailable({
    InitialSyncStatus? status,
    void Function(InitialDownloadProgress progress)? onProgress,
  }) async {
    final effectiveStatus = status ?? await getInitialDownloadStatus();
    if (!effectiveStatus.shouldDownload) {
      return false;
    }

    final documentsDir = await getApplicationDocumentsDirectory();
    final clientsFile = File(p.join(documentsDir.path, 'clientes.db'));
    final productsFile = File(p.join(documentsDir.path, 'productos.db'));

    try {
      onProgress?.call(
        const InitialDownloadProgress(step: InitialDownloadStep.clientes, progress: 0.1),
      );
      final clientsBytes = await _remoteDataSource
          .downloadClientsDatabase(prefix: effectiveStatus.prefix);
      await clientsFile.writeAsBytes(clientsBytes, flush: true);
      await _validateDatabaseFile(clientsFile, 'clientes');

      onProgress?.call(
        const InitialDownloadProgress(step: InitialDownloadStep.productos, progress: 0.6),
      );
      final productsBytes = await _remoteDataSource
          .downloadProductsDatabase(prefix: effectiveStatus.prefix);
      await productsFile.writeAsBytes(productsBytes, flush: true);
      await _validateDatabaseFile(productsFile, 'productos');

      onProgress?.call(
        const InitialDownloadProgress(step: InitialDownloadStep.verificando, progress: 0.85),
      );

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_syncedFlagKey, true);
      await prefs.setString(_storedPrefixKey, effectiveStatus.prefix);

      developer.log('clientes.db almacenado en ${clientsFile.path}', name: 'SyncService');
      developer.log('productos.db almacenado en ${productsFile.path}', name: 'SyncService');
      print('clientes.db -> ${clientsFile.path}');
      print('productos.db -> ${productsFile.path}');

      onProgress?.call(
        const InitialDownloadProgress(step: InitialDownloadStep.completado, progress: 1.0),
      );

      return true;
    } on Failure {
      await _cleanupFiles(<File>[clientsFile, productsFile]);
      rethrow;
    } catch (error, stackTrace) {
      await _cleanupFiles(<File>[clientsFile, productsFile]);
      developer.log('Error guardando bases locales',
          name: 'SyncService', error: error, stackTrace: stackTrace);
      throw Failure('Error al guardar bases locales', cause: error);
    }
  }

  /// Compatibility wrapper retained from the refactor API.
  Future<Result<void>> syncLocalSales({required String rut}) async {
    try {
      await sincronizarVentas(rut: rut);
      return const Success<void>(null);
    } on Failure catch (failure) {
      return FailureResult<void>(failure);
    }
  }

  /// Compatibility wrapper retained from the refactor API.
  Future<Result<void>> downloadLatestData({required String rut}) async {
    try {
      await descargarDatosActualizados(rut: rut);
      return const Success<void>(null);
    } on Failure catch (failure) {
      return FailureResult<void>(failure);
    }
  }

  Future<String?> _obtenerPrefijoDesdeCache(String rut) async {
    final cachedPrefix = await _loginService.getCachedPrefix(rut);
    if (cachedPrefix != null) {
      return cachedPrefix;
    }

    try {
      final prefijo = await _loginService.obtenerPrefijo(rut);
      if (prefijo != null) {
        await _loginService.asegurarBaseLocal(prefijo);
      }
      return prefijo;
    } on Failure catch (failure) {
      developer.log('No fue posible recuperar prefijo', name: 'SyncService', error: failure);
      return null;
    }
  }

  Future<void> _validateDatabaseFile(File file, String name) async {
    if (!await file.exists()) {
      throw Failure('No se pudo guardar $name.db');
    }
    final bytes = await file.length();
    if (bytes <= 0) {
      throw Failure('El archivo $name.db descargado está vacío');
    }
  }

  Future<void> _cleanupFiles(List<File> files) async {
    for (final file in files) {
      try {
        if (await file.exists()) {
          await file.delete();
        }
      } catch (_) {
        // Intentionally ignored: cleanup best-effort only.
      }
    }
  }
}
