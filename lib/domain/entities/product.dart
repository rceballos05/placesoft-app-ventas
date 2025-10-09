/// Domain entity that describes a product available in the catalogue.
class Product {
  const Product({
    required this.code,
    required this.description,
    required this.price,
    required this.discount,
    required this.imageUrl,
  });

  final String code;
  final String description;
  final double price;
  final double discount;
  final String imageUrl;
}
