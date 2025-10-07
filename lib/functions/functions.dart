import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:aplicacion_ventas/db/clientes.dart';
import 'package:aplicacion_ventas/db/db_clientes.dart';
import 'package:aplicacion_ventas/db/db_destinos.dart';
import 'package:aplicacion_ventas/db/db_precios.dart';
import 'package:aplicacion_ventas/db/db_productos.dart';
import 'package:aplicacion_ventas/db/db_rollo.dart';
import 'package:aplicacion_ventas/db/db_rollo_observaciones.dart';
import 'package:aplicacion_ventas/db/db_ventaCabeza.dart';
import 'package:aplicacion_ventas/db/db_ventasDetalle.dart';
import 'package:aplicacion_ventas/db/db_ventas_observaciones.dart';
import 'package:aplicacion_ventas/db/productos.dart';
import 'package:aplicacion_ventas/db/rollo.dart';
import 'package:aplicacion_ventas/db/venta_cabeza.dart';
import 'package:aplicacion_ventas/db/venta_detalle.dart';
import 'package:aplicacion_ventas/db/venta_observaciones.dart';
import 'package:aplicacion_ventas/models/boleta.dart';
import 'package:aplicacion_ventas/models/cantidad.dart';
import 'package:aplicacion_ventas/models/cliente.dart';
import 'package:aplicacion_ventas/models/cliente_palabra.dart';
import 'package:aplicacion_ventas/models/destinos.dart';
import 'package:aplicacion_ventas/models/download_data_dto.dart';
import 'package:aplicacion_ventas/models/email.dart';
import 'package:aplicacion_ventas/models/log_vendedores_app.dart';
import 'package:aplicacion_ventas/models/nuevo_cliente.dart';
import 'package:aplicacion_ventas/models/nuevo_destino.dart';
import 'package:aplicacion_ventas/models/observacion.dart';
import 'package:aplicacion_ventas/models/observaciones_venta.dart';
import 'package:aplicacion_ventas/models/precio.dart';
import 'package:aplicacion_ventas/models/producto.dart';
import 'package:aplicacion_ventas/models/producto_palabra.dart';
import 'package:aplicacion_ventas/models/query_data.dart';
import 'package:aplicacion_ventas/models/response.dart';
import 'package:aplicacion_ventas/models/rollo.dart';
import 'package:aplicacion_ventas/models/track.dart';
import 'package:aplicacion_ventas/models/user.dart';
import 'package:aplicacion_ventas/models/user_pass.dart';
import 'package:aplicacion_ventas/models/user_update.dart';
import 'package:aplicacion_ventas/models/vendedor_app.dart';
import 'package:aplicacion_ventas/models/venta.dart';
import 'package:aplicacion_ventas/models/venta_cabeza.dart';
import 'package:aplicacion_ventas/models/venta_detalle.dart';
import 'package:aplicacion_ventas/models/venta_observaciones.dart';
import 'package:aplicacion_ventas/statics/globals.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:darq/darq.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:sqflite/sqflite.dart';

import 'package:path/path.dart';

// LOGIN START
Future<bool> iniciarSesion(String rut, String pass) async {
  var response = await getPrefijo(rut);
  var login = false;
  if (response != null) {
    var data = await getPass(response.prefijo!, pass, rut);
    if (data == true) {
      login = true;
    }
  }
  return login;
}

Future<VendedorAppModel?> getPrefijo(String rut) async {
  try {
    final response =
        await http.get(Uri.http(urlData, '/api/Login/$rut'), headers: {});
    var rsp = jsonDecode(response.body);
    var responseData = ResponseData.fromJson(rsp);
    if (responseData.code == 200) {
      for (var item in responseData.items!) {
        vendedor = VendedorAppModel.fromJson(item);
      }

      return vendedor;
    } else {
      return null;
    }
  } catch (error) {
    log(error.toString());
  }
  return null;
}

Future<bool> getPass(String prefijo, String pass, String rut) async {
  try {
    final response = await http
        .get(Uri.http(urlData, 'api/Login/$prefijo/iniciar-sesion/$rut/$pass'));
    var json = jsonDecode(response.body);
    var responseData = ResponseData.fromJson(json);
    if (responseData.code == 200) {
      for (var item in responseData.items!) {
        user = User.fromJson(item);
        log(user.toString());
      }
      loged = true;
      return true;
    } else {
      return false;
    }
  } catch (error) {
    log(error.toString());
    return false;
  }
}

// LOGIN END

// CLIENTE START
Future buscarClientePalabra(String palabra) async {
  try {
    var response = await http.get(Uri.http(urlData,
        '/api/mantencion/${vendedor.prefijo}/buscar-cliente/$palabra'));
    var data = jsonDecode(response.body);
    List<ClientePalabra> clientes = [];
    if (data != null) {
      for (var item in data) {
        clientes.add(ClientePalabra.fromJson(item));
      }
      return clientes;
    } else {
      return null;
    }
  } catch (error) {
    log(error.toString());
  }
}

