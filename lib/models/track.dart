import 'dart:convert';

import 'package:flutter/foundation.dart';

/// Representa una consulta pendiente de sincronización con el ERP.
@immutable
class TrackDto {
  const TrackDto({
    required this.server,
    required this.basedatos,
    required this.fechaCreacion,
    required this.horaCreacion,
    required this.prioridad,
    required this.queryStr,
    required this.caja,
  });

  final String server;
  final String basedatos;
  final String fechaCreacion;
  final String horaCreacion;
  final String prioridad;
  final String queryStr;
  final String caja;

  Map<String, dynamic> toMap() => {
        'server': server,
        'basedatos': basedatos,
        'fechaCreacion': fechaCreacion,
        'horaCreacion': horaCreacion,
        'prioridad': prioridad,
        'queryStr': queryStr,
        'caja': caja,
      };

  String toJson() => jsonEncode(toMap());
}
