import 'dart:async';
import 'package:animated_theme_switcher/animated_theme_switcher.dart';
import 'package:aplicacion_ventas/db/db_rollo.dart';
import 'package:aplicacion_ventas/db/db_rollo_observaciones.dart';
import 'package:aplicacion_ventas/db/db_ventaCabeza.dart';
import 'package:aplicacion_ventas/db/rollo.dart';
import 'package:aplicacion_ventas/db/rollo_observaciones.dart';
import 'package:aplicacion_ventas/db/venta_cabeza.dart';
import 'package:aplicacion_ventas/db/venta_detalle.dart';
import 'package:aplicacion_ventas/functions/functions.dart';
import 'package:aplicacion_ventas/models/data_tabla_detalle.dart';
import 'package:aplicacion_ventas/models/rollo.dart';
import 'package:aplicacion_ventas/models/venta.dart';
import 'package:aplicacion_ventas/models/venta_cabeza.dart';
import 'package:aplicacion_ventas/models/venta_observaciones.dart';
import 'package:aplicacion_ventas/statics/globals.dart';
import 'package:aplicacion_ventas/widgets/busqueda_cliente.dart';
import 'package:flutter/material.dart';

class DetalleVenta extends StatefulWidget {
  const DetalleVenta({super.key});

  @override
  _DetalleVentaState createState() => _DetalleVentaState();
}

class _DetalleVentaState extends State<DetalleVenta> {
  // late List<Map<String, dynamic>> _data;
  late DataTablaDetalle _data;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _data = DataTablaDetalle();
    _data.venta(numeroVenta);
    _isLoading = false;

