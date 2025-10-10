import 'package:aplicacion_ventas/pages/agregar_cliente_page.dart';
import 'package:aplicacion_ventas/pages/agregar_destino_page.dart';
import 'package:aplicacion_ventas/pages/cart_page.dart';
import 'package:aplicacion_ventas/pages/detalle_page.dart';
import 'package:aplicacion_ventas/pages/historial_page.dart';
import 'package:aplicacion_ventas/pages/home_page.dart';
import 'package:aplicacion_ventas/pages/login.dart';
import 'package:aplicacion_ventas/pages/modificar_cliente_page.dart';
import 'package:aplicacion_ventas/pages/modificar_datos_page.dart';
import 'package:aplicacion_ventas/pages/perfil.dart';
import 'package:flutter/material.dart';

/// Centralized route configuration for the application.
class AppRouter {
  const AppRouter._();

  /// Default route table mapping each page route name to its builder.
  static Map<String, WidgetBuilder> get routes => {
        LoginPage.routeName: (context) => const LoginPage(),
        HomePage.routeName: (context) => const HomePage(),
        CartPage.routeName: (context) => const CartPage(),
        Perfil.routeName: (context) => const Perfil(),
        DetallePage.routeName: (context) => const DetallePage(),
        HistorialPage.routeName: (context) => const HistorialPage(),
        AgregarClientePage.routeName: (context) => const AgregarClientePage(),
        ModificarClientePage.routeName: (context) => const ModificarClientePage(),
        AgregarDestinoPage.routeName: (context) => const AgregarDestinoPage(),
        ModificarDatosPage.routeName: (context) => const ModificarDatosPage(),
      };

  /// Default initial route used when launching the app.
  static String get initialRoute => LoginPage.routeName;
}
