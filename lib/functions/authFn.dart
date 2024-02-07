import 'dart:convert';

import 'package:app_ventas/models/VendedorApp.dart';
import 'package:http/http.dart' as http;

const url = '192.168.1.3:7177';
Future<bool> iniciarSesion(String rut, String pass) async {
  // var response = await getPrefijo(rut);
  // var login = false;
  // if (response != null) {
  //   var data = await getPass(response.prefijo, pass, rut);
  //   if (data == true) {
  //     login = true;
  //   }
  // }
  // return login;
  return false;
}

Future<VendedorAppModel?> getPrefijo(String rut) async {
  var rsp;

  try {
    final response =
        await http.get(Uri.http(url, '/api/Login/' + rut), headers: {});
    rsp = jsonDecode(response.body);
  } catch (error) {
    print(error);
  }
  if (rsp['code'] == 200) {
    // VendedorAppModel vendedorApp = new VendedorAppModel(
    //     rut: rsp['items'][0]['rut'], prefijos: rsp['items'][0]['prefijo']);

    return null;
  } else {
    return null;
  }
}

Future<bool> getPass(String prefijo, String pass, String rut) async {
  var data;
  try {
    final response = await http.get(
        Uri.http(url, 'api/Login/aalegria/iniciar-sesion/' + rut + '/' + pass));
    data = jsonDecode(response.body);
  } catch (error) {
    print(error);
  }
  if (data['code'] == 200) {
    return true;
  } else {
    return false;
  }
}