Future datosCliente(String rut) async {
  try {
    var response = await http.get(Uri.http(urlData,
        'api/mantencion/${vendedor.prefijo}/obtener-cliente-rut/$rut'));
    var json = jsonDecode(response.body);
    var data = ResponseData.fromJson(json);
    var cliente = Cliente();
    log(data.items.toString());
    if (data.code == 200) {
      List<Saldo> saldo = [];
      for (var item in data.items!) {
        cliente = Cliente.fromJson(item);
        log(cliente.toString());
        if (item['saldos'] != null) {
          for (var i in item['saldos']) {
            saldo.add(Saldo.fromJson(i));
          }
          log(saldo.toString());
          cliente.saldos = saldo;
        }
      }
      return cliente;
    }
  } catch (error) {
    log(error.toString());
  }
}
// CLIENTE END

// PRODUCTO START

Future detalleProducto(String codigo) async {
  try {
    final response = await http.get(Uri.http(
        urlData, 'api/Inventario/${vendedor.prefijo}/producto/$codigo'));
    var data = jsonDecode(response.body);
    var responseData = ResponseData.fromJson(data);
    final responseStock = await http.get(
        Uri.http(urlData, '/api/inventario/${vendedor.prefijo}/stock/$codigo'));
    var json = jsonDecode(responseStock.body);

    if (responseData.code == 200) {
      var producto = Producto();
      for (var element in responseData.items!) {
        producto = Producto.fromJson(element);
        producto.stock = json;
      }
      return producto;
    } else {
      return responseData.code;
    }
  } catch (e) {
    log(e.toString());
  }
}

Future obtenerProductos() async => runZonedGuarded<Future>(() async {
      var params = {'page': '1', 'itemsperpage': '10'};
      try {
        var response = await http.get(Uri.http(
            urlData, '/api/inventario/${vendedor.prefijo}/productos', params));
        var data = jsonDecode(response.body);
        var responseData = ResponseData.fromJson(data);
        List<Producto> productos = [];
        if (responseData.code == 200) {
          for (var element in responseData.items!) {
            productos.add(Producto.fromJson(element));
          }
          return productos;
        } else {
          return responseData.message;
        }
      } catch (error) {
        log(error.toString());
      }
    }, (error, stack) {
      throw Exception(error);
    });

class Params {
  late int? page;
  late int? itemsperpage;
  Params({
    this.page,
    this.itemsperpage,
  });
}

Future obtenerProductosSearch(String palabra) async {
  try {
    var nuevaPalabra = palabra.replaceAll('%', '&');
    final response = await http.get(Uri.http(urlData,
        'api/inventario/${vendedor.prefijo}/busqueda-producto/$nuevaPalabra'));
    var data = jsonDecode(response.body);
    List<ProductoSearch> productos = [];
    if (data != null) {
      for (var item in data) {
        var producto = ProductoSearch.fromJson(item);
        productos.add(producto);
      }
      return productos;
    } else {
      return null;
    }
  } catch (error) {
    log(error.toString());
  }
}
// PRODUCTO END

// LOG START
void logInicioSesionFunction() async {
  Position position = await Geolocator.getCurrentPosition();
  LogVendedoresApp vendedoresLog = LogVendedoresApp(
    rut: user!.rut!,
    mensajeLog: "${user!.nombre} ha iniciado sesión",
    latitud: position.latitude.toString(),
    longitud: position.longitude.toString(),
    fecha: DateTime.now().toIso8601String(),
  );

  Map<String, dynamic> datos = {
    'rut': vendedoresLog.rut,
    'latitud': vendedoresLog.latitud,
    'longitud': vendedoresLog.longitud,
    'mensajelog': vendedoresLog.mensajeLog,
    'fecha': vendedoresLog.fecha
  };

  await http.post(
    Uri.http(urlData, '/api/log/${vendedor.prefijo}/log-vendedores-app'),
    headers: headers,
    body: jsonEncode(datos),
  );
}

void logVentaFunction() async {
  Position position = await Geolocator.getCurrentPosition();
  LogVendedoresApp vendedoresLog = LogVendedoresApp(
    rut: user!.rut!,
    mensajeLog: "${user!.nombre} ha realizado una venta a $nombreCliente",
    latitud: position.latitude.toString(),
    longitud: position.longitude.toString(),
    fecha: DateTime.now().toIso8601String(),
  );

  Map<String, dynamic> datos = {
    'rut': vendedoresLog.rut,
    'latitud': vendedoresLog.latitud,
    'longitud': vendedoresLog.longitud,
    'mensajelog': vendedoresLog.mensajeLog,
    'fecha': vendedoresLog.fecha
  };

  await http.post(
    Uri.http(urlData, '/api/log/${vendedor.prefijo}/log-vendedores-app'),
    headers: headers,
    body: jsonEncode(datos),
  );
}

void logCerrarSesionFunction() async {
  Position position = await Geolocator.getCurrentPosition();
  LogVendedoresApp vendedoresLog = LogVendedoresApp(
    rut: user!.rut!,
    mensajeLog: "${user!.nombre} ha cerrado su sesión",
    latitud: position.latitude.toString(),
    longitud: position.longitude.toString(),
    fecha: DateTime.now().toIso8601String(),
  );

  Map<String, dynamic> datos = {
    'rut': vendedoresLog.rut,
    'latitud': vendedoresLog.latitud,
    'longitud': vendedoresLog.longitud,
    'mensajelog': vendedoresLog.mensajeLog,
    'fecha': vendedoresLog.fecha
  };

  await http.post(
    Uri.http(urlData, '/api/log/${vendedor.prefijo}/log-vendedores-app'),
    headers: headers,
    body: jsonEncode(datos),
  );
}

