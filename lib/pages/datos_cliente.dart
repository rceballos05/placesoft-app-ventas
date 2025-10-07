import 'package:animated_theme_switcher/animated_theme_switcher.dart';
import 'package:aplicacion_ventas/functions/dart_rut_validator.dart';
import 'package:aplicacion_ventas/functions/functions.dart';
import 'package:aplicacion_ventas/statics/globals.dart';
import 'package:aplicacion_ventas/statics/statics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';

class DetalleCliente extends StatefulWidget {
  const DetalleCliente({super.key});

  @override
  _DetalleClienteState createState() => _DetalleClienteState();
}

class _DetalleClienteState extends State<DetalleCliente> {
  @override
  void initState() {
    super.initState();
    setState(() {
      datosCliente();
    });
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context,
        designSize: const Size(414, 896), minTextAdapt: true);

    dynamic profileInfo;

    profileInfo = Flexible(
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
            clienteVenta!.nombre ?? "",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
            ),
            // textAlign: TextAlign.start,
          ),
          SizedBox(height: kSpacingUnit.w * 0.5),
          Text(
            //cliente.rut!,
            RUTValidator.formatFromText(
                clienteVenta!.rut!.replaceFirst('0', '')),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
            ),
            textAlign: TextAlign.start,
          ),
          Container(
            alignment: Alignment.topLeft,
            child: Column(
              children: [
                SizedBox(height: kSpacingUnit.h * 4),
                Text(
                  "Codigo local:  ${clienteData.codDestino}",
                  textAlign: TextAlign.start,
                ),
                Text(
                  "Dirección local:  ${clienteData.direccionDestino}",
                  textAlign: TextAlign.start,
                ),
                SizedBox(height: kSpacingUnit.h * 1),
                Text(
                  "Comuna: ${clienteData.comuna}",
                  textAlign: TextAlign.start,
                ),
                SizedBox(height: kSpacingUnit.h * 1),
                Text(
                  "Nombre contacto: ${clienteData.nombreContacto}",
                  textAlign: TextAlign.start,
                ),
                SizedBox(height: kSpacingUnit.h * 1),
                Text(
                  "Correo contacto: ${clienteData.emailContacto}",
                  textAlign: TextAlign.start,
                ),
                SizedBox(height: kSpacingUnit.h * 1),
                Text(
                  "Fono contacto: ${clienteData.fonoContacto}",
                  textAlign: TextAlign.start,
                ),
                SizedBox(height: kSpacingUnit.h * 1),
                Text(
                  "Plazo pago: ${clienteVenta!.plaso ?? 0} días",
                  textAlign: TextAlign.start,
                ),
                SizedBox(height: kSpacingUnit.h * 3),
                const Text("Saldos:"),
                SizedBox(height: kSpacingUnit.h * 1),
                Text(
                  "Monto: ${clienteVenta!.saldos!.isEmpty ? "0" : clienteVenta!.saldos!.first.monto} ",
                  textAlign: TextAlign.start,
                ),
                SizedBox(height: kSpacingUnit.h * 1),
                Text(
                  "Utilizado: ${clienteVenta!.saldos!.isNotEmpty ? clienteVenta!.saldos!.first.utilizado : "0"}",
                  textAlign: TextAlign.start,
                )
              ],
            ),
          ),
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
          onTap: () => Navigator.pop(context),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: profileInfo,
        ),
        SizedBox(width: kSpacingUnit.w * 3),
      ],
    );
    var nav = BottomAppBar(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(
              height: kSpacingUnit.h * 1,
            ),
            Expanded(
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: const Color(0xFF4C53A5),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: InkWell(
                  child: const Text(
                    "Seleccionar Cliente",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                    ),
                  ),
                  onTap: () {
                    clienteVenta = clienteVenta;
                    nombreCliente = clienteVenta!.nombre!;
                    correoCliente = clienteVenta!.email!;
                    Navigator.pushNamed(context, '/home');
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );

    var headerMin = Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SizedBox(width: kSpacingUnit.w * 3),
        InkWell(
          child: Icon(
            LineAwesomeIcons.arrow_left,
            size: ScreenUtil().setSp(kSpacingUnit.w * 3),
          ),
          onTap: () => Navigator.pop(context),
        ),
        //
        profileInfo,
        SizedBox(width: kSpacingUnit.w * 3),
      ],
    );

    return ThemeSwitchingArea(
      child: Builder(
        builder: (context) {
          return Scaffold(
            body: LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth < 600) {
                  return Column(
                    children: <Widget>[
                      SizedBox(height: kSpacingUnit.w * 3),
                      headerMin,
                    ],
                  );
                } else {
                  return Column(
                    children: <Widget>[
                      SizedBox(height: kSpacingUnit.w * 5),
                      header,
                    ],
                  );
                }
              },
            ),
            bottomNavigationBar: nav,
          );
        },
      ),
    );
  }

  void datosCliente() async {
    dynamic clte = await detalleCliente(rutCliente, codigoDestino);
    setState(() {
      clienteVenta = clte;
      clienteVenta?.saldos = List.empty();
    });
  }
}
