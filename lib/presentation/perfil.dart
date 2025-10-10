import 'package:animated_theme_switcher/animated_theme_switcher.dart';
import 'package:aplicacion_ventas/statics/globals.dart';
import 'package:aplicacion_ventas/widgets/busqueda_cliente.dart';
import 'package:aplicacion_ventas/widgets/profile_list_item.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';

class Perfil extends StatefulWidget {
  const Perfil({super.key});

  @override
  State<Perfil> createState() => _PerfilState();
}

class _PerfilState extends State<Perfil> with SingleTickerProviderStateMixin {
  final TextEditingController _nuevoPasswordController = TextEditingController();
  late final AnimationController _animationController;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;
  bool _isDarkMode = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.04),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutCubic,
      ),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final brightness = Theme.of(context).brightness;
    _isDarkMode = brightness == Brightness.dark;
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _nuevoPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return ThemeSwitchingArea(
      child: Builder(
        builder: (context) {
          return Scaffold(
            body: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: isDark
                      ? [const Color(0xFF1F1147), Colors.black]
                      : [const Color(0xFF4A75FF), const Color(0xFFA079FF)],
                ),
              ),
              child: SafeArea(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _Header(onBackPressed: _handleBack),
                          const SizedBox(height: 24),
                          _ProfileCard(isDark: isDark),
                          const SizedBox(height: 28),
                          _OptionSection(
                            isDark: isDark,
                            isDarkMode: _isDarkMode,
                            onThemeChanged: (value) => _toggleTheme(context, value),
                            onChangePassword: () => _openPasswordDialog(context),
                            onLogout: () => _confirmLogout(context),
                          ),
                          const SizedBox(height: 32),
                          _Footer(isDark: isDark),
                        ],
                      ),
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

  void _handleBack() {
    if (clienteVenta == null) {
      showSearch(context: context, delegate: BuscarCliente());
      return;
    }
    Navigator.of(context).maybePop();
  }

  void _toggleTheme(BuildContext context, bool value) {
    setState(() => _isDarkMode = value);
    final currentTheme = Theme.of(context);
    final newTheme = value
        ? ThemeData(
            brightness: Brightness.dark,
            useMaterial3: currentTheme.useMaterial3,
            colorSchemeSeed: currentTheme.colorScheme.primary,
          )
        : ThemeData(
            brightness: Brightness.light,
            useMaterial3: currentTheme.useMaterial3,
            colorSchemeSeed: currentTheme.colorScheme.primary,
          );
    ThemeSwitcher.of(context).changeTheme(theme: newTheme);
  }

  Future<void> _openPasswordDialog(BuildContext context) async {
    _nuevoPasswordController.clear();
    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        final theme = Theme.of(dialogContext);
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Cambiar Contraseña'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Ingresa una nueva contraseña para tu cuenta.',
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _nuevoPasswordController,
                obscureText: true,
                decoration: InputDecoration(
                  hintText: 'Nueva contraseña',
                  filled: true,
                  fillColor: theme.colorScheme.surfaceVariant.withOpacity(0.2),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () {
                final password = _nuevoPasswordController.text.trim();
                if (password.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('La contraseña no puede estar vacía.')),
                  );
                  return;
                }
                Navigator.of(dialogContext).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Contraseña actualizada')),
                );
              },
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _confirmLogout(BuildContext context) async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Cerrar sesión'),
          content: const Text('¿Deseas cerrar sesión?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Cerrar sesión'),
            ),
          ],
        );
      },
    );

    if (shouldLogout == true) {
      user = null;
      clienteVenta = null;
      if (!mounted) return;
      Navigator.of(context).pushNamedAndRemoveUntil('/login', (_) => false);
    }
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.onBackPressed});

  final VoidCallback onBackPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        _CircularIconButton(
          icon: LineAwesomeIcons.angle_left,
          color: theme.colorScheme.onPrimary,
          onPressed: onBackPressed,
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            'Perfil de Usuario',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: theme.colorScheme.onPrimary,
            ),
          ),
        ),
        const SizedBox(width: 48),
      ],
    );
  }
}