void solicitarPermisos() async {
  LocationPermission permission;
  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      return Future.error(
          'Se necesita permiso de ubicación para realizar la acción');
    }
  }
}
// LOG END

//VENTA START
Future<String?> generarNumeroBoleta() async {
  var boleta = Boleta();

  try {
    var response = await http.get(Uri.http(urlData,
        '/api/local00/${vendedor.prefijo}/obtener-cantidad-boletas/${vendedor.caja}'));
    var json = jsonDecode(response.body);
    var responseData = ResponseData.fromJson(json);
    if (responseData.code == 200) {
      for (var item in responseData.items!) {
        boleta = Boleta.fromJSon(item);
      }
    }
    var num = (boleta.numero! + 1).toString();
    var numeroBoleta = num.padLeft(10, '0');
    return numeroBoleta;
  } catch (e) {
    mensaje = e.toString();
    return null;
  }
}

Future<bool> cabezaVenta(VentaCabeza cabeza) async {
  try {
    var json = jsonEncode(cabeza.toJson());
    log(json);
    var respuesta = await http.post(
      Uri.http(
          urlData, 'api/local00/${vendedor.prefijo}/realizar-venta-cabeza'),
      headers: headers,
      body: json,
    );
    var p = jsonDecode(respuesta.body);
    var data = ResponseData.fromJson(p);
    if (data.code == 200) {
      return true;
    } else {
      mensaje = data.message!;
      return false;
    }
  } catch (e) {
    mensaje = e.toString();
    return false;
  }
}

Future<bool> registrarObservacion(VentaObservaciones obs) async {
  var json = jsonEncode(obs.toJson());
  var respuesta = await http.post(
    Uri.http(
        urlData, 'api/local00/${vendedor.prefijo}/registrar-observaciones'),
    headers: headers,
    body: json,
  );
  var p = jsonDecode(respuesta.body);
  var data = ResponseData.fromJson(p);
  if (data.code == 200) {
    return true;
  } else {
    return false;
  }
}

Future<bool> realizarVenta(Venta venta) async {
  var json = jsonEncode(venta.toJson());
  log(json);
  var respuesta = await http.post(
      Uri.http(
          urlData, 'api/local00/${vendedor.prefijo}/realizar-venta-detalle'),
      headers: headers,
      body: json);
  var p = jsonDecode(respuesta.body);
  var data = ResponseData.fromJson(p);
  if (data.code == 200) {
    logVentaFunction();
    eliminarRollo(vendedor.caja!);
    clienteVenta = null;
    mensaje = data.message!;
    return true;
  } else {
    mensaje = data.message!;
    return false;
  }
}

Future agregarProductoRollo(Rollo rollo) async {
  var json = jsonEncode(rollo.toJson());
  var response = await http.post(
    Uri.http(
        urlData, '/api/local00/${vendedor.prefijo}/insertar-producto-rollo'),
    headers: headers,
    body: json,
  );
  var p = jsonDecode(response.body);
  var data = ResponseData.fromJson(p);
  if (data.code == 200) {
    obtenerRollo(vendedor.caja!);
    return;
  } else {
    return;
  }
}

Future obtenerRollo(String caja) async {
  List<Rollo> list = [];
  var response = await http.get(Uri.http(
      urlData, '/api/Local00/${vendedor.prefijo}/obtener-rollo/$caja'));
  var p = jsonDecode(response.body);
  var data = ResponseData.fromJson(p);
  if (data.code == 200) {
    for (var item in data.items!) {
      list.add(Rollo.fromJson(item));
    }
    productos = list;
    return list;
  } else {
    return null;
  }
}

Future eliminarRollo(String caja) async {
  var response = await http.get(Uri.http(
      urlData, '/api/Local00/${vendedor.prefijo}/eliminar-rollo/$caja'));
  var p = jsonDecode(response.body);
  var data = ResponseData.fromJson(p);
  if (data.code == 200) {
    obtenerRollo(vendedor.caja!);
    return true;
  } else {
    return false;
  }
}

Future actualizarCantidadProductoRollo(Cantidad obj) async {
  var json = jsonEncode(obj.toJson());
  var response = await http.post(
    Uri.http(urlData,
        '/api/Local00/${vendedor.prefijo}/actualizar-cantidad-producto-rollo'),
    headers: headers,
    body: json,
  );
  var p = jsonDecode(response.body);
  var data = ResponseData.fromJson(p);
  if (data.code == 200) {
    obtenerRollo(vendedor.caja!);
    return true;
  } else {
    return false;
  }
}

Future actualizarObservacionProductoRollo(Observacion obj) async {
  var json = jsonEncode(obj.toJson());
  var response = await http.post(
    Uri.http(
        urlData, '/api/Local00/${vendedor.prefijo}/actualizar-observacion'),
    headers: headers,
    body: json,
  );
  var p = jsonDecode(response.body);
  var data = ResponseData.fromJson(p);
  if (data.code == 200) {
    obtenerRollo(vendedor.caja!);
    return true;
  } else {
    return false;
  }
}

Future nuevaObservacionProducto(Observacion obj) async {
  var json = jsonEncode(obj.toJson());
  var response = await http.post(
    Uri.http(urlData, '/api/Local00/${vendedor.prefijo}/nueva-observacion'),
    headers: headers,
    body: json,
  );
  var p = jsonDecode(response.body);
  var data = ResponseData.fromJson(p);
  if (data.code == 200) {
    obtenerRollo(vendedor.caja!);
    return true;
  } else {
    return false;
  }
}

