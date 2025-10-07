class DetalleVentaCabezaDto {
  String? local;
  String? tipoDoc;
  String? numeroDoc;
  String? cajaDoc;
  String? fechaEmision;
  String? foliosii;
  String? vencimiento;
  String? rutCliente;
  String? direccionDestino;
  String? rutCajera;
  String? notaPedido;
  String? ordenDeCompra;
  double? subtotal;
  double? montoNeto;
  double? montoIva;
  String? plazo;
  double? impHarina;
  double? impCarne;
  double? impRefrescos;
  double? impLicores;
  double? impVinos;
  double? impLight;
  double? impCerveza;
  double? impDiesel;
  double? montoExento;
  double? montoTotal;
  double? montoLey20956;
  double? abono;
  double? montoDonacion;
  String? horaVenta;
  String? horaVendedor;
  String? rutVendedor;
  double? dctoglobal;
  double? porceDescuento;
  String? formaPago;
  String? despachoPatente;
  String? despachoFecha;
  String? despachoFolio;
  String? despachoHora;
  String? glosaGuia;
  String? usuarioFacturacion;
  String? observacion;
  String? refTipo;
  String? refFecha;
  String? refNumero;
  String? refGlosa;
  String? nombreCliente;
  String? fonoCliente;
  String? emailCliente;
  int? revision1;
  int? revision2;
  int? revision3;
  int? generarDte;
  int? numeroImpresora;
  int? procesada;
  String? acteco;
  int? imprimePorGrupos;
  String? tipoTraslado;
  double? montoPropina;
  String? localTraslado;
  String? estado;

  DetalleVentaCabezaDto({
    this.abono,
    this.acteco,
    this.cajaDoc,
    this.dctoglobal,
    this.despachoFecha,
    this.despachoFolio,
    this.despachoHora,
    this.despachoPatente,
    this.direccionDestino,
    this.emailCliente,
    this.fechaEmision,
    this.foliosii,
    this.fonoCliente,
    this.formaPago,
    this.generarDte,
    this.glosaGuia,
    this.horaVendedor,
    this.horaVenta,
    this.impCarne,
    this.impCerveza,
    this.impDiesel,
    this.impHarina,
    this.impLicores,
    this.impLight,
    this.impRefrescos,
    this.impVinos,
    this.imprimePorGrupos,
    this.local,
    this.localTraslado,
    this.montoDonacion,
    this.montoExento,
    this.montoIva,
    this.montoLey20956,
    this.montoNeto,
    this.montoPropina,
    this.montoTotal,
    this.nombreCliente,
    this.notaPedido,
    this.numeroDoc,
    this.numeroImpresora,
    this.observacion,
    this.ordenDeCompra,
    this.plazo,
    this.porceDescuento,
    this.procesada,
    this.refFecha,
    this.refGlosa,
    this.refNumero,
    this.refTipo,
    this.revision1,
    this.revision2,
    this.revision3,
    this.rutCajera,
    this.rutCliente,
    this.rutVendedor,
    this.subtotal,
    this.tipoDoc,
    this.tipoTraslado,
    this.usuarioFacturacion,
    this.vencimiento,
    this.estado,
  });

  Map<String, dynamic> toMap() {
    return {
      'local': local,
      'tipo_doc': tipoDoc,
      'numero_doc': numeroDoc,
      'caja_doc': cajaDoc,
      'fecha_emision': fechaEmision,
      'foliosii': foliosii,
      'vencimiento': vencimiento,
      'rut_cliente': rutCliente,
      'direccion_destino': direccionDestino,
      'rut_cajera': rutCajera,
      'nota_pedido': notaPedido,
      'orden_de_compra': ordenDeCompra,
      'subtotal': subtotal,
      'monto_neto': montoNeto,
      'monto_iva': montoIva,
      'plazo': plazo,
      'imp_harina': impHarina,
      'imp_carne': impCarne,
      'imp_refrescos': impRefrescos,
      'imp_licores': impLicores,
      'imp_vinos': impVinos,
      'imp_light': impLight,
      'imp_cerveza': impCerveza,
      'imp_diesel': impDiesel,
      'monto_exento': montoExento,
      'monto_total': montoTotal,
      'monto_ley20956': montoLey20956,
      'abono': abono,
      'monto_donacion': montoDonacion,
      'hora_venta': horaVenta,
      'hora_vendedor': horaVendedor,
      'rut_vendedor': rutVendedor,
      'dctoglobal': dctoglobal,
      'porce_descuento': porceDescuento,
      'formapago': formaPago,
      'despacho_patente': despachoPatente,
      'despacho_fecha': despachoFecha,
      'despacho_folio': despachoFolio,
      'despacho_hora': despachoHora,
      'glosa_guia': glosaGuia,
      'usuario_facturacion': usuarioFacturacion,
      'observacion': observacion,
      'ref_tipo': refTipo,
      'ref_fecha': refFecha,
      'ref_numero': refNumero,
      'ref_glosa': refGlosa,
      'nombre_cliente': nombreCliente,
      'fono_cliente': fonoCliente,
      'email_cliente': emailCliente,
      'revision1': revision1,
      'revision2': revision2,
      'revision3': revision3,
      'generar_dte': generarDte,
      'numero_impresora': numeroImpresora,
      'procesada': procesada,
      'acteco': acteco,
      'imprime_por_grupos': imprimePorGrupos,
      'tipo_traslado': tipoTraslado,
      'monto_propina': montoPropina,
      'local_traslado': localTraslado,
      'estado': estado,
    };
  }

  factory DetalleVentaCabezaDto.fromJson(Map<String, dynamic> json) {
    return DetalleVentaCabezaDto(
      local: json['local'],
      tipoDoc: json['tipo_doc'],
      numeroDoc: json['numero_doc'],
      cajaDoc: json['caja_doc'],
      fechaEmision: json['fecha_emision'],
      foliosii: json['foliosii'],
      vencimiento: json['vencimiento'],
      rutCliente: json['rut_cliente'],
      direccionDestino: json['direccion_destino'],
      rutCajera: json['rut_cajera'],
      notaPedido: json['nota_pedido'],
      ordenDeCompra: json['orden_de_compra'],
      subtotal: (json['subtotal'] as num?)?.toDouble(),
      montoNeto: (json['monto_neto'] as num?)?.toDouble(),
      montoIva: (json['monto_iva'] as num?)?.toDouble(),
      plazo: json['plazo'],
      impHarina: (json['imp_harina'] as num?)?.toDouble(),
      impCarne: (json['imp_carne'] as num?)?.toDouble(),
      impRefrescos: (json['imp_refrescos'] as num?)?.toDouble(),
      impLicores: (json['imp_licores'] as num?)?.toDouble(),
      impVinos: (json['imp_vinos'] as num?)?.toDouble(),
      impLight: (json['imp_light'] as num?)?.toDouble(),
      impCerveza: (json['imp_cerveza'] as num?)?.toDouble(),
      impDiesel: (json['imp_diesel'] as num?)?.toDouble(),
      montoExento: (json['monto_exento'] as num?)?.toDouble(),
      montoTotal: (json['monto_total'] as num?)?.toDouble(),
      montoLey20956: (json['monto_ley20956'] as num?)?.toDouble(),
      abono: (json['abono'] as num?)?.toDouble(),
      montoDonacion: (json['monto_donacion'] as num?)?.toDouble(),
      horaVenta: json['hora_venta'],
      horaVendedor: json['hora_vendedor'],
      rutVendedor: json['rut_vendedor'],
      dctoglobal: (json['dctoglobal'] as num?)?.toDouble(),
      porceDescuento: (json['porce_descuento'] as num?)?.toDouble(),
      formaPago: json['formapago'],
      despachoPatente: json['despacho_patente'],
      despachoFecha: json['despacho_fecha'],
      despachoFolio: json['despacho_folio'],
      despachoHora: json['despacho_hora'],
      glosaGuia: json['glosa_guia'],
      usuarioFacturacion: json['usuario_facturacion'],
      observacion: json['observacion'],
      refTipo: json['ref_tipo'],
      refFecha: json['ref_fecha'],
      refNumero: json['ref_numero'],
      refGlosa: json['ref_glosa'],
      nombreCliente: json['nombre_cliente'],
      fonoCliente: json['fono_cliente'],
      emailCliente: json['email_cliente'],
      revision1: json['revision1'],
      revision2: json['revision2'],
      revision3: json['revision3'],
      generarDte: json['generar_dte'],
      numeroImpresora: json['numero_impresora'],
      procesada: json['procesada'],
      acteco: json['acteco'],
      imprimePorGrupos: json['imprime_por_grupos'],
      tipoTraslado: json['tipo_traslado'],
      montoPropina: (json['monto_propina'] as num?)?.toDouble(),
      localTraslado: json['local_traslado'],
    );
  }
}
