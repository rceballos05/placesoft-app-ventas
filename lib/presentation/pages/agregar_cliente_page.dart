import 'dart:developer' as developer;

import 'package:animated_theme_switcher/animated_theme_switcher.dart';
import 'package:aplicacion_ventas/db/db_clientes.dart';
import 'package:aplicacion_ventas/db/db_destinos.dart';
import 'package:aplicacion_ventas/db/track_db.dart';
import 'package:aplicacion_ventas/models/mae_cliente.dart';
import 'package:aplicacion_ventas/models/mae_cliente_destino.dart';
import 'package:aplicacion_ventas/models/nuevo_cliente.dart';
import 'package:aplicacion_ventas/models/track.dart';
import 'package:aplicacion_ventas/statics/globals.dart' as globals;
import 'package:aplicacion_ventas/statics/statics.dart';
import 'package:aplicacion_ventas/utils/rut_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';

class AgregarClientePage extends StatefulWidget {
  const AgregarClientePage({super.key});
  static const routeName = '/cliente';
  @override
  State<AgregarClientePage> createState() => _AgregarClientePageState();
}

class _AgregarClientePageState extends State<AgregarClientePage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _rutController = TextEditingController();
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _direccionController = TextEditingController();
  final TextEditingController _comunaController = TextEditingController();
  final TextEditingController _ciudadController = TextEditingController();
  final TextEditingController _sectorController = TextEditingController();
  final TextEditingController _fonoController = TextEditingController();
  final TextEditingController _celularController = TextEditingController();
  final TextEditingController _giroController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _contactoController = TextEditingController();
  bool _esInstitucionPublica = false;
  bool _isSaving = false;

  @override
  void dispose() {
    _rutController.dispose();
    _nombreController.dispose();
    _direccionController.dispose();
    _comunaController.dispose();
    _ciudadController.dispose();
    _sectorController.dispose();
    _fonoController.dispose();
    _celularController.dispose();
    _giroController.dispose();
    _emailController.dispose();
    _contactoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(
      context,
      designSize: const Size(414, 896),
      minTextAdapt: true,
    );

    final header = Row(
      children: <Widget>[
        SizedBox(width: kSpacingUnit.w * 8),
        Center(
          child: Text(
            'Agregar Cliente',
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
      ],
    );

    final bottomNav = BottomAppBar(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(height: kSpacingUnit.h * 1),
            Expanded(
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: const Color(0xFF4C53A5),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: InkWell(
                  child: Text(
                    _isSaving ? 'Guardando...' : 'Agregar Cliente',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  onTap: _isSaving ? null : _onSubmit,
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
                        controller: _rutController,
                        decoration: const InputDecoration(
                          labelText: 'Rut',
                          hintText: 'Ingrese su Rut',
                          prefixIcon: Icon(Icons.key),
                          border: OutlineInputBorder(),
                        ),
                        inputFormatters: <TextInputFormatter>[
                          RutInputFormatter()
                        ],
                        validator: (value) {
                          final text = value?.trim() ?? '';
                          if (text.isEmpty) {
                            return 'El campo rut no puede estar vacío';
                          }
                          if (!RutUtils.isValid(text)) {
                            return 'RUT no válido';
                          }
                          return null;
                        },
                      ),
                      _gap(),
                      TextFormField(
                        controller: _nombreController,
                        decoration: const InputDecoration(
                          labelText: 'Nombre',
                          hintText: 'Ingrese su Nombre',
                          prefixIcon:
                              Icon(LineAwesomeIcons.identification_badge),
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'El campo Nombre no puede estar vacío';
                          }
                          return null;
                        },
                      ),
                      _gap(),
                      TextFormField(
                        controller: _emailController,
                        decoration: const InputDecoration(
                          labelText: 'Correo',
                          hintText: 'Ingrese su Correo',
                          prefixIcon: Icon(LineAwesomeIcons.at),
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'El campo Correo no puede estar vacío';
                          }
                          return null;
                        },
                      ),
                      _gap(),
                      TextFormField(
                        controller: _direccionController,
                        decoration: const InputDecoration(
                          labelText: 'Direccion',
                          hintText: 'Ingrese su direccion',
                          prefixIcon: Icon(Icons.person),
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'El campo direccion no puede estar vacío';
                          }
                          return null;
                        },
                      ),
                      _gap(),
                      TextFormField(
                        controller: _comunaController,
                        decoration: const InputDecoration(
                          labelText: 'Comuna',
                          hintText: 'Ingrese su Comuna',
                          prefixIcon: Icon(Icons.person),
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'El campo comuna no puede estar vacío';
                          }
                          return null;
                        },
                      ),
                      _gap(),
                      TextFormField(
                        controller: _ciudadController,
                        decoration: const InputDecoration(
                          labelText: 'Ciudad',
                          hintText: 'Ingrese su ciudad',
                          prefixIcon: Icon(Icons.person),
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'El campo ciudad no puede estar vacío';
                          }
                          return null;
                        },
                      ),
                      _gap(),
                      TextFormField(
                        controller: _sectorController,
                        decoration: const InputDecoration(
                          labelText: 'Sector',
                          hintText: 'Ingrese su Sector',
                          prefixIcon: Icon(Icons.person),
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'El campo sector no puede estar vacío';
                          }
                          return null;
                        },
                      ),
                      _gap(),
                      TextFormField(
                        controller: _giroController,
                        decoration: const InputDecoration(
                          labelText: 'Giro',
                          hintText: 'Ingrese el giro',
                          prefixIcon: Icon(Icons.person),
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'El campo giro no puede estar vacío';
                          }
                          return null;
                        },
                      ),
                      _gap(),
                      TextFormField(
                        controller: _fonoController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Fono',
                          hintText: 'Ingrese su Fono',
                          prefixIcon: Icon(Icons.person),
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'El campo Fono no puede estar vacío';
                          }
                          return null;
                        },
                      ),
                      _gap(),
                      TextFormField(
                        controller: _celularController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Celular',
                          hintText: 'Ingrese su Celular',
                          prefixIcon: Icon(Icons.person),
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'El campo celular no puede estar vacío';
                          }
                          return null;
                        },
                      ),
                      _gap(),
                      TextFormField(
                        controller: _contactoController,
                        decoration: const InputDecoration(
                          labelText: 'Contacto',
                          hintText: 'Ingrese el Contacto',
                          prefixIcon: Icon(Icons.person),
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'El campo Contacto no puede estar vacío';
                          }
                          return null;
                        },
                      ),
                      CheckboxListTile(
                        checkColor: kAccentColor,
                        title: const Text('Es institucion pública'),
                        value: _esInstitucionPublica,
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => _esInstitucionPublica = value);
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: kSpacingUnit.h * 3),
            ],
          ),
        ),
        bottomNavigationBar: bottomNav,
      ),
    );
  }

  Future<void> _onSubmit() async {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    final user = globals.user;
    if (user == null) {
      _mostrarAlertaError(context,
          'No se encontró información del vendedor. Inicia sesión nuevamente.');
      return;
    }

    setState(() => _isSaving = true);

    final rut = RutUtils.toDatabaseFormat(_rutController.text);
    final nuevoCliente = NuevoCliente(
      rut: rut.padLeft(10, '0'),
      nombre: _nombreController.text.toUpperCase(),
      direccion: _direccionController.text.toUpperCase(),
      comuna: _comunaController.text.toUpperCase(),
      ciudad: _ciudadController.text.toUpperCase(),
      sector: _sectorController.text.toUpperCase(),
      fono1: _fonoController.text.toUpperCase(),
      celular: _celularController.text.toUpperCase(),
      giro: _giroController.text.toUpperCase(),
      email: _emailController.text.toUpperCase(),
      contacto: _contactoController.text.toUpperCase(),
      institucionPublica: _esInstitucionPublica ? 1 : 0,
      vendedor: user.rut,
    );

    final guardado = await _guardarCliente(nuevoCliente);
    if (!mounted) return;

    setState(() => _isSaving = false);

    if (guardado) {
      _limpiarFormulario();
      _mostrarAlertaOk(context, 'Cliente guardado correctamente.');
    }
  }

  Future<bool> _guardarCliente(NuevoCliente nuevoCliente) async {
    try {
      final codComuna = await _obtenerCodigoComuna(nuevoCliente.comuna);
      final ahora = DateTime.now();
      final fecha = _formatearFecha(ahora);
      final hora = _formatearHora(ahora);

      // Guarda localmente
      final maeCliente = MaeCliente(
        rut: nuevoCliente.rut,
        nombre: nuevoCliente.nombre,
        direccion: nuevoCliente.direccion,
        codComuna: codComuna,
        comuna: nuevoCliente.comuna,
        ciudad: nuevoCliente.ciudad,
        sector: nuevoCliente.sector,
        fono1: nuevoCliente.fono1,
        fono2: '1',
        fax: '1',
        celular: nuevoCliente.celular,
        giro: nuevoCliente.giro,
        email: nuevoCliente.email,
        diasCredito: 30,
        contacto: nuevoCliente.contacto,
        contactoMail: nuevoCliente.email,
        contactoFono: nuevoCliente.celular,
        descuento: 0.0,
        bloqueo: '',
        bloqueoFacturas: '',
        tipoCliente: '01',
        plazo: '',
        cupo: 0.0,
        disponible: 1.0,
        vendedor: nuevoCliente.vendedor,
        canalCliente: '01',
        fechaUltimaModificacion: '',
        localCreacion: '00',
        fechaIngreso: fecha,
        activo: 1,
        codPrecio: '01',
        precioMenor: 0.0,
        webPassword: '',
        codigoListaPrecios: '',
        tarjetaCupo: 0.0,
        tarjetaDiaPago: 0.0,
        terceraEdad: 0,
        dctoSeccion: '',
        dctoDepto: '',
        esInstitucionPublica: nuevoCliente.institucionPublica,
      );
      await DBClientes.insert(maeCliente);

      final destino = MaeClienteDestino(
        codigo: '00',
        cliente: nuevoCliente.rut,
        descripcion: nuevoCliente.direccion,
        codComuna: codComuna,
        vigente: 1,
        nombreContacto: nuevoCliente.nombre,
        fonoContacto: nuevoCliente.celular,
        emailContacto: nuevoCliente.email,
      );
      await DBDestinos.insert(destino);

      // Envía al track
      final queryCliente =
          'INSERT INTO mae_clientes (rut,nombre,direccion,cod_comuna,comuna,ciudad,fono1,fax,celular,email,canalcliente,vendedor,tipocliente,giro,cupo,localcreacion,fechaingreso) '
          'VALUES (~${nuevoCliente.rut}~,~${nuevoCliente.nombre}~,~${nuevoCliente.direccion}~,~$codComuna~,~${nuevoCliente.comuna}~,~${nuevoCliente.ciudad}~,~${nuevoCliente.fono1}~,~1~,~${nuevoCliente.celular}~,~${nuevoCliente.email}~,~02~,~${nuevoCliente.vendedor}~,~01~,~${nuevoCliente.giro}~,~0~,~00~,~$fecha~) '
          'ON DUPLICATE KEY UPDATE rut = rut';

      final trackCliente = TrackDto(
        server: '45.236.164.172',
        basedatos: 'places_crvictoria_mantencion',
        fechaCreacion: fecha,
        horaCreacion: hora,
        prioridad: '',
        queryStr: queryCliente,
        caja: globals.user?.caja ?? '',
      );
      await DBTrack.insert(trackCliente);

      final queryDestino =
          'INSERT INTO mae_clientes_destinos (cliente,codigo,descripcion,vigente,cod_comuna) '
          'VALUES (~${nuevoCliente.rut}~,~000~,~${nuevoCliente.direccion}~,~1~,~$codComuna~) '
          'ON DUPLICATE KEY UPDATE cliente = cliente';

      final trackDestino = TrackDto(
        server: '45.236.164.172',
        basedatos: 'places_crvictoria_mantencion',
        fechaCreacion: fecha,
        horaCreacion: hora,
        prioridad: '',
        queryStr: queryDestino,
        caja: globals.user?.caja ?? '',
      );
      await DBTrack.insert(trackDestino);

      return true;
    } catch (error, stackTrace) {
      developer.log('Error al guardar cliente',
          error: error, stackTrace: stackTrace, name: 'AgregarClientePage');
      if (mounted) {
        _mostrarAlertaError(
          context,
          'Ocurrió un problema al guardar el cliente. Intenta nuevamente.',
        );
      }
      return false;
    }
  }

  Future<String> _obtenerCodigoComuna(String comuna) async {
    if (comuna.isEmpty) {
      return '000';
    }
    final sanitized =
        comuna.replaceAll(RegExp(r'[^0-9A-Za-z]'), '').toUpperCase();
    return sanitized.isEmpty
        ? '000'
        : sanitized
            .substring(0, sanitized.length >= 3 ? 3 : sanitized.length)
            .padLeft(3, '0');
  }

  void _limpiarFormulario() {
    _rutController.clear();
    _nombreController.clear();
    _direccionController.clear();
    _comunaController.clear();
    _ciudadController.clear();
    _sectorController.clear();
    _fonoController.clear();
    _celularController.clear();
    _giroController.clear();
    _emailController.clear();
    _contactoController.clear();
    setState(() => _esInstitucionPublica = false);
  }

  String _formatearFecha(DateTime dateTime) =>
      '${dateTime.year.toString().padLeft(4, '0')}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}';

  String _formatearHora(DateTime dateTime) =>
      '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}:${dateTime.second.toString().padLeft(2, '0')}';
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
            Navigator.pop(context);
          },
          child: const Text('Ok'),
        )
      ],
    ),
  );
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
          child: const Text('Ok'),
        )
      ],
    ),
  );
}
