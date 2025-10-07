import 'dart:async';
import 'dart:developer';
import 'package:aplicacion_ventas/db/db_clientes.dart';
import 'package:aplicacion_ventas/db/db_destinos.dart';
import 'package:aplicacion_ventas/db/db_login.dart';
import 'package:aplicacion_ventas/db/db_precios.dart';
import 'package:aplicacion_ventas/db/db_productos.dart';
import 'package:aplicacion_ventas/db/db_rollo.dart';
import 'package:aplicacion_ventas/db/db_rollo_observaciones.dart';
import 'package:aplicacion_ventas/db/db_ventaCabeza.dart';
import 'package:aplicacion_ventas/db/db_ventasDetalle.dart';
import 'package:aplicacion_ventas/db/db_ventas_observaciones.dart';
import 'package:aplicacion_ventas/db/login.dart';
import 'package:aplicacion_ventas/db/venta_cabeza.dart';
import 'package:aplicacion_ventas/functions/dart_rut_validator.dart';
import 'package:aplicacion_ventas/models/query_data.dart';
import 'package:aplicacion_ventas/statics/globals.dart';
import 'package:aplicacion_ventas/widgets/busqueda_cliente.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:animated_theme_switcher/animated_theme_switcher.dart';
import 'package:aplicacion_ventas/functions/functions.dart';
import 'package:aplicacion_ventas/statics/statics.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController rutController = TextEditingController();
  final TextEditingController passController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final ValueNotifier<bool> _rememberMe = ValueNotifier<bool>(false);
  bool _isPasswordVisible = false;
  final rutValidator = RUTValidator(validationErrorText: 'RUT no válido');
  @override
  void initState() {
    solicitarPermisos();
    revisarConexion();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(
      context,
      designSize: const Size(414, 896),
      minTextAdapt: true,
    );

    var logo = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Image(
          image: AssetImage("assets/img/logo-p.png"),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            "Bienvenido",
            textAlign: TextAlign.center,
            style: kTitleTextStyle,
          ),
        )
      ],
    );

    var form = Container(
      constraints: const BoxConstraints(maxWidth: 300),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextFormField(
              onChanged: (value) {
                RUTValidator.formatFromTextController(rutController);
              },
              controller: rutController,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'El campo rut no puede estar vacío';
                } else {
                  return rutValidator.validator(value);
                }
              },
              decoration: const InputDecoration(
                labelText: 'Rut',
                hintText: 'Ingrese su Rut',
                prefixIcon: Icon(Icons.person),
                border: OutlineInputBorder(),
              ),
            ),
            _gap(),
            TextFormField(
              controller: passController,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'El campo password no puede estar vacío';
                }
                if (value.length < 3) {
                  return 'El password debe contener al menos 3 caracteres';
                }
                return null;
              },
              obscureText: !_isPasswordVisible,
              decoration: InputDecoration(
                labelText: 'Password',
                hintText: 'Ingrese su password',
                prefixIcon: const Icon(Icons.lock_outline_rounded),
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(_isPasswordVisible
                      ? Icons.visibility_off
                      : Icons.visibility),
                  onPressed: () {
                    setState(() {
                      _isPasswordVisible = !_isPasswordVisible;
                    });
                  },
                ),
              ),
            ),
            _gap(),
            ValueListenableBuilder<bool>(
              valueListenable: _rememberMe,
              builder: (context, value, child) {
                return CheckboxListTile(
                  value: value,
                  onChanged: (value) {
                    if (value != null) {
                      _rememberMe.value = value;
                    }
                  },
                  title: const Text('Recuérdame'),
                  controlAffinity: ListTileControlAffinity.leading,
                  dense: true,
                  contentPadding: const EdgeInsets.all(0),
                );
              },
            ),
            _gap(),
            CheckboxListTile(
                value: sincroniza,
                title: const Text("Sincronizar Data"),
                dense: true,
                contentPadding: const EdgeInsets.all(0),
                onChanged: (value) {
                  setState(() {
                    sincroniza = !sincroniza;
                    log(sincroniza.toString());
                  });
                }),
            _gap(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4)),
                ),
                child: const Padding(
                  padding: EdgeInsets.all(10.0),
                  child: Text(
                    'Iniciar Sesión',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                onPressed: () async {
                  if (_formKey.currentState?.validate() ?? false) {
                    var rut = RUTValidator.deFormat(rutController.text);
                    rut = rut.padLeft(10, '0');
                    var login = false;
                    if (conexionInternet) {
                      login = await iniciarSesion(rut, passController.text);
                    } else {
                      DBLogin.IniciarSesion(rut, passController.text);
                      obtenerClientes();
                      login = true;
                    }

                    if (login == false) {
                      _mostrarAlertaErrorLogin(context);
                    } else {
                      logInicioSesionFunction();
                      DBClientes.ConectarBd();
                      DBDestino.conectarBd();
                      DBPrecios.AbirDb();
                      DBProductos.AbirDb();
                      DBRollo.ConectarBd();
                      DBVentaCabeza.ConectarBd();
                      DBVentaDetalle.ConectarBd();
                      DBVentaObservaciones.ConectarBd();
                      DBRolloObservaciones.ConectarBd();

                      if (vendedor.downloadData == "1" &&
                          vendedor.modoLocal == "true") {
                        _mostrarProgressBarDownload(context);
                        await downloadData();
                        var registrado =
                            await DBLogin.verificarRutExiste(vendedor.rut!);
                        if (registrado == false) {
                          var login = LoginDb();
                          login.prefijo = vendedor.prefijo;
                          login.caja = vendedor.caja;
                          login.maxDctoPermitido = vendedor.descuento;
                          login.password = passController.text;
                          login.urlImagen = "";
                          login.rut = vendedor.rut;

                          DBLogin.insert(login);
                        }

                        _mostrarProgressBarBD(context);

                        firstLogin = true;

                        var venta = await obtenerUltimaVenta(
                            vendedor.prefijo!, vendedor.caja!);

                        if (venta != null) {
                          DBVentaCabeza.insertarCabezaVenta(venta);
                        }
                        _mostrarAlertaOkBD(context, "Cargada exitosamente");
                      }
                      if (vendedor.updateCliente == "1") {
                        await copyDatabaseClientes(vendedor.prefijo!);
                        await copyDatabaseProductos(vendedor.prefijo!);
                      }
                      if (sincroniza && conexionInternet) {
                        _mostrarProgressBar(context);
                        var conteo = await enviarVentasServer();
                        var p = int.tryParse(conteo.toString());
                        if (p == null) {
                          return _mostrarAlertaErrorEnvio(context, conteo);
                        }
                        return _mostrarAlertaOkEnvio(
                            context, "Se enviaron $conteo registros");
                      } else {
                        if (conexionInternet) {
                          _mostrarProgressBarDownload(context);

                          var i = await traerData(
                              vendedor.prefijo!, vendedor.caja!);
                          if (i == null) {
                            _mostrarAlertaOk(
                                context, "no hay registros para actualizar");
                          } else {
                            _mostrarAlertaOk(
                                context, "Se actualizaron $i registros");
                          }
                          if (vendedor.errorEnvio == "1") {
                            errorEnvioData();
                          }
                        } else {
                          showSearch(
                              context: context, delegate: BuscarCliente());
                        }
                      }
                    }
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );

    return ThemeSwitchingArea(
      child: Scaffold(
        body: Column(
          children: <Widget>[
            Expanded(
              child: ListView(
                children: <Widget>[
                  SizedBox(height: kSpacingUnit.h * 5),
                  logo,
                  form,
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _mostrarAlertaErrorLogin(BuildContext context) {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (_) => AlertDialog(
              title: const Text('Error'),
              content: const Text('Usuario y/o contraseña inválidos'),
              actions: [
                TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('Ok'))
              ],
            ));
  }

  Widget _gap() => const SizedBox(height: 16);

  Future<int> traerData(String prefijo, String caja) async {
    List<QueryData> data = await traerDataFromLogServer(prefijo, caja);
    var cantidad = data.length;
    var totals = cantidad;
    if (cantidad > 0) {
      while (cantidad > 0) {
        for (var item in data) {
          switch (item.query!.split(" ")[1]) {
            case "mae_clientes_destinos":
              DBDestino.ejecutarQuery(item.query!);
              break;
            case "mae_clientes":
              DBClientes.ejecutarQuery(item.query!);
              break;
            case "mae_articulos_00":
              DBProductos.ejecutarQuery(item.query!);
              break;
            case "mae_articulos_precios_00":
              DBPrecios.ejecutarQuery(item.query!);
              break;
            case "INTO":
              switch (item.query!.split(" ")[2]) {
                case "mae_clientes_destinos":
                  DBDestino.ejecutarQueryInsert(item.query!);
                  break;
                case "mae_clientes":
                  DBClientes.ejecutarQueryInsert(item.query!);
                  break;
                case "mae_articulos_00":
                  DBProductos.ejecutarQueryInsert(item.query!);
                  break;
                case "mae_articulos_precios_00":
                  DBPrecios.ejecutarQueryInsert(item.query!);
                  break;
              }
              break;
            default:
          }
        }
        data = await traerDataFromLogServer(prefijo, caja);
        cantidad = data.length;
        totals += cantidad;
      }
    }

    var x = await obtenerUltimaVenta(vendedor.prefijo!, vendedor.caja!);
    if (x == null) {
      return totals;
    } else {
      var y = await DBVentaCabeza.buscarVenta(x.numeroDoc);
      if (y == false) {
        await DBVentaCabeza.insertarCabezaVenta(LocalVentaCabeza(
          local: x.local,
          tipoDoc: x.tipoDoc,
          numeroDoc: x.numeroDoc,
          cajaDoc: x.cajaDoc,
          fechaEmision: x.fechaEmision,
          foliosii: x.foliosii,
          vencimiento: x.vencimiento,
          rutCliente: x.rutCliente,
          direccionDestino: x.direccionDestino,
          rutCajera: x.rutCajera,
          notaPedido: x.notaPedido,
          ordenDeCompra: x.ordenDeCompra,
          subtotal: x.subtotal,
          montoNeto: x.montoNeto,
          montoIva: x.montoIva,
          plazo: x.plazo,
          impHarina: x.impHarina,
          impCarne: x.impCarne,
          impRefrescos: x.impRefrescos,
          impLicores: x.impLicores,
          impVinos: x.impVinos,
          impLight: x.impLight,
          impCerveza: x.impCerveza,
          impDiesel: x.impDiesel,
          montoExento: x.montoExento,
          montoTotal: x.montoTotal,
          montoLey20956: x.montoLey20956,
          abono: x.abono,
          montoDonacion: x.montoDonacion,
          horaVenta: x.horaVenta,
          horaVendedor: x.horaVendedor,
          rutVendedor: x.rutVendedor,
          dctoglobal: x.dctoglobal,
          porceDescuento: x.porceDescuento,
          formaPago: x.formaPago,
          despachoPatente: x.despachoPatente,
          despachoFecha: x.despachoFecha,
          despachoFolio: x.despachoFolio,
          despachoHora: x.despachoHora,
          glosaGuia: x.glosaGuia,
          usuarioFacturacion: x.usuarioFacturacion,
          observacion: x.observacion,
          refTipo: x.refTipo,
          refFecha: x.refFecha,
          refNumero: x.refNumero,
          refGlosa: x.refGlosa,
          nombreCliente: x.nombreCliente,
          fonoCliente: x.fonoCliente,
          emailCliente: x.emailCliente,
          revision1: x.revision1,
          revision2: x.revision2,
          revision3: x.revision3,
          generarDte: x.generarDte,
          numeroImpresora: x.numeroImpresora,
          procesada: x.procesada,
          acteco: x.acteco,
          imprimePorGrupos: x.imprimePorGrupos,
          tipoTraslado: x.tipoTraslado,
          montoPropina: x.montoPropina,
          localTraslado: x.localTraslado,
        ));
      }
    }
    return totals;
  }

  void _mostrarProgressBarDownload(BuildContext context) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (_) => const AlertDialog(
        title: Text('Descargando Data'),
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
                      showSearch(context: context, delegate: BuscarCliente());
                    },
                    child: const Text('Ok'))
              ],
            ));
  }

  void _mostrarAlertaOkEnvio(BuildContext context, String text) {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (_) => AlertDialog(
              title: const Text('Success'),
              content: Text(text),
              actions: [
                TextButton(
                    onPressed: () async {
                      if (conexionInternet) {
                        _mostrarProgressBarDownload(context);

                        var i =
                            await traerData(vendedor.prefijo!, vendedor.caja!);
                        if (i == null) {
                          _mostrarAlertaOk(
                              context, "no hay registros para actualizar");
                        } else {
                          _mostrarAlertaOk(
                              context, "Se actualizaron $i registros");
                        }
                      }
                    },
                    child: const Text('Ok'))
              ],
            ));
  }

  void _mostrarAlertaErrorEnvio(BuildContext context, String text) {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (_) => AlertDialog(
              title: const Text('Error'),
              content: Text(text),
              actions: [
                TextButton(
                    onPressed: () async {
                      if (conexionInternet) {
                        _mostrarProgressBarDownload(context);

                        var i =
                            await traerData(vendedor.prefijo!, vendedor.caja!);
                        if (i == null) {
                          _mostrarAlertaOk(
                              context, "no hay registros para actualizar");
                        } else {
                          _mostrarAlertaOk(
                              context, "Se actualizaron $i registros");
                        }
                      }
                    },
                    child: const Text('Ok'))
              ],
            ));
  }

  void _mostrarAlertaOkBD(BuildContext context, String text) {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (_) => AlertDialog(
              title: const Text('Success'),
              content: Text(text),
              actions: [
                TextButton(
                    onPressed: () async {
                      showSearch(context: context, delegate: BuscarCliente());
                    },
                    child: const Text('Ok'))
              ],
            ));
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

  void _mostrarProgressBarBD(BuildContext context) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (_) => const AlertDialog(
        title: Text('Cargando Base de datos'),
        content: Flexible(
          child: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      ),
    );
  }

  Future errorEnvioData() async {
    var lst = await DBVentaCabeza.errorEnvioVentas();

    for (LocalVentaCabeza item in lst) {
      item.usuarioFacturacion = 'apiventas.creado';
      await DBVentaCabeza.updateVenta(item);
    }
  }

  Future downloadData() async {
    await copyDatabaseClientes(vendedor.prefijo!);
    await copyDatabaseProductos(vendedor.prefijo!);
    await copyDatabaseRollo();
    await copyDatabaseVentas();
    await copyDatabaseLogin();
    var update = await updateDownloadData(vendedor);
  }
}
