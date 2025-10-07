class LocalRolloObservaciones {
  String codigo;
  String fecha;
  String caja;
  String observaciones;

  LocalRolloObservaciones({
    required this.codigo,
    required this.fecha,
    required this.caja,
    required this.observaciones,
  });

  // Convertir la instancia a un mapa
  Map<String, dynamic> toMap() {
    return {
      'codigo': codigo,
      'fecha': fecha,
      'caja': caja,
      'observaciones': observaciones,
    };
  }

  // Crear una instancia desde un mapa
  factory LocalRolloObservaciones.fromMap(Map<String, dynamic> map) {
    return LocalRolloObservaciones(
      codigo: map['codigo'],
      fecha: map['fecha'],
      caja: map['caja'],
      observaciones: map['observaciones'],
    );
  }
}
