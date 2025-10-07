class Cantidad {
  String? caja;
  int? cantidad;
  String? codigoProducto;

  Cantidad({
    this.caja,
    this.cantidad,
    this.codigoProducto,
  });

  Map<String, dynamic> toJson() {
    return {
      'cantidad': cantidad,
      'codigoProducto': codigoProducto,
      'caja': caja,
    };
  }
}
