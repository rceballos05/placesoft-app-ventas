import 'dart:developer' as developer;

import 'package:animated_theme_switcher/animated_theme_switcher.dart'
    hide ThemeModel;
import 'package:aplicacion_ventas/application/providers/login_provider.dart';
import 'package:aplicacion_ventas/application/services/sync_service.dart';
import 'package:aplicacion_ventas/core/theme/app_theme.dart';
import 'package:aplicacion_ventas/core/theme/theme_model.dart';
import 'package:aplicacion_ventas/domain/entities/user.dart';
import 'package:aplicacion_ventas/presentation/pages/agregar_cliente_page.dart';
import 'package:aplicacion_ventas/presentation/pages/agregar_destino_page.dart';
import 'package:aplicacion_ventas/presentation/pages/historial_page.dart';
import 'package:aplicacion_ventas/presentation/pages/login.dart';
import 'package:aplicacion_ventas/presentation/pages/modificar_cliente_page.dart';
import 'package:aplicacion_ventas/presentation/pages/modificar_datos_page.dart';
import 'package:aplicacion_ventas/presentation/widgets/busqueda_cliente.dart';
import 'package:aplicacion_ventas/presentation/widgets/profile_list_item.dart';
import 'package:aplicacion_ventas/statics/globals.dart';
import 'package:aplicacion_ventas/core/utils/failure.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';

/// Pantalla de perfil del usuario con accesos directos a distintas gestiones.
class Perfil extends ConsumerStatefulWidget {
  const Perfil({super.key});

  static const routeName = '/perfil';

  @override
  ConsumerState<Perfil> createState() => _PerfilState();
}

