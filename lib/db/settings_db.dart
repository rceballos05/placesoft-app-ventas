import 'package:aplicacion_ventas/db/database_helper.dart';
import 'package:aplicacion_ventas/models/log_track.dart';
import 'package:sqflite/sqflite.dart';

class DBLogTrack {
  const DBLogTrack._();

  static const _dbName = 'settings.db';
  static const _tableName = 'log_track';

  static Future<Database> _open() async {
    final db = await DatabaseHelper.openDatabaseFile(_dbName);
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $_tableName (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        operacion TEXT,
        payload TEXT,
        created_at TEXT,
        nivel TEXT,
        enviado INTEGER DEFAULT 0,
        intentos INTEGER DEFAULT 0
      )
    ''');
    await DatabaseHelper.ensureSyncColumns(db, _tableName);
    return db;
  }

  static Future<int> insert(LogTrack log) async {
    final db = await _open();
    try {
      final map = log.toMap()
        ..remove('id')
        ..['enviado'] = 0
        ..['intentos'] = 0;
      return await db.insert(_tableName, map);
    } finally {
      await db.close();
    }
  }

  static Future<int> update(LogTrack log) async {
    final id = log.id;
    if (id == null) {
      throw ArgumentError('El id es obligatorio para actualizar un log.');
    }
    final db = await _open();
    try {
      final map = log.toMap()
        ..remove('id');
      return await db.update(
        _tableName,
        map,
        where: 'id = ?',
        whereArgs: [id],
      );
    } finally {
      await db.close();
    }
  }

  static Future<int> delete(int id) async {
    final db = await _open();
    try {
      return await db.delete(
        _tableName,
        where: 'id = ?',
        whereArgs: [id],
      );
    } finally {
      await db.close();
    }
  }

  static Future<List<LogTrack>> getAll({int? enviado}) async {
    final db = await _open();
    try {
      final result = await db.query(
        _tableName,
        where: enviado == null ? null : 'enviado = ?',
        whereArgs: enviado == null ? null : [enviado],
        orderBy: 'created_at DESC',
      );
      return result.map(LogTrack.fromMap).toList();
    } finally {
      await db.close();
    }
  }

  static Future<LogTrack?> getById(int id) async {
    final db = await _open();
    try {
      final result = await db.query(
        _tableName,
        where: 'id = ?',
        whereArgs: [id],
        limit: 1,
      );
      if (result.isEmpty) {
        return null;
      }
      return LogTrack.fromMap(result.first);
    } finally {
      await db.close();
    }
  }
}