Future eliminarProductoRollo(String caja, String codigo) async {
  var response = await http.get(Uri.http(urlData,
      '/api/local00/${vendedor.prefijo}/eliminar-producto-carro/$caja/$codigo'));
  var p = jsonDecode(response.body);
  var data = ResponseData.fromJson(p);
  if (data.code == 200) {
    obtenerRollo(vendedor.caja!);
    return true;
  } else {
    return false;
  }
}

/// data historial

Future obtenerVentasUsuario(String rut) async {
  var response = await http.get(
      Uri.http(urlData, 'api/local00/${vendedor.prefijo}/obtener-ventas/$rut'));
  var json = jsonDecode(response.body);
  var responseData = ResponseData.fromJson(json);
  List<VentaCabeza> data = [];
  if (responseData.code == 200) {
    for (var item in responseData.items!) {
      data.add(VentaCabeza.fromJson(item));
    }
    return data;
  } else {
    return null;
  }
}

Future obtenerVentasUsuarioFiltradas(String rut, String fecha) async {
  var response = await http.get(Uri.http(urlData,
      'api/local00/${vendedor.prefijo}/obtener-ventas-fecha/$rut/$fecha'));
  var json = jsonDecode(response.body);
  var responseData = ResponseData.fromJson(json);
  List<VentaCabeza> data = [];
  if (responseData.code == 200) {
    for (var item in responseData.items!) {
      data.add(VentaCabeza.fromJson(item));
    }
    return responseData.items;
  } else {
    return null;
  }
}

// update user

Future cambiarPass(String usuario, UserPass user) async {
  var json = user.toJson();
  var response = await http.post(
      Uri.http(
          urlData, 'api/Setting/${vendedor.prefijo}/cambiar-password/$usuario'),
      headers: headers,
      body: jsonEncode(json));
  var p = jsonDecode(response.body);
  var data = ResponseData.fromJson(p);
  if (data.code == 200) {
    mensaje = data.message!;
    return true;
  } else {
    mensaje = data.message!;
    return false;
  }
}

Future<bool> actualizarUsuario(String usuario, UserUpdate user) async {
  var json = user.toJson();
  log(jsonEncode(json));
  var response = await http.post(
      Uri.http(
          urlData, 'api/Setting/${vendedor.prefijo}/modificar-datos/$usuario'),
      headers: headers,
      body: jsonEncode(json));
  var p = jsonDecode(response.body);
  var data = ResponseData.fromJson(p);
  if (data.code == 200) {
    mensaje = data.message!;
    return true;
  } else {
    mensaje = data.message!;
    return false;
  }
}

Future detalleVenta(String numero) async {
  var response = await http.get(Uri.http(
      urlData, 'api/local00/${vendedor.prefijo}/detalle-venta/$numero'));
  var json = jsonDecode(response.body);
  var responseData = ResponseData.fromJson(json);
  List<VentaDetalle> data = [];
  if (responseData.code == 200) {
    for (var item in responseData.items!) {
      data.add(VentaDetalle.fromJson(item));
    }
    return data;
  } else {
    return null;
  }
}

Future observacionVenta(String numero) async {
  var response = await http.get(Uri.http(urlData,
      'api/local00/${vendedor.prefijo}/observaciones-articulo-venta/$numero'));
  var json = jsonDecode(response.body);
  var responseData = ResponseData.fromJson(json);
  List<ObservacionesVenta> data = [];
  if (responseData.code == 200) {
    for (var item in responseData.items!) {
      data.add(ObservacionesVenta.fromJson(item));
    }
    return data;
  } else {
    return null;
  }
}

Future enviarEmail(EmailDto email) async {
  var json = email.toJson();
  var response = await http.post(
      Uri.http(urlData, '/api/email/${vendedor.prefijo}/enviar-correo'),
      headers: headers,
      body: jsonEncode(json));
  var responseJson = jsonDecode(response.body);
  var responseData = ResponseData.fromJson(responseJson);
  if (responseData.code == 400) {
    mensaje = responseData.message!;
    return false;
  }
}

Future agregarCliente(NuevoCliente cliente) async {
  var json = jsonEncode(cliente.toJson());
  var response = await http.post(
    Uri.http(urlData, '/api/mantencion/${vendedor.prefijo}/nuevo-cliente'),
    headers: headers,
    body: json,
  );
  var responseJson = jsonDecode(response.body);
  var responseData = ResponseData.fromJson(responseJson);
  if (responseData.code == 201) {
    mensaje = responseData.message!;
    return true;
  } else {
    mensaje = responseData.message!;
    return false;
  }
}

Future obtenerPrecioProducto(String codigo) async {
  var response = await http.get(
      Uri.http(urlData, '/api/inventario/${vendedor.prefijo}/precio/$codigo'));
  var json = jsonDecode(response.body);
  var responseData = ResponseData.fromJson(json);

  int precio = 0;
  if (responseData.code == 200) {
    for (var item in responseData.items!) {
      var dataPrecio = Precio.fromJson(item);
      precio = dataPrecio.precio!;
    }
  }
  return precio;
}