class _PerfilState extends ConsumerState<Perfil>
    with SingleTickerProviderStateMixin {
  static const _themeAnimationDuration = Duration(milliseconds: 400);
  final TextEditingController nuevoPass = TextEditingController();
  late final AnimationController _controller;
  late final Animation<double> _fade;
  bool _isDownloading = false;
  bool _isCheckingStatus = false;
  double _downloadProgress = 0;
  InitialDownloadStep? _currentDownloadStep;
  InitialSyncStatus? _initialSyncStatus;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    _controller.forward();
    _refreshInitialSyncStatus();
  }

  @override
  void dispose() {
    _controller.dispose();
    nuevoPass.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeModel = ThemeModel.maybeOf(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final loginState = ref.watch(loginControllerProvider);
    final currentUser = loginState.user;
    if (currentUser == null) {
      developer.log('Perfil renderizado sin usuario autenticado',
          name: 'Perfil');
    }

    return Directionality(
      textDirection: TextDirection.ltr,
      child: ThemeSwitchingArea(
        child: FadeTransition(
          opacity: _fade,
          child: Scaffold(
            backgroundColor: theme.scaffoldBackgroundColor,
            body: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildHeader(
                      context,
                      isDark: isDark,
                      themeModel: themeModel,
                    ),
                    const SizedBox(height: 24),
                    _buildUserCard(
                      context,
                      isDark: isDark,
                      user: currentUser,
                    ),
                    const SizedBox(height: 24),
                    _buildOptions(context),
                    const SizedBox(height: 20),
                    Divider(color: theme.dividerColor.withOpacity(0.6)),
                    const SizedBox(height: 6),
                    Text(
                      'v1.0.3 — ${(currentUser?.prefijo ?? '—').toUpperCase()}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context, {
    required bool isDark,
    ThemeModel? themeModel,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final titleColor = colorScheme.onSurface;

    return Row(
      children: [
        IconButton(
          icon: Icon(
            LineAwesomeIcons.arrow_left,
            color: titleColor,
          ),
          onPressed: () {
            if (clienteVenta == null) {
              showSearch(context: context, delegate: BuscarCliente());
            } else {
              Navigator.pop(context);
            }
          },
        ),
        Expanded(
          child: Text(
            'Perfil de Usuario',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: titleColor,
            ),
          ),
        ),
        const SizedBox(width: 8),
        ThemeSwitcher(
          builder: (context) {
            final isCurrentlyDark =
                Theme.of(context).brightness == Brightness.dark;
            final iconColor =
                isCurrentlyDark ? colorScheme.secondary : colorScheme.primary;

            return IconButton(
              tooltip: isCurrentlyDark
                  ? 'Cambiar a modo claro'
                  : 'Cambiar a modo oscuro',
              onPressed: () {
                HapticFeedback.lightImpact();
                final switcher = ThemeSwitcher.of(context);
                final theme =
                    isCurrentlyDark ? AppTheme.lightTheme : AppTheme.darkTheme;
                switcher.changeTheme(theme: theme);
                themeModel?.updateThemeMode(
                  isCurrentlyDark ? ThemeMode.light : ThemeMode.dark,
                );

                final snackBarMessage = isCurrentlyDark
                    ? 'Modo claro activado'
                    : 'Modo oscuro activado';
                ScaffoldMessenger.of(context)
                  ..hideCurrentSnackBar()
                  ..showSnackBar(
                    SnackBar(
                      content: Text(snackBarMessage),
                      duration: const Duration(seconds: 2),
                    ),
                  );
              },
              icon: AnimatedSwitcher(
                duration: _themeAnimationDuration,
                transitionBuilder: (child, animation) {
                  final rotationAnimation =
                      Tween<double>(begin: 0.75, end: 1).animate(animation);
                  return FadeTransition(
                    opacity: animation,
                    child: RotationTransition(
                      turns: rotationAnimation,
                      child: child,
                    ),
                  );
                },
                child: Text(
                  isCurrentlyDark ? '☀️' : '🌙',
                  key: ValueKey<bool>(isCurrentlyDark),
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: iconColor,
                    fontSize: 26,
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildUserCard(
    BuildContext context, {
    required bool isDark,
    required User? user,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isLoggedIn = user != null;
    final nombre = user?.nombre ?? 'Usuario';
    final rut = user?.rut ?? 'Sin sesión activa';
    final cajaAsignadaValue = user?.caja;
    final cajaAsignada =
        (cajaAsignadaValue == null || cajaAsignadaValue.isEmpty)
            ? 'No asignada'
            : cajaAsignadaValue;
    final prefijo = user?.prefijo ?? '—';
    final maxDctoLabel = user != null
        ? '${user.maxDcto.toStringAsFixed(2)}%'
        : 'Sin información disponible';

    if (!isLoggedIn) {
      developer.log('Mostrando tarjeta de perfil sin datos de usuario',
          name: 'Perfil');
    }

    final gradientColors = isDark
        ? [
            Color.lerp(colorScheme.primary, colorScheme.surface, 0.1)!,
            Color.lerp(colorScheme.secondary, colorScheme.background, 0.6)!,
          ]
        : [
            Color.lerp(
              colorScheme.primaryContainer,
              colorScheme.secondaryContainer,
              0.4,
            )!,
            Color.lerp(colorScheme.secondary, colorScheme.surface, 0.1)!,
          ];

    final cardTextColor =
        isDark ? colorScheme.onPrimary : colorScheme.onPrimaryContainer;
    final subtleTextColor = cardTextColor.withOpacity(0.7);

    return AnimatedContainer(
      duration: _themeAnimationDuration,
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(isDark ? 0.5 : 0.2),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
        border: Border.all(
          color: colorScheme.outline.withOpacity(isDark ? 0.3 : 0.2),
        ),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 50,
                backgroundImage: const NetworkImage(
                  'https://e7.pngegg.com/pngimages/644/920/png-clipart-computer-icons-user-profile-avatar-avatar-white-heroes.png',
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  height: 32,
                  width: 32,
                  decoration: BoxDecoration(
                    color: isDark
                        ? colorScheme.surface.withOpacity(0.9)
                        : colorScheme.surface,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    LineAwesomeIcons.pen,
                    color: isDark ? colorScheme.primary : colorScheme.secondary,
                    size: 18,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            nombre,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: cardTextColor,
            ),
          ),
          Text(
            rut,
            style: TextStyle(
              fontSize: 14,
              color: subtleTextColor,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _UserDataRow(
                      label: 'Caja asignada',
                      value: cajaAsignada,
                      textColor: cardTextColor,
                      subtleTextColor: subtleTextColor,
                    ),
                    const SizedBox(height: 8),
                    _UserDataRow(
                      label: 'Prefijo',
                      value: prefijo,
                      textColor: cardTextColor,
                      subtleTextColor: subtleTextColor,
                    ),
                    const SizedBox(height: 8),
                    _UserDataRow(
                      label: 'Descuento máximo',
                      value: maxDctoLabel,
                      textColor: cardTextColor,
                      subtleTextColor: subtleTextColor,
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (!isLoggedIn)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Text(
                'Inicia sesión nuevamente para ver los datos actualizados.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: subtleTextColor,
                  fontSize: 13,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildOptions(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Card(
          elevation: 0,
          color: theme.colorScheme.surface,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Respaldos manuales',
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                if (_isCheckingStatus)
                  const Center(
                    child: SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(strokeWidth: 2.5),
                    ),
                  )
                else
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      _buildSyncStatusMessage(),
                      style: theme.textTheme.bodySmall,
                    ),
                  ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  icon: const Icon(LineAwesomeIcons.download),
                  label: const Text('Descargar clientes'),
                  onPressed: _isDownloading ? null : _downloadInitialData,
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  icon: const Icon(LineAwesomeIcons.download),
                  label: const Text('Descargar productos'),
                  onPressed: _isDownloading ? null : _downloadInitialData,
                ),
                if (_isDownloading) ...[
                  const SizedBox(height: 16),
                  Center(
                    child: SizedBox(
                      height: 32,
                      width: 32,
                      child: CircularProgressIndicator(
                        value: _downloadProgress > 0
                            ? _downloadProgress.clamp(0, 1)
                            : null,
                      ),
                    ),
                  ),
                  if (_currentDownloadStep != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      _mapDownloadStepToMessage(_currentDownloadStep!),
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        ProfileListItem(
          icon: LineAwesomeIcons.user,
          text: 'Mostrar Datos',
          onTap: () =>
              Navigator.pushNamed(context, ModificarDatosPage.routeName),
        ),
        ProfileListItem(
          icon: LineAwesomeIcons.history,
          text: 'Historial de Ventas',
          onTap: () => Navigator.pushNamed(context, HistorialPage.routeName),
        ),
        ProfileListItem(
          icon: LineAwesomeIcons.user_plus,
          text: 'Agregar Cliente',
          onTap: () =>
              Navigator.pushNamed(context, AgregarClientePage.routeName),
        ),
        ProfileListItem(
          icon: LineAwesomeIcons.user_edit,
          text: 'Modificar Cliente',
          onTap: () =>
              Navigator.pushNamed(context, ModificarClientePage.routeName),
        ),
        ProfileListItem(
          icon: LineAwesomeIcons.map_marker,
          text: 'Agregar Destino Cliente',
          onTap: () =>
              Navigator.pushNamed(context, AgregarDestinoPage.routeName),
        ),
        ProfileListItem(
          icon: LineAwesomeIcons.key,
          text: 'Cambiar Contraseña',
          onTap: () => _openDialog(context),
        ),
        ProfileListItem(
          icon: LineAwesomeIcons.alternate_sign_out,
          text: 'Cerrar Sesión',
          textColor: Theme.of(context).colorScheme.error,
          iconColor: Theme.of(context).colorScheme.error,
          onTap: () => _cerrarSesion(context),
        ),
      ],
    );
  }

  Future<void> _refreshInitialSyncStatus() async {
    if (!mounted) {
      return;
    }
    setState(() {
      _isCheckingStatus = true;
    });

    try {
      final status =
          await ref.read(syncServiceProvider).getInitialDownloadStatus();
      if (!mounted) return;
      setState(() {
        _initialSyncStatus = status;
      });
    } on Failure catch (failure) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(content: Text(failure.message)),
        );
    } finally {
      if (!mounted) return;
      setState(() {
        _isCheckingStatus = false;
      });
    }
  }

  Future<void> _downloadInitialData() async {
    setState(() {
      _isDownloading = true;
      _downloadProgress = 0;
      _currentDownloadStep = null;
    });

    try {
      // final didDownload = await ref
      //     .read(syncServiceProvider)
      //     .ensureInitialDataAvailable(
      //   onProgress: (progress) {
      //     if (!mounted) return;
      //     setState(() {
      //       _downloadProgress = progress.progress;
      //       _currentDownloadStep = progress.step;
      //     });
      //   },
      // );

      if (!mounted) return;

      setState(() {
        _downloadProgress = 1;
        _currentDownloadStep = InitialDownloadStep.completado;
      });

      // if (didDownload) {
      //   ScaffoldMessenger.of(context)
      //     ..hideCurrentSnackBar()
      //     ..showSnackBar(
      //       const SnackBar(
      //         content: Text('Bases locales descargadas correctamente'),
      //       ),
      //     );
      // }

      await _refreshInitialSyncStatus();
    } on Failure catch (failure) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(content: Text(failure.message)),
        );
    } finally {
      if (!mounted) return;
      setState(() {
        _isDownloading = false;
        _downloadProgress = 0;
        _currentDownloadStep = null;
      });
    }
  }

  String _buildSyncStatusMessage() {
    final status = _initialSyncStatus;
    if (status == null) {
      return 'Estado de bases locales no disponible';
    }
    if (status.alreadySynchronized) {
      return 'Bases locales disponibles ✅';
    }
    if (status.shouldDownload) {
      return 'Faltan bases locales ❌';
    }
    if (status.missingPrefix) {
      return 'Prefijo no configurado para descargas';
    }
    return 'Modo offline no requiere descarga';
  }

  String _mapDownloadStepToMessage(InitialDownloadStep step) {
    switch (step) {
      case InitialDownloadStep.clientes:
        return 'Descargando clientes...';
      case InitialDownloadStep.productos:
        return 'Descargando productos...';
      case InitialDownloadStep.verificando:
        return 'Verificando integridad...';
      case InitialDownloadStep.completado:
        return 'Completado ✅';
    }
  }

  Future<void> _cerrarSesion(BuildContext context) async {
    final salir = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Cerrar sesión'),
        content: const Text('¿Deseas cerrar la sesión actual?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
    if (salir == true) {
      developer.log('Solicitud de cierre de sesión confirmada', name: 'Perfil');
      await ref.read(loginControllerProvider.notifier).logout();
      clienteVenta = null;
      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(
        context,
        LoginPage.routeName,
        (_) => false,
      );
    }
  }

  void _openDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cambiar Contraseña'),
        content: TextField(
          controller: nuevoPass,
          obscureText: true,
          decoration: const InputDecoration(hintText: 'Nueva contraseña'),
        ),
        actions: [
          TextButton(
            onPressed: () {
              if (nuevoPass.text.isNotEmpty) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Contraseña actualizada')),
                );
              }
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }
}

class _UserDataRow extends StatelessWidget {
  const _UserDataRow({
    required this.label,
    required this.value,
    required this.textColor,
    required this.subtleTextColor,
  });

  final String label;
  final String value;
  final Color textColor;
  final Color subtleTextColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: subtleTextColor,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
                color: textColor,
                fontWeight: FontWeight.w600,
              ) ??
              TextStyle(
                fontSize: 15,
                color: textColor,
                fontWeight: FontWeight.w600,
              ),
        ),
      ],
    );
  }
}
