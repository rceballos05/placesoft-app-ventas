// class LogVendedoresApp {
//   String? rut;
//   String? mensajeLog;
//   String? latitud;
//   String? longitud;
//   DateTime? fecha;
//   LogVendedoresApp(
//       {this.fecha, this.latitud, this.longitud, this.mensajeLog, this.rut});

//   Map<String, dynamic> toJson() {
//     return {
//       'id': ,
//       'nombre': nombre,
//       'email': email,
//     };
// }

class LogVendedoresApp {
  final String rut;
  final String mensajeLog;
  final String latitud;
  final String longitud;
  final String fecha;

  LogVendedoresApp(
      {required this.rut,
      required this.mensajeLog,
      required this.fecha,
      required this.latitud,
      required this.longitud});

  Map<String, dynamic> toJson() {
    return {
      'rut': rut,
      'mensajelog': mensajeLog,
      'latitud': latitud,
      'longitud': longitud,
      'fecha': fecha,
    };
  }
}
