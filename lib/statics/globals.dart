import 'package:aplicacion_ventas/models/cliente.dart';
import 'package:aplicacion_ventas/models/cliente_palabra.dart';
import 'package:aplicacion_ventas/models/producto.dart';
import 'package:aplicacion_ventas/models/producto_carro.dart';
import 'package:aplicacion_ventas/models/rollo.dart';
import 'package:aplicacion_ventas/models/user.dart';
import 'package:aplicacion_ventas/models/vendedor_app.dart';
import 'package:aplicacion_ventas/models/venta_cabeza.dart';
import 'package:currency_formatter/currency_formatter.dart';
import 'package:flutter/material.dart';

ScrollController scrollController = ScrollController();
bool conexionInternet = false;
int indiceAnterior = -1;
bool fromDetalle = false;
bool fromBusqueda = false;
String urlData = '45.236.164.152';
// String urlData = '192.168.1.4';
String busqueda = "";
int precio = 0;
int totalVenta = 0;
String rutCliente = "";
bool loged = false;
List<ClientePalabra> clientes = [];
Cliente? clienteVenta = null;
User? user = User();
ClientePalabra clienteData = ClientePalabra();
VendedorAppModel vendedor = VendedorAppModel();
String codigo = "";
int lineaventa = 1;
int cantidad = 1;
String codigoDestino = "";
// List<ProductoCarro> carroCompras = [];
List<Rollo> productos = [];
ProductoCarro productoCarro = ProductoCarro();
Map<String, String> headers = {
  'Content-Type': 'application/json',
};
String nombreCliente = "";
String numeroVenta = "";
String mensaje = "";
List<VentaCabeza> listadoVentas = [];
//String url_img = "https://mundoaladdin.cl/v2/util/image/";
String url_img = "null";
String correoCliente = "";

const CurrencyFormat clpSettings = CurrencyFormat(
  // formatter settings for euro
  code: 'clp',
  symbol: '\$',
  symbolSide: SymbolSide.left,
  thousandSeparator: '.',
  decimalSeparator: ',',
  symbolSeparator: '',
);
bool sincroniza = false;
bool firstLogin = false;
Producto p = Producto();
