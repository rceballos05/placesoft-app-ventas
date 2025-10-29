import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import 'package:aplicacion_ventas/application/providers/login_provider.dart';
import 'package:aplicacion_ventas/utils/rut_utils.dart';

// Manejo de estado con Riverpod
final agregarClienteControllerProvider =
    StateNotifierProvider.autoDispose<AgregarClienteController, AgregarClienteState>((ref) {
  return AgregarClienteController(ref);
});

/// Estados posibles del formulario de agregar cliente.
enum AgregarClienteStatus { idle, saving, success, error }

/// Modelo con los datos principales del formulario.
class ClienteFormData {
  ClienteFormData({
    required this.rut,
    required this.nombre,
    required this.direccion,
    required this.comuna,
    required this.ciudad,
    required this.sector,
    required this.giro,
    required this.fono1,
    required this.celular,
    required this.email,
    required this.contacto,
    required this.esInstitucionPublica,
  });

  final String rut;
  final String nombre;
  final String direccion;
  final String comuna;
  final String ciudad;
  final String sector;
  final String giro;
  final String fono1;
  final String celular;
  final String email;
  final String contacto;
  final bool esInstitucionPublica;
}

/// Estado consumido por la UI.
class AgregarClienteState {
  const AgregarClienteState({
    this.status = AgregarClienteStatus.idle,
    this.errorMessage,
    this.successMessage,
  });

  final AgregarClienteStatus status;
  final String? errorMessage;
  final String? successMessage;

  bool get isSaving => status == AgregarClienteStatus.saving;

  AgregarClienteState copyWith({
    AgregarClienteStatus? status,
    String? errorMessage,
    String? successMessage,
    bool clearMessages = false,
  }) {
    return AgregarClienteState(
      status: status ?? this.status,
      errorMessage: clearMessages ? errorMessage : (errorMessage ?? this.errorMessage),
      successMessage: clearMessages ? successMessage : (successMessage ?? this.successMessage),
    );
  }
}

class _ClienteAlreadyExistsException implements Exception {}

/// Notifier responsable de validar e insertar el cliente en la base local.
class AgregarClienteController extends StateNotifier<AgregarClienteState> {
  AgregarClienteController(this._ref) : super(const AgregarClienteState());

  final Ref _ref;

  Future<void> guardarCliente(ClienteFormData data) async {
    state = state.copyWith(status: AgregarClienteStatus.saving, clearMessages: true);
    final loginState = _ref.read(loginControllerProvider);
    final vendedor = loginState.user?.rut ?? '';
    final localCreacion = loginState.user?.caja ?? '';
    try {
      final dbPath = await _resolveClientesDbPath();
      final database = await openDatabase(dbPath);
      try {
        await database.transaction((txn) async {
          final rutDb = RutUtils.toDatabaseFormat(data.rut);
          final existing = await txn.query(
            'mae_clientes',
            columns: const ['rut'],
            where: 'rut = ?',
            whereArgs: [rutDb],
            limit: 1,
          );
          if (existing.isNotEmpty) {
            throw _ClienteAlreadyExistsException();
          }

          final nowIso = DateTime.now().toIso8601String();
          // Inserción local en mae_clientes
          await txn.insert(
            'mae_clientes',
            <String, Object?>{
              'rut': rutDb,
              'nombre': data.nombre.trim(),
              'direccion': data.direccion.trim(),
              'cod_comuna': '',
              'comuna': data.comuna.trim(),
              'ciudad': data.ciudad.trim(),
              'sector': data.sector.trim(),
              'fono1': data.fono1.trim(),
              'fono2': '',
              'fax': '',
              'celular': data.celular.trim(),
              'giro': data.giro.trim(),
              'email': data.email.trim(),
              'diascredito': 0,
              'contacto': data.contacto.trim(),
              'contacto_mail': '',
              'contacto_fono': data.celular.trim(),
              'descuento': 0.0,
              'bloqueo': 'N',
              'bloqueo_facturas': 'N',
              'tipocliente': '',
              'plazo': '',
              'cupo': 0.0,
              'disponible': 0,
              'vendedor': vendedor,
              'canalcliente': '',
              'fechaultimamodificacion': nowIso,
              'localcreacion': localCreacion,
              'fechaingreso': nowIso,
              'activo': 1,
              'cod_precio': '',
              'precio_menor': 0.0,
              'web_password': '',
              'codigo_lista_precios': '',
              'tarjeta_cupo': 0.0,
              'tarjeta_dia_pago': 0.0,
              'tercera_edad': 0,
              'dcto_seccion': '',
              'dcto_depto': '',
              'es_institucion_publica': data.esInstitucionPublica ? 1 : 0,
              'enviado': 0,
              'intentos': 0,
            },
            conflictAlgorithm: ConflictAlgorithm.abort,
          );

          // Inserción local en mae_clientes_destinos
          await txn.insert(
            'mae_clientes_destinos',
            <String, Object?>{
              'cliente': rutDb,
              'codigo': '${rutDb}_PRINCIPAL',
              'descripcion': 'Dirección principal',
              'vigente': 1,
              'cod_comuna': '',
              'nombre_contacto': data.contacto.trim(),
              'fono_contacto': data.celular.trim(),
              'email_contacto': data.email.trim(),
              'enviado': 0,
              'intentos': 0,
            },
          );
        });
      } finally {
        await database.close();
      }

      state = state.copyWith(
        status: AgregarClienteStatus.success,
        successMessage: 'Cliente guardado localmente.',
        errorMessage: null,
        clearMessages: true,
      );
    } on _ClienteAlreadyExistsException {
      state = state.copyWith(
        status: AgregarClienteStatus.error,
        errorMessage: 'Ya existe un cliente con el RUT ingresado.',
        successMessage: null,
        clearMessages: true,
      );
    } on DatabaseException catch (error) {
      final details = error.toString().trim();
      final suffix = details.isEmpty ? '' : ' ' + details;
      state = state.copyWith(
        status: AgregarClienteStatus.error,
        errorMessage: 'No fue posible guardar el cliente localmente.' + suffix,
        successMessage: null,
        clearMessages: true,
      );
    } catch (_) {
      state = state.copyWith(
        status: AgregarClienteStatus.error,
        errorMessage: 'Ocurrió un error inesperado al guardar el cliente.',
        successMessage: null,
        clearMessages: true,
      );
    }
  }

