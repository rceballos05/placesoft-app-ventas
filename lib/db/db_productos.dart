import 'package:aplicacion_ventas/db/productos.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBProductos {
  static Future<Database> _openDb() async {
    return openDatabase(
      join(await getDatabasesPath(), 'productos.db'),
      version: 1,
    );
  }

  static Future<void> AbirDb() async {
    await _openDb();
  }

  static Future ejecutarQuery(String query) async {
    Database database = await _openDb();
    await database.rawUpdate(query);
  }

  static Future ejecutarQueryInsert(String query) async {
    Database database = await _openDb();
    await database.rawInsert(query);
  }

  static Future<int> insert(MaeArticulos productosDb) async {
    Database database = await _openDb();
    return database.insert("productos", productosDb.toMap());
  }

  static Future<int> delete(MaeArticulos productosDb) async {
    Database database = await _openDb();
    return database.delete("productos",
        where: "codigobarra = ?", whereArgs: [productosDb.codigobarra]);
  }

  static Future<int> update(MaeArticulos productosDb) async {
    Database database = await _openDb();

    return database.update("productos", productosDb.toMap(),
        where: "codigobarra = ?", whereArgs: [productosDb.codigobarra]);
  }

  static Future<MaeArticulos> get(String codigo) async {
    Database database = await _openDb();

    final List<Map<String, dynamic>> login = await database.query(
        "mae_Articulos_00",
        where: "codigobarra = ?",
        whereArgs: [codigo]);

    return MaeArticulos.fromMap(login.first);
  }

  static Future productos() async {
    Database database = await _openDb();
    List<MaeArticulos> productos = [];
    var result = await database.query("mae_Articulos_00", limit: 10);
    if (result.isNotEmpty) {
      for (var item in result) {
        productos.add(MaeArticulos.fromMap(item));
      }
      return productos;
    }
  }

  static Future productosSearch(String palabra) async {
    Database database = await _openDb();
    List<MaeArticulos> prod = [];

    var result = await database.query("mae_Articulos_00",
        where: "descripcion LIKE ? OR codigobarra LIKE ?",
        limit: 30,
        orderBy: "codigobarra asc",
        whereArgs: ['%$palabra%', '%$palabra%']);
    if (result.isNotEmpty) {
      for (var item in result) {
        prod.add(MaeArticulos.fromMap(item));
      }
      return prod;
    }
  }
}
