import 'package:animated_theme_switcher/animated_theme_switcher.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// 🔁 Refactor: manejo de estado con Riverpod
final agregarClienteControllerProvider =
    StateNotifierProvider.autoDispose<AgregarClienteController, AgregarClienteState>((ref) {
  return AgregarClienteController();
});

/// Estados posibles del formulario de registro.
enum ClienteFormStatus { idle, submitting, success, failure }

/// Modelo con los datos del formulario para agregar un cliente.
class ClienteFormData {
  const ClienteFormData({
    required this.fullName,
    required this.phone,
    required this.email,
    required this.address,
    this.notes = '',
  });

  final String fullName;
  final String phone;
  final String email;
  final String address;
  final String notes;

  Map<String, String> toMap() {
    return <String, String>{
      'fullName': fullName,
      'phone': phone,
      'email': email,
      'address': address,
      'notes': notes,
    };
  }
}

/// Estado del formulario de agregar cliente.
class AgregarClienteState {
  const AgregarClienteState({
    this.status = ClienteFormStatus.idle,
    this.errorMessage,
    this.successMessage,
    this.lastSubmittedData,
  });

  final ClienteFormStatus status;
  final String? errorMessage;
  final String? successMessage;
  final ClienteFormData? lastSubmittedData;

  bool get isLoading => status == ClienteFormStatus.submitting;

  AgregarClienteState copyWith({
    ClienteFormStatus? status,
    String? errorMessage,
    String? successMessage,
    ClienteFormData? lastSubmittedData,
    bool resetMessages = false,
  }) {
    return AgregarClienteState(
      status: status ?? this.status,
      errorMessage: resetMessages ? null : (errorMessage ?? this.errorMessage),
      successMessage: resetMessages ? null : (successMessage ?? this.successMessage),
      lastSubmittedData: lastSubmittedData ?? this.lastSubmittedData,
    );
  }
}

/// Notifier encargado de coordinar el guardado del cliente.
class AgregarClienteController extends StateNotifier<AgregarClienteState> {
  AgregarClienteController() : super(const AgregarClienteState());

  Future<void> submit(ClienteFormData data) async {
    state = state.copyWith(status: ClienteFormStatus.submitting, resetMessages: true);

    try {
      // 🔁 Refactor: simulación de envío de datos aislada en el notifier
      await Future<void>.delayed(const Duration(milliseconds: 800));

      state = state.copyWith(
        status: ClienteFormStatus.success,
        successMessage: 'Cliente "${data.fullName}" registrado correctamente.',
        lastSubmittedData: data,
      );
    } catch (error) {
      state = state.copyWith(
        status: ClienteFormStatus.failure,
        errorMessage: 'Ocurrió un error inesperado al guardar el cliente.',
      );
    }
  }

  void resetStatus() {
    state = state.copyWith(status: ClienteFormStatus.idle, resetMessages: true);
  }
}

/// Formulario para agregar un nuevo cliente a la cartera del vendedor.
class AgregarClientePage extends ConsumerStatefulWidget {
  const AgregarClientePage({super.key});

  static const routeName = '/agregar-cliente';

  @override
  ConsumerState<AgregarClientePage> createState() => _AgregarClientePageState();
}

