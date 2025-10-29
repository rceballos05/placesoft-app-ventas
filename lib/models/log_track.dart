import 'package:flutter/foundation.dart';

/// Registro de operaciones locales pendiente de sincronización.
@immutable
class LogTrack {
  const LogTrack({
    this.id,
    this.operacion,
    this.payload,
    this.createdAt,
    this.nivel,
    this.enviado = 0,
    this.intentos = 0,
  });

  final int? id;
  final String? operacion;
  final String? payload;
  final String? createdAt;
  final String? nivel;
  final int? enviado;
  final int? intentos;

  Map<String, dynamic> toMap() => {
        'id': id,
        'operacion': operacion,
        'payload': payload,
        'created_at': createdAt,
        'nivel': nivel,
        'enviado': enviado,
        'intentos': intentos,
      };

  factory LogTrack.fromMap(Map<String, dynamic> json) => LogTrack(
        id: json['id'] as int?,
        operacion: json['operacion'] as String?,
        payload: json['payload'] as String?,
        createdAt: json['created_at'] as String?,
        nivel: json['nivel'] as String?,
        enviado: json['enviado'] as int? ?? 0,
        intentos: json['intentos'] as int? ?? 0,
      );
}
