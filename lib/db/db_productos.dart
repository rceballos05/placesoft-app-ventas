import 'dart:io';

import 'package:aplicacion_ventas/db/productos.dart';
import 'package:aplicacion_ventas/models/producto.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DBProductos {
  const DBProductos._();

  static const _tableName = 'mae_articulos_00';
  static Database? _cachedDb;
  static String? _cachedPath;

  static Future<List<MaeArticulos>> productos({
    Database? database,
    String? databasePath,
    int? limit,
  }) async {
    final shouldClose = database == null;
    final db = database ?? await openDatabase(databasePath!, readOnly: true);
    try {
      final result = await db.query(
        _tableName,
        limit: limit,
        orderBy: 'descripcion COLLATE NOCASE ASC',
      );
      return result.map((map) => MaeArticulos.fromMap(map)).toList();
    } finally {
      if (shouldClose) {
        await db.close();
      }
    }
  }

  static Future<List<Producto>> productoSearch(String query) async {
    final db = await _openDb();
    final palabra = query.trim().toLowerCase();
    final productos = <Producto>[];

    if (palabra.isEmpty) {
      final result = await db.query(
        _tableName,
        limit: 30,
        orderBy: 'descripcion ASC',
      );
      return result.map((e) => Producto.fromMap(e)).toList();
    }

    final result = await db.rawQuery('''
    SELECT * FROM $_tableName
    WHERE LOWER(descripcion) LIKE ?
       OR LOWER(codigobarra) LIKE ?
       OR LOWER(cod_interno) LIKE ?
    ORDER BY descripcion ASC
    LIMIT 50
  ''', ['%$palabra%', '%$palabra%', '%$palabra%']);

    for (final item in result) {
      productos.add(Producto.fromMap(item));
    }

    return productos;
  }

  static Future<Database> _openDb() async {
    final cached = _cachedDb;
    if (cached != null && cached.isOpen) {
      return cached;
    }

    final path = await _resolveDatabasePath();
    final db = await openDatabase(path, readOnly: true);
    _cachedDb = db;
    return db;
  }

  static Future<String> _resolveDatabasePath() async {
    final cachedPath = _cachedPath;
    if (cachedPath != null && await File(cachedPath).exists()) {
      return cachedPath;
    }

    final documentsDirectory = await getApplicationDocumentsDirectory();
    final databasesPath = await getDatabasesPath();
    final candidates = <String>{
      p.join(documentsDirectory.path, 'productos.db'),
      p.join(databasesPath, 'productos.db'),
    };

    final baseDir = Directory(databasesPath);
    if (await baseDir.exists()) {
      await for (final entity in baseDir.list(followLinks: false)) {
        if (entity is File) {
          final name = p.basename(entity.path).toLowerCase();
          if (name == 'productos.db' || name.endsWith('_local00.db')) {
            candidates.add(entity.path);
          }
        } else if (entity is Directory) {
          final dirName = p.basename(entity.path).toLowerCase();
          candidates
            ..add(p.join(entity.path, 'productos.db'))
            ..add(p.join(entity.path, '${dirName}_local00.db'));
        }
      }
    }

    for (final path in candidates) {
      final file = File(path);
      if (await file.exists()) {
        _cachedPath = path;
        return path;
      }
    }

    throw StateError('No se encontró la base de datos de productos.');
  }
}
