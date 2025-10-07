import 'dart:developer';

import 'package:animated_theme_switcher/animated_theme_switcher.dart';
import 'package:aplicacion_ventas/functions/dart_rut_validator.dart';
import 'package:aplicacion_ventas/statics/globals.dart';
import 'package:aplicacion_ventas/statics/statics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';

class ModificarDatosPage extends StatefulWidget {
  const ModificarDatosPage({super.key});

  @override
  _ModificarDatosPageState createState() => _ModificarDatosPageState();
}

class _ModificarDatosPageState extends State<ModificarDatosPage> {
  final rutValidator = RUTValidator(validationErrorText: 'RUT no válido');
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController rutController = TextEditingController();
  final TextEditingController nombreController = TextEditingController();
  final TextEditingController comunaController = TextEditingController();
  final TextEditingController ciudadController = TextEditingController();
  final TextEditingController direccionController = TextEditingController();
  final TextEditingController emailController = TextEditingController();

  @override
  void initState() {
    setState(() {
      nombreController.text = user!.nombre ?? "";
      rutController.text =
          RUTValidator.formatFromText(user!.rut!.replaceFirst("0", ""));
      emailController.text = user!.correo ?? "";
      direccionController.text = user!.direccion ?? "";
      comunaController.text = user!.comuna ?? "";
      ciudadController.text = user!.ciudad ?? "";
      log("user->");
      log(user.toString());
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
            "Datos Usuario",
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
                    "Actualizar Datos",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  onTap: () async {
                    var rut = RUTValidator.deFormat(rutController.text);
                    rut = rut.padLeft(10, '0');
                    // var data = UserUpdate(
                    //   correo: emailController.text,
                    //   usuario: usuarioController.text,
                    //   labor: laborController.text,
                    //   nombre: nombreController.text,
                    //   rut: rut,
                    // );
                    // var result = await actualizarUsuario(user!.usuario!, data);

                    // if (result) {
                    //   user!.rut = data.rut;
                    //   user!.correo = data.correo;
                    //   user!.nombre = data.nombre;
                    //   user!.labor = data.labor;
                    //   _mostrarAlertaOk(context, mensaje);
                    // }
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
                        readOnly: true,
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
                        readOnly: true,
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
                        readOnly: true,
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
                        readOnly: true,
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
                        readOnly: true,
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
                    ],
                  ),
                ),
              ),
              SizedBox(height: kSpacingUnit.h * 3),
            ],
          ),
        ),
      ),
    );
  }
}

Widget _gap() => const SizedBox(height: 16);

// void _mostrarAlertaOk(BuildContext context, String text) {
//   showDialog(
//       barrierDismissible: false,
//       context: context,
//       builder: (_) => AlertDialog(
//             title: const Text('Success'),
//             content: Text(text),
//             actions: [
//               TextButton(
//                   onPressed: () {
//                     Navigator.pushNamed(context, '/home');
//                   },
//                   child: const Text('Ok'))
//             ],
//           ));
// }
