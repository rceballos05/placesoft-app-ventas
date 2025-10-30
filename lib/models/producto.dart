class Producto {
  final String codigobarra;
  final String descripcion;
  final String? codInterno;
  final double? precioVenta;

  const Producto({
    required this.codigobarra,
    required this.descripcion,
    this.codInterno,
    this.precioVenta,
  });

  factory Producto.fromMap(Map<String, dynamic> map) {
    return Producto(
      codigobarra: map['codigobarra']?.toString() ?? '',
      descripcion: map['descripcion']?.toString() ?? '',
      codInterno: map['cod_interno']?.toString(),
      precioVenta: (map['precio_venta'] as num?)?.toDouble(),
    );
  }

  double get precio => precioVenta ?? 0;

  double get descuento => 0;
}