Future<String> obtenerCodigoNuevoDestino(String rut) async {
  var response = await http.get(Uri.http(urlData,
      '/api/mantencion/${vendedor.prefijo}/obtener-codigo-destino/$rut'));

  var json = jsonDecode(response.body);
  if (json.code == 200) {
    return json.items!.first;
  }
  return "001";
}

Future modificarCliente(NuevoCliente cliente, String rut) async {
  var json = jsonEncode(cliente.toJson());
  var response = await http.post(
    Uri.http(
        urlData, '/api/mantencion/${vendedor.prefijo}/modificar-cliente/$rut'),
    headers: headers,
    body: json,
  );
  var responseJson = jsonDecode(response.body);
  var responseData = ResponseData.fromJson(responseJson);
  if (responseData.code == 200) {
    mensaje = responseData.message!;
    return true;
  } else {
    mensaje = responseData.message!;
    return false;
  }
}

Future nuevoDestinoCliente(String rut, NuevoDestino destino) async {
  var json = jsonEncode(destino.toJson());
  var response = await http.post(
    Uri.http(urlData,
        '/api/mantencion/${vendedor.prefijo}/agregar-destino-cliente/$rut'),
    headers: headers,
    body: json,
  );
  var responseJson = jsonDecode(response.body);
  var responseData = ResponseData.fromJson(responseJson);
  if (responseData.code == 200) {
    mensaje = responseData.message!;
    return true;
  } else {
    mensaje = responseData.message!;
    return false;
  }
}

Future<void> revisarConexion() async {
  var connectivityResult = await Connectivity().checkConnectivity();
  if (connectivityResult.first == ConnectivityResult.mobile) {
    conexionInternet = true;
    print('Conectado a una red móvil');
  } else if (connectivityResult.first == ConnectivityResult.wifi) {
    conexionInternet = true;
    print('Conectado a una red Wi-Fi');
  } else {
    conexionInternet = false;
    print('No hay conexión a Internet');
  }
}

//ofline

void obtenerClientes() async {
  var result = await DBClientes.obtenerClientes();
  for (var item in result) {
    var prueba = ClientePalabra.fromJson(item);
    //log(data.toString());
    clientes.add(prueba);
  }
  var temp = await DBDestino.obtenerDestinosCliente(clientes);
  clientes = temp;
}

Future detalleCliente(String rut, String local) async {
  var result = await DBClientes.get(rut);
  var destino = await DBDestino.datosLocalCliente(local, rut);

  var cliente = Cliente(
    rut: result.rut,
    nombre: result.nombre,
    activo: result.activo,
    direccion: destino.descripcion,
    celular: destino.fonoContacto,
    email: destino.emailContacto,
    contacto: destino.nombreContacto,
    contactoFono: destino.fonoContacto,
    contactoMail: destino.emailContacto,
    localCreacion: destino.codigo,
    codComuna: destino.codComuna,
    comuna: result.comuna,
    cupo: double.parse(result.cupo.toString()).round(),
    plaso: result.plazo,
    fono1: result.fono1,
  );
  clienteData.codComuna = destino.codComuna;
  clienteData.codDestino = destino.codigo;
  clienteData.direccionDestino = destino.descripcion;
  clienteData.emailContacto = cliente.contactoMail;
  clienteData.fonoContacto = cliente.contactoFono;
  clienteData.rut = cliente.rut;
  clienteData.nombre = cliente.nombre;
  clienteData.nombreContacto = cliente.contacto;

  return cliente;
}

Future productoBusquedaOfline(String palabra) async {
  List<ProductoSearch> search = [];
  var result = await DBProductos.productosSearch(palabra);
  for (MaeArticulos item in result) {
    search.add(ProductoSearch(
      codigo: item.codigobarra,
      nombre: item.descripcion,
      precio: await DBPrecios.precio(item.codigobarra),
    ));
  }
  return search;
}

Future detalleProductoOffline(String codigo) async {
  MaeArticulos result = await DBProductos.get(codigo);
  var pr = Producto(
    artDescontinuado: false,
    codDepto: result.codDepto,
    codLinea: result.codLinea,
    codMarca: result.codMarca,
    codSeccion: result.codSeccion,
    codigobarra: result.codigobarra,
    contenido: result.contenido,
    descripcion: result.descripcion,
    descuento: result.descuento.toInt(),
    margenBase: result.margenBase.toInt(),
    precio: await DBPrecios.precio(codigo),
    precioCostoCiva: result.precioCostoCiva.toInt(),
    stock: 0,
    uniMedida: "",
    unicompramax: result.unicompramax.toInt(),
    unicompramin: result.unicompramin.toInt(),
  );
  return pr;
}

Future clienteBusquedaOfline(String palabra) async {
  List<ClientePalabra> search = [];
  var result = await DBClientes.clienteSearch(palabra);
  for (MaeClientes item in result) {
    search.add(ClientePalabra(
      rut: item.rut,
      codComuna: item.codComuna,
      comuna: item.comuna,
      nombre: item.nombre,
    ));
  }
  var response = await DBDestino.obtenerDestinosCliente(search);
  return response;
}

