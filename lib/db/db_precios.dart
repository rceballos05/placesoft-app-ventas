import 'package:aplicacion_ventas/db/precios.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBPrecios {
  static Future<Database> _openDb() async {
    return openDatabase(
      join(await getDatabasesPath(), 'productos.db'),
      version: 1,
    );
  }

  static Future<void> AbirDb() async {
    await _openDb();
  }

  static Future<int> insert(MaeArticulosPrecios productosDb) async {
    Database database = await _openDb();
    return database.insert("mae_articulos_precios_00", productosDb.toMap());
  }

  static Future get(String codigo) async {
    Database database = await _openDb();

    final List<Map<String, dynamic>> login = await database.query(
        "mae_articulos_precios_00",
        where: "codigo = ?",
        whereArgs: [codigo]);

    return MaeArticulosPrecios.fromMap(login.first);
  }

  static Future ejecutarQuery(String query) async {
    Database database = await _openDb();
    await database.rawUpdate(query);
  }

  static Future ejecutarQueryInsert(String query) async {
    Database database = await _openDb();
    await database.rawInsert(query);
  }

  static Future precio(String codigo) async {
    Database database = await _openDb();

    final List<Map<String, dynamic>> login = await database.query(
        "mae_articulos_precios_00",
        where: "codigo = ?",
        whereArgs: [codigo]);

    var precio = MaeArticulosPrecios.fromMap(login.first);

    return precio.precioVenta.toInt();
  }
}
