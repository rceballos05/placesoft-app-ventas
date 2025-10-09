import 'dart:convert';

import 'package:aplicacion_ventas/core/utils/failure.dart';
import 'package:aplicacion_ventas/data/models/product_model.dart';
import 'package:http/http.dart' as http;

/// Fetches catalogue information from the remote API.
class ProductRemoteDataSource {
  ProductRemoteDataSource({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;
  final String _baseUrl = '192.168.1.3:7177';

  /// Downloads the product listing using pagination parameters.
  Future<List<ProductModel>> fetchProducts({int page = 1, int itemsPerPage = 20}) async {
    try {
      final params = <String, String>{
        'page': page.toString(),
        'itemsperpage': itemsPerPage.toString(),
      };
      final response = await _client.get(Uri.http(_baseUrl, '/api/Inventario00/productos', params));
      final decoded = jsonDecode(response.body) as Map<String, dynamic>;
      if (decoded['code'] != 200) {
        throw Failure(decoded['message']?.toString() ?? 'Error al cargar productos');
      }
      final items = decoded['items'];
      if (items is! List) {
        throw Failure('Formato de productos inválido');
      }
      return items
          .map((dynamic json) => ProductModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on Failure {
      rethrow;
    } catch (error) {
      throw Failure('No fue posible cargar los productos', cause: error);
    }
  }
}
