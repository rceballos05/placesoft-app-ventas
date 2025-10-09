import 'dart:async';
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
}
