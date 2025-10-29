import 'package:aplicacion_ventas/db/clientes_db.dart';
import 'package:aplicacion_ventas/models/mae_cliente_destino.dart';

class DBDestinos {
  const DBDestinos._();

  static Future<int> insert(MaeClienteDestino destino) {
    return DBMaeClientesDestinos.insert(destino);
  }
}
