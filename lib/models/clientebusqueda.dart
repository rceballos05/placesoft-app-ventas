class ClienteBusquedaDto {
  final String rut;
  final String nombre;
  final String direccion;
  final String comuna;
  final String ciudad;
  final String? destinoCodigo;
  final String? destinoDescripcion;
  final String? contacto;
  final String? telefono;
  final String? email;

  ClienteBusquedaDto({
    required this.rut,
    required this.nombre,
    required this.direccion,
    required this.comuna,
    required this.ciudad,
    this.destinoCodigo,
    this.destinoDescripcion,
    this.contacto,
    this.telefono,
    this.email,
  });

  factory ClienteBusquedaDto.fromMap(Map<String, dynamic> map) {
    return ClienteBusquedaDto(
      rut: map['rut'] ?? '',
      nombre: map['nombre'] ?? '',
      direccion: map['direccion'] ?? '',
      comuna: map['comuna'] ?? '',
      ciudad: map['ciudad'] ?? '',
      destinoCodigo: map['codigo'] ?? '',
      destinoDescripcion: map['descripcion'] ?? '',
      contacto: map['nombre_contacto'] ?? '',
      telefono: map['fono_contacto'] ?? '',
      email: map['email_contacto'] ?? '',
    );
  }
}
