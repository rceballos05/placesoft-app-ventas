class Cliente {
  const Cliente({
    required this.rut,
    required this.nombre,
    this.direccion,
    this.comuna,
  });

  final String rut;
  final String nombre;
  final String? direccion;
  final String? comuna;

  factory Cliente.fromMap(Map<String, dynamic> map) {
    return Cliente(
      rut: (map['rut'] ?? '').toString(),
      nombre: (map['nombre'] ?? '').toString(),
      direccion: map['direccion'] as String?,
      comuna: map['comuna'] as String?,
    );
  }
}
