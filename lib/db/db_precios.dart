import 'package:aplicacion_ventas/db/precios.dart';
import 'package:sqflite/sqflite.dart';

class DBPrecios {
  const DBPrecios._();

  static const _tableName = 'mae_articulos_precios_00';

  static Future<MaePrecios> get(
    String codigo, {
    Database? database,
    String? databasePath,
  }) async {
    final shouldClose = database == null;
    final db = database ?? await openDatabase(databasePath!, readOnly: true);
    try {
      final result = await db.query(
        _tableName,
        where: 'codigo = ?',
        whereArgs: [codigo],
        limit: 1,
      );
      if (result.isEmpty) {
        return MaePrecios.empty;
      }
      return MaePrecios.fromMap(result.first);
    } finally {
      if (shouldClose) {
        await db.close();
      }
    }
  }
}
