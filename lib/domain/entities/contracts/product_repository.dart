import 'package:aplicacion_ventas/core/utils/result.dart';
import 'package:aplicacion_ventas/domain/entities/product.dart';

/// Contract for fetching catalogue products.
abstract class ProductRepository {
  /// Retrieves the available products from remote or local sources.
  Future<Result<List<Product>>> fetchProducts();
}
