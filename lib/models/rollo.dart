class Rollo {
  String? local;

  String? cajaDoc;

  int? lineaVenta;

  String? rutCajero;

  int? artCantidad;

  String? artCodigo;

  String? artDescripcion;

  double? artDescuento;

  double? artPrecio;

  double? totalLinea;

  String? rutVendedor;

  String? fechaTransaccion;

  String? tipoventa;

  String? codImpuesto;

  double? porceImpuesto;

  String? observacion;

  Rollo({
    this.artCantidad,
    this.artCodigo,
    this.artDescripcion,
    this.artDescuento,
    this.artPrecio,
    this.cajaDoc,
    this.codImpuesto,
    this.fechaTransaccion,
    this.lineaVenta,
    this.local,
    this.porceImpuesto,
    this.rutCajero,
    this.rutVendedor,
    this.tipoventa,
    this.totalLinea,
    this.observacion,
  });
  factory Rollo.fromJson(Map<String, dynamic> json) {
    return Rollo(
      artCantidad: int.parse(json["artCantidad"].toString().split('.')[0]),
      artCodigo: json["artCodigo"].toString(),
      artDescripcion: json["artDescripcion"].toString(),
      artDescuento: double.parse(json["artDescuento"].toString()),
      artPrecio: double.parse(json["artPrecio"].toString()),
      cajaDoc: json["cajaDoc"].toString(),
      codImpuesto: json["codImpuesto"].toString(),
      fechaTransaccion: json["fechaTransaccion"].toString(),
      lineaVenta: int.parse(json["lineaVenta"].toString()),
      local: json["local"].toString(),
      observacion: json["observacion"].toString(),
      porceImpuesto: double.parse(json["porceImpuesto"].toString()),
      rutCajero: json["rutCajero"].toString(),
      rutVendedor: json["rutVendedor"].toString(),
      tipoventa: json["tipoventa"].toString(),
      totalLinea: double.parse(json["totalLinea"].toString()),
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'local': local,
      'cajaDoc': cajaDoc,
      'lineaVenta': lineaVenta,
      'rutCajero': rutCajero,
      'artCantidad': artCantidad,
      'artCodigo': artCodigo,
      'artDescripcion': artDescripcion,
      'artDescuento': artDescuento,
      'artPrecio': artPrecio,
      'totalLinea': totalLinea,
      'rutVendedor': rutVendedor,
      'fechaTransaccion': fechaTransaccion,
      'tipoventa': tipoventa,
      'codImpuesto': codImpuesto,
      'porceImpuesto': porceImpuesto,
      'observacion': observacion,
    };
  }
}
