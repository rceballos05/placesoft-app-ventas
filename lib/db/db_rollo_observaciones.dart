import 'package:aplicacion_ventas/db/rollo.dart';
import 'package:aplicacion_ventas/db/rollo_observaciones.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBRolloObservaciones {
  static Future<Database> _openDb() async {
    return openDatabase(
      join(await getDatabasesPath(), 'rollo.db'),
      version: 1,
    );
  }

  static Future<void> ConectarBd() async {
    await _openDb();
  }

  static Future obtenerObservacionesRollo() async {
    Database database = await _openDb();
    List<TblRolloTerreno00> rllo = [];
    var result = await database.query("local_rollo_observaciones_00");
    if (result.isNotEmpty) {
      for (var item in result) {
        rllo.add(TblRolloTerreno00.fromMap(item));
      }
      return rllo;
    }
  }

  static Future obtenerObservacionProductoRollo(String codigobarra) async {
    Database database = await _openDb();
    var result = await database.query("local_rollo_observaciones_00",
        where: "codigo = ?", whereArgs: [codigobarra]);
    if (result.isNotEmpty) {
      LocalRolloObservaciones response =
          LocalRolloObservaciones.fromMap(result.first);
      return response.observaciones;
    }
    return null;
  }

  static Future<int> insert(LocalRolloObservaciones rollo) async {
    Database database = await _openDb();
    return database.insert("local_rollo_observaciones_00", rollo.toMap());
  }

  static Future<int> deleteObservacionProducto(String codigo) async {
    Database database = await _openDb();
    return database.delete("local_rollo_observaciones_00",
        where: "codigo = ?", whereArgs: [codigo]);
  }

  static Future<int> deleteObservaciones() async {
    Database database = await _openDb();
    return database.delete("local_rollo_observaciones_00");
  }

  static Future<int> update(LocalRolloObservaciones rollo) async {
    Database database = await _openDb();

    return database.update("local_rollo_observaciones_00", rollo.toMap(),
        where: "codigo = ?", whereArgs: [rollo.codigo]);
  }
}
