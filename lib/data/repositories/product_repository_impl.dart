import 'package:aplicacion_ventas/core/utils/failure.dart';
import 'package:aplicacion_ventas/core/utils/result.dart';
import 'package:aplicacion_ventas/data/datasources/remote/product_remote_datasource.dart';
import 'package:aplicacion_ventas/data/models/product_model.dart';
import 'package:aplicacion_ventas/domain/entities/product.dart';
import 'package:aplicacion_ventas/domain/entities/contracts/product_repository.dart';

/// Repository responsible for retrieving products from the API.
class ProductRepositoryImpl implements ProductRepository {
  ProductRepositoryImpl({ProductRemoteDataSource? remoteDataSource})
      : _remoteDataSource = remoteDataSource ?? ProductRemoteDataSource();

  final ProductRemoteDataSource _remoteDataSource;

  @override
  Future<Result<List<Product>>> fetchProducts() async {
    try {
      final List<ProductModel> items = await _remoteDataSource.fetchProducts();
      return Success<List<Product>>(items);
    } on Failure catch (failure) {
      return FailureResult(failure);
    } catch (error) {
      return FailureResult(Failure('No fue posible cargar los productos', cause: error));
    }
  }
}
