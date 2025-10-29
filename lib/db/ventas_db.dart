import 'package:aplicacion_ventas/db/database_helper.dart';
import 'package:aplicacion_ventas/models/local_venta_cabeza.dart';
import 'package:aplicacion_ventas/models/local_venta_detalle.dart';
import 'package:aplicacion_ventas/models/local_venta_observacion.dart';
import 'package:sqflite/sqflite.dart';

class DBVentaCabeza {
  const DBVentaCabeza._();

  static const _dbName = 'ventas.db';
  static const _tableName = 'local_venta_cabeza_00';

  static Future<Database> _open() async {
    final db = await DatabaseHelper.openDatabaseFile(_dbName);
    await DatabaseHelper.ensureSyncColumns(db, _tableName);
    return db;
  }

  static Future<int> insert(LocalVentaCabeza venta) async {
    final db = await _open();
    try {
      final map = venta.toMap()
        ..['enviado'] = 0
        ..['intentos'] = 0;
      return await db.insert(_tableName, map);
    } finally {
      await db.close();
    }
  }

  static Future<int> update(LocalVentaCabeza venta) async {
    final numeroDoc = venta.numeroDoc;
    if (numeroDoc == null || numeroDoc.isEmpty) {
      throw ArgumentError('El numero_doc es obligatorio para actualizar la cabecera.');
    }
    final db = await _open();
    try {
      final map = venta.toMap();
      return await db.update(
        _tableName,
        map,
        where: 'numero_doc = ?',
        whereArgs: [numeroDoc],
      );
    } finally {
      await db.close();
    }
  }

  static Future<int> delete(String numeroDoc) async {
    final db = await _open();
    try {
      return await db.delete(
        _tableName,
        where: 'numero_doc = ?',
        whereArgs: [numeroDoc],
      );
    } finally {
      await db.close();
    }
  }

  static Future<List<LocalVentaCabeza>> getAll({int? enviado}) async {
    final db = await _open();
    try {
      final result = await db.query(
        _tableName,
        where: enviado == null ? null : 'enviado = ?',
        whereArgs: enviado == null ? null : [enviado],
      );
      return result.map(LocalVentaCabeza.fromMap).toList();
    } finally {
      await db.close();
    }
  }

  static Future<LocalVentaCabeza?> getById(String numeroDoc) async {
    final db = await _open();
    try {
      final result = await db.query(
        _tableName,
        where: 'numero_doc = ?',
        whereArgs: [numeroDoc],
        limit: 1,
      );
      if (result.isEmpty) {
        return null;
      }
      return LocalVentaCabeza.fromMap(result.first);
    } finally {
      await db.close();
    }
  }
}

class DBVentaDetalle {
  const DBVentaDetalle._();

  static const _dbName = 'ventas.db';
  static const _tableName = 'local_venta_detalle_00';

  static Future<Database> _open() async {
    final db = await DatabaseHelper.openDatabaseFile(_dbName);
    await DatabaseHelper.ensureSyncColumns(db, _tableName);
    return db;
  }

  static Future<int> insert(LocalVentaDetalle detalle) async {
    final db = await _open();
    try {
      final map = detalle.toMap()
        ..['enviado'] = 0
        ..['intentos'] = 0;
      return await db.insert(_tableName, map);
    } finally {
      await db.close();
    }
  }

  static Future<int> update(LocalVentaDetalle detalle) async {
    final numeroDoc = detalle.numeroDoc;
    final linea = detalle.lineaVenta;
    if (numeroDoc == null || linea == null) {
      throw ArgumentError('numero_doc y linea_venta son obligatorios para actualizar el detalle.');
    }
    final db = await _open();
    try {
      final map = detalle.toMap();
      return await db.update(
        _tableName,
        map,
        where: 'numero_doc = ? AND linea_venta = ?',
        whereArgs: [numeroDoc, linea],
      );
    } finally {
      await db.close();
    }
  }

