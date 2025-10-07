import 'package:aplicacion_ventas/db/venta_observaciones.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBVentaObservaciones {
  static Future<Database> _openDb() async {
    return openDatabase(
      join(await getDatabasesPath(), 'ventas.db'),
      version: 1,
    );
  }

  static Future<void> ConectarBd() async {
    await _openDb();
  }

  static Future insertarObservacionesVenta(
      LocalVentaObservaciones cabeza) async {
    Database database = await _openDb();

    var result =
        await database.insert("local_venta_observaciones_00", cabeza.toMap());
    if (result > 0) {
      return true;
    } else {
      return false;
    }
  }

  static Future obtenerObservacionesVentas(String numeroDoc) async {
    Database database = await _openDb();
    var result = await database.query("local_venta_observaciones_00",
        where: "numero_doc = ? ", whereArgs: [numeroDoc]);
    List<LocalVentaObservaciones> list = [];

    for (var item in result) {
      list.add(LocalVentaObservaciones.fromMap(item));
    }

    return list;
  }

  static Future observacionProductoVenta(String codigo) async {
    Database database = await _openDb();
    var result = await database.query("local_venta_observaciones_00",
        where: "codigo = ? ", whereArgs: [codigo]);

    if (result.isNotEmpty) {
      for (var item in result) {
        var itm = LocalVentaObservaciones.fromMap(item);
        return itm.observaciones;
      }
    } else {
      return null;
    }
  }
}
