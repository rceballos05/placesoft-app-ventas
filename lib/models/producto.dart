class Producto {
  const Producto({
    required this.codigobarra,
    required this.descripcion,
    required this.precio,
    required this.descuento,
  });

  final String codigobarra;
  final String descripcion;
  final int precio;
  final int descuento;
}
