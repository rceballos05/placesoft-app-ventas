import 'package:aplicacion_ventas/db/database_helper.dart';
import 'package:aplicacion_ventas/models/rollo_observacion.dart';
import 'package:aplicacion_ventas/models/rollo_terreno.dart';
import 'package:sqflite/sqflite.dart';

/// Helper encapsulating CRUD operations over the tbl_rollo_terreno_00 table.
class DBRolloTerreno {
  const DBRolloTerreno._();

  static const _dbName = 'rollo.db';
  static const _tableName = 'tbl_rollo_terreno_00';

  static Future<Database> _open() async {
    final db = await DatabaseHelper.openDatabaseFile(_dbName);
    await DatabaseHelper.ensureSyncColumns(db, _tableName);
    return db;
  }

  static Future<int> insert(RolloTerreno rollo) async {
    final db = await _open();
    try {
      final map = rollo.toMap()
        ..['enviado'] = 0
        ..['intentos'] = 0;
      return await db.insert(_tableName, map);
    } finally {
      await db.close();
    }
  }

  static Future<int> update(RolloTerreno rollo) async {
    final lineaVenta = rollo.lineaVenta;
    if (lineaVenta == null) {
      throw ArgumentError('El campo linea_venta es obligatorio para actualizar.');
    }
    final db = await _open();
    try {
      final map = rollo.toMap()
        ..remove('linea_venta');
      return await db.update(
        _tableName,
        map,
        where: 'linea_venta = ?',
        whereArgs: [lineaVenta],
      );
    } finally {
      await db.close();
    }
  }

  static Future<int> deleteByLineaVenta(double lineaVenta) async {
    final db = await _open();
    try {
      return await db.delete(
        _tableName,
        where: 'linea_venta = ?',
        whereArgs: [lineaVenta],
      );
    } finally {
      await db.close();
    }
  }

  static Future<int> deleteByCodigo(String codigo) async {
    final db = await _open();
    try {
      return await db.delete(
        _tableName,
        where: 'art_codigo = ?',
        whereArgs: [codigo],
      );
    } finally {
      await db.close();
    }
  }

  static Future<List<RolloTerreno>> getAll() async {
    final db = await _open();
    try {
      final result = await db.query(_tableName, orderBy: 'linea_venta ASC');
      return result.map(RolloTerreno.fromMap).toList();
    } finally {
      await db.close();
    }
  }

  static Future<RolloTerreno?> getByCodigo(String codigo) async {
    final db = await _open();
    try {
      final result = await db.query(
        _tableName,
        where: 'art_codigo = ?',
        whereArgs: [codigo],
        limit: 1,
      );
      if (result.isEmpty) {
        return null;
      }
      return RolloTerreno.fromMap(result.first);
    } finally {
      await db.close();
    }
  }

  static Future<int> getNextLineNumber() async {
    final db = await _open();
    try {
      final result = await db.rawQuery('SELECT MAX(linea_venta) as max_line FROM $_tableName');
      var current = 0;
      if (result.isNotEmpty) {
        final value = result.first['max_line'];
        if (value is num) {
          current = value.toInt();
        } else if (value is String) {
          current = int.tryParse(value) ?? 0;
        }
      }
      return current + 1;
    } finally {
      await db.close();
    }
  }

  static Future<int> deleteAll() async {
    final db = await _open();
    try {
      return await db.delete(_tableName);
    } finally {
      await db.close();
    }
  }
}

/// Helper for the local_rollo_observaciones_00 table.
class DBRolloObservaciones {
  const DBRolloObservaciones._();

  static const _dbName = 'rollo.db';
  static const _tableName = 'local_rollo_observaciones_00';

  static Future<Database> _open() async {
    final db = await DatabaseHelper.openDatabaseFile(_dbName);
    await DatabaseHelper.ensureSyncColumns(db, _tableName);
    return db;
  }

  static Future<int> insert(RolloObservacion observacion) async {
    final db = await _open();
    try {
      final map = observacion.toMap()
        ..['enviado'] = 0
        ..['intentos'] = 0;
      return await db.insert(_tableName, map);
    } finally {
      await db.close();
    }
  }

  static Future<int> update(RolloObservacion observacion) async {
    final codigo = observacion.codigo;
    if (codigo == null || codigo.isEmpty) {
      throw ArgumentError('El campo codigo es obligatorio para actualizar.');
    }
    final db = await _open();
    try {
      final map = observacion.toMap();
      return await db.update(
        _tableName,
        map,
        where: 'codigo = ?',
        whereArgs: [codigo],
      );
    } finally {
      await db.close();
    }
  }

  static Future<int> deleteByCodigo(String codigo) async {
    final db = await _open();
    try {
      return await db.delete(
        _tableName,
        where: 'codigo = ?',
        whereArgs: [codigo],
      );
    } finally {
      await db.close();
    }
  }

  static Future<List<RolloObservacion>> getAll() async {
    final db = await _open();
    try {
      final result = await db.query(_tableName);
      return result.map(RolloObservacion.fromMap).toList();
    } finally {
      await db.close();
    }
  }

  static Future<RolloObservacion?> getByCodigo(String codigo) async {
    final db = await _open();
    try {
      final result = await db.query(
        _tableName,
        where: 'codigo = ?',
        whereArgs: [codigo],
        limit: 1,
      );
      if (result.isEmpty) {
        return null;
      }
      return RolloObservacion.fromMap(result.first);
    } finally {
      await db.close();
    }
  }

  static Future<int> deleteAll() async {
    final db = await _open();
    try {
      return await db.delete(_tableName);
    } finally {
      await db.close();
    }
  }
}
