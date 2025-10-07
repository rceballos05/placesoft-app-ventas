class LocalVentaCabeza {
  String local;
  String tipoDoc;
  String numeroDoc;
  String cajaDoc;
  String fechaEmision;
  String foliosii;
  String vencimiento;
  String rutCliente;
  String direccionDestino;
  String rutCajera;
  String notaPedido;
  String ordenDeCompra;
  double subtotal;
  double montoNeto;
  double montoIva;
  String plazo;
  double impHarina;
  double impCarne;
  double impRefrescos;
  double impLicores;
  double impVinos;
  double impLight;
  double impCerveza;
  double impDiesel;
  double montoExento;
  double montoTotal;
  double montoLey20956;
  double abono;
  double montoDonacion;
  String horaVenta;
  String horaVendedor;
  String rutVendedor;
  double dctoglobal;
  double porceDescuento;
  String formaPago;
  String despachoPatente;
  String despachoFecha;
  String despachoFolio;
  String despachoHora;
  String glosaGuia;
  String usuarioFacturacion;
  String observacion;
  String refTipo;
  String refFecha;
  String refNumero;
  String refGlosa;
  String nombreCliente;
  String fonoCliente;
  String emailCliente;
  int revision1;
  int revision2;
  int revision3;
  int generarDte;
  int numeroImpresora;
  int procesada;
  String acteco;
  int imprimePorGrupos;
  String tipoTraslado;
  double montoPropina;
  String localTraslado;
  String? estado;

  LocalVentaCabeza({
    required this.local,
    required this.tipoDoc,
    required this.numeroDoc,
    required this.cajaDoc,
    required this.fechaEmision,
    required this.foliosii,
    required this.vencimiento,
    required this.rutCliente,
    required this.direccionDestino,
    required this.rutCajera,
    required this.notaPedido,
    required this.ordenDeCompra,
    required this.subtotal,
    required this.montoNeto,
    required this.montoIva,
    required this.plazo,
    required this.impHarina,
    required this.impCarne,
    required this.impRefrescos,
    required this.impLicores,
    required this.impVinos,
    required this.impLight,
    required this.impCerveza,
    required this.impDiesel,
    required this.montoExento,
    required this.montoTotal,
    required this.montoLey20956,
    required this.abono,
    required this.montoDonacion,
    required this.horaVenta,
    required this.horaVendedor,
    required this.rutVendedor,
    required this.dctoglobal,
    required this.porceDescuento,
    required this.formaPago,
    required this.despachoPatente,
    required this.despachoFecha,
    required this.despachoFolio,
    required this.despachoHora,
    required this.glosaGuia,
    required this.usuarioFacturacion,
    required this.observacion,
    required this.refTipo,
    required this.refFecha,
    required this.refNumero,
    required this.refGlosa,
    required this.nombreCliente,
    required this.fonoCliente,
    required this.emailCliente,
    required this.revision1,
    required this.revision2,
    required this.revision3,
    required this.generarDte,
    required this.numeroImpresora,
    required this.procesada,
    required this.acteco,
    required this.imprimePorGrupos,
    required this.tipoTraslado,
    required this.montoPropina,
    required this.localTraslado,
    this.estado,
  });

  // Convertir la instancia a un mapa
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
    };
  }

  // Crear una instancia desde un mapa
  factory LocalVentaCabeza.fromMap(Map<String, dynamic> map) {
    return LocalVentaCabeza(
      local: map['local'],
      tipoDoc: map['tipo_doc'] ?? map['tipoDoc'],
      numeroDoc: map['numero_doc'] ?? map['numeroDoc'],
      cajaDoc: map['caja_doc'] ?? map['cajaDoc'],
      fechaEmision: map['fecha_emision'] ?? map['fechaEmision'],
      foliosii: map['foliosii'],
      vencimiento: map['vencimiento'],
      rutCliente: map['rut_cliente'] ?? map['rutCliente'],
      direccionDestino: map['direccion_destino'] ?? map['direccionDestino'],
      rutCajera: map['rut_cajera'] ?? map['rutCajera'],
      notaPedido: map['nota_pedido'] ?? map['notaPedido'],
      ordenDeCompra: map['orden_de_compra'] ?? map['ordenDeCompra'] ?? "",
      subtotal: double.parse(map['subtotal'].toString()),
      montoNeto: map['monto_neto'] ?? double.parse(map['montoNeto'].toString()),
      montoIva: map['monto_iva'] ?? double.parse(map['montoIva'].toString()),
      plazo: map['plazo'],
      impHarina: map['imp_harina'] ?? double.parse(map['impHarina'].toString()),
      impCarne: map['imp_carne'] ?? double.parse(map['impCarne'].toString()),
      impRefrescos:
          map['imp_refrescos'] ?? double.parse(map['impRefrescos'].toString()),
      impLicores:
          map['imp_licores'] ?? double.parse(map['impLicores'].toString()),
      impVinos: map['imp_vinos'] ?? double.parse(map['impVinos'].toString()),
      impLight: map['imp_light'] ?? double.parse(map['impLight'].toString()),
      impCerveza:
          map['imp_cerveza'] ?? double.parse(map['impCerveza'].toString()),
      impDiesel: map['imp_diesel'] ?? double.parse(map['impDiesel'].toString()),
      montoExento:
          map['monto_exento'] ?? double.parse(map['montoExento'].toString()),
      montoTotal:
          map['monto_total'] ?? double.parse(map['montoTotal'].toString()),
      montoLey20956: map['monto_ley20956'] ??
          double.parse(map['montoLey20956'].toString()),
      abono: double.parse(map['abono'].toString()),
      montoDonacion: map['monto_donacion'] ??
          double.parse(map['montoDonacion'].toString()),
      horaVenta: map['hora_venta'] ?? map['horaVenta'],
      horaVendedor: map['hora_vendedor'] ?? map['horaVendedor'],
      rutVendedor: map['rut_vendedor'] ?? map['rutVendedor'],
      dctoglobal: map['dctoglobal'].toDouble(),
      porceDescuento: map['porce_descuento'] ??
          double.parse(map['porceDescuento'].toString()),
      formaPago: map['formapago'] ?? map['formaPago'],
      despachoPatente: map['despacho_patente'] ?? map['despachoPatente'],
      despachoFecha: map['despacho_fecha'] ?? map['despachoFecha'],
      despachoFolio: map['despacho_folio'] ?? map['despachoFolio'],
      despachoHora: map['despacho_hora'] ?? map['despachoHora'],
      glosaGuia: map['glosa_guia'] ?? map['glosaGuia'],
      usuarioFacturacion:
          map['usuario_facturacion'] ?? map['usuarioFacturacion'],
      observacion: map['observacion'],
      refTipo: map['ref_tipo'] ?? map['refTipo'],
      refFecha: map['ref_fecha'] ?? map['refFecha'],
      refNumero: map['ref_numero'] ?? map['refNumero'],
      refGlosa: map['ref_glosa'] ?? map['refGlosa'],
      nombreCliente: map['nombre_cliente'] ?? map['nombreCliente'],
      fonoCliente: map['fono_cliente'] ?? map['fonoCliente'],
      emailCliente: map['email_cliente'] ?? map['emailCliente'],
      revision1: map['revision1'],
      revision2: map['revision2'],
      revision3: map['revision3'],
      generarDte: map['generar_dte'] ?? map['generarDte'],
      numeroImpresora: 0,
      procesada: map['procesada'],
      acteco: map['acteco'],
      imprimePorGrupos: map['imprime_por_grupos'] ?? map['imprimePorGrupos'],
      tipoTraslado: map['tipo_traslado'] ?? map['tipoTraslado'],
      montoPropina:
          map['monto_propina'] ?? double.parse(map['montoPropina'].toString()),
      localTraslado: map['local_traslado'] ?? map['localTraslado'],
    );
  }
}
