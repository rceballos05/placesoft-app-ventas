import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:aplicacion_ventas/application/providers/login_provider.dart';
import 'package:aplicacion_ventas/core/utils/screen_utils.dart';
import 'package:aplicacion_ventas/presentation/pages/home_page.dart';
import 'package:aplicacion_ventas/presentation/widgets/numeric_keyboard.dart';
import 'package:aplicacion_ventas/utils/rut_utils.dart';

/// Login screen that authenticates the user and triggers sync tasks.
class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  static const routeName = '/login';

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _rutController = TextEditingController();
  final _passwordController = TextEditingController();
  final _rutFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  bool _showRutKeyboard = false;
  bool _rememberMe = false;
  bool _downloadAfterLogin = false;
  bool _syncAfterLogin = false;
  bool _postLoginFlowRunning = false;
  bool _suppressDownloadAlerts = false;
  bool _suppressSyncAlerts = false;

  @override
  void initState() {
    super.initState();
    _rutFocusNode.addListener(_handleRutFocusChange);
  }

  @override
  void dispose() {
    _rutFocusNode.removeListener(_handleRutFocusChange);
    _rutController.dispose();
    _passwordController.dispose();
    _rutFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<LoginState>(loginControllerProvider, (previous, next) {
      if (previous?.isLoggingIn == true && next.isLoggingIn == false) {
        if (next.user != null) {
          Future<void>.microtask(() => _handleSuccessfulLogin(next));
        } else if (next.errorMessage != null && next.errorMessage!.isNotEmpty) {
          Future<void>.microtask(
              () => _mostrarAlertaErrorLogin(next.errorMessage!));
        }
      }

      if (!_suppressDownloadAlerts &&
          previous?.isDownloading == true &&
          next.isDownloading == false) {
        if (next.errorMessage != null && next.errorMessage!.isNotEmpty) {
          Future<void>.microtask(
              () => _mostrarAlertaErrorEnvio(next.errorMessage!));
        } else if (next.infoMessage != null && next.infoMessage!.isNotEmpty) {
          Future<void>.microtask(() => _mostrarAlertaOk(next.infoMessage!));
        }
      }

      if (!_suppressSyncAlerts &&
          previous?.isSyncing == true &&
          next.isSyncing == false) {
        if (next.errorMessage != null && next.errorMessage!.isNotEmpty) {
          Future<void>.microtask(
              () => _mostrarAlertaErrorEnvio(next.errorMessage!));
        } else if (next.infoMessage != null && next.infoMessage!.isNotEmpty) {
          Future<void>.microtask(() => _mostrarAlertaOk(next.infoMessage!));
        }
      }
    });

    final state = ref.watch(loginControllerProvider);
    final theme = Theme.of(context);
    final isBusy = state.isLoggingIn || state.isDownloading || state.isSyncing;

    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 700;
          return Center(
            child: SingleChildScrollView(
              padding: context
                  .horizontalPadding(isWide ? 0.18 : 0.08)
                  .copyWith(top: 48, bottom: 48),
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: isWide ? 520 : 420),
                child: Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24)),
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Column(
                            children: [
                              Image.asset('assets/img/logo-p.png',
                                  height: isWide ? 120 : 96),
                              const SizedBox(height: 16),
                              Text('Bienvenido',
                                  style: theme.textTheme.headlineSmall),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        if (isBusy) const LinearProgressIndicator(minHeight: 3),
                        if (isBusy) const SizedBox(height: 16),
                        if (state.isOffline)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: Chip(
                              avatar: const Icon(Icons.wifi_off, size: 18),
                              label: const Text('Operando en modo offline'),
                            ),
                          ),
                        Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              TextFormField(
                                controller: _rutController,
                                focusNode: _rutFocusNode,
                                keyboardType: TextInputType.none,
                                readOnly: true,
                                showCursor: true,
                                decoration: const InputDecoration(
                                  labelText: 'RUT',
                                  hintText: 'Ej: 11.111.111-1',
                                  prefixIcon: Icon(Icons.person),
                                  border: OutlineInputBorder(),
                                ),
                                inputFormatters: [RutInputFormatter()],
                                onTap: () => _onFieldTapped(_rutFocusNode),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Ingrese su RUT';
                                  }
                                  if (!RutUtils.isValid(value)) {
                                    return 'El RUT ingresado no es válido.';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _passwordController,
                                obscureText: true,
                                focusNode: _passwordFocusNode,
                                keyboardType: TextInputType.visiblePassword,
                                textInputAction: TextInputAction.done,
                                decoration: const InputDecoration(
                                  labelText: 'Contraseña',
                                  prefixIcon: Icon(Icons.lock_outline),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'La contraseña es obligatoria';
                                  }
                                  if (value.length < 3) {
                                    return 'Debe contener al menos 3 caracteres';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 12),
                              CheckboxListTile(
                                value: _rememberMe,
                                onChanged: (value) => setState(
                                    () => _rememberMe = value ?? false),
                                contentPadding: EdgeInsets.zero,
                                title: const Text('Recordarme'),
                              ),
                              const Divider(height: 32),
                              AnimatedSwitcher(
                                duration: const Duration(milliseconds: 250),
                                transitionBuilder: (Widget child,
                                    Animation<double> animation) {
                                  return SizeTransition(
                                    sizeFactor: animation,
                                    axisAlignment: -1,
                                    child: child,
                                  );
                                },
                                child: _showRutKeyboard
                                    ? NumericKeyboard(
                                        key: const ValueKey('rut_keyboard'),
                                        onKeyTap: _onKeyboardKeyTap,
                                        onBackspace: _onKeyboardBackspace,
                                      )
                                    : const SizedBox.shrink(
                                        key: ValueKey('empty_keyboard'),
                                      ),
                              ),
                              CheckboxListTile(
                                value: _downloadAfterLogin,
                                onChanged: state.isLoggingIn
                                    ? null
                                    : (value) => setState(() =>
                                        _downloadAfterLogin = value ?? false),
                                contentPadding: EdgeInsets.zero,
                                title: const Text('Descargar Data'),
                                subtitle: const Text(
                                    'Obtiene la información actualizada antes de ingresar.'),
                              ),
                              CheckboxListTile(
                                value: _syncAfterLogin,
                                onChanged: state.isLoggingIn
                                    ? null
                                    : (value) => setState(
                                        () => _syncAfterLogin = value ?? false),
                                contentPadding: EdgeInsets.zero,
                                title: const Text('Sincronizar Data'),
                                subtitle: const Text(
                                    'Envía las ventas pendientes al iniciar sesión.'),
                              ),
                              const SizedBox(height: 24),
                              SizedBox(
                                width: double.infinity,
                                child: FilledButton(
                                  onPressed: state.isLoggingIn
                                      ? null
                                      : _onLoginPressed,
                                  child: state.isLoggingIn
                                      ? const SizedBox(
                                          width: 24,
                                          height: 24,
                                          child: CircularProgressIndicator(
                                              strokeWidth: 2),
                                        )
                                      : const Text('Iniciar sesión'),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _onLoginPressed() {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }
    FocusScope.of(context).unfocus();
    final rut = RutUtils.toDatabaseFormat(_rutController.text);
    final password = _passwordController.text.trim();
    ref.read(loginControllerProvider.notifier).login(rut, password);
  }

  void _onFieldTapped(FocusNode focusNode) {
    FocusScope.of(context).requestFocus(focusNode);
    final controller = _controllerForFocus(focusNode);
    if (controller != null) {
      controller.selection =
          TextSelection.collapsed(offset: controller.text.length);
    }
  }

  void _onKeyboardKeyTap(String key) {
    final controller = _activeController;
    if (controller == null) {
      return;
    }
    _insertText(controller, key.toUpperCase());
  }

  void _onKeyboardBackspace() {
    final controller = _activeController;
    if (controller == null) {
      return;
    }
    _deleteText(controller);
  }

  void _handleRutFocusChange() {
    setState(() {
      _showRutKeyboard = _rutFocusNode.hasFocus;
    });
  }

  TextEditingController? get _activeController {
    if (_rutFocusNode.hasFocus) {
      return _rutController;
    }
    if (_passwordFocusNode.hasFocus) {
      return _passwordController;
    }
    return null;
  }

  TextEditingController? _controllerForFocus(FocusNode node) {
    if (node == _rutFocusNode) {
      return _rutController;
    }
    if (node == _passwordFocusNode) {
      return _passwordController;
    }
    return null;
  }

  void _insertText(TextEditingController controller, String text) {
    final oldValue = controller.value;
    final selection = oldValue.selection;
    final start = selection.isValid ? selection.start : oldValue.text.length;
    final end = selection.isValid ? selection.end : oldValue.text.length;
    final newText = oldValue.text.replaceRange(start, end, text);
    var newValue = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: start + text.length),
    );
    if (controller == _rutController) {
      newValue = RutInputFormatter().formatEditUpdate(oldValue, newValue);
    }
    controller.value = newValue;
  }

  void _deleteText(TextEditingController controller) {
    final oldValue = controller.value;
    final selection = oldValue.selection;
    if (oldValue.text.isEmpty) {
      return;
    }

    if (selection.isValid && !selection.isCollapsed) {
      _replaceRange(controller, selection.start, selection.end, '');
      return;
    }

    final caretIndex =
        selection.isValid ? selection.start : oldValue.text.length;
    if (caretIndex == 0) {
      return;
    }
    _replaceRange(controller, caretIndex - 1, caretIndex, '');
  }

  void _replaceRange(TextEditingController controller, int start, int end,
      String replacement) {
    final oldValue = controller.value;
    final newText = oldValue.text.replaceRange(start, end, replacement);
    var newValue = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: start + replacement.length),
    );
    if (controller == _rutController) {
      newValue = RutInputFormatter().formatEditUpdate(oldValue, newValue);
    }
    controller.value = newValue;
  }

  Future<void> _handleSuccessfulLogin(LoginState state) async {
    if (!mounted || _postLoginFlowRunning) {
      return;
    }
    _postLoginFlowRunning = true;
    final rut = RutUtils.toDatabaseFormat(_rutController.text);
    final controller = ref.read(loginControllerProvider.notifier);
    final loginMessage =
        state.infoMessage != null && state.infoMessage!.isNotEmpty
            ? state.infoMessage!
            : state.isOffline
                ? 'Sesión iniciada en modo offline'
                : 'Sesión iniciada correctamente';

    var hasErrors = false;

    try {
      if (_downloadAfterLogin) {
        _suppressDownloadAlerts = true;
        try {
          final success = await controller.downloadData(rut);
          final latestState = ref.read(loginControllerProvider);
          if (!success &&
              latestState.errorMessage != null &&
              latestState.errorMessage!.isNotEmpty) {
            hasErrors = true;
            await _mostrarAlertaErrorEnvio(latestState.errorMessage!);
          }
        } finally {
          _suppressDownloadAlerts = false;
        }
      }

      if (_syncAfterLogin) {
        _suppressSyncAlerts = true;
        try {
          final success = await controller.synchronizeSales(rut);
          final latestState = ref.read(loginControllerProvider);
          if (!success &&
              latestState.errorMessage != null &&
              latestState.errorMessage!.isNotEmpty) {
            hasErrors = true;
            await _mostrarAlertaErrorEnvio(latestState.errorMessage!);
          }
        } finally {
          _suppressSyncAlerts = false;
        }
      }

      if (loginMessage.isNotEmpty) {
        await _mostrarAlertaOk(loginMessage);
      }

      if (!hasErrors && _downloadAfterLogin) {
        final latestState = ref.read(loginControllerProvider);
        final infoMessage = latestState.infoMessage;
        if (infoMessage != null &&
            infoMessage.isNotEmpty &&
            infoMessage != loginMessage) {
          await _mostrarAlertaOk(infoMessage);
        }
      }
    } finally {
      _postLoginFlowRunning = false;
      if (mounted) {
        Navigator.of(context).pushReplacementNamed(HomePage.routeName);
      }
    }
  }

  Future<void> _mostrarAlertaOk(String message) async {
    if (!mounted || message.isEmpty) {
      return;
    }
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Información'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Aceptar'),
          ),
        ],
      ),
    );
  }

  Future<void> _mostrarAlertaErrorLogin(String message) async {
    if (!mounted || message.isEmpty) {
      return;
    }
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error al iniciar sesión'),
        content: Text(message),
        icon: const Icon(Icons.error_outline, color: Colors.redAccent),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Entendido'),
          ),
        ],
      ),
    );
  }

  Future<void> _mostrarAlertaErrorEnvio(String message) async {
    if (!mounted || message.isEmpty) {
      return;
    }
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Proceso incompleto'),
        content: Text(message),
        icon: const Icon(Icons.warning_amber, color: Colors.orange),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Aceptar'),
          ),
        ],
      ),
    );
  }
}
