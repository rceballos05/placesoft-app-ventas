import 'package:animated_theme_switcher/animated_theme_switcher.dart';
import 'package:aplicacion_ventas/statics/globals.dart';
import 'package:aplicacion_ventas/widgets/busqueda_cliente.dart';
import 'package:aplicacion_ventas/widgets/profile_list_item.dart';
import 'package:flutter/material.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';

class Perfil extends StatefulWidget {
  const Perfil({super.key});

  @override
  State<Perfil> createState() => _PerfilState();
}

class _PerfilState extends State<Perfil> with SingleTickerProviderStateMixin {
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
                  _buildUserCard(isDark),
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

  Widget _buildUserCard(bool isDark) => Container(
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
              user?.nombre ?? 'Usuario',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            Text(
              user?.correo ?? 'correo@ejemplo.cl',
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.white70 : Colors.black54,
              ),
            ),
          ],
        ),
      );

  Widget _buildOptions(BuildContext context) => Column(
        children: [
          ProfileListItem(
            icon: LineAwesomeIcons.user,
            text: 'Mostrar Datos',
            onTap: () => Navigator.pushNamed(context, '/modificar-datos'),
          ),
          ProfileListItem(
            icon: LineAwesomeIcons.history,
            text: 'Historial de Ventas',
            onTap: () => Navigator.pushNamed(context, '/historial'),
          ),
          ProfileListItem(
            icon: LineAwesomeIcons.user_plus,
            text: 'Agregar Cliente',
            onTap: () => Navigator.pushNamed(context, '/agregar-cliente'),
          ),
          ProfileListItem(
            icon: LineAwesomeIcons.user_edit,
            text: 'Modificar Cliente',
            onTap: () => Navigator.pushNamed(context, '/modificar-cliente'),
          ),
          ProfileListItem(
            icon: LineAwesomeIcons.map_marker,
            text: 'Agregar Destino Cliente',
            onTap: () => Navigator.pushNamed(context, '/agregar-destino'),
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
      user = null;
      clienteVenta = null;
      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
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
