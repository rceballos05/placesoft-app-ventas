import 'package:aplicacion_ventas/domain/entities/product.dart';

/// Concrete data representation of [Product].
class ProductModel extends Product {
  const ProductModel({
    required super.code,
    required super.description,
    required super.price,
    required super.discount,
    required super.imageUrl,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    double toDouble(dynamic value) {
      if (value is num) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? 0;
      return 0;
    }

    final priceValue = toDouble(json['precioFinal'] ?? json['precio'] ?? 0);
    final discountValue = toDouble(json['descuento'] ?? 0);
    final codeValue = json['codigobarra']?.toString() ?? '';
    final descriptionValue = json['descripcion']?.toString() ?? '';
    return ProductModel(
      code: codeValue,
      description: descriptionValue,
      price: priceValue,
      discount: discountValue,
      imageUrl: json['imageUrl']?.toString() ?? 'https://picsum.photos/seed/$codeValue/400/400',
    );
  }
}
