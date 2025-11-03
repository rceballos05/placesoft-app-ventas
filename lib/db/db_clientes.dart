import 'package:aplicacion_ventas/db/clientes_db.dart';
import 'package:aplicacion_ventas/db/database_helper.dart';
import 'package:aplicacion_ventas/models/cliente.dart';
import 'package:aplicacion_ventas/models/clientebusqueda.dart';
import 'package:aplicacion_ventas/models/mae_cliente.dart';
import 'package:sqflite/sqflite.dart';

class DBClientes {
  const DBClientes._();

  static Future<Database> _openDb() async {
    final db = await DatabaseHelper.openDatabaseFile('clientes.db');
    //await DatabaseHelper.ensureSyncColumns(db, 'mae_clientes');
    return db;
  }

  static Future<int> insert(MaeCliente cliente) {
    return DBMaeClientes.insert(cliente);
  }

  static Future<List<ClienteBusquedaDto>> clienteSearch(String query) async {
    final db = await _openDb();
    try {
      final palabra = query.trim().toLowerCase();
      final clientes = <ClienteBusquedaDto>[];

      if (palabra.isEmpty) {
        // Devuelve los primeros registros por defecto
        final result = await db.query(
          "mae_clientes",
          limit: 20,
          orderBy: "nombre ASC",
        );
        return result.map((e) => ClienteBusquedaDto.fromMap(e)).toList();
      }

      // Búsqueda flexible: coincide en cualquier parte del nombre o rut
      final result = await db.rawQuery('''
    SELECT 
      c.rut, 
      c.nombre, 
      c.direccion,
      c.comuna,
      c.ciudad,
      d.codigo,
      d.descripcion,
      d.nombre_contacto,
      d.fono_contacto,
      d.email_contacto
    FROM mae_clientes c
    LEFT JOIN mae_clientes_destinos d 
      ON c.rut = d.cliente
    WHERE 
      c.nombre LIKE ? 
      OR c.rut LIKE ? 
      OR d.descripcion LIKE ?
    ORDER BY c.nombre ASC
  ''', ['%$query%', '%$query%', '%$query%']);

      for (final item in result) {
        clientes.add(ClienteBusquedaDto.fromMap(item));
      }

      return clientes;
    } finally {
      await db.close();
    }
  }
}
