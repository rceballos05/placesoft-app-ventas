import 'package:flutter/foundation.dart';

/// Cabecera de una nota de pedido almacenada localmente.
@immutable
class LocalVentaCabeza {
  const LocalVentaCabeza({
    this.local,
    this.tipoDoc,
    this.numeroDoc,
    this.cajaDoc,
    this.fechaEmision,
    this.folioSii,
    this.vencimiento,
    this.rutCliente,
    this.direccionDestino,
    this.rutCajera,
    this.notaPedido,
    this.ordenDeCompra,
    this.subtotal,
    this.montoNeto,
    this.montoIva,
    this.plazo,
    this.impHarina,
    this.impCarne,
    this.impRefrescos,
    this.impLicores,
    this.impVinos,
    this.impLight,
    this.impCerveza,
    this.impDiesel,
    this.montoExento,
    this.montoTotal,
    this.montoLey20956,
    this.abono,
    this.montoDonacion,
    this.horaVenta,
    this.horaVendedor,
    this.rutVendedor,
    this.dctoGlobal,
    this.porceDescuento,
    this.formaPago,
    this.despachoPatente,
    this.despachoFecha,
    this.despachoFolio,
    this.despachoHora,
    this.glosaGuia,
    this.usuarioFacturacion,
    this.observacion,
    this.refTipo,
    this.refFecha,
    this.refNumero,
    this.refGlosa,
    this.nombreCliente,
    this.fonoCliente,
    this.emailCliente,
    this.revision1,
    this.revision2,
    this.revision3,
    this.generarDte,
    this.numeroImpresora,
    this.procesada,
    this.acteco,
    this.imprimePorGrupos,
    this.tipoTraslado,
    this.montoPropina,
    this.localTraslado,
    this.enviado = 0,
    this.intentos = 0,
  });

  final String? local;
  final String? tipoDoc;
  final String? numeroDoc;
  final String? cajaDoc;
  final String? fechaEmision;
  final String? folioSii;
  final String? vencimiento;
  final String? rutCliente;
  final String? direccionDestino;
  final String? rutCajera;
  final String? notaPedido;
  final String? ordenDeCompra;
  final double? subtotal;
  final double? montoNeto;
  final double? montoIva;
  final String? plazo;
  final double? impHarina;
  final double? impCarne;
  final double? impRefrescos;
  final double? impLicores;
  final double? impVinos;
  final double? impLight;
  final double? impCerveza;
  final double? impDiesel;
  final double? montoExento;
  final double? montoTotal;
  final double? montoLey20956;
  final double? abono;
  final double? montoDonacion;
  final String? horaVenta;
  final String? horaVendedor;
  final String? rutVendedor;
  final double? dctoGlobal;
  final double? porceDescuento;
  final String? formaPago;
  final String? despachoPatente;
  final String? despachoFecha;
  final String? despachoFolio;
  final String? despachoHora;
  final String? glosaGuia;
  final String? usuarioFacturacion;
  final String? observacion;
  final String? refTipo;
  final String? refFecha;
  final String? refNumero;
  final String? refGlosa;
  final String? nombreCliente;
  final String? fonoCliente;
  final String? emailCliente;
  final int? revision1;
  final int? revision2;
  final int? revision3;
  final int? generarDte;
  final int? numeroImpresora;
  final int? procesada;
  final String? acteco;
  final int? imprimePorGrupos;
  final String? tipoTraslado;
  final double? montoPropina;
  final String? localTraslado;
  final int? enviado;
  final int? intentos;

  Map<String, dynamic> toMap() => {
        'local': local,
        'tipo_doc': tipoDoc,
        'numero_doc': numeroDoc,
        'caja_doc': cajaDoc,
        'fecha_emision': fechaEmision,
        'foliosii': folioSii,
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
        'dctoglobal': dctoGlobal,
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
        'enviado': enviado,
        'intentos': intentos,
      };

  factory LocalVentaCabeza.fromMap(Map<String, dynamic> json) => LocalVentaCabeza(
        local: json['local'] as String?,
        tipoDoc: json['tipo_doc'] as String?,
        numeroDoc: json['numero_doc'] as String?,
        cajaDoc: json['caja_doc'] as String?,
        fechaEmision: json['fecha_emision'] as String?,
        folioSii: json['foliosii'] as String?,
        vencimiento: json['vencimiento'] as String?,
        rutCliente: json['rut_cliente'] as String?,
        direccionDestino: json['direccion_destino'] as String?,
        rutCajera: json['rut_cajera'] as String?,
        notaPedido: json['nota_pedido'] as String?,
        ordenDeCompra: json['orden_de_compra'] as String?,
        subtotal: (json['subtotal'] as num?)?.toDouble(),
        montoNeto: (json['monto_neto'] as num?)?.toDouble(),
        montoIva: (json['monto_iva'] as num?)?.toDouble(),
        plazo: json['plazo'] as String?,
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
        horaVenta: json['hora_venta'] as String?,
        horaVendedor: json['hora_vendedor'] as String?,
        rutVendedor: json['rut_vendedor'] as String?,
        dctoGlobal: (json['dctoglobal'] as num?)?.toDouble(),
        porceDescuento: (json['porce_descuento'] as num?)?.toDouble(),
        formaPago: json['formapago'] as String?,
        despachoPatente: json['despacho_patente'] as String?,
        despachoFecha: json['despacho_fecha'] as String?,
        despachoFolio: json['despacho_folio'] as String?,
        despachoHora: json['despacho_hora'] as String?,
        glosaGuia: json['glosa_guia'] as String?,
        usuarioFacturacion: json['usuario_facturacion'] as String?,
        observacion: json['observacion'] as String?,
        refTipo: json['ref_tipo'] as String?,
        refFecha: json['ref_fecha'] as String?,
        refNumero: json['ref_numero'] as String?,
        refGlosa: json['ref_glosa'] as String?,
        nombreCliente: json['nombre_cliente'] as String?,
        fonoCliente: json['fono_cliente'] as String?,
        emailCliente: json['email_cliente'] as String?,
        revision1: json['revision1'] as int?,
        revision2: json['revision2'] as int?,
        revision3: json['revision3'] as int?,
        generarDte: json['generar_dte'] as int?,
        numeroImpresora: json['numero_impresora'] as int?,
        procesada: json['procesada'] as int?,
        acteco: json['acteco'] as String?,
        imprimePorGrupos: json['imprime_por_grupos'] as int?,
        tipoTraslado: json['tipo_traslado'] as String?,
        montoPropina: (json['monto_propina'] as num?)?.toDouble(),
        localTraslado: json['local_traslado'] as String?,
        enviado: json['enviado'] as int? ?? 0,
        intentos: json['intentos'] as int? ?? 0,
      );
}
