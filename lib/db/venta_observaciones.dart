class LocalVentaObservaciones {
  String local;
  String tipoDoc;
  String numeroDoc;
  String fechaEmision;
  String rutCliente;
  String cajaDoc;
  String lineaVenta;
  String codigo;
  String observaciones;

  LocalVentaObservaciones({
    required this.local,
    required this.tipoDoc,
    required this.numeroDoc,
    required this.fechaEmision,
    required this.rutCliente,
    required this.cajaDoc,
    required this.lineaVenta,
    required this.codigo,
    required this.observaciones,
  });

  // Convertir la instancia a un mapa
  Map<String, dynamic> toMap() {
    return {
      'local': local,
      'tipo_doc': tipoDoc,
      'numero_doc': numeroDoc,
      'fecha_emision': fechaEmision,
      'rut_cliente': rutCliente,
      'caja_doc': cajaDoc,
      'linea_venta': lineaVenta,
      'codigo': codigo,
      'observaciones': observaciones,
    };
  }

  // Crear una instancia desde un mapa
  factory LocalVentaObservaciones.fromMap(Map<String, dynamic> map) {
    return LocalVentaObservaciones(
      local: map['local'],
      tipoDoc: map['tipo_doc'],
      numeroDoc: map['numero_doc'],
      fechaEmision: map['fecha_emision'],
      rutCliente: map['rut_cliente'],
      cajaDoc: map['caja_doc'],
      lineaVenta: map['linea_venta'],
      codigo: map['codigo'],
      observaciones: map['observaciones'],
    );
  }
}
