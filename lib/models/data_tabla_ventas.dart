import 'package:aplicacion_ventas/db/db_ventaCabeza.dart';
import 'package:aplicacion_ventas/statics/globals.dart';
import 'package:flutter/material.dart';

class DataTablaVentas extends DataTableSource {
  List<Map<String, dynamic>> _data = [];
  final BuildContext context;
  DataTablaVentas(this.context);

  Future venta() async {
    var result = await DBVentaCabeza.obtenerVentasOffline();
    _data = result;
    notifyListeners();
  }

  Future ventaFiltrada(String fecha, String rut) async {
    var result = await DBVentaCabeza.ventasFiltradasXFecha(rut, fecha);
    _data = result;
    notifyListeners();
  }

  @override
  DataRow? getRow(int index) {
    if (index >= _data.length) return null;
    final item = _data[index];
    return DataRow(
      cells: [
        DataCell(
          Text(item['numero_doc'].toString()),
          onTap: () {
            numeroVenta = item['numero_doc'];
            Navigator.pushNamed(context, '/detalle-ventas');
          },
        ),
        DataCell(Text(item['fecha_emision'].toString())),
        DataCell(Text(item['rut_vendedor'].toString())),
        DataCell(Text(item['rut_cliente'].toString())),
        DataCell(Text(item['nombre_cliente'].toString())),
        DataCell(Text(item['monto_total'].toString())),
        DataCell(Text(item['observacion'].toString())),
        DataCell(Text(item['estado'].toString())),
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
