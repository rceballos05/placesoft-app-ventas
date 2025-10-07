import 'dart:developer';

import 'package:animated_theme_switcher/animated_theme_switcher.dart';
import 'package:aplicacion_ventas/db/db_rollo.dart';
import 'package:aplicacion_ventas/db/db_rollo_observaciones.dart';
import 'package:aplicacion_ventas/db/rollo.dart';
import 'package:aplicacion_ventas/db/rollo_observaciones.dart';
import 'package:aplicacion_ventas/functions/functions.dart';
import 'package:aplicacion_ventas/models/producto.dart';
import 'package:aplicacion_ventas/models/rollo.dart';
import 'package:aplicacion_ventas/statics/globals.dart';
import 'package:aplicacion_ventas/statics/statics.dart';
import 'package:aplicacion_ventas/widgets/busqueda_producto.dart';
import 'package:currency_formatter/currency_formatter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class Detalle extends StatefulWidget {
  const Detalle({super.key});

  @override
  _DetalleState createState() => _DetalleState();
}

class _DetalleState extends State<Detalle> with AutomaticKeepAliveClientMixin {
  late Future<dynamic> _data;
  var total = 0;
  TextEditingController cantidadP = TextEditingController();
  TextEditingController obs = TextEditingController();
  TextEditingController dcto = TextEditingController();
  var pr = Producto();
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    cantidadP.text = "1";

