import 'package:aplicacion_ventas/db/productos.dart';
import 'package:sqflite/sqflite.dart';

class DBProductos {
  const DBProductos._();

  static const _tableName = 'mae_articulos_00';

  static Future<List<MaeArticulos>> productos({
    Database? database,
    String? databasePath,
    int? limit,
  }) async {
    final shouldClose = database == null;
    final db = database ?? await openDatabase(databasePath!, readOnly: true);
    try {
      final result = await db.query(
        _tableName,
        limit: limit,
        orderBy: 'descripcion COLLATE NOCASE ASC',
      );
      return result.map((map) => MaeArticulos.fromMap(map)).toList();
    } finally {
      if (shouldClose) {
        await db.close();
      }
    }
  }
}
