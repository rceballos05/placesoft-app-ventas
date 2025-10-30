import 'package:aplicacion_ventas/db/clientes_db.dart';
import 'package:aplicacion_ventas/db/database_helper.dart';
import 'package:aplicacion_ventas/models/cliente.dart';
import 'package:aplicacion_ventas/models/mae_cliente.dart';
import 'package:sqflite/sqflite.dart';

class DBClientes {
  const DBClientes._();

  static Future<Database> _openDb() async {
    final db = await DatabaseHelper.openDatabaseFile('clientes.db');
    await DatabaseHelper.ensureSyncColumns(db, 'mae_clientes');
    return db;
  }

  static Future<int> insert(MaeCliente cliente) {
    return DBMaeClientes.insert(cliente);
  }

  static Future<List<Cliente>> clienteSearch(String query) async {
    final db = await _openDb();
    try {
      final palabra = query.trim().toLowerCase();
      final clientes = <Cliente>[];

      if (palabra.isEmpty) {
        // Devuelve los primeros registros por defecto
        final result = await db.query(
          "mae_clientes",
          limit: 20,
          orderBy: "nombre ASC",
        );
        return result.map((e) => Cliente.fromMap(e)).toList();
      }

      // Búsqueda flexible: coincide en cualquier parte del nombre o rut
      final result = await db.rawQuery('''
        SELECT * FROM mae_clientes
        WHERE LOWER(nombre) LIKE ?
           OR LOWER(rut) LIKE ?
        ORDER BY nombre ASC
        LIMIT 50
      ''', ['%$palabra%', '%$palabra%']);

      for (final item in result) {
        clientes.add(Cliente.fromMap(item));
      }

      return clientes;
    } finally {
      await db.close();
    }
  }
}
