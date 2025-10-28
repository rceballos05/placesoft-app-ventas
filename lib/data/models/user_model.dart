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
    String _readString(List<String> keys, {String defaultValue = ''}) {
      for (final key in keys) {
        final value = json[key];
        if (value == null) {
          continue;
        }
        if (value is String) {
          final trimmed = value.trim();
          if (trimmed.isNotEmpty) {
            return trimmed;
          }
        } else if (value is num || value is bool) {
          return value.toString();
        }
      }
      return defaultValue;
    }

    double _readDouble(List<String> keys, {double defaultValue = 0}) {
      for (final key in keys) {
        final value = json[key];
        if (value is num) {
          return value.toDouble();
        }
        if (value is String) {
          final parsed = double.tryParse(value);
          if (parsed != null) {
            return parsed;
          }
        }
      }
      return defaultValue;
    }

    return UserModel(
      rut: _readString(<String>['rut']),
      prefijo: _readString(<String>['prefijo']),
      caja: _readString(<String>['caja', 'caja_doc']),
      maxDcto: _readDouble(<String>['maxDctoProducto', 'max_dcto', 'descuento']),
      nombre: _readString(<String>['nombre', 'nombreUsuario']),
    );
  }
}
