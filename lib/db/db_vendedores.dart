import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DBVendedores {
  static Future<Database> _openDb() async {
    return openDatabase(
      join(await getDatabasesPath(), 'vendedores.db'),
      onCreate: (db, version) {
        return db.execute(
            "CREATE TABLE mae_vendedores (rut TEXT, nombre TEXT, Local TEXT, comision REAL, password TEXT, direccion TEXT, comuna TEXT, ciudad TEXT, fono TEXT, celular TEXT, codigo TEXT, master INTEGER, comisionista INTEGER, vigente INTEGER, email TEXT)");
      },
      version: 1,
    );
  }

  static Future obtenerDatosVendedor(String rut) async {
    Database database = await _openDb();
    var result =
        await database.query("vendedores", where: "rut = ?", whereArgs: [rut]);
    if (result.isNotEmpty) {
      return "";
    }
  }

  static Future<void> conectarBd() async {
    await _openDb();
  }
}
