import 'package:animated_theme_switcher/animated_theme_switcher.dart';
import 'package:aplicacion_ventas/db/db_destinos.dart';
import 'package:aplicacion_ventas/functions/dart_rut_validator.dart';
import 'package:aplicacion_ventas/functions/functions.dart';
import 'package:aplicacion_ventas/models/destinos.dart';
import 'package:aplicacion_ventas/models/track.dart';
import 'package:aplicacion_ventas/statics/globals.dart';
import 'package:aplicacion_ventas/statics/statics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';

class AgregarLocalPage extends StatefulWidget {
  const AgregarLocalPage({super.key});

  @override
  _AgregarLocalPageState createState() => _AgregarLocalPageState();
}

class _AgregarLocalPageState extends State<AgregarLocalPage> {
  final rutValidator = RUTValidator(validationErrorText: 'RUT no válido');
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController codigoController = TextEditingController();
  final TextEditingController clienteController = TextEditingController();
  final TextEditingController descripcionController = TextEditingController();
  final TextEditingController comunaController = TextEditingController();
  final TextEditingController nombreController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController fono1Controller = TextEditingController();

  bool _vigente = true;
  String codigoNuevo = "";
  @override
  void initState() {
    obtenerCodigoDestino();
    setState(() {
      clienteController.text = clienteVenta!.rut!;
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

    var header = Row(
      children: <Widget>[
        SizedBox(width: kSpacingUnit.w * 8),
        Center(
          child: Text(
            "Agregar Destino Cliente",
            style: kTitleTextStyle,
          ),
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
                    "Agregar destino Cliente",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  onTap: () async {
                    var destino = MaeClientesDestinos(
                      codigo: codigoNuevo,
                      cliente: clienteController.text.toUpperCase(),
                      descripcion: descripcionController.text.toUpperCase(),
                      codComuna:
                          await codComuna(comunaController.text.toUpperCase()),
                      vigente: 1,
                      nombreContacto: nombreController.text.toUpperCase(),
                      fonoContacto: fono1Controller.text,
                      emailContacto: emailController.text.toUpperCase(),
                    );
                    var rsp = await agregarDestinoCliente(
                      destino,
                      rutCliente,
                    );
                    if (rsp) {
                      var query =
                          "INSERT INTO mae_clientes_destinos (cliente,codigo,descripcion,vigente,cod_comuna) VALUES (~${destino.cliente.toUpperCase()}~,~${destino.codigo}~,~${destino.descripcion.toUpperCase()}~,~1~,~${destino.codComuna}~) ON DUPLICATE KEY UPDATE cliente = cliente";
                      var resp = await ingresarTrack(TrackDto(
                        server: "45.236.164.172",
                        basedatos: "places_crvictoria_mantencion",
                        fechaCreacion:
                            DateTime.now().toIso8601String().split('T')[0],
                        horaCreacion: DateTime.now()
                            .toIso8601String()
                            .split('T')[1]
                            .split('.')[0],
                        prioridad: "",
                        queryStr: query,
                        caja: vendedor.caja!,
                      ));
                      await DBDestino.insert(destino);
                      if (resp) {
                        _mostrarAlertaOk(context, mensaje);
                        Navigator.pushNamed(context, '/perfil');
                      }
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );

    return ThemeSwitchingArea(
      child: Scaffold(
        appBar: AppBar(
          title: header,
        ),
        body: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              SizedBox(height: kSpacingUnit.h * 2),
              Form(
                key: _formKey,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: kSpacingUnit.w * 4),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        readOnly: true,
                        onChanged: (value) {},
                        controller: codigoController,
                        decoration: const InputDecoration(
                          labelText: 'Codigo',
                          prefixIcon: Icon(Icons.key),
                          border: OutlineInputBorder(),
                        ),
                      ),
                      _gap(),
                      TextFormField(
                        controller: clienteController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'El campo Cliente no puede estar vacío';
                          }
                          return null;
                        },
                        decoration: const InputDecoration(
                          labelText: 'Cliente',
                          prefixIcon:
                              Icon(LineAwesomeIcons.identification_badge),
                          border: OutlineInputBorder(),
                        ),
                      ),
                      _gap(),
                      TextFormField(
                        controller: emailController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'El campo Correo no puede estar vacío';
                          }
                          return null;
                        },
                        decoration: const InputDecoration(
                          labelText: 'Correo',
                          hintText: 'Ingrese su Correo',
                          prefixIcon: Icon(LineAwesomeIcons.at),
                          border: OutlineInputBorder(),
                        ),
                      ),
                      _gap(),
                      TextFormField(
                        controller: descripcionController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'El campo descripcion no puede estar vacío';
                          }
                          return null;
                        },
                        decoration: const InputDecoration(
                          labelText: 'Descripcion',
                          hintText: 'Ingrese su direccion',
                          prefixIcon: Icon(Icons.person),
                          border: OutlineInputBorder(),
                        ),
                      ),
                      _gap(),
                      TextFormField(
                        controller: comunaController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'El campo comuna no puede estar vacío';
                          }
                          return null;
                        },
                        decoration: const InputDecoration(
                          labelText: 'Comuna',
                          hintText: 'Ingrese su Comuna',
                          prefixIcon: Icon(Icons.person),
                          border: OutlineInputBorder(),
                        ),
                      ),
                      _gap(),
                      TextFormField(
                        controller: nombreController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'El campo nombre contacto no puede estar vacío';
                          }
                          return null;
                        },
                        decoration: const InputDecoration(
                          labelText: 'Nombre Contacto',
                          hintText: 'Ingrese el Nombre del Contacto',
                          prefixIcon: Icon(Icons.person),
                          border: OutlineInputBorder(),
                        ),
                      ),
                      _gap(),
                      TextFormField(
                        controller: fono1Controller,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'El campo fono contacto no puede estar vacío';
                          }
                          return null;
                        },
                        decoration: const InputDecoration(
                          labelText: 'Fono Contacto',
                          hintText: 'Ingrese el número de fono del contacto',
                          prefixIcon: Icon(Icons.person),
                          border: OutlineInputBorder(),
                        ),
                      ),
                      _gap(),
                      TextFormField(
                        controller: emailController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'El campo email contacto no puede estar vacío';
                          }
                          return null;
                        },
                        decoration: const InputDecoration(
                          labelText: 'Email Contacto',
                          hintText: 'Ingrese el email del contacto',
                          prefixIcon: Icon(Icons.person),
                          border: OutlineInputBorder(),
                        ),
                      ),
                      CheckboxListTile(
                        checkColor: kAccentColor,
                        title: const Text("Vigente"),
                        value: _vigente,
                        onChanged: (value) {
                          setState(() {
                            _vigente = value!;
                          });
                        },
                      )
                    ],
                  ),
                ),
              ),
              SizedBox(height: kSpacingUnit.h * 3),
            ],
          ),
        ),
        bottomNavigationBar: botomNav,
      ),
    );
  }

  void obtenerCodigoDestino() async {
    var codigo = await obtenerCodigoNuevoDestino(clienteData.rut!);
    setState(() {
      codigoNuevo = codigo;
      codigoController.text = codigoNuevo;
    });
  }
}

Widget _gap() => const SizedBox(height: 16);

void _mostrarAlertaOk(BuildContext context, String text) {
  showDialog(
      barrierDismissible: false,
      context: context,
      builder: (_) => AlertDialog(
            title: const Text('Success'),
            content: Text(text),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/home');
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