Future<void> obtenerRolloYActualizarOffline() async {
  var tblRollooffline = await DBRollo.obtenerRollo();
  productos = [];
  List<Rollo> data = [];
  if (tblRollooffline != null) {
    for (TblRolloTerreno00 item in tblRollooffline) {
      data.add(
        Rollo(
          artCantidad: item.artCantidad.toInt(),
          artCodigo: item.artCodigo,
          artDescripcion: item.artDescripcion,
          artDescuento: item.artDescuento,
          artPrecio: item.artPrecio,
          cajaDoc: item.cajaDoc,
          codImpuesto: item.codImpuesto,
          fechaTransaccion: item.fechaTransaccion,
          lineaVenta: item.lineaVenta.toInt(),
          local: item.local,
          porceImpuesto: item.porceImpuesto,
          rutCajero: item.rutCajero,
          rutVendedor: item.rutVendedor,
          tipoventa: item.tipoVenta,
          totalLinea: item.totalLinea,
          observacion:
              await DBRolloObservaciones.obtenerObservacionProductoRollo(
                      item.artCodigo) ??
                  "",
        ),
      );
    }

    productos = data;
    log(productos.length.toString());
  }
}

Future deleteRolloCnObservacionesOffline() async {
  await DBRollo.deleteRollo();
  await DBRolloObservaciones.deleteObservaciones();
}

Future deleteArticuloRolloOffline(String codigo) async {
  await DBRollo.deleteArticuloRollo(codigo);
  await DBRolloObservaciones.deleteObservacionProducto(codigo);
}

Future<void> copyDatabaseRollo() async {
  // Obtén la ruta del directorio de la base de datos en el dispositivo
  final databasePath = await getDatabasesPath();
  final path = join(databasePath, 'rollo.db');

  // Verifica si el archivo de la base de datos ya existe en el dispositivo
  final exists = await databaseExists(path);

  if (!exists) {
    // Carga la base de datos desde los assets
    ByteData data = await rootBundle.load('assets/database/rollo.db');

    // Escribe los bytes en el archivo
    List<int> bytes =
        data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
    await File(path).writeAsBytes(bytes, flush: true);
  } else {
    await deleteDatabase(path);
    ByteData data = await rootBundle.load('assets/database/rollo.db');

    // Escribe los bytes en el archivo
    List<int> bytes =
        data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
    await File(path).writeAsBytes(bytes, flush: true);
  }
}

Future<void> copyDatabaseLogin() async {
  // Obtén la ruta del directorio de la base de datos en el dispositivo
  final databasePath = await getDatabasesPath();
  final path = join(databasePath, 'login.db');

  // Verifica si el archivo de la base de datos ya existe en el dispositivo
  final exists = await databaseExists(path);

  if (!exists) {
    // Carga la base de datos desde los assets
    ByteData data = await rootBundle.load('assets/database/login.db');

    // Escribe los bytes en el archivo
    List<int> bytes =
        data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
    await File(path).writeAsBytes(bytes, flush: true);
  } else {
    await deleteDatabase(path);
    ByteData data = await rootBundle.load('assets/database/login.db');

    // Escribe los bytes en el archivo
    List<int> bytes =
        data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
    await File(path).writeAsBytes(bytes, flush: true);
  }
}

Future<void> copyDatabaseVentas() async {
  // Obtén la ruta del directorio de la base de datos en el dispositivo
  final databasePath = await getDatabasesPath();
  final path = join(databasePath, 'ventas.db');

  // Verifica si el archivo de la base de datos ya existe en el dispositivo
  final exists = await databaseExists(path);

  if (!exists) {
    // Carga la base de datos desde los assets
    ByteData data = await rootBundle.load('assets/database/ventas.db');

    // Escribe los bytes en el archivo
    List<int> bytes =
        data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
    await File(path).writeAsBytes(bytes, flush: true);
  } else {
    await deleteDatabase(path);
    ByteData data = await rootBundle.load('assets/database/ventas.db');

    // Escribe los bytes en el archivo
    List<int> bytes =
        data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
    await File(path).writeAsBytes(bytes, flush: true);
  }
}

Future<void> copyDatabaseProductos(String prefijo) async {
  // Obtén la ruta del directorio de la base de datos en el dispositivo
  final databasePath = await getDatabasesPath();
  final path = join(databasePath, 'productos.db');

  // Verifica si el archivo de la base de datos ya existe en el dispositivo
  final exists = await databaseExists(path);

  if (!exists) {
    late ByteData data;
    // Carga la base de datos desde los assets
    switch (prefijo.toUpperCase()) {
      case "AALEGRIA":
        data = await rootBundle.load('assets/database/aalegria/productos.db');
        break;
      case "CRVICTORIA":
        data = await rootBundle.load('assets/database/crvictoria/productos.db');
        break;
      case "WALROB":
        data = await rootBundle.load('assets/database/walrob/productos.db');
        break;
    }

    // Escribe los bytes en el archivo
    List<int> bytes =
        data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
    await File(path).writeAsBytes(bytes, flush: true);
  } else {
    await deleteDatabase(path);
    late ByteData data;
    // Carga la base de datos desde los assets
    switch (prefijo.toUpperCase()) {
      case "AALEGRIA":
        data = await rootBundle.load('assets/database/aalegria/productos.db');
        break;
      case "CRVICTORIA":
        data = await rootBundle.load('assets/database/crvictoria/productos.db');
        break;
      case "WALROB":
        data = await rootBundle.load('assets/database/walrob/productos.db');
        break;
    }

    // Escribe los bytes en el archivo
    List<int> bytes =
        data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
    await File(path).writeAsBytes(bytes, flush: true);
  }
}

