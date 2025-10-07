class DetalleVentaDto {
  String local;
  String tipoDoc;
  String numeroDoc;
  String cajaDoc;
  String lineaVenta;
  String fechaEmision;
  String rutCliente;
  String destinoCliente;
  String artCodigo;
  String artDescripcion;
  double artCantidad;
  double artPrecio;
  double artDescuento;
  double porceDescuento;
  double totalLinea;
  String rutVendedor;
  double precioCostoCiva;
  String almacen;
  String impuesto;
  double porceImpuesto;
  double montoImpuesto;
  double descuento;
  String horaventa;
  String usuarioFacturacion;
  String foliosii;
  String fechaviaje;
  String refTipo;
  String refNumero;
  String refFecha;
  String? observacion;

  DetalleVentaDto({
    required this.local,
    required this.tipoDoc,
    required this.numeroDoc,
    required this.cajaDoc,
    required this.lineaVenta,
    required this.fechaEmision,
    required this.rutCliente,
    required this.destinoCliente,
    required this.artCodigo,
    required this.artDescripcion,
    required this.artCantidad,
    required this.artPrecio,
    required this.artDescuento,
    required this.porceDescuento,
    required this.totalLinea,
    required this.rutVendedor,
    required this.precioCostoCiva,
    required this.almacen,
    required this.impuesto,
    required this.porceImpuesto,
    required this.montoImpuesto,
    required this.descuento,
    required this.horaventa,
    required this.usuarioFacturacion,
    required this.foliosii,
    required this.fechaviaje,
    required this.refTipo,
    required this.refNumero,
    required this.refFecha,
    this.observacion,
  });

  Map<String, dynamic> toMap() {
    return {
      'local': local,
      'tipo_doc': tipoDoc,
      'numero_doc': numeroDoc,
      'caja_doc': cajaDoc,
      'linea_venta': lineaVenta,
      'fecha_emision': fechaEmision,
      'rut_cliente': rutCliente,
      'destino_cliente': destinoCliente,
      'art_codigo': artCodigo,
      'art_descripcion': artDescripcion,
      'art_cantidad': artCantidad,
      'art_precio': artPrecio,
      'art_descuento': artDescuento,
      'porce_descuento': porceDescuento,
      'total_linea': totalLinea,
      'rut_vendedor': rutVendedor,
      'precio_costo_civa': precioCostoCiva,
      'almacen': almacen,
      'impuesto': impuesto,
      'porce_impuesto': porceImpuesto,
      'monto_impuesto': montoImpuesto,
      'descuento': descuento,
      'horaventa': horaventa,
      'usuario_facturacion': usuarioFacturacion,
      'foliosii': foliosii,
      'fechaviaje': fechaviaje,
      'ref_tipo': refTipo,
      'ref_numero': refNumero,
      'ref_fecha': refFecha,
      'observacion': observacion,
    };
  }

  factory DetalleVentaDto.fromMap(Map<String, dynamic> map) {
    return DetalleVentaDto(
      local: map['local'],
      tipoDoc: map['tipo_doc'],
      numeroDoc: map['numero_doc'],
      cajaDoc: map['caja_doc'],
      lineaVenta: map['linea_venta'],
      fechaEmision: map['fecha_emision'],
      rutCliente: map['rut_cliente'] ?? "",
      destinoCliente: map['destino_cliente'],
      artCodigo: map['art_codigo'],
      artDescripcion: map['art_descripcion'],
      artCantidad: map['art_cantidad'],
      artPrecio: map['art_precio'],
      artDescuento: map['art_descuento'],
      porceDescuento: map['porce_descuento'],
      totalLinea: map['total_linea'],
      rutVendedor: map['rut_vendedor'],
      precioCostoCiva: map['precio_costo_civa'],
      almacen: map['almacen'],
      impuesto: map['impuesto'],
      porceImpuesto: map['porce_impuesto'],
      montoImpuesto: map['monto_impuesto'],
      descuento: map['descuento'],
      horaventa: map['horaventa'],
      usuarioFacturacion: map['usuario_facturacion'],
      foliosii: map['foliosii'],
      fechaviaje: map['fechaviaje'],
      refTipo: map['ref_tipo'],
      refNumero: map['ref_numero'],
      refFecha: map['ref_fecha'],
      observacion: map['observacion'],
    );
  }
}
