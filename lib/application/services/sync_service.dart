import 'dart:developer' as developer;

import 'package:aplicacion_ventas/core/utils/failure.dart';
import 'package:aplicacion_ventas/core/utils/result.dart';
import 'package:aplicacion_ventas/data/datasources/remote/sync_remote_datasource.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import 'login_service.dart';

/// Coordinates synchronization tasks ensuring connectivity checks and error reporting.
class SyncService {
  SyncService({
    required SyncRemoteDataSource remoteDataSource,
    required LoginService loginService,
    Connectivity? connectivity,
  })  : _remoteDataSource = remoteDataSource,
        _loginService = loginService,
        _connectivity = connectivity ?? Connectivity();

  final SyncRemoteDataSource _remoteDataSource;
  final LoginService _loginService;
  final Connectivity _connectivity;

  /// Sends local sales to the server using the cached prefix for the provided [rut].
  Future<Result<void>> syncLocalSales({required String rut}) async {
    developer.log('Solicitando sincronización de ventas', name: 'SyncService');
    final normalizedRut = rut.trim().toLowerCase();
    if (normalizedRut.isEmpty) {
      return FailureResult<void>(Failure('Debes ingresar un RUT para sincronizar'));
    }

    try {
      final connectivityResult = await _connectivity.checkConnectivity();
      if (connectivityResult == ConnectivityResult.none) {
        developer.log('Sin conexión disponible para sincronizar', name: 'SyncService');
        return FailureResult<void>(Failure('No hay conexión a internet'));
      }

      final prefix = await _loginService.getCachedPrefix(normalizedRut);
      if (prefix == null) {
        developer.log('No existe prefijo cacheado para $normalizedRut', name: 'SyncService');
        return FailureResult<void>(Failure('Modo offline no disponible'));
      }

      await _remoteDataSource.syncLocalSales(prefix: prefix);
      developer.log('Sincronización completada', name: 'SyncService');
      return const Success<void>(null);
    } catch (error, stackTrace) {
      developer.log('Error durante la sincronización', name: 'SyncService', error: error, stackTrace: stackTrace);
      return FailureResult<void>(Failure('No fue posible sincronizar los datos', cause: error));
    }
  }

  /// Downloads new catalog information for the company associated to the provided [rut].
  Future<Result<void>> downloadLatestData({required String rut}) async {
    developer.log('Iniciando descarga de datos', name: 'SyncService');
    final normalizedRut = rut.trim().toLowerCase();
    if (normalizedRut.isEmpty) {
      return FailureResult<void>(Failure('Debes ingresar un RUT para descargar datos'));
    }

    try {
      final connectivityResult = await _connectivity.checkConnectivity();
      if (connectivityResult == ConnectivityResult.none) {
        developer.log('Sin conexión para descargar datos', name: 'SyncService');
        return FailureResult<void>(Failure('No hay conexión a internet'));
      }

      final prefix = await _loginService.getCachedPrefix(normalizedRut);
      if (prefix == null) {
        developer.log('No existe prefijo cacheado para $normalizedRut', name: 'SyncService');
        return FailureResult<void>(Failure('Modo offline no disponible'));
      }

      await _remoteDataSource.downloadCatalog(prefix: prefix);
      developer.log('Descarga finalizada', name: 'SyncService');
      return const Success<void>(null);
    } catch (error, stackTrace) {
      developer.log('Error durante la descarga', name: 'SyncService', error: error, stackTrace: stackTrace);
      return FailureResult<void>(Failure('Error al descargar información', cause: error));
    }
  }
}
