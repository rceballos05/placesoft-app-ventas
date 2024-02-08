import 'package:app_ventas/pages/cart_page.dart';
import 'package:app_ventas/pages/producto_detalle_page.dart';
import 'package:flutter/material.dart';
import 'package:app_ventas/pages/home_page.dart';
import 'package:app_ventas/pages/login_page.dart';

var customRoutes = <String, WidgetBuilder>{
  LoginPage.id: (_) => const LoginPage(),
  HomePage.id: (_) => const HomePage(),
  ProductoDetalle.id: (_) => const ProductoDetalle(),
  CartPage.id: (_) => const CartPage(),
};
