import 'package:aplicacion_ventas/db/db_clientes.dart';
import 'package:aplicacion_ventas/db/venta_cabeza.dart';
import 'package:aplicacion_ventas/models/detalle_cabeza_dto.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBVentaCabeza {
  static Future<Database> _openDb() async {
    return openDatabase(
      join(await getDatabasesPath(), 'ventas.db'),
      version: 1,
    );
  }

  static Future<void> ConectarBd() async {
    await _openDb();
  }

  static Future insertarCabezaVenta(LocalVentaCabeza cabeza) async {
    Database database = await _openDb();

    var result = await database.insert("local_venta_cabeza_00", cabeza.toMap());
    if (result > 0) {
      return true;
    } else {
      return false;
    }
  }

  static Future obtenerNumeroBoleta() async {
    Database database = await _openDb();

    var result = await database.query("local_venta_cabeza_00",
        orderBy: "numero_doc desc", limit: 1);

    if (result.isNotEmpty) {
      var resp = LocalVentaCabeza.fromMap(result.first);
      return resp.numeroDoc;
    } else {
      return "0";
    }
  }

  static Future ventasFiltradasXFecha(String rut, String fecha) async {
    Database database = await _openDb();

    var result = await database.query("local_venta_cabeza_00",
        where: "fecha_emision like ? and rut_vendedor = ?",
        whereArgs: ['%$fecha%', rut]);
    List<Map<String, dynamic>> list = [];
    if (result.isNotEmpty) {
      List<Map<String, dynamic>> list = [];
      for (var item in result) {
        list.add(item);
      }
      return list;
    }
    return list;
  }

  static Future errorEnvioVentas() async {
    Database database = await _openDb();

    var result = await database.query("local_venta_cabeza_00",
        where: "fecha_emision like ?",
        whereArgs: ['%${DateTime.now().toIso8601String().split('T')[0]}%']);

    List<LocalVentaCabeza> list = [];
    for (var item in result) {
      list.add(LocalVentaCabeza.fromMap(item));
    }
    return list;
  }

  static Future obtenerVentas() async {
    Database database = await _openDb();

    var result = await database.query("local_venta_cabeza_00",
        where: "usuario_facturacion = ? ", whereArgs: ["apiventas.creado"]);

    List<LocalVentaCabeza> list = [];
    for (var item in result) {
      list.add(LocalVentaCabeza.fromMap(item));
    }
    return list;
  }

  static Future obtenerVentasOffline() async {
    Database database = await _openDb();

    var result = await database.query("local_venta_cabeza_00");

    List<Map<String, dynamic>> list = [];
    for (var item in result) {
      DetalleVentaCabezaDto cb = DetalleVentaCabezaDto.fromJson(item);
      cb.nombreCliente = await DBClientes.ObtenerNombreCliente(cb.rutCliente!);
      cb.estado = cb.usuarioFacturacion == "apiventas.creado"
          ? "Sin enviar"
          : "Enviado";
      list.add(cb.toMap());
    }
    return list;
  }

  static Future buscarVenta(String numero) async {
    Database database = await _openDb();
    var result = await database.query(
      "local_venta_cabeza_00",
      where: "numero_doc = ?",
      whereArgs: [numero],
    );
    if (result.isNotEmpty) {
      return LocalVentaCabeza.fromMap(result.first);
    } else {
      return false;
    }
  }

  static Future updateVenta(LocalVentaCabeza venta) async {
    Database database = await _openDb();
    var result = database.update(
      "local_venta_cabeza_00",
      where: "numero_doc = ? ",
      whereArgs: [venta.numeroDoc],
      venta.toMap(),
    );
  }
}
