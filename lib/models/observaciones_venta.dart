class ObservacionesVenta {
  String? codigoVenta;
  String? codigoProducto;
  String? observacion;

  ObservacionesVenta({this.codigoProducto, this.codigoVenta, this.observacion});

  factory ObservacionesVenta.fromJson(Map<String, dynamic> json) {
    return ObservacionesVenta(
      codigoVenta: json['numdoc'],
      codigoProducto: json['codigo'],
      observacion: json['observaciones'],
    );
  }
}
