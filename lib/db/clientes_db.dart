import 'package:aplicacion_ventas/db/database_helper.dart';
import 'package:aplicacion_ventas/models/mae_cliente.dart';
import 'package:aplicacion_ventas/models/mae_cliente_destino.dart';
import 'package:sqflite/sqflite.dart';

class DBMaeClientes {
  const DBMaeClientes._();

  static const _defaultDbName = 'clientes.db';
  static const _tableName = 'mae_clientes';

  static Future<Database> _open([String? databaseName]) async {
    final db = await DatabaseHelper.openDatabaseFile(databaseName ?? _defaultDbName);
    await DatabaseHelper.ensureSyncColumns(db, _tableName);
    return db;
  }

  static Future<int> insert(MaeCliente cliente, {String? databaseName}) async {
    final db = await _open(databaseName);
    try {
      final map = cliente.toMap()
        ..['enviado'] = 0
        ..['intentos'] = 0;
      return await db.insert(_tableName, map);
    } finally {
      await db.close();
    }
  }

  static Future<int> update(MaeCliente cliente, {String? databaseName}) async {
    final rut = cliente.rut;
    if (rut == null || rut.isEmpty) {
      throw ArgumentError('El RUT es obligatorio para actualizar un cliente.');
    }
    final db = await _open(databaseName);
    try {
      final map = cliente.toMap();
      return await db.update(
        _tableName,
        map,
        where: 'rut = ?',
        whereArgs: [rut],
      );
    } finally {
      await db.close();
    }
  }

  static Future<int> delete(String rut, {String? databaseName}) async {
    final db = await _open(databaseName);
    try {
      return await db.delete(
        _tableName,
        where: 'rut = ?',
        whereArgs: [rut],
      );
    } finally {
      await db.close();
    }
  }

  static Future<List<MaeCliente>> getAll({String? databaseName}) async {
    final db = await _open(databaseName);
    try {
      final result = await db.query(_tableName);
      return result.map(MaeCliente.fromMap).toList();
    } finally {
      await db.close();
    }
  }

  static Future<MaeCliente?> getById(String rut, {String? databaseName}) async {
    final db = await _open(databaseName);
    try {
      final result = await db.query(
        _tableName,
        where: 'rut = ?',
        whereArgs: [rut],
        limit: 1,
      );
      if (result.isEmpty) {
        return null;
      }
      return MaeCliente.fromMap(result.first);
    } finally {
      await db.close();
    }
  }
}

class DBMaeClientesDestinos {
  const DBMaeClientesDestinos._();

  static const _defaultDbName = 'clientes.db';
  static const _tableName = 'mae_clientes_destinos';

  static Future<Database> _open([String? databaseName]) async {
    final db = await DatabaseHelper.openDatabaseFile(databaseName ?? _defaultDbName);
    await DatabaseHelper.ensureSyncColumns(db, _tableName);
    return db;
  }

  static Future<int> insert(MaeClienteDestino destino, {String? databaseName}) async {
    final db = await _open(databaseName);
    try {
      final map = destino.toMap()
        ..['enviado'] = 0
        ..['intentos'] = 0;
      return await db.insert(_tableName, map);
    } finally {
      await db.close();
    }
  }

  static Future<int> update(MaeClienteDestino destino, {String? databaseName}) async {
    final codigo = destino.codigo;
    final cliente = destino.cliente;
    if (codigo == null || cliente == null) {
      throw ArgumentError('codigo y cliente son obligatorios para actualizar un destino.');
    }
    final db = await _open(databaseName);
    try {
      final map = destino.toMap();
      return await db.update(
        _tableName,
        map,
        where: 'codigo = ? AND cliente = ?',
        whereArgs: [codigo, cliente],
      );
    } finally {
      await db.close();
    }
  }

  static Future<int> delete(String codigo, String cliente, {String? databaseName}) async {
    final db = await _open(databaseName);
    try {
      return await db.delete(
        _tableName,
        where: 'codigo = ? AND cliente = ?',
        whereArgs: [codigo, cliente],
      );
    } finally {
      await db.close();
    }
  }

  static Future<List<MaeClienteDestino>> getAll({String? databaseName, String? cliente}) async {
    final db = await _open(databaseName);
    try {
      final result = await db.query(
        _tableName,
        where: cliente == null ? null : 'cliente = ?',
        whereArgs: cliente == null ? null : [cliente],
      );
      return result.map(MaeClienteDestino.fromMap).toList();
    } finally {
      await db.close();
    }
  }

  static Future<MaeClienteDestino?> getById(String codigo, String cliente, {String? databaseName}) async {
    final db = await _open(databaseName);
    try {
      final result = await db.query(
        _tableName,
        where: 'codigo = ? AND cliente = ?',
        whereArgs: [codigo, cliente],
        limit: 1,
      );
      if (result.isEmpty) {
        return null;
      }
      return MaeClienteDestino.fromMap(result.first);
    } finally {
      await db.close();
    }
  }
}
