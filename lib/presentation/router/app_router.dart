import 'package:aplicacion_ventas/pages/product_list_page.dart';
import 'package:aplicacion_ventas/models/local_venta_cabeza.dart';
import 'package:aplicacion_ventas/presentation/pages/agregar_cliente_page.dart';
import 'package:aplicacion_ventas/presentation/pages/agregar_destino_page.dart';
import 'package:aplicacion_ventas/presentation/pages/cart_page.dart';
import 'package:aplicacion_ventas/presentation/pages/detalle.dart';
import 'package:aplicacion_ventas/presentation/pages/detalle_venta_page.dart';
import 'package:aplicacion_ventas/presentation/pages/historial_page.dart';
import 'package:aplicacion_ventas/presentation/pages/home_page.dart';
import 'package:aplicacion_ventas/presentation/pages/login.dart';
import 'package:aplicacion_ventas/presentation/pages/modificar_cliente_page.dart';
import 'package:aplicacion_ventas/presentation/pages/modificar_datos_page.dart';
import 'package:aplicacion_ventas/presentation/pages/perfil.dart';
import 'package:flutter/material.dart';

/// Centralized route configuration for the application.
class AppRouter {
  const AppRouter._();

  /// Default route table mapping each page route name to its builder.
  static Map<String, WidgetBuilder> get routes => {
        LoginPage.routeName: (context) => const LoginPage(),
        ProductListPage.routeName: (context) => const ProductListPage(),
        HomePage.routeName: (context) => const HomePage(),
        CartPage.routeName: (context) => const CartPage(),
        Perfil.routeName: (context) => const Perfil(),
        Detalle.routeName: (context) => const Detalle(),
        HistorialPage.routeName: (context) => const HistorialPage(),
        DetalleVentaPage.routeName: (context) {
          final venta = ModalRoute.of(context)?.settings.arguments;
          if (venta is! LocalVentaCabeza) {
            throw ArgumentError('Se esperaba un objeto LocalVentaCabeza como argumento.');
          }
          return DetalleVentaPage(venta: venta);
        },
        AgregarClientePage.routeName: (context) => const AgregarClientePage(),
        ModificarClientePage.routeName: (context) => const ModificarClientePage(),
        AgregarDestinoPage.routeName: (context) => const AgregarDestinoPage(),
        ModificarDatosPage.routeName: (context) => const ModificarDatosPage(),
      };

  /// Default initial route used when launching the app.
  static String get initialRoute => LoginPage.routeName;
}
