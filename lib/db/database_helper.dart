import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

/// Utility helpers to work with the local SQLite databases shipped in the app.
class DatabaseHelper {
  const DatabaseHelper._();

  static Future<String> _resolveDatabasePath(String fileName) async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final documentsPath = p.join(documentsDirectory.path, fileName);
    final documentsFile = File(documentsPath);
    if (await documentsFile.exists()) {
      return documentsPath;
    }

    final databasesPath = await getDatabasesPath();
    return p.join(databasesPath, fileName);
  }

  static Future<Database> openDatabaseFile(String fileName) async {
    final path = await _resolveDatabasePath(fileName);
    return openDatabase(path);
  }

  /// Ensures the given table contains the synchronization columns required to
  /// track offline → online operations.
  static Future<void> ensureSyncColumns(Database db, String tableName) async {
    final columns = await db.rawQuery('PRAGMA table_info($tableName)');
    final hasEnviado = columns.any((row) => row['name'] == 'enviado');
    if (!hasEnviado) {
      await db.execute(
        'ALTER TABLE $tableName ADD COLUMN enviado INTEGER DEFAULT 0',
      );
    }
    final hasIntentos = columns.any((row) => row['name'] == 'intentos');
    if (!hasIntentos) {
      await db.execute(
        'ALTER TABLE $tableName ADD COLUMN intentos INTEGER DEFAULT 0',
      );
    }
  }
}
