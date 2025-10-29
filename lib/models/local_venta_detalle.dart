import 'package:flutter/foundation.dart';

/// Detalle de una venta local almacenada en SQLite.
@immutable
class LocalVentaDetalle {
  const LocalVentaDetalle({
    this.local,
    this.tipoDoc,
    this.numeroDoc,
    this.cajaDoc,
    this.lineaVenta,
    this.fechaEmision,
    this.rutCliente,
    this.destinoCliente,
    this.artCodigo,
    this.artDescripcion,
    this.artCantidad,
    this.artPrecio,
    this.artDescuento,
    this.porceDescuento,
    this.totalLinea,
    this.rutVendedor,
    this.precioCostoCiva,
    this.almacen,
    this.impuesto,
    this.porceImpuesto,
    this.montoImpuesto,
    this.descuento,
    this.horaVenta,
    this.usuarioFacturacion,
    this.folioSii,
    this.fechaViaje,
    this.refTipo,
    this.refNumero,
    this.refFecha,
    this.enviado = 0,
    this.intentos = 0,
  });

  final String? local;
  final String? tipoDoc;
  final String? numeroDoc;
  final String? cajaDoc;
  final String? lineaVenta;
  final String? fechaEmision;
  final String? rutCliente;
  final String? destinoCliente;
  final String? artCodigo;
  final String? artDescripcion;
  final double? artCantidad;
  final double? artPrecio;
  final double? artDescuento;
  final double? porceDescuento;
  final double? totalLinea;
  final String? rutVendedor;
  final double? precioCostoCiva;
  final String? almacen;
  final String? impuesto;
  final double? porceImpuesto;
  final double? montoImpuesto;
  final double? descuento;
  final String? horaVenta;
  final String? usuarioFacturacion;
  final String? folioSii;
  final String? fechaViaje;
  final String? refTipo;
  final String? refNumero;
  final String? refFecha;
  final int? enviado;
  final int? intentos;

  Map<String, dynamic> toMap() => {
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
        'horaventa': horaVenta,
        'usuario_facturacion': usuarioFacturacion,
        'foliosii': folioSii,
        'fechaviaje': fechaViaje,
        'ref_tipo': refTipo,
        'ref_numero': refNumero,
        'ref_fecha': refFecha,
        'enviado': enviado,
        'intentos': intentos,
      };

  factory LocalVentaDetalle.fromMap(Map<String, dynamic> json) => LocalVentaDetalle(
        local: json['local'] as String?,
        tipoDoc: json['tipo_doc'] as String?,
        numeroDoc: json['numero_doc'] as String?,
        cajaDoc: json['caja_doc'] as String?,
        lineaVenta: json['linea_venta'] as String?,
        fechaEmision: json['fecha_emision'] as String?,
        rutCliente: json['rut_cliente'] as String?,
        destinoCliente: json['destino_cliente'] as String?,
        artCodigo: json['art_codigo'] as String?,
        artDescripcion: json['art_descripcion'] as String?,
        artCantidad: (json['art_cantidad'] as num?)?.toDouble(),
        artPrecio: (json['art_precio'] as num?)?.toDouble(),
        artDescuento: (json['art_descuento'] as num?)?.toDouble(),
        porceDescuento: (json['porce_descuento'] as num?)?.toDouble(),
        totalLinea: (json['total_linea'] as num?)?.toDouble(),
        rutVendedor: json['rut_vendedor'] as String?,
        precioCostoCiva: (json['precio_costo_civa'] as num?)?.toDouble(),
        almacen: json['almacen'] as String?,
        impuesto: json['impuesto'] as String?,
        porceImpuesto: (json['porce_impuesto'] as num?)?.toDouble(),
        montoImpuesto: (json['monto_impuesto'] as num?)?.toDouble(),
        descuento: (json['descuento'] as num?)?.toDouble(),
        horaVenta: json['horaventa'] as String?,
        usuarioFacturacion: json['usuario_facturacion'] as String?,
        folioSii: json['foliosii'] as String?,
        fechaViaje: json['fechaviaje'] as String?,
        refTipo: json['ref_tipo'] as String?,
        refNumero: json['ref_numero'] as String?,
        refFecha: json['ref_fecha'] as String?,
        enviado: json['enviado'] as int? ?? 0,
        intentos: json['intentos'] as int? ?? 0,
      );
}
