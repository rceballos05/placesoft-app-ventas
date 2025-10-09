import 'package:aplicacion_ventas/data/services/sync_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provides access to the synchronization service across the app.
final syncServiceProvider = Provider((ref) => SyncService());
