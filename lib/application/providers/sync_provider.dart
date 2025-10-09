import 'package:aplicacion_ventas/data/datasources/remote/sync_remote_datasource.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provides access to the synchronization service across the app.
final syncRemoteDataSourceProvider = Provider((ref) => SyncRemoteDataSource());
