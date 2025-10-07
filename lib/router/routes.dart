import 'package:aplicacion_ventas/pages/agregar_cliente.dart';
import 'package:aplicacion_ventas/pages/agregar_local.dart';
import 'package:aplicacion_ventas/pages/carro.dart';
import 'package:aplicacion_ventas/pages/datos_cliente.dart';
import 'package:aplicacion_ventas/pages/detalle.dart';
import 'package:aplicacion_ventas/pages/detalle_venta.dart';
import 'package:aplicacion_ventas/pages/historial_ventas.dart';
import 'package:aplicacion_ventas/pages/home.dart';
import 'package:aplicacion_ventas/pages/login.dart';
import 'package:aplicacion_ventas/pages/modificar_cliente.dart';
import 'package:aplicacion_ventas/pages/modificar_datos.dart';
import 'package:aplicacion_ventas/pages/perfil_page.dart';

var routes = {
  '/detalle': (context) => const Detalle(),
  '/home': (context) => Home(),
  '/perfil': (context) => const Perfil(),
  '/carro': (context) => const CartPage(),
  '/login': (context) => const LoginPage(),
  '/cliente': (context) => const DetalleCliente(),
  '/historial': (context) => const Historial(),
  '/detalle-ventas': (context) => const DetalleVenta(),
  '/modificar-datos': (context) => const ModificarDatosPage(),
  '/agregar-cliente': (context) => const AgregarClientePage(),
  '/modificar-cliente': (context) => const ModificarClientePage(),
  '/agregar-destino': (context) => const AgregarLocalPage(),
};
