class Usuario {
  const Usuario({
    required this.rut,
    required this.nombre,
    required this.correo,
    required this.caja,
    required this.prefijo,
    required this.maxDscto,
    required this.tieneDescuento,
  });

  final String rut;
  final String nombre;
  final String correo;
  final String caja;
  final String prefijo;
  final double maxDscto;
  final bool tieneDescuento;
}
