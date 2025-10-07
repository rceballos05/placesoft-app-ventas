import 'package:aplicacion_ventas/db/db_ventas_observaciones.dart';
import 'package:aplicacion_ventas/db/venta_detalle.dart';
import 'package:aplicacion_ventas/models/detalle_venta_dto.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBVentaDetalle {
  static Future<Database> _openDb() async {
    return openDatabase(
      join(await getDatabasesPath(), 'ventas.db'),
      version: 1,
    );
  }

  static Future<void> ConectarBd() async {
    await _openDb();
  }

  static Future insertarDetalleVenta(LocalVentaDetalle cabeza) async {
    Database database = await _openDb();

    var result =
        await database.insert("local_venta_detalle_00", cabeza.toMap());
    if (result > 0) {
      return true;
    } else {
      return false;
    }
  }

  static Future obtenerVentasOffline(String numeroDoc) async {
    Database database = await _openDb();

    var result = await database.query("local_venta_detalle_00",
        where: "numero_doc = ? ", whereArgs: [numeroDoc]);

    List<Map<String, dynamic>> list = [];
    for (var item in result) {
      var dt = DetalleVentaDto.fromMap(item);
      dt.observacion =
          await DBVentaObservaciones.observacionProductoVenta(dt.artCodigo);
      list.add(dt.toMap());
    }
    return list;
  }

  static Future obtenerDetalleVentas(String numeroDoc) async {
    Database database = await _openDb();
    var result = await database.query("local_venta_detalle_00",
        where: "numero_doc = ? ", whereArgs: [numeroDoc]);
    List<LocalVentaDetalle> list = [];

    for (var item in result) {
      list.add(LocalVentaDetalle.fromMap(item));
    }

    return list;
  }
}
