class VentaDetalle {
  String? numeroDoc;
  String? fechaEmision;
  String? rutCliente;
  String? codigoArticulo;
  String? descripcionArticulo;
  int? cantidad;
  double? precioUnitario;
  double? total;
  String? rutVendedor;
  VentaDetalle(
      {this.cantidad,
      this.codigoArticulo,
      this.descripcionArticulo,
      this.fechaEmision,
      this.numeroDoc,
      this.precioUnitario,
      this.rutCliente,
      this.rutVendedor,
      this.total});
  factory VentaDetalle.fromJson(Map<String, dynamic> json) {
    return VentaDetalle(
      numeroDoc: json['numeroDoc'],
      fechaEmision: "" + json['fechaEmision'] + " " + json['horaVendedor'],
      rutVendedor: json['rutVendedor'],
      rutCliente: json['rutCliente'],
      total: double.parse(json['montoTotal'].toString()),
    );
  }
  factory VentaDetalle.fromMap(Map<String, dynamic> json) {
    return VentaDetalle(
      numeroDoc: json['numeroDoc'],
      fechaEmision: json['fechaEmision'],
      rutVendedor: json['rutVendedor'],
      rutCliente: json['rutCliente'],
      cantidad: json['artCantidad'],
      codigoArticulo: json['artCodigo'],
      descripcionArticulo: json['artDescripcion'],
      precioUnitario: double.parse(json['artPrecio'].toString()),
      total: double.parse(json['totalLinea'].toString()),
    );
  }
}
