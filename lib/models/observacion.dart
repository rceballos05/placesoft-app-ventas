class Observacion {
  String? caja;
  String? observacion;
  String? codigoProducto;

  Observacion({
    this.caja,
    this.observacion,
    this.codigoProducto,
  });

  Map<String, dynamic> toJson() {
    return {
      'observacion': observacion,
      'codigoProducto': codigoProducto,
      'caja': caja,
    };
  }
}
