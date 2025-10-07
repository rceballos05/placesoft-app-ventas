import 'package:aplicacion_ventas/db/rollo.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBRollo {
  static Future<Database> _openDb() async {
    return openDatabase(
      join(await getDatabasesPath(), 'rollo.db'),
      version: 1,
    );
  }

  static Future<void> ConectarBd() async {
    await _openDb();
  }

  static Future obtenerRollo() async {
    Database database = await _openDb();
    List<TblRolloTerreno00> rllo = [];
    var result = await database.query("tbl_rollo_terreno_00");
    if (result.isNotEmpty) {
      for (var item in result) {
        rllo.add(TblRolloTerreno00.fromMap(item));
      }
      return rllo;
    }
  }

  static Future<int> insert(TblRolloTerreno00 rollo) async {
    Database database = await _openDb();
    return database.insert("tbl_rollo_terreno_00", rollo.toMap());
  }

  static Future<int> deleteArticuloRollo(String codigo) async {
    Database database = await _openDb();
    return database.delete("tbl_rollo_terreno_00",
        where: "art_codigo = ?", whereArgs: [codigo]);
  }

  static Future<int> deleteRollo() async {
    Database database = await _openDb();
    return database.delete("tbl_rollo_terreno_00");
  }

  static Future<int> update(TblRolloTerreno00 rollo) async {
    Database database = await _openDb();

    return database.update("tbl_rollo_terreno_00", rollo.toMap(),
        where: "art_codigo = ?", whereArgs: [rollo.artCodigo]);
  }
}
