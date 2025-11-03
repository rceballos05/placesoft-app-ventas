import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

/// Muestra información sobre las bases de datos locales (clientes y productos)
Future<void> mostrarInfoBasesLocales(BuildContext context) async {
  try {
    final databasesPath = await getDatabasesPath();
    final docsPath = (await getApplicationDocumentsDirectory()).path;

    // Buscar posibles bases de datos
    final clientesDb =
        await _buscarArchivoDb('clientes.db', databasesPath, docsPath);
    final productosDb =
        await _buscarArchivoDb('productos.db', databasesPath, docsPath);

    final infoClientes = await _obtenerInfoArchivo(clientesDb);
    final infoProductos = await _obtenerInfoArchivo(productosDb);

    final contenido = StringBuffer();

    if (infoClientes != null) {
      contenido.writeln('📂 CLIENTES.DB');
      contenido.writeln('Ruta: ${infoClientes.path}');
      contenido.writeln('Tamaño: ${infoClientes.size}');
      contenido.writeln('Filas (mae_clientes): ${infoClientes.rowCount}');
      contenido.writeln('');
    } else {
      contenido.writeln('⚠️ No se encontró clientes.db\n');
    }

    if (infoProductos != null) {
      contenido.writeln('📦 PRODUCTOS.DB');
      contenido.writeln('Ruta: ${infoProductos.path}');
      contenido.writeln('Tamaño: ${infoProductos.size}');
      contenido.writeln('Filas (mae_productos): ${infoProductos.rowCount}');
    } else {
      contenido.writeln('⚠️ No se encontró productos.db');
    }

    // Mostrar diálogo con la información
    // ignore: use_build_context_synchronously
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Estado de las bases locales'),
        content: SingleChildScrollView(child: Text(contenido.toString())),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  } catch (e) {
    // ignore: use_build_context_synchronously
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Error'),
        content: Text('No se pudo leer la información de las bases.\n$e'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Aceptar'),
          ),
        ],
      ),
    );
  }
}

/// Model para los datos de cada base
class _DbInfo {
  final String path;
  final String size;
  final int rowCount;
  const _DbInfo(
      {required this.path, required this.size, required this.rowCount});
}

/// Intenta localizar el archivo .db en las carpetas típicas
Future<File?> _buscarArchivoDb(
    String name, String databasesPath, String docsPath) async {
  final candidates = [
    File(p.join(databasesPath, name)),
    File(p.join(docsPath, name)),
  ];

  // Buscar también en subcarpetas de prefijos (p.ej. crvictoria)
  final dbDir = Directory(databasesPath);
  if (await dbDir.exists()) {
    await for (final entity
        in dbDir.list(recursive: true, followLinks: false)) {
      if (entity is File &&
          p.basename(entity.path).toLowerCase() == name.toLowerCase()) {
        candidates.add(entity);
      }
    }
  }

  for (final file in candidates) {
    if (await file.exists()) {
      return file;
    }
  }
  return null;
}

/// Obtiene tamaño del archivo y cantidad de filas de una tabla esperada
Future<_DbInfo?> _obtenerInfoArchivo(File? file) async {
  if (file == null || !await file.exists()) return null;

  final bytes = await file.length();
  final sizeMb = (bytes / (1024 * 1024)).toStringAsFixed(2);
  int rowCount = 0;

  try {
    final db = await openDatabase(file.path);
    final table = file.path.toLowerCase().contains('clientes')
        ? 'mae_clientes'
        : 'mae_productos';
    final result = await db.rawQuery('SELECT COUNT(*) AS count FROM $table');
    rowCount = result.first['count'] as int? ?? 0;
    await db.close();
  } catch (_) {
    // Tabla no existe o DB corrupta
  }

  return _DbInfo(path: file.path, size: '$sizeMb MB', rowCount: rowCount);
}
