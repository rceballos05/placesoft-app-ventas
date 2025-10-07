import 'package:animated_theme_switcher/animated_theme_switcher.dart';
import 'package:aplicacion_ventas/statics/globals.dart';
import 'package:aplicacion_ventas/statics/statics.dart';
import 'package:aplicacion_ventas/widgets/busqueda_cliente.dart';
import 'package:aplicacion_ventas/widgets/profile_list_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';

TextEditingController nuevoPass = TextEditingController();

class Perfil extends StatelessWidget {
  const Perfil({super.key});

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context,
        designSize: const Size(414, 896), minTextAdapt: true);

    var profileInfo = Expanded(
      child: Column(
        children: <Widget>[
          Container(
            height: kSpacingUnit.w * 10,
            width: kSpacingUnit.w * 10,
            margin: EdgeInsets.only(top: kSpacingUnit.w * 3),
            child: Stack(
              children: <Widget>[
                CircleAvatar(
                  radius: kSpacingUnit.w * 5,
                  backgroundImage: const NetworkImage(
                      "https://e7.pngegg.com/pngimages/644/920/png-clipart-computer-icons-user-profile-avatar-avatar-white-heroes.png"),
                ),
                Align(
                  alignment: Alignment.bottomRight,
                  child: Container(
                    height: kSpacingUnit.w * 2.5,
                    width: kSpacingUnit.w * 2.5,
                    decoration: const BoxDecoration(
                      color: kAccentColor,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      heightFactor: kSpacingUnit.w * 1.5,
                      widthFactor: kSpacingUnit.w * 1.5,
                      child: Icon(
                        LineAwesomeIcons.pen,
                        color: kDarkPrimaryColor,
                        size: ScreenUtil().setSp(kSpacingUnit.w * 1.5),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: kSpacingUnit.w * 2),
          Text(
            user!.nombre ?? "",
            style: const TextStyle(color: Colors.white, fontSize: 22),
          ),
          SizedBox(height: kSpacingUnit.w * 0.5),
          Text(
            user!.correo ?? "",
            style: const TextStyle(color: Colors.white, fontSize: 15),
          ),
          SizedBox(height: kSpacingUnit.w * 2),
        ],
      ),
    );

    var header = Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SizedBox(width: kSpacingUnit.w * 3),
        InkWell(
          child: Icon(
            LineAwesomeIcons.arrow_left,
            size: ScreenUtil().setSp(kSpacingUnit.w * 3),
          ),
          onTap: () {
            if (clienteVenta == null) {
              showSearch(context: context, delegate: BuscarCliente());
            } else {
              Navigator.pop(context);
            }
          },
        ),
        profileInfo,
        SizedBox(width: kSpacingUnit.w * 3),
      ],
    );

    return ThemeSwitchingArea(
      child: Builder(
        builder: (context) {
          return Scaffold(
            body: Column(
              children: <Widget>[
                SizedBox(height: kSpacingUnit.w * 5),
                header,
                Expanded(
                  child: ListView(
                    children: <Widget>[
                      InkWell(
                        child: const ProfileListItem(
                          icon: LineAwesomeIcons.user,
                          text: 'Mostrar Datos',
                        ),
                        onTap: () {
                          Navigator.pushNamed(context, '/modificar-datos');
                        },
                      ),
                      InkWell(
                        child: const ProfileListItem(
                          icon: LineAwesomeIcons.history,
                          text: 'Historial de Ventas',
                        ),
                        onTap: () {
                          // llenarData();
                          Navigator.pushNamed(context, '/historial');
                        },
                      ),
                      InkWell(
                        child: const ProfileListItem(
                          icon: LineAwesomeIcons.history,
                          text: 'Agregar Cliente',
                        ),
                        onTap: () {
                          Navigator.pushNamed(context, '/agregar-cliente');
                        },
                      ),
                      InkWell(
                        child: const ProfileListItem(
                          icon: LineAwesomeIcons.history,
                          text: 'Modificar Cliente',
                        ),
                        onTap: () {
                          Navigator.pushNamed(context, '/modificar-cliente');
                        },
                      ),
                      InkWell(
                        child: const ProfileListItem(
                          icon: LineAwesomeIcons.history,
                          text: 'Agregar Destino Cliente',
                        ),
                        onTap: () {
                          Navigator.pushNamed(context, '/agregar-destino');
                        },
                      ),
                      // InkWell(
                      //   child: const ProfileListItem(
                      //     icon: LineAwesomeIcons.key,
                      //     text: 'Cambiar Contraseña',
                      //   ),
                      //   onTap: () {
                      //     openDialog(context);
                      //   },
                      // ),
                      InkWell(
                          child: const ProfileListItem(
                            icon: LineAwesomeIcons.alternate_sign_out,
                            text: 'Cerrar Sesión',
                            hasNavigation: false,
                          ),
                          onTap: () {
                            user = null;
                            Navigator.pushNamed(context, '/login');
                          }),
                    ],
                  ),
                )
              ],
            ),
          );
        },
      ),
    );
  }

  // var newUser = UserPass(usuario: user!.usuario, clave: nuevoPass.text);

  // Future openDialog(BuildContext context) => showDialog(
  //       context: context,
  //       builder: (context) => AlertDialog(
  //         title: const Text("Cambiar Password"),
  //         content: TextField(
  //           controller: nuevoPass,
  //         ),
  //         actions: [
  //           TextButton(
  //             onPressed: () {
  //               cambiarPass(user!.usuario!, newUser);
  //               Navigator.pushNamed(context, '/home');
  //             },
  //             child: const Text("Cambiar Password"),
  //           ),
  //         ],
  //       ),
  //     );
}
