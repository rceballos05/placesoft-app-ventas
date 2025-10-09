import 'dart:developer' as developer;

/// Handles synchronization tasks with offline databases and remote APIs.
class SyncRemoteDataSource {
  /// Downloads data required for offline usage.
  Future<void> downloadCatalog({required String prefix}) async {
    try {
      developer.log('Descargando catálogo para $prefix', name: 'SyncRemoteDataSource');
      await Future<void>.delayed(const Duration(milliseconds: 300));
    } catch (error, stackTrace) {
      developer.log('Error al descargar catálogo', name: 'SyncRemoteDataSource', error: error, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Synchronizes pending changes captured offline.
  Future<void> syncLocalSales({required String prefix}) async {
    try {
      developer.log('Sincronizando ventas locales de $prefix', name: 'SyncRemoteDataSource');
      await Future<void>.delayed(const Duration(milliseconds: 300));
    } catch (error, stackTrace) {
      developer.log('Error al sincronizar ventas', name: 'SyncRemoteDataSource', error: error, stackTrace: stackTrace);
      rethrow;
    }
  }
}
