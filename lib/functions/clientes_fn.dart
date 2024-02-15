import 'dart:convert';

import 'package:app_ventas/models/cliente.dart';
import 'package:app_ventas/models/response.dart';
import 'package:http/http.dart' as http;

const url = '192.168.1.3:7177';

Future BuscarClientePalabra(String palabra) async {
  var data;
  try {
    var response = await http
        .get(Uri.http(url, '/api/mantencion/buscar-cliente/${palabra}'));
    data = jsonDecode(response.body);
    var responseData = ResponseData.fromJson(data);
    List<dynamic> clientes = [];
    if (responseData.items != null) {
      for (var item in responseData.items!) {
        clientes.add(Cliente.fromJson(item));
      }
      return clientes;
    } else {
      return null;
    }
  } catch (error) {
    print(error);
  }
}
