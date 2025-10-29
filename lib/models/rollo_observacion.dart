import 'package:flutter/foundation.dart';

/// Represents extra notes associated to a rollo line stored locally.
@immutable
class RolloObservacion {
  const RolloObservacion({
    this.codigo,
    this.fecha,
    this.caja,
    this.observaciones,
    this.enviado = 0,
    this.intentos = 0,
  });

  final String? codigo;
  final String? fecha;
  final String? caja;
  final String? observaciones;
  final int? enviado;
  final int? intentos;

  RolloObservacion copyWith({
    String? codigo,
    String? fecha,
    String? caja,
    String? observaciones,
    int? enviado,
    int? intentos,
  }) {
    return RolloObservacion(
      codigo: codigo ?? this.codigo,
      fecha: fecha ?? this.fecha,
      caja: caja ?? this.caja,
      observaciones: observaciones ?? this.observaciones,
      enviado: enviado ?? this.enviado,
      intentos: intentos ?? this.intentos,
    );
  }

  Map<String, dynamic> toMap() => {
        'codigo': codigo,
        'fecha': fecha,
        'caja': caja,
        'observaciones': observaciones,
        'enviado': enviado,
        'intentos': intentos,
      };

  factory RolloObservacion.fromMap(Map<String, dynamic> json) => RolloObservacion(
        codigo: json['codigo'] as String?,
        fecha: json['fecha'] as String?,
        caja: json['caja'] as String?,
        observaciones: json['observaciones'] as String?,
        enviado: json['enviado'] as int? ?? 0,
        intentos: json['intentos'] as int? ?? 0,
      );
}
