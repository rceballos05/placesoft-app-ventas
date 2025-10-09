import 'dart:convert';

import 'package:aplicacion_ventas/core/errors/failure.dart';
import 'package:aplicacion_ventas/core/utils/result.dart';
import 'package:aplicacion_ventas/data/models/product_model.dart';
import 'package:aplicacion_ventas/domain/entities/product.dart';
import 'package:aplicacion_ventas/domain/repositories/product_repository.dart';
import 'package:http/http.dart' as http;

/// Repository responsible for retrieving products from the API.
class ProductRepositoryImpl implements ProductRepository {
  ProductRepositoryImpl({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;
  final String _baseUrl = '192.168.1.3:7177';

  @override
  Future<Result<List<Product>>> fetchProducts() async {
    try {
      final params = <String, String>{'page': '1', 'itemsperpage': '20'};
      final response = await _client.get(Uri.http(_baseUrl, '/api/Inventario00/productos', params));
      final decoded = jsonDecode(response.body) as Map<String, dynamic>;
      if (decoded['code'] != 200) {
        return FailureResult(Failure(decoded['message']?.toString() ?? 'Error al cargar productos'));
      }
      final items = (decoded['items'] as List<dynamic>)
          .map((dynamic json) => ProductModel.fromJson(json as Map<String, dynamic>))
          .toList();
      return Success<List<Product>>(items);
    } catch (error) {
      return FailureResult(Failure('No fue posible cargar los productos', cause: error));
    }
  }
}
