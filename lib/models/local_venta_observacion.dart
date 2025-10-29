import 'package:flutter/foundation.dart';

/// Observaciones asociadas a las líneas de ventas locales.
@immutable
class LocalVentaObservacion {
  const LocalVentaObservacion({
    this.local,
    this.tipoDoc,
    this.numeroDoc,
    this.fechaEmision,
    this.rutCliente,
    this.cajaDoc,
    this.lineaVenta,
    this.codigo,
    this.observaciones,
    this.enviado = 0,
    this.intentos = 0,
  });

  final String? local;
  final String? tipoDoc;
  final String? numeroDoc;
  final String? fechaEmision;
  final String? rutCliente;
  final String? cajaDoc;
  final String? lineaVenta;
  final String? codigo;
  final String? observaciones;
  final int? enviado;
  final int? intentos;

  Map<String, dynamic> toMap() => {
        'local': local,
        'tipo_doc': tipoDoc,
        'numero_doc': numeroDoc,
        'fecha_emision': fechaEmision,
        'rut_cliente': rutCliente,
        'caja_doc': cajaDoc,
        'linea_venta': lineaVenta,
        'codigo': codigo,
        'observaciones': observaciones,
        'enviado': enviado,
        'intentos': intentos,
      };

  factory LocalVentaObservacion.fromMap(Map<String, dynamic> json) => LocalVentaObservacion(
        local: json['local'] as String?,
        tipoDoc: json['tipo_doc'] as String?,
        numeroDoc: json['numero_doc'] as String?,
        fechaEmision: json['fecha_emision'] as String?,
        rutCliente: json['rut_cliente'] as String?,
        cajaDoc: json['caja_doc'] as String?,
        lineaVenta: json['linea_venta'] as String?,
        codigo: json['codigo'] as String?,
        observaciones: json['observaciones'] as String?,
        enviado: json['enviado'] as int? ?? 0,
        intentos: json['intentos'] as int? ?? 0,
      );
}
