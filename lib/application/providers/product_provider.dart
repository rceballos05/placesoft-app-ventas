import 'package:aplicacion_ventas/core/utils/result.dart';
import 'package:aplicacion_ventas/data/datasources/remote/product_remote_datasource.dart';
import 'package:aplicacion_ventas/data/repositories/product_repository_impl.dart';
import 'package:aplicacion_ventas/domain/entities/product.dart';
import 'package:aplicacion_ventas/domain/usecases/fetch_products_usecase.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Holds the catalogue state information.
class ProductState {
  const ProductState({
    this.products = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  final List<Product> products;
  final bool isLoading;
  final String? errorMessage;

  ProductState copyWith({
    List<Product>? products,
    bool? isLoading,
    String? errorMessage,
    bool resetError = false,
  }) {
    return ProductState(
      products: products ?? this.products,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: resetError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

/// Notifier that manages the catalogue retrieval.
class ProductController extends StateNotifier<ProductState> {
  ProductController(this._fetchProductsUseCase) : super(const ProductState());

  final FetchProductsUseCase _fetchProductsUseCase;

  Future<void> loadProducts() async {
    state = state.copyWith(isLoading: true, resetError: true);
    final result = await _fetchProductsUseCase();
    state = result.fold(
      failure: (error) => state.copyWith(isLoading: false, errorMessage: error.message),
      success: (products) => ProductState(products: products, isLoading: false),
    );
  }
}

final productRemoteDataSourceProvider = Provider((ref) => ProductRemoteDataSource());
final productRepositoryProvider = Provider(
  (ref) => ProductRepositoryImpl(remoteDataSource: ref.watch(productRemoteDataSourceProvider)),
);
final fetchProductsUseCaseProvider =
    Provider((ref) => FetchProductsUseCase(ref.watch(productRepositoryProvider)));
final productControllerProvider = StateNotifierProvider<ProductController, ProductState>(
  (ref) => ProductController(ref.watch(fetchProductsUseCaseProvider))..loadProducts(),
);