    _data = obtenerDetalleOffline(codigo);
    setState(() {
      totalProducto(1, precio);
      actualizarRollo();
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(
      context,
      designSize: const Size(414, 896),
      minTextAdapt: true,
    );
    bool check = false;
    var header = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SizedBox(
          width: kSpacingUnit.w * 2,
        ),
        InkWell(
          child: const Icon(
            Icons.arrow_back,
            size: 35,
          ),
          onTap: () {
            if (fromBusqueda) {
              fromDetalle = true;
              fromBusqueda = false;
              showSearch(
                context: context,
                delegate: BuscarProducto(),
                query: busqueda,
              );
            } else {
              Navigator.pop(context);
            }
          },
        ),
        SizedBox(width: kSpacingUnit.w * 10),
        const Center(
          child: Text(
            "Detalle Producto",
            style: TextStyle(
                color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );

    var bottomBar = BottomAppBar(
      child: Container(
        height: 70,
        padding: const EdgeInsets.symmetric(horizontal: 2),
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 3,
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            SizedBox(
              width: kSpacingUnit.w * 2,
            ),
            const Text(
              "Total:  ",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.bold),
            ),
            Text(
              CurrencyFormatter.format(total, clpSettings),
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.bold),
            ),
            const Spacer(),
            ElevatedButton.icon(
              onPressed: () async {
                // ProductoCarro nuevoProducto = ProductoCarro(
                //   codigo: producto.codigo,
                //   descripcion: producto.descripcion,
                //   cantidad: producto.cantidad,
                //   precio: producto.precio,
                //   observacion: obs.text,
                //   articuloDescuento: producto.articuloDescuento,
                //   precioCostoCIva: producto.precioCostoCIva,
                //   porcentajeDescuento: producto.porcentajeDescuento,
                // // );
                // carroCompras.add(nuevoProducto);
                if (productos
                        .where((element) => element.artCodigo == pr.codigobarra)
                        .firstOrNull !=
                    null) {
                  mensaje = "No se puede volver a agregar el mismo producto";
                  return _mostrarAlertaError(context, mensaje);
                }
                if (productos.length == 32) {
                  mensaje = "Se alcanzó el límite de productos permitidos";
                  return _mostrarAlertaError(context, mensaje);
                }
                Rollo rollo = Rollo();
                rollo.artCantidad = int.parse(cantidadP.text);
                rollo.artCodigo = pr.codigobarra;
                rollo.artDescripcion = pr.descripcion;
                rollo.artDescuento = double.parse(pr.descuento.toString());
                rollo.artPrecio = double.parse((pr.precio ?? 0).toString());
                rollo.tipoventa = "NPE";
                rollo.cajaDoc = vendedor.caja;
                rollo.fechaTransaccion = DateTime.now().toIso8601String();
                rollo.totalLinea = (rollo.artPrecio! * rollo.artCantidad!);
                rollo.local = "00";
                rollo.codImpuesto = "0000";
                rollo.porceImpuesto = 0;
                rollo.rutCajero = vendedor.rut;
                rollo.rutVendedor = vendedor.rut;
                rollo.lineaVenta = lineaventa;
                rollo.observacion = obs.text;

                cantidad = 0;
                lineaventa = lineaventa + 1;
                agregarProductoCarro(rollo);
                Navigator.pushNamed(context, '/carro');
              },
              icon: const Icon(
                CupertinoIcons.cart_badge_plus,
                color: Colors.white,
              ),
              label: const Text(
                "Añadir al carro",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(
                    const Color(0xFF4C53A5),
                  ),
                  padding: MaterialStateProperty.all(
                    const EdgeInsets.symmetric(vertical: 13, horizontal: 15),
                  ),
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  )),
            ),
          ],
        ),
      ),
    );
    var body;
    if (vendedor.descuento == 0) {
      body = FutureBuilder(
        future: _data,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else {
            pr = snapshot.data!;

            return ListView(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Image.network(
                    '$url_img${pr.codigobarra}.jpg',
                    height: 200,
                    errorBuilder: (context, error, stackTrace) =>
                        Image.asset('assets/img/producto.png'),
                  ),
                ),
                Container(
                  width: kSpacingUnit.w * 30,
                  color: Theme.of(context).focusColor,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(
                            top: 45,
                            bottom: 20,
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(
                                  pr.descripcion ?? "",
                                  style: const TextStyle(
                                      color: Colors.white, fontSize: 20),
                                ),
                              )
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                            top: 5,
                            bottom: 10,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                CurrencyFormatter.format(
                                    pr.precio ?? 0, clpSettings),
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius:
                                            BorderRadiusDirectional.circular(
                                                20),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.grey.withOpacity(0.5),
                                            spreadRadius: 1,
                                            blurRadius: 10,
                                          ),
                                        ]),
                                    child: InkWell(
                                      onTap: () {
                                        cantidad++;
                                        cantidadP.text = cantidad.toString();
                                        setState(() {
                                          totalProducto(cantidad, pr.precio);
                                        });
                                      },
                                      child: Icon(
                                        CupertinoIcons.plus,
                                        size: 18,
                                        color: Theme.of(context).primaryColor,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    width: 50,
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 10),
                                    child: TextField(
                                      controller: cantidadP,
                                      onChanged: (value) {
                                        if (value.isEmpty) {
                                        } else {
                                          cantidad = int.parse(value);
                                          // cantidadP.text = value;
                                          cantidadP.text = cantidad.toString();
                                          setState(() {
                                            totalProducto(cantidad, pr.precio);
                                          });
                                        }
                                      },
                                      keyboardType: TextInputType.number,
                                      inputFormatters: <TextInputFormatter>[
                                        FilteringTextInputFormatter.digitsOnly
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
                                  Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius:
                                            BorderRadiusDirectional.circular(
                                                20),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.grey.withOpacity(0.5),
                                            spreadRadius: 1,
                                            blurRadius: 10,
                                          ),
                                        ]),
                                    child: InkWell(
                                      onTap: () {
                                        cantidad--;
                                        cantidadP.text = cantidad.toString();
                                        setState(() {
                                          totalProducto(cantidad, pr.precio);
                                        });
                                      },
                                      child: Icon(
                                        CupertinoIcons.minus,
                                        size: 18,
                                        color: Theme.of(context).primaryColor,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                            top: 5,
                            bottom: 10,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("Stock: ${pr.stock}",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 19,
                                    fontWeight: FontWeight.bold,
                                  )),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                            top: 5,
                            bottom: 10,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                "Observaciones: ",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(
                                height: kSpacingUnit.h * 0.8,
                              ),
                            ],
                          ),
                        ),
                        Row(
                          children: [
                            Container(
                              width: 300,
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              child: TextField(
                                controller: obs,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                                maxLength: 50,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }
        },
      );
    } else {
      body = FutureBuilder(
        future: _data,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else {
            pr = snapshot.data!;

            return ListView(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Image.network(
                    "https://definicion.de/wp-content/uploads/2009/06/producto.png",
                    height: 200,
                    errorBuilder: (context, error, stackTrace) =>
                        Image.asset('assets/img/producto.png'),
                  ),
                ),
                Container(
                  width: kSpacingUnit.w * 30,
                  color: Theme.of(context).focusColor,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(
                            top: 45,
                            bottom: 20,
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(
                                  pr.descripcion ?? "",
                                  style: const TextStyle(
                                      color: Colors.white, fontSize: 20),
                                ),
                              )
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                            top: 5,
                            bottom: 10,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                CurrencyFormatter.format(
                                    pr.precio ?? 0, clpSettings),
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius:
                                            BorderRadiusDirectional.circular(
                                                20),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.grey.withOpacity(0.5),
                                            spreadRadius: 1,
                                            blurRadius: 10,
                                          ),
                                        ]),
                                    child: InkWell(
                                      onTap: () {
                                        cantidad++;
                                        cantidadP.text = cantidad.toString();
                                        setState(() {
                                          totalProducto(cantidad, pr.precio);
                                        });
                                      },
                                      child: Icon(
                                        CupertinoIcons.plus,
                                        size: 18,
                                        color: Theme.of(context).primaryColor,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    width: 50,
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 10),
                                    child: TextField(
                                      controller: cantidadP,
                                      onChanged: (value) {
                                        if (value.isEmpty) {
                                        } else {
                                          cantidad = int.parse(value);
                                          // cantidadP.text = value;
                                          cantidadP.text = cantidad.toString();
                                          setState(() {
                                            totalProducto(cantidad, pr.precio);
                                          });
                                        }
                                      },
                                      keyboardType: TextInputType.number,
                                      inputFormatters: <TextInputFormatter>[
                                        FilteringTextInputFormatter.digitsOnly
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
                                  Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius:
                                            BorderRadiusDirectional.circular(
                                                20),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.grey.withOpacity(0.5),
                                            spreadRadius: 1,
                                            blurRadius: 10,
                                          ),
                                        ]),
                                    child: InkWell(
                                      onTap: () {
                                        cantidad--;
                                        cantidadP.text = cantidad.toString();
                                        setState(() {
                                          totalProducto(cantidad, pr.precio);
                                        });
                                      },
                                      child: Icon(
                                        CupertinoIcons.minus,
                                        size: 18,
                                        color: Theme.of(context).primaryColor,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                            top: 5,
                            bottom: 10,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("Stock: ${pr.stock}",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 19,
                                    fontWeight: FontWeight.bold,
                                  )),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                            top: 5,
                            bottom: 10,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                "Observaciones: ",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(
                                height: kSpacingUnit.h * 0.8,
                              ),
                            ],
                          ),
                        ),
                        Row(
                          children: [
                            Container(
                              width: 300,
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              child: TextField(
                                controller: obs,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                                maxLength: 50,
                              ),
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                            top: 5,
                            bottom: 10,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                "Descuento ",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(
                                height: kSpacingUnit.h * 0.8,
                              ),
                            ],
                          ),
                        ),
                        Row(
                          children: [
                            Container(
                              width: 45,
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              child: TextField(
                                controller: dcto,
                                keyboardType: TextInputType.number,
                                inputFormatters: <TextInputFormatter>[
                                  FilteringTextInputFormatter.digitsOnly
                                ],
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                                maxLength: 3,
                                onSubmitted: (value) {
                                  if (double.parse(value) >
                                      vendedor.descuento!) {
                                    _mostrarAlertaError(context,
                                        "Error el descuento no puede ser mayor a ${vendedor.descuento}");
                                    dcto.text = "0";
                                  } else {
                                    setState(() {
                                      var precio = pr.precio;
                                      var nuevoPrecio = precio! /
                                          (1 + vendedor.descuento! / 100);

                                      log(nuevoPrecio.toString());
                                      pr.descuento =
                                          vendedor.descuento!.toInt();
                                      pr.precio = nuevoPrecio.round();
                                      totalProducto(cantidad, pr.precio);
                                    });
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }
        },
      );
    }

    return ThemeSwitchingArea(
      child: Builder(
        builder: (context) {
          return Scaffold(
            body: Column(
              children: <Widget>[
                SizedBox(
                  height: kSpacingUnit.h * 3.5,
                ),
                header,
                SizedBox(
                  height: kSpacingUnit.h * 3,
                ),
                Expanded(child: body),
              ],
            ),
            bottomNavigationBar: bottomBar,
          );
        },
      ),
    );
  }

  Future<void> obtenerRolloYActualizar() async {
    await obtenerRollo(vendedor.caja!);
    setState(() {});
  }

  void totalProducto(int? cantidad, int? precio) {
    if (cantidad != null && precio != null) {
      setState(() {
        total = cantidad * precio;
      });
    } else {
      total = 0;
    }
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
    if (obs.text != "") {
      await DBRolloObservaciones.insert(LocalRolloObservaciones(
          codigo: tblRollo.artCodigo,
          fecha: tblRollo.fechaTransaccion,
          caja: tblRollo.cajaDoc,
          observaciones: obs.text));
    }
  }

  Future obtenerDetalleOffline(String codigo) async {
    Producto producto = await detalleProductoOffline(codigo);
    return producto;
  }

  void actualizarRollo() async {
    //await obtenerRolloYActualizarOffline();
    setState(() {});
  }
}
