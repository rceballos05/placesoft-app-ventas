import 'dart:convert';
import 'dart:html';
import 'dart:typed_data';

class Producto {
  String? codigobarra;
  String? descripcion;
  String? codSeccion;
  String? codDepto;
  String? codLinea;
  String? codMarca;
  String? uniMedida;
  String? contenido;
  double? precioCostoCiva;
  int? margenBase;
  bool? artDescontinuado;
  int? descuento;
  int? unicompramax;
  int? unicompramin;
  int? stock;
  Foto? fotos;
  int? precio;
  Producto({
    this.artDescontinuado,
    this.codDepto,
    this.codLinea,
    this.codMarca,
    this.codSeccion,
    this.codigobarra,
    this.contenido,
    this.descripcion,
    this.descuento,
    this.fotos,
    this.margenBase,
    this.precioCostoCiva,
    this.stock,
    this.uniMedida,
    this.unicompramax,
    this.unicompramin,
    this.precio,
  });

  factory Producto.fromJson(Map<String, dynamic> json) {
    return Producto(
      codigobarra: json['codigobarra'],
      descripcion: json['descripcion'],
      codSeccion: json['codSeccion'],
      codDepto: json['codDepto'],
      codLinea: json['codLinea'],
      codMarca: json['codMarca'],
      uniMedida: json['uniMedida'],
      contenido: json['contenido'],
      precioCostoCiva: json['precioCostoCiva'],
      margenBase: json['margenBase'],
      artDescontinuado: json['artDescontinuado'],
      descuento: json['descuento'],
      unicompramax: json['unicompramax'],
      unicompramin: json['unicompramin'],
      stock: json['stock'],
      fotos: Foto.fromJson(json['fotos'][0]),
      precio:
          (json['precioCostoCiva'] * (json['margenBase'] * 0.01 + 1)).round(),
    );
  }
}

class Foto {
  String? codigoBarra;
  Uint8List? imagen;
  Foto({this.codigoBarra, this.imagen});
  factory Foto.fromJson(Map<String, dynamic> json) {
    return Foto(
      codigoBarra: json['codigobarra'],
      imagen: base64.decode(json['imagen']),
    );
  }
}
