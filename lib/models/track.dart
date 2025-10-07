import 'package:aplicacion_ventas/statics/globals.dart';

class TrackDto {
  String server;
  String queryStr;
  String basedatos;
  String fechaCreacion;
  String horaCreacion;
  String prioridad;
  String caja;

  TrackDto({
    required this.server,
    required this.queryStr,
    required this.basedatos,
    required this.fechaCreacion,
    required this.horaCreacion,
    required this.prioridad,
    required this.caja,
  });

  // Factory constructor para crear una instancia de TrackDto desde un JSON
  factory TrackDto.fromJson(Map<String, dynamic> json) {
    return TrackDto(
      server: json['server'],
      queryStr: json['queryStr'],
      basedatos: json['basedatos'],
      fechaCreacion: json['fechaCreacion'],
      horaCreacion: json['horaCreacion'],
      prioridad: json['prioridad'],
      caja: json['caja'],
    );
  }

  // Método para convertir una instancia de TrackDto a JSON
  Map<String, dynamic> toJson() {
    return {
      'server': server,
      'queryStr': queryStr,
      'basedatos': basedatos,
      'fechaCreacion': fechaCreacion,
      'horaCreacion': horaCreacion,
      'prioridad': prioridad,
      'caja': caja,
    };
  }
}
