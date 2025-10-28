import 'package:aplicacion_ventas/domain/entities/user.dart';

/// Concrete data representation of [User] coming from remote API responses.
class UserModel extends User {
  const UserModel(
      {required super.rut,
      required super.prefijo,
      required super.caja,
      required super.maxDcto,
      required super.nombre});

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
        rut: json['rut'] as String,
        prefijo: json['prefijo'] as String,
        caja: json['caja_doc'] as String,
        maxDcto: json['descuento'] as double,
        nombre: json['nombre'] as String);
  }
}
