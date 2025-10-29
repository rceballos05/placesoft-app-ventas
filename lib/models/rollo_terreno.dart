import 'package:flutter/foundation.dart';

/// Data model that represents a line added to the local rollo table.
@immutable
class RolloTerreno {
  const RolloTerreno({
    this.local,
    this.cajaDoc,
    this.lineaVenta,
    this.rutCajero,
    this.artCantidad,
    this.artCodigo,
    this.artDescripcion,
    this.artDescuento,
    this.artPrecio,
    this.totalLinea,
    this.rutVendedor,
    this.fechaTransaccion,
    this.horaTransaccion,
    this.tipoVenta,
    this.codImpuesto,
    this.porceImpuesto,
    this.enviado = 0,
    this.intentos = 0,
  });

  final String? local;
  final String? cajaDoc;
  final double? lineaVenta;
  final String? rutCajero;
  final double? artCantidad;
  final String? artCodigo;
  final String? artDescripcion;
  final double? artDescuento;
  final double? artPrecio;
  final double? totalLinea;
  final String? rutVendedor;
  final String? fechaTransaccion;
  final String? horaTransaccion;
  final String? tipoVenta;
  final String? codImpuesto;
  final double? porceImpuesto;
  final int? enviado;
  final int? intentos;

  RolloTerreno copyWith({
    String? local,
    String? cajaDoc,
    double? lineaVenta,
    String? rutCajero,
    double? artCantidad,
    String? artCodigo,
    String? artDescripcion,
    double? artDescuento,
    double? artPrecio,
    double? totalLinea,
    String? rutVendedor,
    String? fechaTransaccion,
    String? horaTransaccion,
    String? tipoVenta,
    String? codImpuesto,
    double? porceImpuesto,
    int? enviado,
    int? intentos,
  }) {
    return RolloTerreno(
      local: local ?? this.local,
      cajaDoc: cajaDoc ?? this.cajaDoc,
      lineaVenta: lineaVenta ?? this.lineaVenta,
      rutCajero: rutCajero ?? this.rutCajero,
      artCantidad: artCantidad ?? this.artCantidad,
      artCodigo: artCodigo ?? this.artCodigo,
      artDescripcion: artDescripcion ?? this.artDescripcion,
      artDescuento: artDescuento ?? this.artDescuento,
      artPrecio: artPrecio ?? this.artPrecio,
      totalLinea: totalLinea ?? this.totalLinea,
      rutVendedor: rutVendedor ?? this.rutVendedor,
      fechaTransaccion: fechaTransaccion ?? this.fechaTransaccion,
      horaTransaccion: horaTransaccion ?? this.horaTransaccion,
      tipoVenta: tipoVenta ?? this.tipoVenta,
      codImpuesto: codImpuesto ?? this.codImpuesto,
      porceImpuesto: porceImpuesto ?? this.porceImpuesto,
      enviado: enviado ?? this.enviado,
      intentos: intentos ?? this.intentos,
    );
  }

  Map<String, dynamic> toMap() => {
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
        'enviado': enviado,
        'intentos': intentos,
      };

  factory RolloTerreno.fromMap(Map<String, dynamic> json) => RolloTerreno(
        local: json['local'] as String?,
        cajaDoc: json['caja_doc'] as String?,
        lineaVenta: (json['linea_venta'] as num?)?.toDouble(),
        rutCajero: json['rut_cajero'] as String?,
        artCantidad: (json['art_cantidad'] as num?)?.toDouble(),
        artCodigo: json['art_codigo'] as String?,
        artDescripcion: json['art_descripcion'] as String?,
        artDescuento: (json['art_descuento'] as num?)?.toDouble(),
        artPrecio: (json['art_precio'] as num?)?.toDouble(),
        totalLinea: (json['total_linea'] as num?)?.toDouble(),
        rutVendedor: json['rut_vendedor'] as String?,
        fechaTransaccion: json['fecha_transaccion'] as String?,
        horaTransaccion: json['hora_transaccion'] as String?,
        tipoVenta: json['tipoventa'] as String?,
        codImpuesto: json['cod_impuesto'] as String?,
        porceImpuesto: (json['porce_impuesto'] as num?)?.toDouble(),
        enviado: json['enviado'] as int? ?? 0,
        intentos: json['intentos'] as int? ?? 0,
      );
}
