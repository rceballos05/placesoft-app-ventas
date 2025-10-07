import 'package:aplicacion_ventas/db/db_rollo.dart';
import 'package:aplicacion_ventas/db/db_rollo_observaciones.dart';
import 'package:aplicacion_ventas/db/db_ventaCabeza.dart';
import 'package:aplicacion_ventas/db/db_ventasDetalle.dart';
import 'package:aplicacion_ventas/db/db_ventas_observaciones.dart';
import 'package:aplicacion_ventas/db/rollo.dart';
import 'package:aplicacion_ventas/db/rollo_observaciones.dart';
import 'package:aplicacion_ventas/db/venta_cabeza.dart';
import 'package:aplicacion_ventas/db/venta_detalle.dart';
import 'package:aplicacion_ventas/db/venta_observaciones.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:currency_formatter/currency_formatter.dart';
import 'package:animated_theme_switcher/animated_theme_switcher.dart';
import 'package:aplicacion_ventas/functions/dart_rut_validator.dart';
import 'package:aplicacion_ventas/functions/functions.dart';
import 'package:aplicacion_ventas/models/email.dart';
import 'package:aplicacion_ventas/models/observacion.dart';
import 'package:aplicacion_ventas/models/rollo.dart';
import 'package:aplicacion_ventas/models/venta.dart';
import 'package:aplicacion_ventas/models/venta_cabeza.dart';
import 'package:aplicacion_ventas/statics/globals.dart';
import 'package:aplicacion_ventas/statics/statics.dart';
import 'package:aplicacion_ventas/widgets/busqueda_cliente.dart';
import 'package:darq/darq.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  final ValueNotifier<int> _total = ValueNotifier<int>(0);

  @override
  void initState() {
    super.initState();

    actualizarRollo();

    total();
  }

  var correo = "";
  var observacion = TextEditingController();

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(
      context,
      designSize: const Size(414, 896),
      minTextAdapt: true,
    );

    if (clienteVenta != null) {
      correo = clienteVenta!.email ?? "";
    }

    var header = Row(
      children: <Widget>[
        SizedBox(width: kSpacingUnit.w * 3),
        InkWell(
          child: const Icon(Icons.home),
          onTap: () => Navigator.pushNamed(context, '/home'),
        ),
        SizedBox(width: kSpacingUnit.w * 7),
        const Center(
          child: Text(
            "Carro de Compras",
            style: TextStyle(
              color: Color.fromRGBO(255, 255, 255, 1),
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(
          width: kSpacingUnit.w * 5,
        ),
        InkWell(
          child: const Icon(
            Icons.delete,
            color: Colors.white,
          ),
          onTap: () async {
            eliminarRolloOffline();
            setState(() {
              actualizarRollo();
            });
          },
        ),
      ],
    );

    var headerMin = Row(
      children: <Widget>[
        SizedBox(width: kSpacingUnit.w * 3),
        InkWell(
          child: const Icon(Icons.home),
          onTap: () => Navigator.pushNamed(context, '/home'),
        ),
        SizedBox(width: kSpacingUnit.w * 7),
        const Center(
          child: Text(
            "Carro de Compras",
            style: TextStyle(
              color: Color.fromRGBO(255, 255, 255, 1),
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(
          width: kSpacingUnit.w * 5,
        ),
        InkWell(
          child: const Icon(
            Icons.delete,
            color: Colors.white,
          ),
          onTap: () async {
            eliminarRolloOffline();
            obtenerRolloYActualizarOffline();
          },
        ),
      ],
    );

    var botomNav = BottomAppBar(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(
              height: kSpacingUnit.h * 1,
            ),
            Expanded(
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: const Color(0xFF4C53A5),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: InkWell(
                  child: const Text(
                    "Realizar Pedido",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  onTap: () {
                    openDialog();
                    lineaventa = 0;
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );

    var carro = ListView.builder(
      itemCount: productos.length,
      itemBuilder: (context, index) {
        var item = productos[index];
        var cantidadController =
            TextEditingController(text: item.artCantidad.toString());
        return InkWell(
          onDoubleTap: () {
            observacion.text = item.observacion ?? "";
            _mostrarObservacion(item);
          },
          child: Container(
            height: 140,
            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColorDark,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Radio(
                  value: "",
                  groupValue: "",
                  activeColor: const Color(0xFF4C53A5),
                  onChanged: (index) {},
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        item.artDescripcion ?? "",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                        ),
                      ),
                      Text(
                        "${item.artCantidad} x ${CurrencyFormatter.format(item.artPrecio, clpSettings)}",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 1),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      InkWell(
                        child: const Icon(
                          Icons.delete,
                          color: Colors.red,
                        ),
                        onTap: () async {
                          eliminarProductoRolloOffline(item.artCodigo!);
                          obtenerRolloYActualizarOffline();
                        },
                      ),
                      Row(
                        children: [
                          InkWell(
                            onTap: () async {
                              setState(() {
                                item.artCantidad = item.artCantidad! + 1;
                                cantidadController.text =
                                    item.artCantidad.toString();
                              });
                              await DBRollo.update(TblRolloTerreno00(
                                local: item.local!,
                                cajaDoc: item.cajaDoc!,
                                lineaVenta: item.lineaVenta!.toDouble(),
                                rutCajero: item.rutCajero!,
                                artCantidad: item.artCantidad!.toDouble(),
                                artCodigo: item.artCodigo!,
                                artDescripcion: item.artDescripcion!,
                                artDescuento: item.artDescuento!,
                                artPrecio: item.artPrecio!,
                                totalLinea: item.totalLinea!,
                                rutVendedor: item.rutVendedor!,
                                fechaTransaccion: item.fechaTransaccion!,
                                horaTransaccion: "",
                                tipoVenta: item.tipoventa!,
                                codImpuesto: item.codImpuesto!,
                                porceImpuesto: item.porceImpuesto!,
                              ));
                              setState(() {
                                actualizarRollo();
                              });
                            },
                            child: const Icon(
                              CupertinoIcons.plus,
                              size: 18,
                            ),
                          ),
                          Container(
                            width: 59,
                            margin: const EdgeInsets.symmetric(horizontal: 10),
                            child: TextField(
                              onSubmitted: (value) async {
                                setState(() {
                                  item.artCantidad = int.parse(value);
                                });
                                await DBRollo.update(TblRolloTerreno00(
                                  local: item.local!,
                                  cajaDoc: item.cajaDoc!,
                                  lineaVenta: item.lineaVenta!.toDouble(),
                                  rutCajero: item.rutCajero!,
                                  artCantidad: item.artCantidad!.toDouble(),
                                  artCodigo: item.artCodigo!,
                                  artDescripcion: item.artDescripcion!,
                                  artDescuento: item.artDescuento!,
                                  artPrecio: item.artPrecio!,
                                  totalLinea: item.totalLinea!,
                                  rutVendedor: item.rutVendedor!,
                                  fechaTransaccion: item.fechaTransaccion!,
                                  horaTransaccion: "",
                                  tipoVenta: item.tipoventa!,
                                  codImpuesto: item.codImpuesto!,
                                  porceImpuesto: item.porceImpuesto!,
                                ));
                                setState(() {
                                  actualizarRollo();
                                });
                              },
                              controller: cantidadController,
                              keyboardType: TextInputType.number,
                              inputFormatters: <TextInputFormatter>[
                                FilteringTextInputFormatter.allow(RegExp(
                                    r'[0-9]')), // Permitir cualquier texto
                              ],
                              decoration: const InputDecoration(
                                  contentPadding: EdgeInsets.symmetric(
                                      vertical: 5, horizontal: 5)),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          InkWell(
                            onTap: () async {
                              setState(() {
                                if (item.artCantidad! > 1) {
                                  item.artCantidad = item.artCantidad! - 1;
                                  cantidadController.text =
                                      item.artCantidad.toString();
                                } else {
                                  productos.removeAt(index);
                                }
                              });
                              await DBRollo.update(TblRolloTerreno00(
                                local: item.local!,
                                cajaDoc: item.cajaDoc!,
                                lineaVenta: item.lineaVenta!.toDouble(),
                                rutCajero: item.rutCajero!,
                                artCantidad: item.artCantidad!.toDouble(),
                                artCodigo: item.artCodigo!,
                                artDescripcion: item.artDescripcion!,
                                artDescuento: item.artDescuento!,
                                artPrecio: item.artPrecio!,
                                totalLinea: item.totalLinea!,
                                rutVendedor: item.rutVendedor!,
                                fechaTransaccion: item.fechaTransaccion!,
                                horaTransaccion: "",
                                tipoVenta: item.tipoventa!,
                                codImpuesto: item.codImpuesto!,
                                porceImpuesto: item.porceImpuesto!,
                              ));
                              setState(() {
                                actualizarRollo();
                              });
                            },
                            child: const Icon(
                              CupertinoIcons.minus,
                              size: 18,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
    var carroMin = ListView.builder(
      itemCount: productos.length,
      itemBuilder: (context, index) {
        var item = productos[index];
        var cantidadController =
            TextEditingController(text: item.artCantidad.toString());
        return InkWell(
          onTap: () {
            observacion.text = item.observacion ?? "";
            _mostrarObservacion(item);
          },
          child: Container(
            height: 140,
            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColorDark,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        item.artDescripcion ?? "",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                        ),
                      ),
                      Text(
                        "${item.artCantidad} x ${CurrencyFormatter.format(item.artPrecio, clpSettings)}",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 1),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      InkWell(
                        child: const Icon(
                          Icons.delete,
                          color: Colors.red,
                        ),
                        onTap: () async {
                          eliminarProductoRolloOffline(item.artCodigo!);
                          obtenerRolloYActualizarOffline();
                        },
                      ),
                      Row(
                        children: [
                          InkWell(
                            onTap: () async {
                              setState(() {
                                item.artCantidad = item.artCantidad! + 1;
                                cantidadController.text =
                                    item.artCantidad.toString();
                              });
                              await DBRollo.update(TblRolloTerreno00(
                                local: item.local!,
                                cajaDoc: item.cajaDoc!,
                                lineaVenta: item.lineaVenta!.toDouble(),
                                rutCajero: item.rutCajero!,
                                artCantidad: item.artCantidad!.toDouble(),
                                artCodigo: item.artCodigo!,
                                artDescripcion: item.artDescripcion!,
                                artDescuento: item.artDescuento!,
                                artPrecio: item.artPrecio!,
                                totalLinea: item.totalLinea!,
                                rutVendedor: item.rutVendedor!,
                                fechaTransaccion: item.fechaTransaccion!,
                                horaTransaccion: "",
                                tipoVenta: item.tipoventa!,
                                codImpuesto: item.codImpuesto!,
                                porceImpuesto: item.porceImpuesto!,
                              ));
                              setState(() {
                                actualizarRollo();
                              });
                            },
                            child: const Icon(
                              CupertinoIcons.plus,
                              size: 18,
                            ),
                          ),
                          Container(
                            width: 59,
                            margin: const EdgeInsets.symmetric(horizontal: 10),
                            child: TextField(
                              onSubmitted: (value) async {
                                setState(() {
                                  item.artCantidad = int.parse(value);
                                });
                                await DBRollo.update(TblRolloTerreno00(
                                  local: item.local!,
                                  cajaDoc: item.cajaDoc!,
                                  lineaVenta: item.lineaVenta!.toDouble(),
                                  rutCajero: item.rutCajero!,
                                  artCantidad: item.artCantidad!.toDouble(),
                                  artCodigo: item.artCodigo!,
                                  artDescripcion: item.artDescripcion!,
                                  artDescuento: item.artDescuento!,
                                  artPrecio: item.artPrecio!,
                                  totalLinea: item.totalLinea!,
                                  rutVendedor: item.rutVendedor!,
                                  fechaTransaccion: item.fechaTransaccion!,
                                  horaTransaccion: "",
                                  tipoVenta: item.tipoventa!,
                                  codImpuesto: item.codImpuesto!,
                                  porceImpuesto: item.porceImpuesto!,
                                ));
                                setState(() {
                                  actualizarRollo();
                                });
                              },
                              controller: cantidadController,
                              keyboardType: TextInputType.number,
                              inputFormatters: <TextInputFormatter>[
                                FilteringTextInputFormatter.allow(RegExp(
                                    r'[0-9]')), // Permitir cualquier texto
                              ],
                              decoration: const InputDecoration(
                                  contentPadding: EdgeInsets.symmetric(
                                      vertical: 5, horizontal: 5)),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          InkWell(
                            onTap: () async {
                              setState(() {
                                if (item.artCantidad! > 1) {
                                  item.artCantidad = item.artCantidad! - 1;
                                  cantidadController.text =
                                      item.artCantidad.toString();
                                } else {
                                  productos.removeAt(index);
                                }
                              });
                              await DBRollo.update(TblRolloTerreno00(
                                local: item.local!,
                                cajaDoc: item.cajaDoc!,
                                lineaVenta: item.lineaVenta!.toDouble(),
                                rutCajero: item.rutCajero!,
                                artCantidad: item.artCantidad!.toDouble(),
                                artCodigo: item.artCodigo!,
                                artDescripcion: item.artDescripcion!,
                                artDescuento: item.artDescuento!,
                                artPrecio: item.artPrecio!,
                                totalLinea: item.totalLinea!,
                                rutVendedor: item.rutVendedor!,
                                fechaTransaccion: item.fechaTransaccion!,
                                horaTransaccion: "",
                                tipoVenta: item.tipoventa!,
                                codImpuesto: item.codImpuesto!,
                                porceImpuesto: item.porceImpuesto!,
                              ));
                              setState(() {
                                actualizarRollo();
                              });
                            },
                            child: const Icon(
                              CupertinoIcons.minus,
                              size: 18,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    return ThemeSwitchingArea(child: Builder(builder: (context) {
      return Scaffold(
        body: LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth < 600) {
              return Column(
                children: <Widget>[
                  SizedBox(
                    height: kSpacingUnit.h * 6,
                  ),
                  headerMin,
                  SizedBox(height: kSpacingUnit.w * 1.5),
                  Expanded(
                    child: carroMin,
                  ),
                  Container(
                    height: kSpacingUnit.h * 12,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    color: Colors.transparent, // Color de fondo para el total
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Text(
                              "Nombre Cliente: ${clienteVenta != null ? clienteVenta!.nombre : ""}",
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Text(
                              "Rut: ${clienteVenta != null ? RUTValidator.formatFromText(clienteVenta!.rut!.replaceFirst("0", "")) : ""}",
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                              ),
                            )
                          ],
                        ),
                        Row(
                          children: [
                            Text(
                              "Correo: ${clienteVenta != null ? correo : ""}",
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            const Text(
                              "Total Carro:  ",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                              ),
                            ),
                            ValueListenableBuilder(
                              valueListenable: _total,
                              builder: (BuildContext context, int value,
                                  Widget? child) {
                                return Text(
                                  CurrencyFormatter.format(value, clpSettings),
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              );
            } else {
              return Column(
                children: <Widget>[
                  SizedBox(
                    height: kSpacingUnit.h * 4,
                  ),
                  header,
                  SizedBox(height: kSpacingUnit.w * 5),
                  Expanded(
                    child: carro,
                  ),
                  Container(
                    height: kSpacingUnit.h * 12,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    color: Colors.transparent, // Color de fondo para el total
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Text(
                                "Nombre Cliente: ${clienteVenta != null ? clienteVenta!.nombre : ""}"),
                          ],
                        ),
                        Row(
                          children: [
                            Text(
                                "Rut: ${clienteVenta != null ? RUTValidator.formatFromText(clienteVenta!.rut!.replaceFirst("0", "")) : ""}")
                          ],
                        ),
                        Row(
                          children: [
                            Text(
                                "Correo: ${clienteVenta != null ? correo : ""}"),
                          ],
                        ),
                        Row(
                          children: [
                            const Text("Total Carro:  "),
                            ValueListenableBuilder(
                              valueListenable: _total,
                              builder: (BuildContext context, int value,
                                  Widget? child) {
                                return Text(
                                  CurrencyFormatter.format(value, clpSettings),
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }
          },
        ),
        bottomNavigationBar: botomNav,
      );
    }));
  }

  void total() {
    if (productos.isNotEmpty) {
      setState(() {
        _total.value =
            productos.sum((i) => (i.artCantidad! * i.artPrecio!).toInt());
      });
    } else {
      _total.value = 0;
    }
  }

  Future openDialog() => showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Observaciones"),
          content: TextField(
            controller: observacion,
          ),
          actions: [
            TextButton(
              onPressed: () {
                RealizarVentaFn();
              },
              child: const Text("Realizar Venta"),
            ),
          ],
        ),
      );

  Future _mostrarObservacion(Rollo p) => showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("Observaciones ${p.artCodigo}"),
          content: TextField(
            controller: observacion,
          ),
          actions: [
            TextButton(
              onPressed: () async {
                var i = 0;
                while (i < productos.length) {
                  if (productos[i].artCodigo == p.artCodigo) {
                    Observacion obj = Observacion(
                      caja: vendedor.caja,
                      codigoProducto: productos[i].artCodigo,
                      observacion: observacion.text,
                    );
                    if (productos[i].observacion == "null" ||
                        productos[i].observacion == "") {
                      DBRolloObservaciones.insert(LocalRolloObservaciones(
                          caja: productos[i].cajaDoc!,
                          codigo: productos[i].artCodigo!,
                          fecha: productos[i].fechaTransaccion!,
                          observaciones: observacion.text));

                      Navigator.pushNamed(context, '/carro');
                    } else {
                      DBRolloObservaciones.update(
                        LocalRolloObservaciones(
                          caja: productos[i].cajaDoc!,
                          codigo: productos[i].artCodigo!,
                          fecha: productos[i].fechaTransaccion!,
                          observaciones: observacion.text,
                        ),
                      );
                      Navigator.pushNamed(context, '/carro');
                    }
                  }
                  i++;
                }

                // Navigator.pushNamed(context, '/carro');
              },
              child: const Text("Actualizar"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Salir"),
            ),
          ],
        ),
      );

  Future<void> obtenerRolloYActualizar() async {
    await obtenerRollo(vendedor.caja!);
    setState(() {
      total();
    });
  }

  void RealizarVentaFn() async {
    //await revisarConexion();
    _mostrarProgressBar(context);
    // if (conexionInternet) {
    //   numeroVenta = (await generarNumeroBoleta())!;
    // } else {
    numeroVenta =
        (int.parse(await DBVentaCabeza.obtenerNumeroBoleta()) + 1).toString();

    numeroVenta = numeroVenta.padLeft(10, '0');
    // }

    if (numeroVenta == null) {
      return _mostrarAlertaError(context, mensaje);
    }
    var i = 1;
    for (var item in productos) {
      if (item.observacion != null &&
          item.observacion != "" &&
          item.observacion != "null" &&
          item.observacion != "Sin Observaciones") {
        var result = await DBVentaObservaciones.insertarObservacionesVenta(
          LocalVentaObservaciones(
            local: "00",
            tipoDoc: "NPE",
            numeroDoc: numeroVenta,
            fechaEmision: DateTime.now().toIso8601String(),
            rutCliente: clienteVenta!.rut!,
            cajaDoc: vendedor.caja!,
            lineaVenta: i.toString().padLeft(3, '0'),
            codigo: item.artCodigo!,
            observaciones: item.observacion!,
          ),
        );
      }
      var detalle = await DBVentaDetalle.insertarDetalleVenta(
        LocalVentaDetalle(
          almacen: "",
          local: "00",
          artCantidad: item.artCantidad!.toDouble(),
          artCodigo: item.artCodigo!,
          artDescripcion: item.artDescripcion!,
          artDescuento: item.artDescuento!,
          artPrecio: item.artPrecio!,
          cajaDoc: vendedor.caja!,
          descuento: 0,
          destinoCliente: clienteData.codDestino!,
          fechaEmision: DateTime.now().toIso8601String(),
          fechaviaje: "",
          foliosii: numeroVenta,
          horaventa: "",
          impuesto: "",
          lineaVenta: i.toString().padLeft(3, '0'),
          montoImpuesto: 0,
          numeroDoc: numeroVenta,
          porceDescuento: 0,
          porceImpuesto: 0,
          precioCostoCiva: 1,
          refFecha: "",
          refNumero: "",
          refTipo: "",
          rutCliente: clienteVenta!.rut!,
          rutVendedor: vendedor.rut!,
          tipoDoc: "NPE ",
          totalLinea: item.totalLinea!,
          usuarioFacturacion: "apiventas.creado",
        ),
      );

      i++;
    }
    // se crea la cabeza de la venta
    var cabeza = VentaCabeza();
    cabeza.local = "00";
    cabeza.tipoDoc = "NPE";
    cabeza.numeroDoc = numeroVenta;
    cabeza.cajaDoc = vendedor.caja;
    cabeza.fechaEmision = DateTime.now().toIso8601String();
    cabeza.foliosii = numeroVenta;
    cabeza.rutCliente = clienteVenta?.rut;
    cabeza.montoTotal = double.parse(_total.value.toString());
    cabeza.subtotal = cabeza.montoTotal;
    cabeza.montoNeto = (cabeza.subtotal! / 1.19).roundToDouble();
    cabeza.montoIva = cabeza.subtotal! - cabeza.montoNeto!;
    cabeza.rutVendedor = vendedor.rut!;
    cabeza.observacion = observacion.text;
    cabeza.impCarne = 0;
    cabeza.impCerveza = 0;
    cabeza.impDiesel = 0;
    cabeza.impHarina = 0;
    cabeza.impLicores = 0;
    cabeza.impLight = 0;
    cabeza.impRefrescos = 0;
    cabeza.impVinos = 0;
    cabeza.montoDonacion = 0;
    cabeza.montoExento = 0;
    cabeza.montoLey20956 = 0;
    cabeza.abono = 0;
    cabeza.formapago = "1";
    cabeza.dctoglobal = 0;
    cabeza.despachoPatente = "";
    cabeza.direccionDestino = clienteData.codDestino;
    cabeza.notaPedido = "";
    cabeza.ordenDeCompra = "";
    if (clienteVenta?.plaso == "\$ 0") {
      cabeza.plazo = "0";
    } else {
      cabeza.plazo = clienteVenta?.plaso == "" ? "30" : clienteVenta?.plaso;
    }

    cabeza.porceDescuento = 0;
    cabeza.rutCajera = vendedor.rut;
    cabeza.porceDescuento = 0;
    cabeza.acteco = "";
    cabeza.despachoFolio = "";
    cabeza.despachoHora = "";
    cabeza.emailCliente = clienteVenta?.email;
    cabeza.fonoCliente = "";
    cabeza.generarDte = 0;
    cabeza.glosaGuia = "";
    cabeza.localTraslado = "";
    cabeza.montoPropina = 0;
    cabeza.nombreCliente = clienteVenta?.nombre;
    cabeza.numeroImpresora = "";
    cabeza.procesada = 0;
    cabeza.refGlosa = "";
    cabeza.refNumero = "";
    cabeza.refTipo = "";
    cabeza.revision1 = 0;
    cabeza.revision2 = 0;
    cabeza.revision3 = 0;
    cabeza.tipoTraslado = "";
    cabeza.usuarioFacturacion = "apiventas.creado";
    var bool = false;

    bool = await DBVentaCabeza.insertarCabezaVenta(
      LocalVentaCabeza(
        local: cabeza.local!,
        tipoDoc: cabeza.tipoDoc!,
        numeroDoc: cabeza.numeroDoc!,
        cajaDoc: cabeza.cajaDoc!,
        fechaEmision: cabeza.fechaEmision!,
        foliosii: cabeza.foliosii!,
        vencimiento: "",
        rutCliente: cabeza.rutCliente!,
        direccionDestino: cabeza.direccionDestino!,
        rutCajera: cabeza.rutCajera!,
        notaPedido: cabeza.notaPedido!,
        ordenDeCompra: cabeza.ordenDeCompra!,
        subtotal: cabeza.subtotal!,
        montoNeto: cabeza.montoNeto!,
        montoIva: cabeza.montoIva!,
        plazo: cabeza.plazo!,
        impHarina: cabeza.impHarina!,
        impCarne: cabeza.impCarne!,
        impRefrescos: cabeza.impRefrescos!,
        impLicores: cabeza.impLicores!,
        impVinos: cabeza.impVinos!,
        impLight: cabeza.impLight!,
        impCerveza: cabeza.impCerveza!,
        impDiesel: cabeza.impDiesel!,
        montoExento: cabeza.montoExento!,
        montoTotal: cabeza.montoTotal!,
        montoLey20956: cabeza.montoLey20956!,
        abono: cabeza.abono!,
        montoDonacion: cabeza.montoDonacion!,
        horaVenta: "",
        horaVendedor: "",
        rutVendedor: cabeza.rutVendedor!,
        dctoglobal: cabeza.dctoglobal!,
        porceDescuento: cabeza.porceDescuento!,
        formaPago: "",
        despachoPatente: cabeza.despachoPatente!,
        despachoFecha: "",
        despachoFolio: cabeza.despachoFolio!,
        despachoHora: cabeza.despachoHora!,
        glosaGuia: cabeza.glosaGuia!,
        usuarioFacturacion: cabeza.usuarioFacturacion!,
        observacion: cabeza.observacion!,
        refTipo: cabeza.refTipo!,
        refFecha: "",
        refNumero: "",
        refGlosa: "",
        nombreCliente: "",
        fonoCliente: "",
        emailCliente: "",
        revision1: 0,
        revision2: 0,
        revision3: 0,
        generarDte: 0,
        numeroImpresora: 0,
        procesada: 0,
        acteco: "",
        imprimePorGrupos: 0,
        tipoTraslado: "",
        montoPropina: 0,
        localTraslado: "",
      ),
    );
    // }

    if (bool == false) {
      return _mostrarAlertaError(context, mensaje);
    }
    var venta = Venta();
    venta.almacen = "00";
    venta.cajaDoc = cabeza.cajaDoc;
    venta.destinoCliente = cabeza.direccionDestino;
    venta.fecha = DateTime.now().toIso8601String();
    venta.rutCliente = clienteVenta?.rut!;
    venta.rutVendedor = vendedor.rut;
    venta.numeroDoc = numeroVenta;
    venta.local = cabeza.local;
    venta.tipoDoc = "NPE";
    venta.lineVenta = "00";
    List<ArticulosVenta> articulosVenta = [];

    if (bool) {
      List<LocalVentaDetalle> res =
          await DBVentaDetalle.obtenerDetalleVentas(numeroVenta);
      if (res.length == productos.length) {
        var cb = await DBVentaCabeza.buscarVenta(numeroVenta);
        if (cb != false) {
          _mostrarAlertaOk(context, "Nota realizada satisfcatoriamente");
          eliminarRolloOffline();
        }
      }
    } else {
      _mostrarAlertaError(context, mensaje);
    }
    // }

    List<Articulo> articulosVendidos = [];
    var email = EmailDto();
    for (var item in articulosVenta) {
      articulosVendidos.add(Articulo(
          codigobarra: item.codigo,
          descripcion: item.descripcion,
          cantidad: item.cantidad,
          total: item.totalLinea));
    }

    email.articulos = articulosVendidos;
    email.to = correo;
    email.cc = "";

    if (conexionInternet) {
      await enviarEmail(email);
    } else {
      eliminarRolloOffline();
    }
  }

  void eliminarRolloYactualizaDatos() async {
    await eliminarRollo(vendedor.caja!);
    await obtenerRollo(vendedor.caja!);
  }

  void _mostrarProgressBar(BuildContext context) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (_) => const AlertDialog(
        title: Text('Enviando Data'),
        content: Flexible(
          child: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      ),
    );
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
                      eliminarRolloOffline();
                      actualizarRollo();
                      showSearch(context: context, delegate: BuscarCliente());
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

  void actualizarRollo() async {
    await obtenerRolloYActualizarOffline();
    setState(() {
      total();
    });
  }

  void eliminarRolloOffline() async {
    await deleteRolloCnObservacionesOffline();
    setState(() {});
  }

  void eliminarProductoRolloOffline(String codigo) async {
    await deleteArticuloRolloOffline(codigo);
    setState(() {});
  }
}
