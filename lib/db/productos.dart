class MaeArticulos {
  // Definición de las columnas de la tabla
  static final String tableName = 'mae_articulos_00';

  static final String columnCodigobarra = 'codigobarra';
  static final String columnDescripcion = 'descripcion';
  static final String columnFechaCreacion = 'fecha_creacion';
  static final String columnCodImpuesto = 'cod_impuesto';
  static final String columnCodSeccion = 'cod_seccion';
  static final String columnCodDepto = 'cod_depto';
  static final String columnCodLinea = 'cod_linea';
  static final String columnCodMarca = 'cod_marca';
  static final String columnCodImpresion = 'cod_impresion';
  static final String columnProveedor = 'proveedor';
  static final String columnUniMedida = 'uni_medida';
  static final String columnContenido = 'contenido';
  static final String columnTipoEmbalaje = 'tipo_embalaje';
  static final String columnQtyPorembalaje = 'qty_porembalaje';
  static final String columnEsPesable = 'es_pesable';
  static final String columnReferenciaproveedor = 'referenciaproveedor';
  static final String columnUltPrecioCompra = 'ult_precio_compra';
  static final String columnPrecioCostoCiva = 'precio_costo_civa';
  static final String columnMargenBase = 'margen_base';
  static final String columnCodInterno = 'cod_interno';
  static final String columnCodTemporada = 'cod_temporada';
  static final String columnProcesado = 'procesado';
  static final String columnArtDescontinuado = 'art_descontinuado';
  static final String columnPrecioLibre = 'precio_libre';
  static final String columnDescuento = 'descuento';
  static final String columnNoDcto = 'no_dcto';
  static final String columnEsPack = 'es_pack';
  static final String columnEsHarina = 'es_harina';
  static final String columnMontoFlete = 'monto_flete';
  static final String columnWebEsInternet = 'web_es_internet';
  static final String columnWebPublicado = 'web_publicado';
  static final String columnWebStockPositivo = 'web_stock_positivo';
  static final String columnWebDescripcion = 'web_descripcion';
  static final String columnWebDetalleArticulo = 'web_detalle_articulo';
  static final String columnWebUrl = 'web_url';
  static final String columnWebMedidas = 'web_medidas';
  static final String columnTieneVencimiento = 'tiene_vencimiento';
  static final String columnAfectoInventario = 'afecto_inventario';
  static final String columnAfectoVenta = 'afecto_venta';
  static final String columnAfectoCompra = 'afecto_compra';
  static final String columnActivoInmovil = 'activo_inmovil';
  static final String columnEsServicio = 'es_servicio';
  static final String columnUnixenvase = 'unixenvase';
  static final String columnUnicontenido = 'unicontenido';
  static final String columnUnicompramax = 'unicompramax';
  static final String columnUnicompramin = 'unicompramin';
  static final String columnAutorizaCompra = 'autoriza_compra';
  static final String columnContenidoFragil = 'contenido_fragil';
  static final String columnCantidadCritica = 'cantidad_critica';
  static final String columnProduccionEs = 'produccion_es';
  static final String columnProduccionMaterial = 'produccion_material';
  static final String columnProduccionCantidad = 'produccion_cantidad';
  static final String columnProduccionDiasDuracion = 'produccion_dias_duracion';
  static final String columnProduccionTotalCosto = 'produccion_total_costo';
  static final String columnProduccionFabricacion = 'produccion_fabricacion';
  static final String columnProduccionEnvasado = 'produccion_envasado';
  static final String columnProduccionTransporte = 'produccion_transporte';
  static final String columnBloquearVenta = 'bloquear_venta';
  static final String columnAutorizado = 'autorizado';
  static final String columnStockTemporal = 'stock_temporal';
  static final String columnBarcode13 = 'barcode13';
  static final String columnPesoKilos = 'peso_kilos';
  static final String columnMargenMinimo = 'margen_minimo';
  static final String columnModificaDescripcion = 'modifica_descripcion';
  static final String columnDescripcionFlejes = 'descripcion_flejes';
  static final String columnLocalCreacion = 'local_creacion';
  static final String columnVendeCodigoAsociado = 'vende_codigo_asociado';
  static final String columnDiasVencimiento = 'dias_vencimiento';

  // Define los atributos de la clase
  final String codigobarra;
  final String descripcion;
  final DateTime fechaCreacion;
  final String codImpuesto;
  final String codSeccion;
  final String codDepto;
  final String codLinea;
  final String codMarca;
  final String codImpresion;
  final String proveedor;
  final String uniMedida;
  final String contenido;
  final String tipoEmbalaje;
  final double qtyPorembalaje;
  final String esPesable;
  final String referenciaproveedor;
  final double ultPrecioCompra;
  final double precioCostoCiva;
  final double margenBase;
  final String codInterno;
  final String codTemporada;
  final String procesado;
  final int artDescontinuado;
  final int precioLibre;
  final double descuento;
  final int noDcto;
  final String esPack;
  final int esHarina;
  final double montoFlete;
  final int webEsInternet;
  final int webPublicado;
  final int webStockPositivo;
  final String webDescripcion;
  final String webDetalleArticulo;
  final String webUrl;
  final String webMedidas;
  final int tieneVencimiento;
  final int afectoInventario;
  final int afectoVenta;
  final int afectoCompra;
  final int activoInmovil;
  final int esServicio;
  final double unixenvase;
  final double unicontenido;
  final double unicompramax;
  final double unicompramin;
  final int autorizaCompra;
  final int contenidoFragil;
  final double cantidadCritica;
  final int produccionEs;
  final int produccionMaterial;
  final double produccionCantidad;
  final double produccionDiasDuracion;
  final double produccionTotalCosto;
  final String produccionFabricacion;
  final String produccionEnvasado;
  final String produccionTransporte;
  final int bloquearVenta;
  final int autorizado;
  final double stockTemporal;
  final String barcode13;
  final double pesoKilos;
  final double margenMinimo;
  final int modificaDescripcion;
  final String descripcionFlejes;
  final String localCreacion;
  final int vendeCodigoAsociado;
  final int diasVencimiento;

  MaeArticulos({
    required this.codigobarra,
    required this.descripcion,
    required this.fechaCreacion,
    required this.codImpuesto,
    required this.codSeccion,
    required this.codDepto,
    required this.codLinea,
    required this.codMarca,
    required this.codImpresion,
    required this.proveedor,
    required this.uniMedida,
    required this.contenido,
    required this.tipoEmbalaje,
    required this.qtyPorembalaje,
    required this.esPesable,
    required this.referenciaproveedor,
    required this.ultPrecioCompra,
    required this.precioCostoCiva,
    required this.margenBase,
    required this.codInterno,
    required this.codTemporada,
    required this.procesado,
    required this.artDescontinuado,
    required this.precioLibre,
    required this.descuento,
    required this.noDcto,
    required this.esPack,
    required this.esHarina,
    required this.montoFlete,
    required this.webEsInternet,
    required this.webPublicado,
    required this.webStockPositivo,
    required this.webDescripcion,
    required this.webDetalleArticulo,
    required this.webUrl,
    required this.webMedidas,
    required this.tieneVencimiento,
    required this.afectoInventario,
    required this.afectoVenta,
    required this.afectoCompra,
    required this.activoInmovil,
    required this.esServicio,
    required this.unixenvase,
    required this.unicontenido,
    required this.unicompramax,
    required this.unicompramin,
    required this.autorizaCompra,
    required this.contenidoFragil,
    required this.cantidadCritica,
    required this.produccionEs,
    required this.produccionMaterial,
    required this.produccionCantidad,
    required this.produccionDiasDuracion,
    required this.produccionTotalCosto,
    required this.produccionFabricacion,
    required this.produccionEnvasado,
    required this.produccionTransporte,
    required this.bloquearVenta,
    required this.autorizado,
    required this.stockTemporal,
    required this.barcode13,
    required this.pesoKilos,
    required this.margenMinimo,
    required this.modificaDescripcion,
    required this.descripcionFlejes,
    required this.localCreacion,
    required this.vendeCodigoAsociado,
    required this.diasVencimiento,
  });

  // Método para convertir un mapa a una instancia de MaeArticulos
  factory MaeArticulos.fromMap(Map<String, dynamic> map) {
    return MaeArticulos(
      codigobarra: map[columnCodigobarra],
      descripcion: map[columnDescripcion],
      fechaCreacion: DateTime.parse(map[columnFechaCreacion]),
      codImpuesto: map[columnCodImpuesto],
      codSeccion: map[columnCodSeccion],
      codDepto: map[columnCodDepto],
      codLinea: map[columnCodLinea],
      codMarca: map[columnCodMarca],
      codImpresion: map[columnCodImpresion],
      proveedor: map[columnProveedor],
      uniMedida: map[columnUniMedida],
      contenido: map[columnContenido],
      tipoEmbalaje: map[columnTipoEmbalaje],
      qtyPorembalaje: map[columnQtyPorembalaje] ?? "",
      esPesable: map[columnEsPesable],
      referenciaproveedor: map[columnReferenciaproveedor],
      ultPrecioCompra: map[columnUltPrecioCompra],
      precioCostoCiva: double.parse(map[columnPrecioCostoCiva].toString()),
      margenBase: map[columnMargenBase],
      codInterno: map[columnCodInterno],
      codTemporada: map[columnCodTemporada] ?? "",
      procesado: map[columnProcesado],
      artDescontinuado: map[columnArtDescontinuado],
      precioLibre: map[columnPrecioLibre],
      descuento: map[columnDescuento],
      noDcto: map[columnNoDcto],
      esPack: map[columnEsPack],
      esHarina: map[columnEsHarina],
      montoFlete: map[columnMontoFlete],
      webEsInternet: map[columnWebEsInternet],
      webPublicado: map[columnWebPublicado],
      webStockPositivo: map[columnWebStockPositivo],
      webDescripcion: map[columnWebDescripcion] ?? "",
      webDetalleArticulo: map[columnWebDetalleArticulo] ?? "",
      webUrl: map[columnWebUrl] ?? "",
      webMedidas: map[columnWebMedidas],
      tieneVencimiento: map[columnTieneVencimiento],
      afectoInventario: map[columnAfectoInventario],
      afectoVenta: map[columnAfectoVenta],
      afectoCompra: map[columnAfectoCompra],
      activoInmovil: map[columnActivoInmovil],
      esServicio: map[columnEsServicio],
      unixenvase: map[columnUnixenvase],
      unicontenido: map[columnUnicontenido],
      unicompramax: map[columnUnicompramax],
      unicompramin: map[columnUnicompramin],
      autorizaCompra: map[columnAutorizaCompra],
      contenidoFragil: map[columnContenidoFragil],
      cantidadCritica: map[columnCantidadCritica],
      produccionEs: map[columnProduccionEs],
      produccionMaterial: map[columnProduccionMaterial],
      produccionCantidad: map[columnProduccionCantidad] ?? 0,
      produccionDiasDuracion: map[columnProduccionDiasDuracion] ?? 0,
      produccionTotalCosto: map[columnProduccionTotalCosto] ?? 0,
      produccionFabricacion: map[columnProduccionFabricacion] ?? "",
      produccionEnvasado: map[columnProduccionEnvasado] ?? "",
      produccionTransporte: map[columnProduccionTransporte] ?? "",
      bloquearVenta: map[columnBloquearVenta] ?? 0,
      autorizado: map[columnAutorizado] ?? 0,
      stockTemporal: map[columnStockTemporal] ?? 0,
      barcode13: map[columnBarcode13],
      pesoKilos: map[columnPesoKilos],
      margenMinimo: map[columnMargenMinimo],
      modificaDescripcion: map[columnModificaDescripcion] ?? 0,
      descripcionFlejes: map[columnDescripcionFlejes] ?? "",
      localCreacion: map[columnLocalCreacion] ?? "00",
      vendeCodigoAsociado: map[columnVendeCodigoAsociado],
      diasVencimiento: map[columnDiasVencimiento],
    );
  }

  // Método para convertir una instancia de MaeArticulos a un mapa
  Map<String, dynamic> toMap() {
    return {
      columnCodigobarra: codigobarra,
      columnDescripcion: descripcion,
      columnFechaCreacion: fechaCreacion.toIso8601String(),
      columnCodImpuesto: codImpuesto,
      columnCodSeccion: codSeccion,
      columnCodDepto: codDepto,
      columnCodLinea: codLinea,
      columnCodMarca: codMarca,
      columnCodImpresion: codImpresion,
      columnProveedor: proveedor,
      columnUniMedida: uniMedida,
      columnContenido: contenido,
      columnTipoEmbalaje: tipoEmbalaje,
      columnQtyPorembalaje: qtyPorembalaje,
      columnEsPesable: esPesable,
      columnReferenciaproveedor: referenciaproveedor,
      columnUltPrecioCompra: ultPrecioCompra,
      columnPrecioCostoCiva: precioCostoCiva,
      columnMargenBase: margenBase,
      columnCodInterno: codInterno,
      columnCodTemporada: codTemporada,
      columnProcesado: procesado,
      columnArtDescontinuado: artDescontinuado,
      columnPrecioLibre: precioLibre,
      columnDescuento: descuento,
      columnNoDcto: noDcto,
      columnEsPack: esPack,
      columnEsHarina: esHarina,
      columnMontoFlete: montoFlete,
      columnWebEsInternet: webEsInternet,
      columnWebPublicado: webPublicado,
      columnWebStockPositivo: webStockPositivo,
      columnWebDescripcion: webDescripcion,
      columnWebDetalleArticulo: webDetalleArticulo,
      columnWebUrl: webUrl,
      columnWebMedidas: webMedidas,
      columnTieneVencimiento: tieneVencimiento,
      columnAfectoInventario: afectoInventario,
      columnAfectoVenta: afectoVenta,
      columnAfectoCompra: afectoCompra,
      columnActivoInmovil: activoInmovil,
      columnEsServicio: esServicio,
      columnUnixenvase: unixenvase,
      columnUnicontenido: unicontenido,
      columnUnicompramax: unicompramax,
      columnUnicompramin: unicompramin,
      columnAutorizaCompra: autorizaCompra,
      columnContenidoFragil: contenidoFragil,
      columnCantidadCritica: cantidadCritica,
      columnProduccionEs: produccionEs,
      columnProduccionMaterial: produccionMaterial,
      columnProduccionCantidad: produccionCantidad,
      columnProduccionDiasDuracion: produccionDiasDuracion,
      columnProduccionTotalCosto: produccionTotalCosto,
      columnProduccionFabricacion: produccionFabricacion,
      columnProduccionEnvasado: produccionEnvasado,
      columnProduccionTransporte: produccionTransporte,
      columnBloquearVenta: bloquearVenta,
      columnAutorizado: autorizado,
      columnStockTemporal: stockTemporal,
      columnBarcode13: barcode13,
      columnPesoKilos: pesoKilos,
      columnMargenMinimo: margenMinimo,
      columnModificaDescripcion: modificaDescripcion,
      columnDescripcionFlejes: descripcionFlejes,
      columnLocalCreacion: localCreacion,
      columnVendeCodigoAsociado: vendeCodigoAsociado,
      columnDiasVencimiento: diasVencimiento,
    };
  }
}
