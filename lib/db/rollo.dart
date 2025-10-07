class TblRolloTerreno00 {
  final String local;
  final String cajaDoc;
  final double lineaVenta;
  final String rutCajero;
  final double artCantidad;
  final String artCodigo;
  final String artDescripcion;
  final double artDescuento;
  final double artPrecio;
  final double totalLinea;
  final String rutVendedor;
  final String fechaTransaccion;
  final String horaTransaccion;
  final String tipoVenta;
  final String codImpuesto;
  final double porceImpuesto;

  TblRolloTerreno00({
    required this.local,
    required this.cajaDoc,
    required this.lineaVenta,
    required this.rutCajero,
    required this.artCantidad,
    required this.artCodigo,
    required this.artDescripcion,
    required this.artDescuento,
    required this.artPrecio,
    required this.totalLinea,
    required this.rutVendedor,
    required this.fechaTransaccion,
    required this.horaTransaccion,
    required this.tipoVenta,
    required this.codImpuesto,
    required this.porceImpuesto,
  });

  Map<String, dynamic> toMap() {
    return {
      'local': local,
      'caja_doc': cajaDoc,
      'linea_venta': lineaVenta,
      'rut_cajero': rutCajero,
      'art_cantidad': artCantidad,
      'art_codigo': artCodigo,
      'art_descripcion': artDescripcion,
      'art_descuento': artDescuento,
      'art_precio': artPrecio,
      'total_linea': totalLinea,
      'rut_vendedor': rutVendedor,
      'fecha_transaccion': fechaTransaccion,
      'hora_transaccion': horaTransaccion,
      'tipoventa': tipoVenta,
      'cod_impuesto': codImpuesto,
      'porce_impuesto': porceImpuesto,
    };
  }

  static TblRolloTerreno00 fromMap(Map<String, dynamic> map) {
    return TblRolloTerreno00(
      local: map['local'],
      cajaDoc: map['caja_doc'],
      lineaVenta: map['linea_venta'],
      rutCajero: map['rut_cajero'],
      artCantidad: map['art_cantidad'],
      artCodigo: map['art_codigo'],
      artDescripcion: map['art_descripcion'],
      artDescuento: map['art_descuento'],
      artPrecio: map['art_precio'],
      totalLinea: map['total_linea'],
      rutVendedor: map['rut_vendedor'],
      fechaTransaccion: map['fecha_transaccion'],
      horaTransaccion: map['hora_transaccion'],
      tipoVenta: map['tipoventa'],
      codImpuesto: map['cod_impuesto'],
      porceImpuesto: map['porce_impuesto'],
    );
  }
}
