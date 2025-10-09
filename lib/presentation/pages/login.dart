import 'package:aplicacion_ventas/application/providers/login_provider.dart';
import 'package:aplicacion_ventas/core/utils/screen_utils.dart';
import 'package:aplicacion_ventas/presentation/pages/home_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
  bool _rememberMe = false;

  @override
  void dispose() {
    _rutController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<LoginState>(loginControllerProvider, (previous, next) {
      if (previous?.user != next.user && next.user != null) {
        Navigator.of(context).pushReplacementNamed(HomePage.routeName);
      }

      if (next.errorMessage != null && next.errorMessage!.isNotEmpty && next.errorMessage != previous?.errorMessage) {
        _showSnackBar(context, next.errorMessage!, isError: true);
      }

      if (next.infoMessage != null && next.infoMessage!.isNotEmpty && next.infoMessage != previous?.infoMessage) {
        _showSnackBar(context, next.infoMessage!);
      }
    });

    final state = ref.watch(loginControllerProvider);
    final theme = Theme.of(context);

    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 700;
          return Center(
            child: SingleChildScrollView(
              padding: context.horizontalPadding(isWide ? 0.18 : 0.08).copyWith(top: 48, bottom: 48),
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: isWide ? 520 : 400),
                child: Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Column(
                            children: [
                              Image.asset('assets/img/logo-p.png', height: isWide ? 120 : 96),
                              const SizedBox(height: 16),
                              Text('Bienvenido', style: theme.textTheme.headlineSmall),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),
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
                                decoration: const InputDecoration(
                                  labelText: 'RUT',
                                  prefixIcon: Icon(Icons.badge_outlined),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'El RUT es obligatorio';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _passwordController,
                                obscureText: true,
                                decoration: const InputDecoration(
                                  labelText: 'Contraseña',
                                  prefixIcon: Icon(Icons.lock_outline),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'La contraseña es obligatoria';
                                  }
                                  if (value.length < 6) {
                                    return 'Debe contener al menos 6 caracteres';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 12),
                              CheckboxListTile(
                                value: _rememberMe,
                                onChanged: (value) => setState(() => _rememberMe = value ?? false),
                                contentPadding: EdgeInsets.zero,
                                title: const Text('Recordarme'),
                              ),
                              const SizedBox(height: 24),
                              Row(
                                children: [
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      onPressed: state.isDownloading
                                          ? null
                                          : () => _handleDownload(ref),
                                      icon: state.isDownloading
                                          ? const SizedBox(
                                              width: 18,
                                              height: 18,
                                              child: CircularProgressIndicator(strokeWidth: 2),
                                            )
                                          : const Icon(Icons.cloud_download_outlined),
                                      label: const Text('Descargar Data'),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      onPressed: state.isSyncing
                                          ? null
                                          : () => _handleSync(ref),
                                      icon: state.isSyncing
                                          ? const SizedBox(
                                              width: 18,
                                              height: 18,
                                              child: CircularProgressIndicator(strokeWidth: 2),
                                            )
                                          : const Icon(Icons.cloud_sync_outlined),
                                      label: const Text('Sincronizar Data'),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 24),
                              SizedBox(
                                width: double.infinity,
                                child: FilledButton(
                                  onPressed: state.isLoggingIn
                                      ? null
                                      : () {
                                          if (_formKey.currentState?.validate() ?? false) {
                                            ref.read(loginControllerProvider.notifier).login(
                                                  _rutController.text.trim(),
                                                  _passwordController.text.trim(),
                                                );
                                          }
                                        },
                                  child: state.isLoggingIn
                                      ? const SizedBox(
                                          width: 24,
                                          height: 24,
                                          child: CircularProgressIndicator(strokeWidth: 2),
                                        )
                                      : const Text('Iniciar sesión'),
                                ),
                              ),
                              if (state.errorMessage != null && state.errorMessage!.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 16),
                                  child: Text(
                                    state.errorMessage!,
                                    style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.error),
                                    textAlign: TextAlign.center,
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

  void _handleDownload(WidgetRef ref) {
    final rut = _rutController.text.trim();
    if (rut.isEmpty) {
      _showSnackBar(context, 'Ingresa tu RUT para descargar datos', isError: true);
      return;
    }
    ref.read(loginControllerProvider.notifier).downloadData(rut);
  }

  void _handleSync(WidgetRef ref) {
    final rut = _rutController.text.trim();
    if (rut.isEmpty) {
      _showSnackBar(context, 'Ingresa tu RUT para sincronizar', isError: true);
      return;
    }
    ref.read(loginControllerProvider.notifier).synchronizeSales(rut);
  }

  void _showSnackBar(BuildContext context, String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Theme.of(context).colorScheme.error : null,
      ),
    );
  }
}
