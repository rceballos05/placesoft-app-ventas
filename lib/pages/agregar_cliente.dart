import 'package:animated_theme_switcher/animated_theme_switcher.dart';
import 'package:aplicacion_ventas/db/clientes.dart';
import 'package:aplicacion_ventas/db/db_clientes.dart';
import 'package:aplicacion_ventas/db/db_destinos.dart';
import 'package:aplicacion_ventas/functions/dart_rut_validator.dart';
import 'package:aplicacion_ventas/functions/functions.dart';
import 'package:aplicacion_ventas/models/destinos.dart';
import 'package:aplicacion_ventas/models/nuevo_cliente.dart';
import 'package:aplicacion_ventas/models/track.dart';
import 'package:aplicacion_ventas/statics/globals.dart';
import 'package:aplicacion_ventas/statics/statics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';

class AgregarClientePage extends StatefulWidget {
  const AgregarClientePage({super.key});

  @override
  _AgregarClientePageState createState() => _AgregarClientePageState();
}

class _AgregarClientePageState extends State<AgregarClientePage> {
  final rutValidator = RUTValidator(validationErrorText: 'RUT no válido');
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController rutController = TextEditingController();
  final TextEditingController nombreController = TextEditingController();
  final TextEditingController comunaController = TextEditingController();
  final TextEditingController ciudadController = TextEditingController();
  final TextEditingController direccionController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController fono1Controller = TextEditingController();
  final TextEditingController celularController = TextEditingController();
  final TextEditingController contactoController = TextEditingController();
  final TextEditingController giroController = TextEditingController();
  final TextEditingController sectorController = TextEditingController();
  bool _isInstitucionPublica = false;

