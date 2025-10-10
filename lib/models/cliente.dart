class Cliente {
  const Cliente({
    required this.codigo,
    required this.nombre,
    this.direccion,
    this.comuna,
  });

  final String codigo;
  final String nombre;
  final String? direccion;
  final String? comuna;
}
