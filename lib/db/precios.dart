class MaeArticulosPrecios {
  String local;
  String codigo;
  String codigoPrecio;
  double precioVenta;
  double precioOferta;
  double precioCosto;
  double margen;
  double margen2;
  DateTime fechaVigencia;
  String precioActivo;
  String interno;
  double precioCambio;

  MaeArticulosPrecios({
    required this.local,
    required this.codigo,
    required this.codigoPrecio,
    required this.precioVenta,
    required this.precioOferta,
    required this.precioCosto,
    required this.margen,
    required this.margen2,
    required this.fechaVigencia,
    required this.precioActivo,
    required this.interno,
    required this.precioCambio,
  });

  // Convertir la instancia a un mapa
  Map<String, dynamic> toMap() {
    return {
      'local': local,
      'codigo': codigo,
      'codigoprecio': codigoPrecio,
      'precio_venta': precioVenta,
      'precio_oferta': precioOferta,
      'preciocosto': precioCosto,
      'margen': margen,
      'margen2': margen2,
      'fechavigencia': fechaVigencia.toIso8601String(),
      'precioactivo': precioActivo,
      'interno': interno,
      'precio_cambio': precioCambio,
    };
  }

  // Crear una instancia desde un mapa
  factory MaeArticulosPrecios.fromMap(Map<String, dynamic> map) {
    return MaeArticulosPrecios(
      local: map['local'],
      codigo: map['codigo'],
      codigoPrecio: map['codigoprecio'],
      precioVenta: map['precio_venta'],
      precioOferta: map['precio_oferta'] ?? 0,
      precioCosto: map['preciocosto'],
      margen: map['margen'],
      margen2: map['margen2'] ?? 0,
      fechaVigencia:
          DateTime.parse(map['fechavigencia'] ?? DateTime.now().toString()),
      precioActivo: map['precioactivo'] ?? '',
      interno: map['interno'] ?? '',
      precioCambio: map['precio_cambio'] ?? 0,
    );
  }
}
