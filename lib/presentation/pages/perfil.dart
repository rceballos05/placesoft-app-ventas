import 'dart:developer' as developer;

import 'package:animated_theme_switcher/animated_theme_switcher.dart';
import 'package:aplicacion_ventas/application/providers/login_provider.dart';
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
import 'package:flutter/material.dart';
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
  final TextEditingController nuevoPass = TextEditingController();
  late final AnimationController _controller;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    nuevoPass.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final loginState = ref.watch(loginControllerProvider);
    final currentUser = loginState.user;
    if (currentUser == null) {
      developer.log('Perfil renderizado sin usuario autenticado',
          name: 'Perfil');
    }

    return ThemeSwitchingArea(
      child: FadeTransition(
        opacity: _fade,
        child: Scaffold(
          backgroundColor: isDark ? Colors.black : const Color(0xFFF6F7FB),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildHeader(context),
                  const SizedBox(height: 24),
                  _buildUserCard(isDark: isDark, user: currentUser),
                  const SizedBox(height: 24),
                  _buildOptions(context),
                  const SizedBox(height: 20),
                  const Divider(),
                  const SizedBox(height: 6),
                  Text(
                    'v1.0.3 — Mundo a la Alegría',
                    style: TextStyle(
                      color: isDark ? Colors.white54 : Colors.black45,
                      fontSize: 12,
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

  Widget _buildHeader(BuildContext context) => Row(
        children: [
          IconButton(
            icon: const Icon(LineAwesomeIcons.arrow_left),
            onPressed: () {
              if (clienteVenta == null) {
                showSearch(context: context, delegate: BuscarCliente());
              } else {
                Navigator.pop(context);
              }
            },
          ),
          const Spacer(),
          const Text(
            'Perfil de Usuario',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const Spacer(flex: 2),
        ],
      );

  Widget _buildUserCard({required bool isDark, required User? user}) {
    final isLoggedIn = user != null;
    final nombre = user?.nombre ?? 'Usuario';
    final rut = user?.rut ?? 'Sin sesión activa';
    final cajaAsignadaValue = user?.caja;
    final cajaAsignada =
        (cajaAsignadaValue == null || cajaAsignadaValue.isEmpty) ? 'No asignada' : cajaAsignadaValue;
    final prefijo = user?.prefijo ?? '—';
    final maxDctoLabel = user != null
        ? '${user.maxDcto.toStringAsFixed(2)}%'
        : 'Sin información disponible';

    if (!isLoggedIn) {
      developer.log('Mostrando tarjeta de perfil sin datos de usuario',
          name: 'Perfil');
    }

    return Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark
                ? [Colors.deepPurple.shade900, Colors.black]
                : [Colors.blue.shade300, Colors.deepPurple.shade200],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Stack(
              children: [
                const CircleAvatar(
                  radius: 50,
                  backgroundImage: NetworkImage(
                    'https://e7.pngegg.com/pngimages/644/920/png-clipart-computer-icons-user-profile-avatar-avatar-white-heroes.png',
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    height: 32,
                    width: 32,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      LineAwesomeIcons.pen,
                      color: Colors.deepPurple,
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
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            Text(
              rut,
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.white70 : Colors.black54,
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
                        isDark: isDark,
                      ),
                      const SizedBox(height: 8),
                      _UserDataRow(
                        label: 'Prefijo',
                        value: prefijo,
                        isDark: isDark,
                      ),
                      const SizedBox(height: 8),
                      _UserDataRow(
                        label: 'Descuento máximo',
                        value: maxDctoLabel,
                        isDark: isDark,
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
                    color: isDark ? Colors.white70 : Colors.black54,
                    fontSize: 13,
                  ),
                ),
              ),
          ],
        ),
      );
  }

  Widget _buildOptions(BuildContext context) => Column(
        children: [
          ProfileListItem(
            icon: LineAwesomeIcons.user,
            text: 'Mostrar Datos',
            onTap: () => Navigator.pushNamed(context, ModificarDatosPage.routeName),
          ),
          ProfileListItem(
            icon: LineAwesomeIcons.history,
            text: 'Historial de Ventas',
            onTap: () => Navigator.pushNamed(context, HistorialPage.routeName),
          ),
          ProfileListItem(
            icon: LineAwesomeIcons.user_plus,
            text: 'Agregar Cliente',
            onTap: () => Navigator.pushNamed(context, AgregarClientePage.routeName),
          ),
          ProfileListItem(
            icon: LineAwesomeIcons.user_edit,
            text: 'Modificar Cliente',
            onTap: () => Navigator.pushNamed(context, ModificarClientePage.routeName),
          ),
          ProfileListItem(
            icon: LineAwesomeIcons.map_marker,
            text: 'Agregar Destino Cliente',
            onTap: () => Navigator.pushNamed(context, AgregarDestinoPage.routeName),
          ),
          ProfileListItem(
            icon: LineAwesomeIcons.key,
            text: 'Cambiar Contraseña',
            onTap: () => _openDialog(context),
          ),
          ProfileListItem(
            icon: LineAwesomeIcons.alternate_sign_out,
            text: 'Cerrar Sesión',
            textColor: Colors.redAccent,
            iconColor: Colors.redAccent,
            onTap: () => _cerrarSesion(context),
          ),
        ],
      );

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
    required this.isDark,
  });

  final String label;
  final String value;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final color = isDark ? Colors.white70 : Colors.black54;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: color,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 15,
            color: isDark ? Colors.white : Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
