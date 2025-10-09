import 'package:aplicacion_ventas/presentation/pages/cart_page.dart';
import 'package:aplicacion_ventas/presentation/pages/home_page.dart';
import 'package:aplicacion_ventas/presentation/pages/login_page.dart';
import 'package:flutter/material.dart';

/// Centralized route configuration for the application.
class AppRouter {
  const AppRouter._();

  /// Default route table mapping each page route name to its builder.
  static Map<String, WidgetBuilder> get routes => {
        LoginPage.routeName: (context) => const LoginPage(),
        HomePage.routeName: (context) => const HomePage(),
        CartPage.routeName: (context) => const CartPage(),
      };

  /// Default initial route used when launching the app.
  static String get initialRoute => LoginPage.routeName;
}
