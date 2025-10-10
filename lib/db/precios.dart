import 'package:aplicacion_ventas/db/utils.dart';

class MaePrecios {
  const MaePrecios({
    required this.precioVenta,
  });

  final double precioVenta;

  factory MaePrecios.fromMap(Map<String, Object?> map) {
    return MaePrecios(
      precioVenta: DbUtils.toDouble(map['precio_venta']),
    );
  }

  static const empty = MaePrecios(precioVenta: 0);
}
