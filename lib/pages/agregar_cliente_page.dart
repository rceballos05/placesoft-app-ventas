import 'package:animated_theme_switcher/animated_theme_switcher.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Formulario para agregar un nuevo cliente a la cartera del vendedor.
class AgregarClientePage extends ConsumerWidget {
  const AgregarClientePage({super.key});

  static const routeName = '/agregar-cliente';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ThemeSwitchingArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Agregar cliente'),
        ),
        body: const _FormPlaceholder(
          title: 'Formulario de registro de clientes',
          description:
              'Completa los datos básicos del cliente y su información de contacto.',
        ),
      ),
    );
  }
}

class _FormPlaceholder extends StatelessWidget {
  const _FormPlaceholder({required this.title, required this.description});

  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(title, style: theme.textTheme.titleLarge),
            const SizedBox(height: 12),
            Text(
              description,
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            const Text(
              'Pronto encontrarás aquí los campos y validaciones necesarias.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