Future<void> copyDatabaseClientes(String prefijo) async {
  // Obtén la ruta del directorio de la base de datos en el dispositivo
  final databasePath = await getDatabasesPath();
  final path = join(databasePath, 'clientes.db');

  // Verifica si el archivo de la base de datos ya existe en el dispositivo
  final exists = await databaseExists(path);
  late ByteData data;
  if (!exists) {
    // Carga la base de datos desde los assets
    switch (prefijo.toUpperCase()) {
      case "AALEGRIA":
        data = await rootBundle.load('assets/database/aalegria/clientes.db');
        break;
      case "CRVICTORIA":
        data = await rootBundle.load('assets/database/crvictoria/clientes.db');
        break;
      case "WALROB":
        data = await rootBundle.load('assets/database/walrob/clientes.db');
        break;
    }
    // Escribe los bytes en el archivo
    List<int> bytes =
        data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
    await File(path).writeAsBytes(bytes, flush: true);
  } else {
    await deleteDatabase(path);
    late ByteData data;
    switch (prefijo.toUpperCase()) {
      case "AALEGRIA":
        data = await rootBundle.load('assets/database/aalegria/clientes.db');
        break;
      case "CRVICTORIA":
        data = await rootBundle.load('assets/database/crvictoria/clientes.db');
        break;
      case "WALROB":
        data = await rootBundle.load('assets/database/walrob/clientes.db');
        break;
    }

    // Escribe los bytes en el archivo
    List<int> bytes =
        data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
    await File(path).writeAsBytes(bytes, flush: true);
  }
}

Future traerDataFromLogServer(String prefijo, String caja) async {
  var response = await http
      .get(Uri.http(urlData, '/api/Sincronizacion/$prefijo/sincroniza/$caja'));
  var json = jsonDecode(response.body);
  if (response.body == "") {
    return null;
  }
  var responseData = ResponseData.fromJson(json);
  List<QueryData> list = [];
  if (responseData.code == 200) {
    for (var item in responseData.items!) {
      list.add(QueryData.fromJson(item));
    }
    return list;
  }
}

Future enviarVentasServer() async {
  List<LocalVentaCabeza> cabeza = await DBVentaCabeza.obtenerVentas();

  for (var item in cabeza) {
    List<LocalVentaDetalle> detalle =
        await DBVentaDetalle.obtenerDetalleVentas(item.numeroDoc);
    List<ArticulosVenta> lista = [];
    for (var x in detalle) {
      lista.add(ArticulosVenta(
        articuloDescuento: x.artDescuento.toInt(),
        cantidad: x.artCantidad.toInt(),
        codigo: x.artCodigo,
        descripcion: x.artDescripcion,
        porcentajeDescuento: x.porceDescuento,
        precio: x.artPrecio.toInt(),
        precioCostoCIva: x.precioCostoCiva.toInt(),
        totalLinea: x.totalLinea.toInt(),
      ));
    }
    var ventaDetalle = Venta(
      almacen: "00",
      articulos: lista,
      cajaDoc: item.cajaDoc,
      destinoCliente: "000",
      fecha: item.fechaEmision,
      lineVenta: "",
      local: item.local,
      numeroDoc: item.numeroDoc,
      rutCliente: item.rutCliente,
      rutVendedor: item.rutVendedor,
      tipoDoc: item.tipoDoc,
    );
    await realizarVenta(ventaDetalle);
    List<LocalVentaObservaciones> obs =
        await DBVentaObservaciones.obtenerObservacionesVentas(item.numeroDoc);

    for (var y in obs) {
      await registrarObservacion(
        VentaObservaciones(
          cajaDoc: y.cajaDoc,
          codigo: y.codigo,
          fechaEmision: y.fechaEmision,
          lineaVenta: y.lineaVenta,
          local: y.local,
          numeroDoc: y.numeroDoc,
          observaciones: y.observaciones,
          rutCliente: y.rutCliente,
          tipoDoc: y.tipoDoc,
        ),
      );
    }
    var cb = VentaCabeza(
      abono: item.abono,
      acteco: item.acteco,
      cajaDoc: item.cajaDoc,
      dctoglobal: item.dctoglobal,
      despachoFolio: item.despachoFolio,
      despachoHora: item.despachoHora,
      despachoPatente: item.despachoPatente,
      direccionDestino: item.direccionDestino,
      emailCliente: item.emailCliente,
      fechaEmision: item.fechaEmision,
      foliosii: item.foliosii,
      fonoCliente: item.fonoCliente,
      formapago: item.formaPago,
      generarDte: item.generarDte,
      glosaGuia: item.glosaGuia,
      impCarne: item.impCarne,
      impCerveza: item.impCerveza,
      impDiesel: item.impDiesel,
      impHarina: item.impHarina,
      impLicores: item.impHarina,
      impLight: item.impLight,
      impRefrescos: item.impRefrescos,
      impVinos: item.impVinos,
      local: item.local,
      localTraslado: item.localTraslado,
      montoDonacion: item.montoDonacion,
      montoExento: item.montoExento,
      montoIva: item.montoIva,
      montoLey20956: item.montoLey20956,
      montoNeto: item.montoNeto,
      montoPropina: item.montoPropina,
      montoTotal: item.montoTotal,
      nombreCliente: item.nombreCliente,
      notaPedido: item.notaPedido,
      numeroDoc: item.numeroDoc,
      numeroImpresora: item.numeroImpresora.toString(),
      observacion: item.observacion,
      ordenDeCompra: item.ordenDeCompra,
      plazo: item.plazo,
      porceDescuento: item.porceDescuento,
      procesada: item.procesada,
      refGlosa: item.refGlosa,
      refNumero: item.refNumero,
      refTipo: item.refTipo,
      revision1: item.revision1,
      revision2: item.revision2,
      revision3: item.revision3,
      rutCajera: item.rutCajera,
      rutCliente: item.rutCliente,
      rutVendedor: item.rutVendedor,
      subtotal: item.subtotal,
      tipoDoc: item.tipoDoc,
      tipoTraslado: item.tipoTraslado,
      usuarioFacturacion: item.usuarioFacturacion,
    );
    await cabezaVenta(cb);
    List<VentaDetalle> lst = await revisarVenta(item.cajaDoc, item.numeroDoc);
    if (lst.length == detalle.length) {
      if (await revisarCb(item.cajaDoc, item.numeroDoc)) {
        item.usuarioFacturacion = "apiventas.procesado";
        await DBVentaCabeza.updateVenta(item);
      } else {
        bool prueba = await cabezaVenta(cb);
        if (!prueba) {
          return "Error, No se pudo enviar la venta ${item.numeroDoc}";
        }
      }
    } else {
      bool dt = await realizarVenta(ventaDetalle);
      if (!dt) {
        return "Error, No se pudo enviar la venta ${item.numeroDoc}";
      }
    }
    //return "Error, No se pudo enviar la venta ${item.numeroDoc}";
  }
  return cabeza.count().toString();
}

