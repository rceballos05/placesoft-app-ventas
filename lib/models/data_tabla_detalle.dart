import 'package:aplicacion_ventas/db/db_ventasDetalle.dart';
import 'package:aplicacion_ventas/statics/globals.dart';
import 'package:flutter/material.dart';

class DataTablaDetalle extends DataTableSource {
  List<Map<String, dynamic>> _data = [];
  DataTablaDetalle();

  Future venta(String numeroDoc) async {
    var result = await DBVentaDetalle.obtenerVentasOffline(numeroDoc);
    _data = result;
    notifyListeners();
  }

  Future dataVenta(String numeroDoc) async {
    var result = await DBVentaDetalle.obtenerVentasOffline(numeroDoc);
    return result;
  }

  @override
  DataRow? getRow(int index) {
    if (index >= _data.length) return null;
    final item = _data[index];
    return DataRow(
      cells: [
        DataCell(Text(item['numero_doc'].toString())),
        DataCell(Text(item['fecha_emision'].toString())),
        DataCell(Text(item['rut_vendedor'].toString())),
        DataCell(Text(item['rut_cliente'].toString())),
        DataCell(Text(item['art_codigo'].toString())),
        DataCell(Text(item['art_descripcion'].toString())),
        DataCell(Text(item['art_cantidad'].toString())),
        DataCell(Text(item['art_precio'].toString())),
        DataCell(Text(item['total_linea'].toString())),
        DataCell(Text(item['observacion'].toString())),
      ],
    );
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => _data.length;

  @override
  int get selectedRowCount => 0;
}
