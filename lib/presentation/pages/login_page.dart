import 'package:aplicacion_ventas/application/providers/auth_provider.dart';
import 'package:aplicacion_ventas/application/providers/sync_provider.dart';
import 'package:aplicacion_ventas/core/utils/screen_utils.dart';
import 'package:aplicacion_ventas/presentation/pages/home_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Login screen that authenticates the user and triggers initial sync tasks.
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
    ref.listen(authControllerProvider, (previous, next) {
      if (previous?.user != next.user && next.user != null) {
        ref.read(syncServiceProvider).downloadInitialData().then((result) {
          result.fold(
            failure: (error) => ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(error.message)),
            ),
            success: (_) {},
          );
        });
        Navigator.of(context).pushReplacementNamed(HomePage.routeName);
      } else if (next.errorMessage != null && next.errorMessage!.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.errorMessage!)),
        );
      }
    });

    final state = ref.watch(authControllerProvider);
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
                              SizedBox(
                                width: double.infinity,
                                child: FilledButton(
                                  onPressed: state.isLoading
                                      ? null
                                      : () {
                                          if (_formKey.currentState?.validate() ?? false) {
                                            ref
                                                .read(authControllerProvider.notifier)
                                                .login(_rutController.text.trim(), _passwordController.text.trim());
                                          }
                                        },
                                  child: state.isLoading
                                      ? const SizedBox(
                                          width: 24,
                                          height: 24,
                                          child: CircularProgressIndicator(strokeWidth: 2),
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
}