Future obtenerUltimaVenta(String prefijo, String caja) async {
  var response = await http
      .get(Uri.http(urlData, '/api/local00/$prefijo/ultima-venta/$caja'));
  var json = jsonDecode(response.body);
  var responseData = ResponseData.fromJson(json);
  late LocalVentaCabeza data;
  if (responseData.items != null) {
    for (var item in responseData.items!) {
      if (item != null) {
        data = LocalVentaCabeza.fromMap(item);
      } else {
        return null;
      }
    }

    return data;
  } else {
    return null;
  }
}

Future updateDownloadData(VendedorAppModel v) async {
  var data = DownloadDataDto(caja: v.caja, prefijo: v.prefijo, rut: v.rut);
  var json = jsonEncode(data.toMap());
  var response = await http.put(
    Uri.http(urlData, 'api/login/update-setting-download-data'),
    headers: headers,
    body: json,
  );

  var rsp = jsonDecode(response.body);
  var responseData = ResponseData.fromJson(rsp);
  if (responseData.code == 200) {
    return true;
  } else {
    return false;
  }
}

Future ingresarTrack(TrackDto track) async {
  var json = jsonEncode(track.toJson());
  var response = await http.post(
    Uri.http(urlData, '/api/log/${vendedor.prefijo}/insertar-track'),
    headers: headers,
    body: json,
  );

  if (response.body == "") {
    return null;
  }
  var jsonRsp = jsonDecode(response.body);
  var responseData = ResponseData.fromJson(jsonRsp);

  if (responseData.code == 200) {
    return true;
  }
  return false;
}

Future codComuna(String comuna) async {
  var response = await http.get(
    Uri.http(urlData, '/api/mantencion/${vendedor.prefijo}/comuna/$comuna'),
  );
  if (response.body == "") {
    return null;
  }
  var jsonRsp = jsonDecode(response.body);
  var responseData = ResponseData.fromJson(jsonRsp);

  if (responseData.code == 200) {
    return responseData.items!.first;
  }
}

Future agregarDestinoCliente(
    MaeClientesDestinos destino, String rutCliente) async {
  var json = jsonEncode(destino.toMap());
  var response = await http.post(
    Uri.http(urlData,
        '/api/mantencion/${vendedor.prefijo}/agregar-destino-cliente/$rutCliente'),
    headers: headers,
    body: json,
  );

  if (response.body == "") {
    return null;
  }
  var jsonRsp = jsonDecode(response.body);
  var responseData = ResponseData.fromJson(jsonRsp);

  if (responseData.code == 200) {
    return true;
  }
  return false;
}

Future revisarVenta(String caja, String numeroDoc) async {
  var response = await http.get(Uri.http(urlData,
      'api/local00/${vendedor.prefijo}/detalle-venta/$numeroDoc/$caja'));
  if (response.body == "") {
    return null;
  }
  List<VentaDetalle> lst = [];
  var jsonRsp = jsonDecode(response.body);
  var responseData = ResponseData.fromJson(jsonRsp);
  if (responseData.code == 200) {
    for (var item in responseData.items!) {
      lst.add(VentaDetalle.fromMap(item));
    }

    return lst;
  }
}

Future revisarCb(String caja, String numeroDoc) async {
  var response = await http.get(Uri.http(urlData,
      'api/local00/${vendedor.prefijo}/cabeza-venta/$numeroDoc/$caja'));
  if (response.body == "") {
    return null;
  }

  var jsonRsp = jsonDecode(response.body);
  var responseData = ResponseData.fromJson(jsonRsp);
  if (responseData.code == 200) {
    return true;
  }

  return false;
}