class _ProfileCard extends StatelessWidget {
  const _ProfileCard({required this.isDark});

  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final displayName = user?.nombre ?? 'Usuario';
    final email = user?.correo ?? 'correo@ejemplo.cl';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [const Color(0xFF3D2C8D), const Color(0xFF0C0832)]
              : [const Color(0xFF6A74FF), const Color(0xFFD1B3FF)],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 18,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 52,
                backgroundColor: Colors.white.withOpacity(0.2),
                backgroundImage: const NetworkImage(
                  'https://e7.pngegg.com/pngimages/644/920/png-clipart-computer-icons-user-profile-avatar-avatar-white-heroes.png',
                ),
              ),
              Positioned(
                right: 4,
                bottom: 4,
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  padding: const EdgeInsets.all(6),
                  child: const Icon(
                    LineAwesomeIcons.pen,
                    size: 16,
                    color: Color(0xFF6A74FF),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            displayName,
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            email,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.white.withOpacity(0.85),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _OptionSection extends StatelessWidget {
  const _OptionSection({
    required this.isDark,
    required this.isDarkMode,
    required this.onThemeChanged,
    required this.onChangePassword,
    required this.onLogout,
  });

  final bool isDark;
  final bool isDarkMode;
  final ValueChanged<bool> onThemeChanged;
  final VoidCallback onChangePassword;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    final cardColor = Colors.white.withOpacity(isDark ? 0.08 : 0.9);
    final borderColor = isDark ? Colors.white12 : Colors.black.withOpacity(0.05);

    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          ProfileListItem(
            icon: LineAwesomeIcons.identification_card,
            text: 'Mostrar Datos',
            onTap: () => Navigator.of(context).pushNamed('/modificar-datos'),
          ),
          ProfileListItem(
            icon: LineAwesomeIcons.history,
            text: 'Historial de Ventas',
            onTap: () => Navigator.of(context).pushNamed('/historial'),
          ),
          ProfileListItem(
            icon: LineAwesomeIcons.user_plus,
            text: 'Agregar Cliente',
            onTap: () => Navigator.of(context).pushNamed('/agregar-cliente'),
          ),
          ProfileListItem(
            icon: LineAwesomeIcons.user_edit,
            text: 'Modificar Cliente',
            onTap: () => Navigator.of(context).pushNamed('/modificar-cliente'),
          ),
          ProfileListItem(
            icon: LineAwesomeIcons.map_marker,
            text: 'Agregar Destino Cliente',
            onTap: () => Navigator.of(context).pushNamed('/agregar-destino'),
          ),
          ProfileListItem(
            icon: LineAwesomeIcons.key,
            text: 'Cambiar Contraseña',
            onTap: onChangePassword,
          ),
          _ThemeSwitchTile(
            value: isDarkMode,
            onChanged: onThemeChanged,
          ),
          ProfileListItem(
            icon: LineAwesomeIcons.alternate_sign_out,
            text: 'Cerrar Sesión',
            iconColor: Colors.redAccent,
            textColor: Colors.redAccent,
            onTap: onLogout,
          ),
        ],
      ),
    );
  }
}

class _ThemeSwitchTile extends StatelessWidget {
  const _ThemeSwitchTile({required this.value, required this.onChanged});

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: () => onChanged(!value),
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
        child: Row(
          children: [
            Icon(
              LineAwesomeIcons.adjust_solid,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Text(
                'Modo Oscuro',
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            CupertinoSwitch(
              value: value,
              onChanged: onChanged,
            ),
          ],
        ),
      ),
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer({required this.isDark});

  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Divider(
          color: isDark ? Colors.white24 : Colors.black12,
          thickness: 0.7,
        ),
        const SizedBox(height: 12),
        Text(
          'v1.0.3 — Mundo a la Alegría',
          textAlign: TextAlign.center,
          style: theme.textTheme.bodySmall?.copyWith(
            color: isDark ? Colors.white70.withOpacity(0.85) : Colors.grey.shade600,
            letterSpacing: 0.3,
          ),
        ),
      ],
    );
  }
}

class _CircularIconButton extends StatelessWidget {
  const _CircularIconButton({
    required this.icon,
    required this.onPressed,
    this.color,
  });

  final IconData icon;
  final VoidCallback onPressed;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withOpacity(0.12),
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onPressed,
        customBorder: const CircleBorder(),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Icon(icon, color: color ?? Colors.white, size: 20),
        ),
      ),
    );
  }
}
