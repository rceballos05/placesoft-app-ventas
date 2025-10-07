import 'package:aplicacion_ventas/models/cliente_palabra.dart';
import 'package:aplicacion_ventas/models/destinos.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBDestino {
  static Future<Database> _openDb() async {
    return openDatabase(
      join(await getDatabasesPath(), 'clientes.db'),
      version: 1,
    );
  }

  static Future<void> conectarBd() async {
    await _openDb();
  }

  static Future datosLocalCliente(String local, String rut) async {
    Database database = await _openDb();
    var result = await database.query("mae_clientes_destinos",
        where: "codigo = ? and cliente = ?", whereArgs: [local, rut]);

    var destino = MaeClientesDestinos.fromMap(result.first);
    return destino;
  }

  static Future ejecutarQuery(String query) async {
    Database database = await _openDb();
    await database.rawUpdate(query);
  }

  static Future ejecutarQueryInsert(String query) async {
    Database database = await _openDb();
    await database.rawInsert(query);
  }

  static Future<int> insert(MaeClientesDestinos clientesDb) async {
    Database database = await _openDb();
    return database.insert("mae_clientes_destinos", clientesDb.toMap());
  }

  static Future obtenerDestinosCliente(List<ClientePalabra> data) async {
    Database database = await _openDb();
    List<ClientePalabra> temp = [];
    for (var item in data) {
      var result = await database.query("mae_clientes_destinos",
          where: "cliente = ?", whereArgs: [item.rut]);
      for (var res in result) {
        var destino = MaeClientesDestinos.fromMap(res);

        temp.add(ClientePalabra(
          codComuna: destino.codComuna,
          direccionDestino: destino.descripcion,
          emailContacto: destino.emailContacto,
          fonoContacto: destino.fonoContacto,
          nombreContacto: destino.nombreContacto,
          codDestino: destino.codigo,
          comuna: item.comuna,
          nombre: item.nombre,
          rut: item.rut,
        ));
      }
    }
    return temp;
  }
}
