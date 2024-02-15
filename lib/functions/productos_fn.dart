import 'dart:convert';
import 'package:app_ventas/models/categoria.dart';
import 'package:app_ventas/models/producto.dart';
import 'package:app_ventas/models/response.dart';
import 'package:http/http.dart' as http;

const url = '192.168.1.3:7177';
Future detalleProducto(String codigo) async {}
void addProductoCarro(String codigo, int cantidad) {}
void eliminarProductoCarro(String codigo, int cantidad) {}
Future obtenerCategorias() async {
  var data;
  try {
    final response =
        await http.get(Uri.http(url, 'api/inventario00/secciones'));
    data = jsonDecode(response.body);
    ResponseData responseData = ResponseData.fromJson(data);
    if (responseData.code == 200) {
      List<dynamic> prueba = [];
      for (var item in responseData.items!) {
        var categoria = Categoria.fromJson(item);
        prueba.add(categoria);
      }
      return prueba;
    } else {
      return responseData.message;
    }
  } catch (error) {
    print(error);
  }
}

Future obtenerProductoByCodigoSeccion(String codigo) async {
  return null;
}

Future obtenerProductos() async {
  var params = {'page': '1', 'itemsperpage': '10'};
  var data;
  try {
    var response =
        await http.get(Uri.http(url, '/api/Inventario00/productos', params));
    data = jsonDecode(response.body);
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
    print(error);
  }
}

class Params {
  late int? page;
  late int? itemsperpage;
  Params({
    this.page,
    this.itemsperpage,
  });
}
