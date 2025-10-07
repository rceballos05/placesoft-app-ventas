import 'dart:async';
import 'dart:developer';
import 'package:animated_theme_switcher/animated_theme_switcher.dart';
import 'package:aplicacion_ventas/db/db_ventaCabeza.dart';
import 'package:aplicacion_ventas/models/data_tabla_ventas.dart';
import 'package:aplicacion_ventas/statics/globals.dart';
import 'package:aplicacion_ventas/statics/statics.dart';
import 'package:flutter/material.dart';

class Historial extends StatefulWidget {
  const Historial({Key? key}) : super(key: key);

  @override
  _HistorialState createState() => _HistorialState();
}

class _HistorialState extends State<Historial> {
  // late List<Map<String, dynamic>> _data;
  bool _isLoading = true;
  DateTime? _selectedDate;
  late DataTablaVentas _data;
  @override
  void initState() {
    super.initState();
    _data = DataTablaVentas(context);
    _data.venta();
    _isLoading = false;
    // ventasOffline();
  }

  // Future<void> _loadData() async {
  //   final response = await http.get(Uri.http(urlData,
  //       'api/local00/${vendedor.prefijo}/obtener-ventas/${user!.rut!}'));
  //   if (response.statusCode == 200) {
  //     final dynamic jsonData = json.decode(response.body);
  //     if (jsonData["items"] is List) {
  //       setState(() {
  //         _data = jsonData["items"].cast<Map<String, dynamic>>();
  //         _isLoading = false;
  //       });
  //     } else if (jsonData["items"] is Map<String, dynamic>) {
  //       setState(() {
  //         _data = [jsonData["items"]];
  //         _isLoading = false;
  //       });
  //     } else {
  //       throw Exception('Invalid data format');
  //     }
  //   } else {
  //     throw Exception('Failed to load data');
  //   }
  // }

  // Future ventasOffline() async {
  //   var datos = await DBVentaCabeza.obtenerVentasOffline();
  //   setState(() {
  //     _data = datos;
  //     _isLoading = false;
  //   });
  // }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(), // Fecha inicial del selector
      firstDate: DateTime(2000), // Fecha mínima seleccionable
      lastDate: DateTime(2101), // Fecha máxima seleccionable
    );
    if (picked != null && picked != _selectedDate) {
      // setState(() {
      //   _selectedDate = picked;
      //   // _isLoading = true;
      // });
      _selectedDate = picked;
      var fecha = _selectedDate!.toIso8601String().split('T')[0];
      _data.ventaFiltrada(
        fecha,
        vendedor.rut!,
      );
    }

    log(_selectedDate!.toIso8601String());
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return ThemeSwitchingArea(
        child: Builder(
          builder: (context) {
            return Scaffold(
              appBar: AppBar(
                title: const Text('Historial de Ventas'),
              ),
              body: const Center(
                child: CircularProgressIndicator(),
              ),
            );
          },
        ),
      );
    }

    return ThemeSwitchingArea(
      child: Builder(
        builder: (context) {
          return Scaffold(
            appBar: AppBar(title: const Text("Historial de Ventas")),
            body: SingleChildScrollView(
              child: PaginatedDataTable(
                header: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          ElevatedButton(
                            style: const ButtonStyle(
                                backgroundColor: MaterialStatePropertyAll(
                                    kDarkSecondaryColor)),
                            onPressed: () => _selectDate(context),
                            child: const Text(
                              'Seleccionar Fecha',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                              ),
                            ),
                          ),
                          const SizedBox(width: 11.0),
                          Text(
                            _selectedDate == null
                                ? 'No se ha seleccionado fecha'
                                : '${_selectedDate?.toIso8601String().split("T")[0]}',
                            style: const TextStyle(
                                color: Colors.white, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                columns: const [
                  DataColumn(label: Text("Numero Documento")),
                  DataColumn(label: Text("Fecha de Emision")),
                  DataColumn(label: Text("Rut Vendedor")),
                  DataColumn(label: Text("Rut Cliente")),
                  DataColumn(label: Text("Nombre Cliente")),
                  DataColumn(label: Text("Monto Total")),
                  DataColumn(label: Text("Observacion")),
                  DataColumn(label: Text("Estado")),
                ],
                source: _data,
                rowsPerPage: 10,
              ),
            ),
          );
        },
      ),
    );
  }

  Future obtenerDataYRecargar(String fecha) async {
    var data = await DBVentaCabeza.ventasFiltradasXFecha(
        vendedor.rut!, fecha.split('T')[0]);
    setState(() {
      _data = data.cast<Map<String, dynamic>>();
      _isLoading = false;
    });
  }
}