  Future<String> _resolveClientesDbPath() async {
    final loginState = _ref.read(loginControllerProvider);
    final prefix = (loginState.user?.prefijo ?? '').trim().toLowerCase();
    final basePath = await getDatabasesPath();

    final candidates = <String>[];
    final cached = loginState.databasePath;
    if (cached != null && cached.isNotEmpty) {
      candidates.add(cached);
      final cachedDirectory = File(cached).parent.path;
      candidates.add(p.join(cachedDirectory, 'clientes.db'));
    }
    if (prefix.isNotEmpty) {
      candidates.add(p.join(basePath, prefix, 'clientes.db'));
    }
    candidates.add(p.join(basePath, 'clientes.db'));

    final visited = <String>{};
    for (final path in candidates) {
      if (path.isEmpty || !visited.add(path)) continue;
      final file = File(path);
      if (await file.exists()) {
        return path;
      }
    }

    throw Exception('Base de datos de clientes no disponible localmente.');
  }
}

/// Página con el formulario de registro local de clientes.
class AgregarClientePage extends ConsumerStatefulWidget {
  const AgregarClientePage({super.key});

  static const routeName = '/agregar-cliente';

  @override
  ConsumerState<AgregarClientePage> createState() => _AgregarClientePageState();
}

class _AgregarClientePageState extends ConsumerState<AgregarClientePage> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _rutController;
  late final TextEditingController _nombreController;
  late final TextEditingController _direccionController;
  late final TextEditingController _comunaController;
  late final TextEditingController _ciudadController;
  late final TextEditingController _sectorController;
  late final TextEditingController _giroController;
  late final TextEditingController _fonoController;
  late final TextEditingController _celularController;
  late final TextEditingController _emailController;
  late final TextEditingController _contactoController;

  bool _esInstitucionPublica = false;

  @override
  void initState() {
    super.initState();
    _rutController = TextEditingController();
    _nombreController = TextEditingController();
    _direccionController = TextEditingController();
    _comunaController = TextEditingController();
    _ciudadController = TextEditingController();
    _sectorController = TextEditingController();
    _giroController = TextEditingController();
    _fonoController = TextEditingController();
    _celularController = TextEditingController();
    _emailController = TextEditingController();
    _contactoController = TextEditingController();
  }

  @override
  void dispose() {
    _rutController.dispose();
    _nombreController.dispose();
    _direccionController.dispose();
    _comunaController.dispose();
    _ciudadController.dispose();
    _sectorController.dispose();
    _giroController.dispose();
    _fonoController.dispose();
    _celularController.dispose();
    _emailController.dispose();
    _contactoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = ref.watch(agregarClienteControllerProvider);

    ref.listen<AgregarClienteState>(agregarClienteControllerProvider, (previous, next) {
      if (!mounted) return;
      final messenger = ScaffoldMessenger.of(context);
      if (next.status == AgregarClienteStatus.success && next.successMessage != null) {
        _formKey.currentState?.reset();
        _clearForm();
        messenger.showSnackBar(
          SnackBar(content: Text(next.successMessage!)),
        );
      } else if (next.status == AgregarClienteStatus.error && next.errorMessage != null) {
        messenger.showSnackBar(
          SnackBar(content: Text(next.errorMessage!), backgroundColor: theme.colorScheme.error),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Agregar cliente'),
      ),
      body: SafeArea(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Form(
              key: _formKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Registro de cliente local',
                    style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Completa los datos obligatorios para guardar el cliente en tu dispositivo.',
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 24),
                  _buildRutField(),
                  const SizedBox(height: 16),
                  _buildRequiredField(
                    controller: _nombreController,
                    label: 'Nombre o razón social',
                    keyboardType: TextInputType.text,
                  ),
                  const SizedBox(height: 16),
                  _buildRequiredField(
                    controller: _direccionController,
                    label: 'Dirección',
                    keyboardType: TextInputType.streetAddress,
                  ),
                  const SizedBox(height: 16),
                  _buildRequiredField(
                    controller: _comunaController,
                    label: 'Comuna',
                    keyboardType: TextInputType.text,
                  ),
                  const SizedBox(height: 16),
                  _buildRequiredField(
                    controller: _ciudadController,
                    label: 'Ciudad',
                    keyboardType: TextInputType.text,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _sectorController,
                    label: 'Sector',
                  ),
                  const SizedBox(height: 16),
                  _buildRequiredField(
                    controller: _giroController,
                    label: 'Giro',
                    keyboardType: TextInputType.text,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _fonoController,
                    label: 'Fono 1',
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 16),
                  _buildRequiredField(
                    controller: _celularController,
                    label: 'Celular',
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 16),
                  _buildEmailField(),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _contactoController,
                    label: 'Nombre del contacto',
                  ),
                  const SizedBox(height: 12),
                  CheckboxListTile(
                    value: _esInstitucionPublica,
                    onChanged: state.isSaving
                        ? null
                        : (value) {
                            if (value == null) return;
                            setState(() => _esInstitucionPublica = value);
                          },
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Es institución pública'),
                    controlAffinity: ListTileControlAffinity.leading,
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: state.isSaving ? null : _onSubmit,
                      icon: state.isSaving
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : const Icon(Icons.save_outlined),
                      label: Text(state.isSaving ? 'Guardando...' : 'Guardar cliente'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  TextFormField _buildRutField() {
    return TextFormField(
      controller: _rutController,
      decoration: const InputDecoration(
        labelText: 'RUT',
        hintText: '12.345.678-5',
      ),
      keyboardType: TextInputType.text,
      textCapitalization: TextCapitalization.characters,
      inputFormatters: <TextInputFormatter>[RutInputFormatter()],
      validator: (value) {
        final text = value?.trim() ?? '';
        if (text.isEmpty) {
          return 'El RUT es obligatorio';
        }
        if (!RutUtils.isValid(text)) {
          return 'El RUT ingresado no es válido';
        }
        return null;
      },
    );
  }

  TextFormField _buildRequiredField({
    required TextEditingController controller,
    required String label,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(labelText: label),
      keyboardType: keyboardType,
      validator: (value) {
        final text = value?.trim() ?? '';
        if (text.isEmpty) {
          return 'Este campo es obligatorio';
        }
        return null;
      },
    );
  }

  TextFormField _buildTextField({
    required TextEditingController controller,
    required String label,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(labelText: label),
      keyboardType: keyboardType,
    );
  }

  TextFormField _buildEmailField() {
    return TextFormField(
      controller: _emailController,
      decoration: const InputDecoration(labelText: 'Correo electrónico'),
      keyboardType: TextInputType.emailAddress,
      validator: (value) {
        final text = value?.trim() ?? '';
        if (text.isEmpty) {
          return null;
        }
        if (!text.contains('@') || !text.contains('.')) {
          return 'Ingresa un correo válido';
        }
        return null;
      },
    );
  }

  void _onSubmit() {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    final data = ClienteFormData(
      rut: _rutController.text,
      nombre: _nombreController.text,
      direccion: _direccionController.text,
      comuna: _comunaController.text,
      ciudad: _ciudadController.text,
      sector: _sectorController.text,
      giro: _giroController.text,
      fono1: _fonoController.text,
      celular: _celularController.text,
      email: _emailController.text,
      contacto: _contactoController.text,
      esInstitucionPublica: _esInstitucionPublica,
    );

    ref.read(agregarClienteControllerProvider.notifier).guardarCliente(data);
  }

  void _clearForm() {
    _rutController.clear();
    _nombreController.clear();
    _direccionController.clear();
    _comunaController.clear();
    _ciudadController.clear();
    _sectorController.clear();
    _giroController.clear();
    _fonoController.clear();
    _celularController.clear();
    _emailController.clear();
    _contactoController.clear();
    setState(() {
      _esInstitucionPublica = false;
    });
  }
}