  @override
  void initState() {
    setState(() {});
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
            "Agregar Cliente",
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
                    "Agregar Cliente",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  onTap: () async {
                    var rut = RUTValidator.deFormat(rutController.text);
                    rut = rut.padLeft(10, '0');
                    var nuevo_cliente = NuevoCliente(
                      rut: rut,
                      nombre: nombreController.text.toUpperCase(),
                      direccion: direccionController.text.toUpperCase(),
                      comuna: comunaController.text.toUpperCase(),
                      ciudad: ciudadController.text.toUpperCase(),
                      email: emailController.text.toUpperCase(),
                      celular: celularController.text.toUpperCase(),
                      contacto: contactoController.text.toUpperCase(),
                      fono1: fono1Controller.text.toUpperCase(),
                      giro: giroController.text.toUpperCase(),
                      sector: sectorController.text.toUpperCase(),
                      institucionPublica: _isInstitucionPublica == true ? 1 : 0,
                      vendedor: vendedor.rut,
                    );
                    var result = await agregarCliente(nuevo_cliente);
                    if (result) {
                      String cod =
                          await codComuna(nuevo_cliente.comuna!.toUpperCase());
                      String fecha =
                          DateTime.now().toIso8601String().split('T')[0];
                      String query =
                          "INSERT INTO mae_clientes (rut,nombre,direccion,cod_comuna,comuna,ciudad,fono1,fax,celular,email,canalcliente,vendedor,tipocliente,giro,cupo,localcreacion,fechaingreso) VALUES (~${nuevo_cliente.rut!}~,~${nuevo_cliente.nombre}~,~${nuevo_cliente.direccion}~,~$cod~,~${nuevo_cliente.comuna}~,~${nuevo_cliente.ciudad}~,~${nuevo_cliente.fono1}~,~1~,~${nuevo_cliente.celular}~,~${nuevo_cliente.email}~,~02~,~${vendedor.rut}~,~01~,~${nuevo_cliente.giro}~,~0~,~00~,~$fecha~) ON DUPLICATE KEY UPDATE rut = rut";
                      bool resp = await ingresarTrack(TrackDto(
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
                      if (resp) {
                        query =
                            "INSERT INTO mae_clientes_destinos (cliente,codigo,descripcion,vigente,cod_comuna) VALUES (~${nuevo_cliente.rut!.toUpperCase()}~,~000~,~${nuevo_cliente.direccion!.toUpperCase()}~,~1~,~$cod~) ON DUPLICATE KEY UPDATE cliente = cliente";
                        resp = await ingresarTrack(
                          TrackDto(
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
                          ),
                        );
                        if (resp) {
                          await DBClientes.insert(
                            MaeClientes(
                              rut: nuevo_cliente.rut!,
                              nombre: nuevo_cliente.nombre!,
                              direccion: nuevo_cliente.direccion!,
                              codComuna: cod,
                              comuna: nuevo_cliente.comuna!,
                              ciudad: nuevo_cliente.ciudad!,
                              sector: nuevo_cliente.sector!,
                              fono1: nuevo_cliente.fono1!,
                              fono2: "1",
                              fax: "1",
                              celular: nuevo_cliente.celular!,
                              giro: nuevo_cliente.giro!,
                              email: nuevo_cliente.email!,
                              diascredito: 30,
                              contacto: nuevo_cliente.contacto!,
                              contactoMail: nuevo_cliente.email!,
                              contactoFono: nuevo_cliente.celular!,
                              descuento: 0,
                              bloqueo: "",
                              bloqueoFacturas: "",
                              tipocliente: "01",
                              plazo: "",
                              cupo: 0,
                              disponible: 1,
                              vendedor: vendedor.rut!,
                              canalcliente: "01",
                              fechaultimamodificacion: "",
                              localcreacion: "00",
                              fechaingreso: DateTime.now()
                                  .toIso8601String()
                                  .split('T')[0],
                              activo: 1,
                              codPrecio: "01",
                              precioMenor: 0,
                              webPassword: "",
                              codigoListaPrecios: "",
                              tarjetaCupo: 0,
                              tarjetaDiaPago: 0,
                              terceraEdad: 0,
                              dctoSeccion: "",
                              dctoDepto: "",
                              esInstitucionPublica:
                                  nuevo_cliente.institucionPublica!,
                            ),
                          );
                          await DBDestino.insert(
                            MaeClientesDestinos(
                                codigo: "00",
                                cliente: nuevo_cliente.rut!,
                                descripcion: nuevo_cliente.nombre!,
                                codComuna: cod,
                                vigente: 1,
                                nombreContacto: nuevo_cliente.nombre!,
                                fonoContacto: nuevo_cliente.celular!,
                                emailContacto: nuevo_cliente.email!),
                          );
                          _mostrarAlertaOk(context, mensaje);
                          Navigator.pushNamed(context, '/agregar-cliente');
                        }
                      }
                    } else {
                      _mostrarAlertaError(context, mensaje);
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
                          prefixIcon: Icon(Icons.key),
                          border: OutlineInputBorder(),
                        ),
                      ),
                      _gap(),
                      TextFormField(
                        controller: nombreController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'El campo Nombre no puede estar vacío';
                          }
                          return null;
                        },
                        decoration: const InputDecoration(
                          labelText: 'Nombre',
                          hintText: 'Ingrese su Nombre',
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
                        controller: direccionController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'El campo direccion no puede estar vacío';
                          }
                          return null;
                        },
                        decoration: const InputDecoration(
                          labelText: 'Direccion',
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
                        controller: ciudadController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'El campo ciudad no puede estar vacío';
                          }
                          return null;
                        },
                        decoration: const InputDecoration(
                          labelText: 'Ciudad',
                          hintText: 'Ingrese su ciudad',
                          prefixIcon: Icon(Icons.person),
                          border: OutlineInputBorder(),
                        ),
                      ),
                      _gap(),
                      TextFormField(
                        controller: sectorController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'El campo sector no puede estar vacío';
                          }
                          return null;
                        },
                        decoration: const InputDecoration(
                          labelText: 'Sector',
                          hintText: 'Ingrese su Sector',
                          prefixIcon: Icon(Icons.person),
                          border: OutlineInputBorder(),
                        ),
                      ),
                      _gap(),
                      TextFormField(
                        controller: giroController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'El campo giro no puede estar vacío';
                          }
                          return null;
                        },
                        decoration: const InputDecoration(
                          labelText: 'Giro',
                          hintText: 'Ingrese el giro',
                          prefixIcon: Icon(Icons.person),
                          border: OutlineInputBorder(),
                        ),
                      ),
                      _gap(),
                      TextFormField(
                        controller: fono1Controller,
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'El campo Fono no puede estar vacío';
                          }
                          return null;
                        },
                        decoration: const InputDecoration(
                          labelText: 'Fono',
                          hintText: 'Ingrese su Fono',
                          prefixIcon: Icon(Icons.person),
                          border: OutlineInputBorder(),
                        ),
                      ),
                      _gap(),
                      TextFormField(
                        keyboardType: TextInputType.number,
                        controller: celularController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'El campo celular no puede estar vacío';
                          }
                          return null;
                        },
                        decoration: const InputDecoration(
                          labelText: 'Celular',
                          hintText: 'Ingrese su Celular',
                          prefixIcon: Icon(Icons.person),
                          border: OutlineInputBorder(),
                        ),
                      ),
                      _gap(),
                      TextFormField(
                        controller: contactoController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'El campo Contacto no puede estar vacío';
                          }
                          return null;
                        },
                        decoration: const InputDecoration(
                          labelText: 'Contacto',
                          hintText: 'Ingrese el Contacto',
                          prefixIcon: Icon(Icons.person),
                          border: OutlineInputBorder(),
                        ),
                      ),
                      CheckboxListTile(
                        checkColor: kAccentColor,
                        title: const Text("Es institucion pública"),
                        value: _isInstitucionPublica,
                        onChanged: (value) {
                          setState(() {
                            _isInstitucionPublica = value!;
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
