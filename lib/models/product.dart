import 'package:flutter/foundation.dart';

/// Model representing a product inside the catalogue.
@immutable
class Product {
  const Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
  });

  /// Unique identifier of the product.
  final String id;

  /// Display name of the product.
  final String name;

  /// Short description to show in the detail page.
  final String description;

  /// Current price expressed in local currency.
  final double price;

  /// URL pointing to a product image.
  final String imageUrl;

  /// Creates a copy of this product with optional property overrides.
  Product copyWith({
    String? id,
    String? name,
    String? description,
    double? price,
    String? imageUrl,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }
}