    // ventasOffline();
  }

  // Future<void> _loadData() async {
  //   try {
  //     final response = await http.get(Uri.http(urlData,
  //         'api/local00/${vendedor.prefijo}/detalle-venta/$numeroVenta/${vendedor.caja}'));
  //     if (response.statusCode == 200) {
  //       final dynamic jsonData = json.decode(response.body);
  //       if (jsonData["items"] is List) {
  //         setState(() {
  //           _data = jsonData["items"].cast<Map<String, dynamic>>();
  //           _isLoading = false;
  //         });
  //       } else if (jsonData["items"] is Map<String, dynamic>) {
  //         setState(() {
  //           _data = [jsonData["items"]];
  //           _isLoading = false;
  //         });
  //       } else {
  //         throw Exception('Invalid data format');
  //       }
  //     } else {
  //       throw Exception('Failed to load data');
  //     }
  //   } catch (error) {
  //     log(error.toString());
  //     setState(() {
  //       _isLoading = false;
  //     });
  //   }
  // }

  // Future ventasOffline() async {
  //   var datos = await DBVentaDetalle.obtenerVentasOffline(numeroVenta);
  //   setState(() {
  //     _data = datos;
  //     _isLoading = false;
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return ThemeSwitchingArea(
        child: Builder(
          builder: (context) {
            return Scaffold(
              appBar: AppBar(
                title: const Text('detalle de Venta'),
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
        builder: ((context) {
          return Scaffold(
            appBar: AppBar(title: const Text("Historial de Ventas")),
            body: Column(
              children: [
                SingleChildScrollView(
                  child: PaginatedDataTable(
                    columns: const [
                      DataColumn(label: Text("Numero Documento")),
                      DataColumn(label: Text("Fecha de Emision")),
                      DataColumn(label: Text("Rut Vendedor")),
                      DataColumn(label: Text("Rut Cliente")),
                      DataColumn(label: Text("Codigo Articulo")),
                      DataColumn(label: Text("Descripcion Articulo")),
                      DataColumn(label: Text("Cantidad")),
                      DataColumn(label: Text("Precio Unitario")),
                      DataColumn(label: Text("Total")),
                      DataColumn(label: Text("Observacion")),
                    ],
                    source: _data,
                    rowsPerPage: 10,
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                InkWell(
                  child: const Text("Volver a realizar venta"),
                  onTap: () async {
                    var list = await _data.dataVenta(numeroVenta);
                    var i = 1;
                    for (var json in list) {
                      var rutCliente = json["rut_cliente"];
                      var rollo = Rollo(
                        artCantidad: int.parse(
                            double.parse(json["art_cantidad"].toString())
                                .round()
                                .toString()),
                        artCodigo: json["art_codigo"].toString(),
                        artDescripcion: json["art_descripcion"].toString(),
                        artPrecio: double.parse(json["art_precio"].toString()),
                        totalLinea:
                            double.parse(json["total_linea"].toString()),
                        artDescuento: 0,
                        cajaDoc: vendedor.caja,
                        codImpuesto: "00000",
                        fechaTransaccion: DateTime.now().toIso8601String(),
                        local: "00",
                        observacion: json["observacion"].toString(),
                        porceImpuesto: 0,
                        rutCajero: vendedor.rut,
                        rutVendedor: vendedor.rut,
                        tipoventa: "0",
                        lineaVenta: i,
                      );
                      await agregarProductoCarro(rollo);
                      i++;
                    }
                    if (clienteVenta?.rut == null) {
                      showSearch(
                        context: context,
                        delegate: BuscarCliente(),
                        query: rutCliente,
                      );
                    } else {
                      Navigator.pushNamed(context, '/carro');
                    }
                  },
                ),
                const SizedBox(
                  height: 10,
                ),
                InkWell(
                  child: const Text("Reenviar Venta"),
                  onTap: () async {
                    List<dynamic> list = await _data.dataVenta(numeroVenta);
                    List<ArticulosVenta> lst = [];
                    for (var item in list) {
                      var p = LocalVentaDetalle.fromMap(item);
                      lst.add(ArticulosVenta(
                        articuloDescuento: p.artDescuento.toInt(),
                        cantidad: p.artCantidad.toInt(),
                        codigo: p.artCodigo,
                        descripcion: p.artDescripcion,
                        porcentajeDescuento: p.porceDescuento,
                        precio: p.artPrecio.toInt(),
                        precioCostoCIva: p.precioCostoCiva.toInt(),
                        totalLinea: p.totalLinea.toInt(),
                      ));
                      if (item["observacion"] != null &&
                          item["observacion"] != "") {
                        await registrarObservacion(VentaObservaciones(
                            cajaDoc: p.cajaDoc,
                            codigo: p.artCodigo,
                            fechaEmision: p.fechaEmision,
                            lineaVenta: p.lineaVenta,
                            local: p.local,
                            numeroDoc: p.numeroDoc,
                            rutCliente: p.rutCliente,
                            tipoDoc: p.tipoDoc,
                            observaciones: item["observaciones"]));
                      }
                    }
                    await realizarVenta(Venta(
                      almacen: list.first["almacen"],
                      cajaDoc: vendedor.caja!,
                      destinoCliente: list.first["destino_cliente"],
                      articulos: lst,
                      fecha: list.first["fecha_emision"],
                      lineVenta: "",
                      local: list.first["local"],
                      numeroDoc: list.first["numero_doc"],
                      rutCliente: list.first["rut_cliente"],
                      rutVendedor: list.first["rut_vendedor"],
                      tipoDoc: "NPE",
                    ));

                    LocalVentaCabeza cabeza =
                        await DBVentaCabeza.buscarVenta(numeroVenta);

                    await cabezaVenta(
                      VentaCabeza(
                        abono: cabeza.abono,
                        acteco: cabeza.acteco,
                        cajaDoc: cabeza.cajaDoc,
                        dctoglobal: cabeza.dctoglobal,
                        despachoFolio: cabeza.despachoFolio,
                        despachoHora: cabeza.despachoHora,
                        despachoPatente: cabeza.despachoPatente,
                        direccionDestino: cabeza.direccionDestino,
                        emailCliente: cabeza.emailCliente,
                        fechaEmision: cabeza.fechaEmision,
                        foliosii: cabeza.foliosii,
                        fonoCliente: cabeza.fonoCliente,
                        formapago: cabeza.formaPago,
                        generarDte: cabeza.generarDte,
                        glosaGuia: cabeza.glosaGuia,
                        impCarne: cabeza.impCarne,
                        impCerveza: cabeza.impCerveza,
                        impDiesel: cabeza.impDiesel,
                        impHarina: cabeza.impHarina,
                        impLicores: cabeza.impLicores,
                        impLight: cabeza.impLight,
                        impRefrescos: cabeza.impRefrescos,
                        impVinos: cabeza.impVinos,
                        local: cabeza.local,
                        localTraslado: cabeza.localTraslado,
                        montoDonacion: cabeza.montoDonacion,
                        montoExento: cabeza.montoExento,
                        montoIva: cabeza.montoIva,
                        montoLey20956: cabeza.montoLey20956,
                        montoNeto: cabeza.montoNeto,
                        montoPropina: cabeza.montoPropina,
                        montoTotal: cabeza.montoTotal,
                        nombreCliente: cabeza.nombreCliente,
                        notaPedido: cabeza.notaPedido,
                        numeroDoc: cabeza.numeroDoc,
                        numeroImpresora: cabeza.numeroImpresora.toString(),
                        observacion: cabeza.observacion,
                        ordenDeCompra: cabeza.ordenDeCompra,
                        plazo: cabeza.plazo,
                        porceDescuento: cabeza.porceDescuento,
                        procesada: cabeza.procesada,
                        refGlosa: cabeza.refGlosa,
                        refNumero: cabeza.refNumero,
                        refTipo: cabeza.refTipo,
                        revision1: cabeza.revision1,
                        revision2: cabeza.revision2,
                        revision3: cabeza.revision3,
                        rutCajera: cabeza.rutCajera,
                        rutCliente: cabeza.rutCliente,
                        rutVendedor: cabeza.rutVendedor,
                        subtotal: cabeza.subtotal,
                        tipoDoc: cabeza.tipoDoc,
                        tipoTraslado: cabeza.tipoTraslado,
                        usuarioFacturacion: "apiventas.creado",
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Future agregarProductoCarro(Rollo rollo) async {
    var fecha = rollo.fechaTransaccion;
    var hora = fecha!.split("T")[1];
    hora = hora.split(".")[0];
    var tblRollo = TblRolloTerreno00(
      local: rollo.local!,
      cajaDoc: rollo.cajaDoc!,
      lineaVenta: rollo.lineaVenta!.toDouble(),
      rutCajero: rollo.rutCajero!,
      artCantidad: rollo.artCantidad!.toDouble(),
      artCodigo: rollo.artCodigo!,
      artDescripcion: rollo.artDescripcion!,
      artDescuento: rollo.artDescuento!,
      artPrecio: rollo.artPrecio!,
      totalLinea: rollo.totalLinea!,
      rutVendedor: rollo.rutVendedor!,
      fechaTransaccion: rollo.fechaTransaccion!,
      tipoVenta: "NPE",
      codImpuesto: rollo.codImpuesto!,
      porceImpuesto: rollo.porceImpuesto!,
      horaTransaccion: hora,
    );
    await DBRollo.insert(tblRollo);
    if (rollo.observacion != "" && rollo.observacion != "Sin Observaciones") {
      await DBRolloObservaciones.insert(LocalRolloObservaciones(
          codigo: tblRollo.artCodigo,
          fecha: tblRollo.fechaTransaccion,
          caja: tblRollo.cajaDoc,
          observaciones: rollo.observacion!));
    }
  }

  void _mostrarAlertaOk(BuildContext context, String text) {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (_) => AlertDialog(
              title: const Text('Success'),
              content: Text(text),
              actions: [
                TextButton(
                    onPressed: () async {
                      Navigator.pop(context);
                    },
                    child: const Text('Ok'))
              ],
            ));
  }

  void _mostrarAlertaError(BuildContext context, String text) {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (_) => AlertDialog(
              title: const Text('Error'),
              content: Text(text),
              actions: [
                TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('Ok'))
              ],
            ));
  }
}
