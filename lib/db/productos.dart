import 'package:aplicacion_ventas/db/utils.dart';

class MaeArticulos {
  const MaeArticulos({
    this.codigobarra,
    this.descripcion,
    this.descuento,
  });

  final String? codigobarra;
  final String? descripcion;
  final double? descuento;

  factory MaeArticulos.fromMap(Map<String, Object?> map) {
    return MaeArticulos(
      codigobarra: map['codigobarra']?.toString(),
      descripcion: map['descripcion']?.toString(),
      descuento: DbUtils.toDouble(map['descuento']),
    );
  }
}