class _AgregarClientePageState extends ConsumerState<AgregarClientePage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _emailController;
  late final TextEditingController _addressController;
  late final TextEditingController _notesController;

  late final FocusNode _nameFocusNode;
  late final FocusNode _phoneFocusNode;
  late final FocusNode _emailFocusNode;
  late final FocusNode _addressFocusNode;
  late final FocusNode _notesFocusNode;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _phoneController = TextEditingController();
    _emailController = TextEditingController();
    _addressController = TextEditingController();
    _notesController = TextEditingController();

    _nameFocusNode = FocusNode();
    _phoneFocusNode = FocusNode();
    _emailFocusNode = FocusNode();
    _addressFocusNode = FocusNode();
    _notesFocusNode = FocusNode();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _notesController.dispose();

    _nameFocusNode.dispose();
    _phoneFocusNode.dispose();
    _emailFocusNode.dispose();
    _addressFocusNode.dispose();
    _notesFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(agregarClienteControllerProvider);

    ref.listen<AgregarClienteState>(agregarClienteControllerProvider, (previous, next) {
      if (next.status == ClienteFormStatus.success && next.successMessage != null) {
        _formKey.currentState?.reset();
        _clearControllers();
        _showSnackBar(context, next.successMessage!, isError: false);
        ref.read(agregarClienteControllerProvider.notifier).resetStatus();
      } else if (next.status == ClienteFormStatus.failure && next.errorMessage != null) {
        _showSnackBar(context, next.errorMessage!, isError: true);
        ref.read(agregarClienteControllerProvider.notifier).resetStatus();
      }
    });

    final theme = Theme.of(context);

    return ThemeSwitchingArea(
      child: Scaffold(
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
                      'Formulario de registro de clientes',
                      style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Completa los datos básicos del cliente y su información de contacto.',
                      style: theme.textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 24),
                    _buildNameField(),
                    const SizedBox(height: 16),
                    _buildPhoneField(),
                    const SizedBox(height: 16),
                    _buildEmailField(),
                    const SizedBox(height: 16),
                    _buildAddressField(),
                    const SizedBox(height: 16),
                    _buildNotesField(),
                    const SizedBox(height: 32),
                    _buildSubmitButton(state),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  TextFormField _buildNameField() {
    return TextFormField(
      controller: _nameController,
      focusNode: _nameFocusNode,
      textInputAction: TextInputAction.next,
      decoration: const InputDecoration(
        labelText: 'Nombre completo',
        hintText: 'Ej. Juan Pérez',
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Ingresa el nombre del cliente';
        }
        if (value.trim().length < 3) {
          return 'El nombre debe tener al menos 3 caracteres';
        }
        return null;
      },
      onFieldSubmitted: (_) => _requestFocus(_phoneFocusNode),
    );
  }

  TextFormField _buildPhoneField() {
    return TextFormField(
      controller: _phoneController,
      focusNode: _phoneFocusNode,
      textInputAction: TextInputAction.next,
      keyboardType: TextInputType.phone,
      decoration: const InputDecoration(
        labelText: 'Teléfono de contacto',
        hintText: '+56 9 1234 5678',
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Ingresa el teléfono del cliente';
        }
        final digitsOnly = value.replaceAll(RegExp('[^0-9+]'), '');
        if (digitsOnly.length < 8) {
          return 'Ingresa un número de teléfono válido';
        }
        return null;
      },
      onFieldSubmitted: (_) => _requestFocus(_emailFocusNode),
    );
  }

  TextFormField _buildEmailField() {
    return TextFormField(
      controller: _emailController,
      focusNode: _emailFocusNode,
      textInputAction: TextInputAction.next,
      keyboardType: TextInputType.emailAddress,
      decoration: const InputDecoration(
        labelText: 'Correo electrónico',
        hintText: 'correo@empresa.cl',
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Ingresa el correo del cliente';
        }
        final trimmed = value.trim();
        if (!trimmed.contains('@') || !trimmed.contains('.')) {
          return 'Ingresa un correo electrónico válido';
        }
        return null;
      },
      onFieldSubmitted: (_) => _requestFocus(_addressFocusNode),
    );
  }

  TextFormField _buildAddressField() {
    return TextFormField(
      controller: _addressController,
      focusNode: _addressFocusNode,
      textInputAction: TextInputAction.next,
      decoration: const InputDecoration(
        labelText: 'Dirección',
        hintText: 'Calle, número y ciudad',
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Ingresa la dirección del cliente';
        }
        return null;
      },
      onFieldSubmitted: (_) => _requestFocus(_notesFocusNode),
    );
  }

  TextFormField _buildNotesField() {
    return TextFormField(
      controller: _notesController,
      focusNode: _notesFocusNode,
      textInputAction: TextInputAction.done,
      decoration: const InputDecoration(
        labelText: 'Notas u observaciones',
        hintText: 'Información adicional del cliente (opcional)',
      ),
      maxLines: 3,
      onFieldSubmitted: (_) => _submitForm(),
    );
  }

  Widget _buildSubmitButton(AgregarClienteState state) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton.icon(
        onPressed: state.isLoading ? null : _submitForm,
        icon: AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          child: state.isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.person_add_alt_1_rounded),
        ),
        label: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Text(state.isLoading ? 'Guardando...' : 'Registrar cliente'),
        ),
      ),
    );
  }

  void _submitForm() {
    FocusScope.of(context).unfocus();
    final form = _formKey.currentState;
    if (form == null) {
      return;
    }
    if (!form.validate()) {
      return;
    }

    final formData = ClienteFormData(
      fullName: _nameController.text.trim(),
      phone: _phoneController.text.trim(),
      email: _emailController.text.trim(),
      address: _addressController.text.trim(),
      notes: _notesController.text.trim(),
    );

    ref.read(agregarClienteControllerProvider.notifier).submit(formData);
  }

  void _requestFocus(FocusNode node) {
    FocusScope.of(context).requestFocus(node);
  }

  void _clearControllers() {
    _nameController.clear();
    _phoneController.clear();
    _emailController.clear();
    _addressController.clear();
    _notesController.clear();
  }

  void _showSnackBar(BuildContext context, String message, {required bool isError}) {
    final messenger = ScaffoldMessenger.of(context);
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: isError ? Colors.redAccent : Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
  }
}
