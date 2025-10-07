import 'package:aplicacion_ventas/db/login.dart';
import 'package:aplicacion_ventas/statics/globals.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBLogin {
  static Future<Database> _openDb() async {
    return openDatabase(
      join(await getDatabasesPath(), 'login.db'),
      version: 1,
    );
  }

  static Future IniciarSesion(String user, String pass) async {
    Database database = await _openDb();
    var result = await database.query("login",
        where: "rut = ? AND password = ?",
        whereArgs: [user.toUpperCase(), pass]);

    if (result.isNotEmpty) {
      dynamic user = result.first;
      dynamic row = user.row;
      vendedor.rut = row[0];
      vendedor.caja = row[3];
      vendedor.prefijo = row[2];
      vendedor.descuento = row[5];
      return true;
    } else {
      return false;
    }
  }

  static Future<int> insert(LoginDb login) async {
    Database database = await _openDb();
    return database.insert("login", login.toMap());
  }

  static Future<int> delete(LoginDb login) async {
    Database database = await _openDb();
    return database.delete("login", where: "rut = ?", whereArgs: [login.rut]);
  }

  static Future<int> update(LoginDb login) async {
    Database database = await _openDb();

    return database.update("login", login.toMap(),
        where: "rut = ?", whereArgs: [login.rut]);
  }

  static Future verificarRutExiste(String rut) async {
    Database database = await _openDb();
    var rsp = await database.query('login', where: "rut = ?", whereArgs: [rut]);
    if (rsp.isNotEmpty) {
      return true;
    }
    return false;
  }

  static Future<LoginDb> get(String rut) async {
    Database database = await _openDb();

    final List<Map<String, dynamic>> login =
        await database.query("login", where: "rut = ?", whereArgs: [rut]);

    return LoginDb.fromJson(login.first);
  }
}
