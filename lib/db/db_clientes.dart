import 'package:aplicacion_ventas/db/clientes_db.dart';
import 'package:aplicacion_ventas/models/mae_cliente.dart';

class DBClientes {
  const DBClientes._();

  static Future<int> insert(MaeCliente cliente) {
    return DBMaeClientes.insert(cliente);
  }
}
