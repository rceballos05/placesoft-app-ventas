import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

/// Utility helpers to work with the local SQLite databases shipped or downloaded by the app.
class DatabaseHelper {
  const DatabaseHelper._();

  /// Busca el archivo de base de datos en todas las ubicaciones posibles.
  static Future<String> _resolveDatabasePath(String fileName) async {
    // 1️⃣ Buscar en /app_flutter
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final docPath = p.join(documentsDirectory.path, fileName);
    if (await File(docPath).exists()) return docPath;

    // 2️⃣ Buscar en /databases/
    final databasesPath = await getDatabasesPath();
    final flatDbPath = p.join(databasesPath, fileName);
    if (await File(flatDbPath).exists()) return flatDbPath;

    // 3️⃣ Buscar en subcarpetas (por ejemplo /databases/<prefijo>/clientes.db)
    final dbDir = Directory(databasesPath);
    if (await dbDir.exists()) {
      await for (final entity
          in dbDir.list(recursive: true, followLinks: false)) {
        if (entity is File && p.basename(entity.path) == fileName) {
          return entity.path;
        }
      }
    }

    // 4️⃣ Si no existe, devolver la ruta plana (Sqflite la creará si se abre en modo RW)
    return flatDbPath;
  }

  /// Abre la base de datos especificada, buscando en todas las rutas posibles.
  static Future<Database> openDatabaseFile(String fileName) async {
    final path = await _resolveDatabasePath(fileName);
    return openDatabase(path);
  }

  /// Añade columnas de sincronización si no existen (enviado / intentos)
  static Future<void> ensureSyncColumns(Database db, String tableName) async {
    final columns = await db.rawQuery('PRAGMA table_info($tableName)');
    final hasEnviado = columns.any((row) => row['name'] == 'enviado');
    if (!hasEnviado) {
      await db.execute(
          'ALTER TABLE $tableName ADD COLUMN enviado INTEGER DEFAULT 0');
    }
    final hasIntentos = columns.any((row) => row['name'] == 'intentos');
    if (!hasIntentos) {
      await db.execute(
          'ALTER TABLE $tableName ADD COLUMN intentos INTEGER DEFAULT 0');
    }
  }
}