  static Future<int> delete(String numeroDoc, String lineaVenta) async {
    final db = await _open();
    try {
      return await db.delete(
        _tableName,
        where: 'numero_doc = ? AND linea_venta = ?',
        whereArgs: [numeroDoc, lineaVenta],
      );
    } finally {
      await db.close();
    }
  }

  static Future<int> deleteByNumeroDoc(String numeroDoc) async {
    final db = await _open();
    try {
      return await db.delete(
        _tableName,
        where: 'numero_doc = ?',
        whereArgs: [numeroDoc],
      );
    } finally {
      await db.close();
    }
  }

  static Future<List<LocalVentaDetalle>> getAll({String? numeroDoc}) async {
    final db = await _open();
    try {
      final result = await db.query(
        _tableName,
        where: numeroDoc == null ? null : 'numero_doc = ?',
        whereArgs: numeroDoc == null ? null : [numeroDoc],
      );
      return result.map(LocalVentaDetalle.fromMap).toList();
    } finally {
      await db.close();
    }
  }

  static Future<LocalVentaDetalle?> getById(String numeroDoc, String lineaVenta) async {
    final db = await _open();
    try {
      final result = await db.query(
        _tableName,
        where: 'numero_doc = ? AND linea_venta = ?',
        whereArgs: [numeroDoc, lineaVenta],
        limit: 1,
      );
      if (result.isEmpty) {
        return null;
      }
      return LocalVentaDetalle.fromMap(result.first);
    } finally {
      await db.close();
    }
  }
}

class DBVentaObservaciones {
  const DBVentaObservaciones._();

  static const _dbName = 'ventas.db';
  static const _tableName = 'local_venta_observaciones_00';

  static Future<Database> _open() async {
    final db = await DatabaseHelper.openDatabaseFile(_dbName);
    await DatabaseHelper.ensureSyncColumns(db, _tableName);
    return db;
  }

  static Future<int> insert(LocalVentaObservacion observacion) async {
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

  static Future<int> update(LocalVentaObservacion observacion) async {
    final numeroDoc = observacion.numeroDoc;
    final linea = observacion.lineaVenta;
    if (numeroDoc == null || linea == null) {
      throw ArgumentError('numero_doc y linea_venta son obligatorios para actualizar observaciones.');
    }
    final db = await _open();
    try {
      final map = observacion.toMap();
      return await db.update(
        _tableName,
        map,
        where: 'numero_doc = ? AND linea_venta = ?',
        whereArgs: [numeroDoc, linea],
      );
    } finally {
      await db.close();
    }
  }

  static Future<int> delete(String numeroDoc, String lineaVenta) async {
    final db = await _open();
    try {
      return await db.delete(
        _tableName,
        where: 'numero_doc = ? AND linea_venta = ?',
        whereArgs: [numeroDoc, lineaVenta],
      );
    } finally {
      await db.close();
    }
  }

  static Future<int> deleteByNumeroDoc(String numeroDoc) async {
    final db = await _open();
    try {
      return await db.delete(
        _tableName,
        where: 'numero_doc = ?',
        whereArgs: [numeroDoc],
      );
    } finally {
      await db.close();
    }
  }

  static Future<List<LocalVentaObservacion>> getAll({String? numeroDoc}) async {
    final db = await _open();
    try {
      final result = await db.query(
        _tableName,
        where: numeroDoc == null ? null : 'numero_doc = ?',
        whereArgs: numeroDoc == null ? null : [numeroDoc],
      );
      return result.map(LocalVentaObservacion.fromMap).toList();
    } finally {
      await db.close();
    }
  }

  static Future<LocalVentaObservacion?> getById(String numeroDoc, String lineaVenta) async {
    final db = await _open();
    try {
      final result = await db.query(
        _tableName,
        where: 'numero_doc = ? AND linea_venta = ?',
        whereArgs: [numeroDoc, lineaVenta],
        limit: 1,
      );
      if (result.isEmpty) {
        return null;
      }
      return LocalVentaObservacion.fromMap(result.first);
    } finally {
      await db.close();
    }
  }
}
