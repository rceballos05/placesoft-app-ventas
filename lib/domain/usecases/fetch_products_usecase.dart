import 'package:aplicacion_ventas/core/utils/result.dart';
import 'package:aplicacion_ventas/domain/entities/product.dart';
import 'package:aplicacion_ventas/domain/repositories/product_repository.dart';

/// Retrieves the available product catalogue.
class FetchProductsUseCase {
  const FetchProductsUseCase(this._repository);

  final ProductRepository _repository;

  /// Executes the product fetching workflow.
  Future<Result<List<Product>>> call() => _repository.fetchProducts();
}
