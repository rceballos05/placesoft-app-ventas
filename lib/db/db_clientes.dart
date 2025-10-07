import 'package:aplicacion_ventas/db/clientes.dart';

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBClientes {
  static Future<Database> _openDb() async {
    return openDatabase(
      join(await getDatabasesPath(), 'clientes.db'),
      version: 1,
    );
  }

  static Future clienteSearch(String palabra) async {
    Database database = await _openDb();
    List<MaeClientes> clientes = [];
    var result = await database.query("mae_clientes",
        where: "nombre LIKE ? OR rut LIKE ?",
        limit: 20,
        orderBy: "nombre asc",
        whereArgs: ['%$palabra%', '%$palabra%']);
    if (result.isNotEmpty) {
      for (var item in result) {
        clientes.add(MaeClientes.fromMap(item));
      }
      return clientes;
    }
  }

  static Future ObtenerNombreCliente(String rut) async {
    Database database = await _openDb();
    var result = await database.query(
      'mae_clientes',
      where: "rut = ?",
      whereArgs: [rut],
    );

    if (result.isNotEmpty) {
      return MaeClientes.fromMap(result.first).nombre;
    } else {
      return null;
    }
  }

  static Future<void> ConectarBd() async {
    await _openDb();
  }

  static Future obtenerClientes() async {
    Database database = await _openDb();
    final List<Map<String, dynamic>> maps = await database.query('clientes');
    return maps;
  }

  static Future ejecutarQuery(String query) async {
    Database database = await _openDb();
    await database.rawUpdate(query);
  }

  static Future ejecutarQueryInsert(String query) async {
    Database database = await _openDb();
    await database.rawInsert(query);
  }

  static Future<int> insert(MaeClientes clientesDb) async {
    Database database = await _openDb();
    return database.insert("mae_clientes", clientesDb.toMap());
  }

  static Future<int> delete(MaeClientes clientesDb) async {
    Database database = await _openDb();
    return database
        .delete("mae_clientes", where: "rut = ?", whereArgs: [clientesDb.rut]);
  }

  static Future<int> update(MaeClientes clientesDb) async {
    Database database = await _openDb();

    return database.update("mae_clientes", clientesDb.toMap(),
        where: "rut = ?", whereArgs: [clientesDb.rut]);
  }

  static Future get(String rut) async {
    Database database = await _openDb();

    final List<Map<String, dynamic>> login = await database
        .query("mae_clientes", where: "rut = ?", whereArgs: [rut]);

    return MaeClientes.fromMap(login.first);
  }
}
