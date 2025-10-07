class Venta {
  String? local;
  String? tipoDoc;
  String? numeroDoc;
  String? cajaDoc;
  String? lineVenta;
  String? fecha;
  String? rutCliente;
  String? destinoCliente;
  String? almacen;
  String? rutVendedor;
  List<ArticulosVenta>? articulos;
  Venta(
      {this.almacen,
      this.articulos,
      this.cajaDoc,
      this.destinoCliente,
      this.fecha,
      this.lineVenta,
      this.local,
      this.numeroDoc,
      this.rutCliente,
      this.rutVendedor,
      this.tipoDoc});
  Map<String, dynamic> toJson() {
    return {
      "local": local,
      "tipoDoc": tipoDoc,
      "numeroDoc": numeroDoc,
      "cajaDoc": cajaDoc,
      "lineVenta": lineVenta,
      "fecha": fecha,
      "rutCliente": rutCliente,
      "destinoCliente": destinoCliente,
      "almacen": almacen,
      "rutVendedor": rutVendedor,
      "articulos": articulos
    };
  }

  factory Venta.fromJson(Map<String, dynamic> json) {
    return Venta(
      almacen: json["almacen"],
      articulos: json["articulos"],
      cajaDoc: json["cajaDoc"],
      destinoCliente: json["destinoCliente"],
      fecha: json["fecha"],
      lineVenta: json["lineaVenta"],
      local: json["local"],
      numeroDoc: json["numeroDoc"],
      rutCliente: json["rutCliente"],
      rutVendedor: json["rutVendedor"],
      tipoDoc: json["tipoDoc"],
    );
  }
}

class ArticulosVenta {
  String? codigo;
  String? descripcion;
  int? cantidad;
  int? precio;
  int? articuloDescuento;
  double? porcentajeDescuento;
  int? totalLinea;
  int? precioCostoCIva;
  ArticulosVenta(
      {this.codigo,
      this.cantidad,
      this.articuloDescuento,
      this.descripcion,
      this.porcentajeDescuento,
      this.precio,
      this.precioCostoCIva,
      this.totalLinea});
  Map<String, dynamic> toJson() {
    return {
      "codigo": codigo,
      "descripcion": descripcion,
      "cantidad": cantidad,
      "precio": precio,
      "articuloDescuento": articuloDescuento,
      "porcentajeDescuento": porcentajeDescuento,
      "totalLinea": totalLinea,
      "precioCostoCIva": precioCostoCIva
    };
  }
}
