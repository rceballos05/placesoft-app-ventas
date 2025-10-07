class ProductoCarro {
  // Blob? img;
  String? codigo;
  String? descripcion;
  int? precio;
  int? cantidad;
  String? observacion;
  int? articuloDescuento;
  int? precioCostoCIva;
  double? porcentajeDescuento;
  ProductoCarro({
    this.codigo,
    this.descripcion,
    this.precio,
    this.cantidad,
    this.articuloDescuento,
    this.observacion,
    this.precioCostoCIva,
    this.porcentajeDescuento,
  });

  void nuevaCantidad(int n) {
    cantidad = n;
  }

  factory ProductoCarro.fromJson(Map<String, dynamic> json) {
    return ProductoCarro(
      codigo: json['artCodigo'],
      cantidad: int.parse(json['artCantidad'].toString()),
      articuloDescuento: 0,
      descripcion: json['artDescripcion'],
      observacion: json['observacion'],
      porcentajeDescuento: 0,
      precio: int.parse(json['artPrecio'].toString()),
      precioCostoCIva: 0,
    );
  }
}
