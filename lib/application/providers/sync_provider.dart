import 'package:aplicacion_ventas/data/datasources/remote/sync_remote_datasource.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provides access to the synchronization data source across the app.
final syncRemoteDataSourceProvider = Provider<SyncRemoteDataSource>(
  (ref) => SyncRemoteDataSource(),
);

/// Public provider used by the UI to trigger synchronization workflows.
final syncServiceProvider = Provider<SyncRemoteDataSource>(
  (ref) => ref.watch(syncRemoteDataSourceProvider),
);
